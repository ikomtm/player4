import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'models/channel_strip_model.dart';

class ChannelAudioController {
  final AudioPlayer player;
  final ChannelStripModel model;
  final bool enableLogs = true;
  
  void _log(String message) {
    if (enableLogs) {
      debugPrint('[${model.name}] $message');
    }
  }



  ChannelAudioController(this.model) : player = AudioPlayer() {
    player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {        
        await player.seek(Duration.zero);
        await player.pause();
      }
    });
  }

  Future<void> loadSource() async {
    final endTime =
        (model.stopTime > Duration.zero && model.stopTime > model.startTime)
            ? model.stopTime
            : null;

    

    await player.setAudioSource(
      ClippingAudioSource(
        start: model.startTime,
        end: endTime,
        child: AudioSource.file(model.filePath),
      ),
      initialPosition: Duration.zero,
    );
  }

  Future<void> toggle() async {
    if (model.filePath.isEmpty) {
      _log('No file path set, cannot toggle playback');
      return;
    }

    // Если источник не загружен - загружаем
    if (player.audioSource == null) {
      await loadSource();
    }

    // Проверяем состояние плеера
    if (player.processingState == ProcessingState.idle ||
        player.processingState == ProcessingState.ready) {
      _log('Player is ready, toggling playback');
    } else {
      _log('Player is not ready, cannot toggle playback');
      return;
    }

  switch (model.playMode) {

    case PlayMode.playStop:
      if (player.playing) {
        // Если играет - останавливаем
        _log('Stopping playback');
        await player.stop();
      } else {
        // Если на паузе или не играет - начинаем с начала
        _log('Starting playback from the beginning');
        await player.seek(Duration.zero);
        await player.play();
      }
      

      case PlayMode.playPause:
        if (player.playing) {
          // Если играет - ставим на паузу
          _log('Pausing playback');
          await player.pause();
        } else {
          // Если на паузе - продолжаем
          _log('Resuming playback');
          await player.play();
        }         
        break;

      case PlayMode.retrigger:
      break;
    }
  }
  }

 

 

  

  

