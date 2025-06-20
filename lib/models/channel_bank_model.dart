import 'package:flutter/material.dart';
import 'channel_strip_model.dart';

class ChannelBankModel extends ChangeNotifier {
  final List<ChannelStripModel> _channels;
  double _masterVolume = 1.0;

  ChannelBankModel(this._channels);
// Геттеры
  List<ChannelStripModel> get channels => _channels;
  double get masterVolume => _masterVolume;
  ChannelStripModel getChannel(int index) => _channels[index];

  // Сеттеры с уведомлением слушателей
  void updateChannel(int index, ChannelStripModel updated) {
    _channels[index] = updated;
    notifyListeners();
  }  

  void updateVolume(int index, double value) {
    if (index >= 0 && index < _channels.length) {
      _channels[index].volume = value;
      // Применяем мастер громкость
      _channels[index].controller.setVolume(value * _masterVolume);
      notifyListeners();
    }
  }

  void setMasterVolume(double value) {
    _masterVolume = value;
    // Обновляем громкость для всех контроллеров
    for (final channel in _channels) {
      channel.controller.setVolume(channel.volume * _masterVolume);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up audio resources
    for (final channel in _channels) {
      channel.controller.player.dispose();
    }
    super.dispose();
  }
}
