import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'models/channel_strip_model.dart';

class ChannelAudioController {
  final AudioPlayer player;
  ChannelStripModel? model;
  final bool enableLogs;
  
  // Таймер для fade-in
  Timer? _fadeInTimer;
  
  // Подписки на стримы
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  
  // Контроллеры для трансляции состояний
  final _positionController = StreamController<Duration>.broadcast();
  final _playingStateController = StreamController<bool>.broadcast();
  
  // Публичные стримы
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<bool> get playingStream => _playingStateController.stream;
 
  ChannelAudioController({
    this.model,
    this.enableLogs = true,
  }) : player = AudioPlayer() {
    _initStreams();
  }

  void _initStreams() {
    // Подписка на позицию
    _positionSub = player.positionStream.listen((position) {
      _positionController.add(position); 
      
      // Проверка конечной метки
      final stop = model?.stopTime;
      final start = model?.startTime ?? Duration.zero;
      if (stop != null && stop > Duration.zero && position >= stop) {
        _cancelFadeIn(); // Отменяем fade-in при достижении конечной метки
        player.pause();
        player.seek(start);
      }
    });

    // Подписка на состояние плеера
    _playerStateSub = player.playerStateStream.listen((state) {
      _playingStateController.add(state.playing);
      if (state.processingState == ProcessingState.completed) {
        _cancelFadeIn(); // Отменяем fade-in при завершении воспроизведения
        player.seek(model?.startTime ?? Duration.zero);
        player.pause();
      }
      
      // Если воспроизведение остановлено, отменяем fade-in
      if (!state.playing) {
        _cancelFadeIn();
      }
    });
  }

  // Геттеры текущего состояния
  bool get isPlaying => player.playing;
  Duration get position => player.position;

  void updatePosition(Duration position) {
    _positionController.add(position);
  }

  void _log(String message) {
    if (enableLogs) {
      debugPrint('[${model?.name ?? "Unknown"}] $message');
    }
  }

  Future<void> loadFile([String? filePath]) async {
    final path = filePath ?? model?.filePath ?? '';
    if (path.isEmpty) {
      _log('No file path provided');
      return;
    }

    try {
      await player.setFilePath(path);
      _log('File loaded successfully');
    } catch (e) {
      _log('Error loading file: $e');
    }
  }

  void setVolume(double value) {
    player.setVolume(value);
  }

// Метод для отмены fade-in
  void _cancelFadeIn() {
    if (_fadeInTimer != null && _fadeInTimer!.isActive) {
      _fadeInTimer!.cancel();
      _fadeInTimer = null;
      _log('Fade-in cancelled');
    }
  }
  // Новый метод для начала воспроизведения с fade-in
    // В методе playWithFadeIn удалите проверку player.playing после play
  Future<void> playWithFadeIn() async {
    final fadeInSeconds = model?.fadeInSeconds ?? 0;
    final targetVolume = model?.volume ?? 1.0;
    final start = model?.startTime ?? Duration.zero;
    
    _cancelFadeIn();
    
    if (fadeInSeconds <= 0) {
      // Обычное воспроизведение без fade-in
      player.setVolume(targetVolume);
      await player.seek(start);
      await player.play();
      _log('Playing at normal volume: $targetVolume');
      return;
    }
    
    _log('Starting fade-in: $fadeInSeconds seconds');
    
    // Устанавливаем начальную громкость 0
    player.setVolume(0);
    
    // Позиционируем и начинаем воспроизведение
    await player.seek(start);
    
    // Начинаем воспроизведение
    player.play();
    
    // Не проверяем player.playing, сразу запускаем fade-in
    // Рассчитываем параметры fade-in
    const updateRate = 50;
    final steps = (fadeInSeconds * 1000 / updateRate).round();
    final volumeStep = targetVolume / steps;
    
    int currentStep = 0;
    
    _fadeInTimer = Timer.periodic(Duration(milliseconds: updateRate), (timer) {
      if (!player.playing) {
        timer.cancel();
        _fadeInTimer = null;
        _log('Playback stopped, fade-in cancelled');
        return;
      }
      
      currentStep++;
      if (currentStep >= steps) {
        player.setVolume(targetVolume);
        _log('Fade-in completed: volume = $targetVolume');
        timer.cancel();
        _fadeInTimer = null;
      } else {
        final newVolume = volumeStep * currentStep;
        player.setVolume(newVolume);
        if (currentStep % 5 == 0) {
          _log('Fade-in step: $currentStep/$steps, volume = $newVolume');
        }
      }
    });
  }

  Future<void> toggle() async {
    if (model?.filePath.isEmpty ?? true) {
      _log('No file path set, cannot toggle playback');
      return;
    }

    // Load source if not loaded
    if (player.audioSource == null) {
      await loadFile();
    }

    // Check player state
    if (player.processingState == ProcessingState.idle ||
        player.processingState == ProcessingState.ready) {
      _log('Player is ready, toggling playback');
    } else {
      _log('Player is not ready, cannot toggle playback');
      return;
    }
    final start = model?.startTime ?? Duration.zero;

    switch (model?.playMode) {
      case PlayMode.playStop:
        if (player.playing) {
          _log('Stopping playback');
          _cancelFadeIn(); // Важно: отменяем fade-in перед остановкой
          await player.stop();
          await player.seek(start);
          player.setVolume(model?.volume ?? 1.0); // Сбрасываем громкость к начальной
        } else {
          _log('Starting playback with possible fade-in');
          await playWithFadeIn(); // Используем новый метод вместо прямого play
        }
        break;

      case PlayMode.playPause:
        if (player.playing) {
          _log('Pausing playback');
          _cancelFadeIn();
          await player.pause();
        } else {
          _log('Resuming playback');
          // При возобновлении НЕ используем fade-in!
          player.setVolume(model?.volume ?? 1.0);
          await player.play();
        }         
        break;

      case PlayMode.retrigger:
        _log('Retriggering playback with possible fade-in');
        _cancelFadeIn(); // Отменяем текущий fade-in, если был
        await playWithFadeIn(); // Используем новый метод
        break;

      case null:
        _log('No play mode set');
        break;
    }
  }
  
  @override
  void dispose() {
    _cancelFadeIn();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _positionController.close();
    _playingStateController.close();
    player.dispose();
  }
}