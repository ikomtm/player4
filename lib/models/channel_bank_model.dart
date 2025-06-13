import 'package:flutter/material.dart';
import 'channel_strip_model.dart';

class ChannelBankModel extends ChangeNotifier {
  final List<ChannelStripModel> _channels;

  ChannelBankModel(this._channels);

  List<ChannelStripModel> get channels => _channels;

  ChannelStripModel getChannel(int index) => _channels[index];

  void updateChannel(int index, ChannelStripModel updated) {
    _channels[index] = updated;
    notifyListeners();
  }
}
