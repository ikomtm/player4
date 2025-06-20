import 'package:flutter/material.dart';
import 'package:player3/ChannelAudioController.dart';


enum PlayMode {
  playStop,
  playPause,
  retrigger,
}

class ChannelStripModel {
  String name;
  Color color;
  String filePath;
  double volume;
  Duration startTime;
  Duration stopTime;
  PlayMode playMode;
  double fadeInSeconds;
  double fadeOutSeconds;
  late final ChannelAudioController controller;

  ChannelStripModel({
  required this.name,
  required this.color,
  required this.filePath,
  required this.volume,
  required this.startTime,
  required this.stopTime,
  required this.playMode,
  this.fadeInSeconds = 0,
  this.fadeOutSeconds = 0,
}) : controller = ChannelAudioController() {
  controller.model = this; // 
  if (filePath.isNotEmpty) {
    controller.loadFile(filePath);
  }
  controller.setVolume(volume);
}
  

  // Using factory constructor for copy
  factory ChannelStripModel.copy(ChannelStripModel source) {
    return ChannelStripModel(
      name: source.name,
      color: source.color,
      filePath: source.filePath,
      volume: source.volume,
      startTime: source.startTime,
      stopTime: source.stopTime,
      playMode: source.playMode,
      fadeInSeconds: source.fadeInSeconds,
      fadeOutSeconds: source.fadeOutSeconds,
    );
  }
}