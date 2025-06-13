import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'channel1.dart';
import 'models/channel_bank_model.dart';
import 'models/channel_strip_model.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChannelBankModel(
       List.generate(18, (index) => ChannelStripModel(
        name: 'Channel ${index + 1}',
        color: Colors.grey,
        filePath: '',
        volume: 0.5,
        startTime: Duration.zero,
        stopTime: Duration.zero,
        playMode: PlayMode.playStop,
      )),
    ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstantPlay',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Widget buildRow(int rowIndex, int offset) {
    return Row(
      children: List.generate(9, (i) {
        return Expanded(
          child: Container(
            key: Key('Column_$rowIndex-${i + 1}'),
            margin: const EdgeInsets.all(4),
            child: Channel1(index: i + offset),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          buildRow(1, 0),  // Row 1: indexes 0–8
          const SizedBox(height: 2),
          buildRow(2, 9),  // Row 2: indexes 9–17
        ],
      ),
    );
  }
}
