
import 'package:flutter/material.dart';
import 'package:player3/settings.dart';
import 'package:provider/provider.dart';

import 'models/channel_bank_model.dart';

String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final h = twoDigits(d.inHours);
  final m = twoDigits(d.inMinutes.remainder(60));
  final s = twoDigits(d.inSeconds.remainder(60));
  return '$h:$m:$s';
}

class Channel1 extends StatelessWidget {
  final int index;
  const Channel1({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final channel = context.watch<ChannelBankModel>().channels[index];
    return Container(
      key: Key('Channel1_\$index'),
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: channel.color,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('Name_frame'),
            width: double.infinity,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  key: const Key('Name_label'),
                  channel.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SettingsWindow(index: index),
                    );
                  },
                  child: Container(
                    key: const Key('settings_frame'),
                    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD5D5D5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Center(
                      child: Text(
                        '...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            key: Key('Fader_frame'),
            fit: FlexFit.loose,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    key: Key('Fader_line_frame'),
                    fit: FlexFit.loose,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            key: Key('fader_bg'),
                            fit: FlexFit.loose,
                            child: Container(
                              width: 4,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFC9C9C9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    key: Key('fader_fill_frame'),
                                    width: 4,
                                    height: 65,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF3E31FF),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            key: Key('fader_thumb'),
                            width: 28,
                            height: 28,
                            padding: const EdgeInsets.all(10),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(2, 4),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    key: Key('Fader_value_frame'),
                    width: double.infinity,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          key: Key('Fader_value_text'),
                          '50%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            key: Key('range_tc_frame'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<Duration>(
                  stream: channel.controller.player.createPositionStream(
                    minPeriod: const Duration(milliseconds: 100),
                  ),
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final effectiveTime = position;
                    return Text(
                      formatDuration(effectiveTime),
                      key: const Key('Start_timecode'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
                Text(
                  key: const Key('Stop_timecode'),
                  formatDuration(channel.stopTime),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          InkWell(
            onTap: () async {
              final channel = context.read<ChannelBankModel>().channels[index];  
              debugPrint('[Channel ${channel.name}] === Button Pressed ===');           
              if (channel.filePath.isEmpty) return;
              
              await channel.controller.toggle(); // вызов логики из контроллера              
            },
          
          borderRadius: BorderRadius.circular(17),
          splashColor: Colors.black12,              
          child: Container(
              key: const Key('knob_frame'),
              width: double.infinity,
              height: 124,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    key: const Key('knob'),
                    width: 120,
                    height: 120,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFCBCBCB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                  Container(
                    key: const Key('knob_label'),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
