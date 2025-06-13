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
 }) {
    controller = ChannelAudioController(this);
  }

  ChannelStripModel copy() {
    return ChannelStripModel(
      name: name,
      color: color,
      filePath: filePath,
      volume: volume,
      startTime: startTime,
      stopTime: stopTime,
      playMode: playMode,
      fadeInSeconds: fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds,      
    );
  }
}
