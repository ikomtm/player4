import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'channel1.dart';
import 'master_fader.dart';
import 'models/channel_bank_model.dart';
import 'models/channel_strip_model.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Add this line
  
  final channels = List.generate(18, (index) => ChannelStripModel(
    name: 'Channel ${index + 1}',
    color: const Color(0xFF1E1E1E),  // Use dark background color
    filePath: '',
    volume: 0.5,
    startTime: Duration.zero,
    stopTime: Duration.zero,
    playMode: PlayMode.playStop,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChannelBankModel(channels),
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
  const MainPage({Key? key}) : super(key: key);

  Widget buildRow(int rowIndex, int offset) {
    return Expanded(  // Добавляем Expanded для равномерного распределения
      child: Row(
        children: List.generate(9, (i) {
          return Expanded(
            child: Container(
              key: Key('Column_$rowIndex-${i + 1}'),
              margin: const EdgeInsets.all(4),
              child: Channel1(index: i + offset),
            ),
          );
        }),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9, // Девять столбцов
            childAspectRatio: 0.4, // Высота больше ширины
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 18, // Всего 18 элементов
          itemBuilder: (context, index) {
            if (index == 17) { // 18-й элемент (с нуля: 17)
              return const MasterFader();
            } else {
              return Channel1(index: index);
            }
          },
        ),
      ),
    );
  }
}