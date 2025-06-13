import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/channel_strip_model.dart';
import 'models/channel_bank_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'WaveformEditorDialog.dart';

class SettingsWindow extends StatefulWidget {
  final int index;
  const SettingsWindow({super.key, required this.index});

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  late ChannelStripModel temp;
  late TextEditingController _nameController;
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _fadeInController;
  late TextEditingController _fadeOutController;
  final timeFormatter = MaskTextInputFormatter(
    mask: '##:##:##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final Map<String, Color> colorOptions = {
    'None': Colors.grey,
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Yellow': Colors.yellow,
    'Purple': Colors.purple,
  };

  String shortenPath(String fullPath, {int maxLength = 40}) {
    if (fullPath.length <= maxLength) return fullPath;
    final parts = fullPath.split(RegExp(r'[\\/]'));
    String fileName = parts.last;
    int keepLength = maxLength - fileName.length - 4;
    if (keepLength < 0) return '.../$fileName';
    return '...${fullPath.substring(fullPath.length - keepLength - fileName.length)}';
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  Duration parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length != 3) return Duration.zero;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: h, minutes: m, seconds: s);
  }

  @override
  void initState() {
    super.initState();
    final original = context.read<ChannelBankModel>().channels[widget.index];
    temp = original.copy();
    _nameController = TextEditingController(text: temp.name);
    _startController = TextEditingController(
      text: formatDuration(temp.startTime),
    );
    _endController = TextEditingController(text: formatDuration(temp.stopTime));
    _fadeInController = TextEditingController(
      text: temp.fadeInSeconds.toStringAsFixed(0),
    );
    _fadeOutController = TextEditingController(
      text: temp.fadeOutSeconds.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  Widget buildColorButton(String label, Color color) {
    final isSelected = temp.color == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          temp.color = color;
        });
      },
      child: Container(
        key: Key('${label}_btn_frame'),
        width: 102, // фиксированная ширина
        height: 40, // фиксированная высота
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isSelected ? color.withOpacity(0.5) : const Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0xFF919191)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKeyRow(String label, String keyName) {
    return Expanded(
      key: Key(keyName),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        key: Key('Settings_window'),
        width: 1015,
        height: 612,
        padding: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          key: Key('Settings_subframe'),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Expanded(
                      key: Key('Table_frame'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              key: Key('Settings_keys_frame'),
                              width: 203,
                              height: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFA1A1A1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  buildKeyRow('Name:', 'Name_k_frame'),
                                  buildKeyRow('Color:', 'Color_k_frame'),
                                  buildKeyRow('File Name:', 'FileName_k_frame'),
                                  buildKeyRow('Play Mode:', 'PlayMode_k_frame'),
                                  buildKeyRow('Loop:', 'Loop_k_frame'),
                                  buildKeyRow('Fade-In:', 'FadeIn_k_frame'),
                                  buildKeyRow('Fade-Out:', 'FadeOut_k_frame'),
                                  buildKeyRow(
                                    'Playback Mode:',
                                    'PlaybackMode_k_frame',
                                  ),
                                  buildKeyRow(
                                    'Play Range:',
                                    'PlayRange_k_frame',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              key: Key('Settings_value_frame'),
                              child: Container(
                                height: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFA1A1A1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      key: const Key('Name'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        child: TextField(
                                          key: const Key('Name_textedit_field'),
                                          controller: _nameController,
                                          onChanged: (val) {
                                            setState(() {
                                              temp.name = val;
                                            });
                                          },
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                            filled: true,
                                            fillColor: Color(0xFFD9D9D9),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      key: Key('Color_frame'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: colorOptions.entries
                                              .map(
                                                (entry) => buildColorButton(
                                                  entry.key,
                                                  entry.value,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      key: const Key('File_Name_frame'),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Текстовое поле с именем файла
                                            Expanded(
                                              child: Container(
                                                key: const Key(
                                                  'File_Name_text_frame',
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 10,
                                                    ),
                                                decoration: ShapeDecoration(
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  temp.filePath.isEmpty
                                                      ? 'No file selected'
                                                      : shortenPath(
                                                          temp.filePath,
                                                          maxLength: 40,
                                                        ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Inter',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Кнопка Browse
                                            GestureDetector(
                                              onTap: () async {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles(
                                                          type: FileType.custom,
                                                          allowedExtensions: [
                                                            'mp3',
                                                            'wav',
                                                            'aiff',
                                                          ],
                                                        );

                                                if (result != null &&
                                                    result.files.single.path !=
                                                        null) {
                                                  temp.filePath =
                                                      result.files.single.path!;
                                                  Duration? d = await temp
                                                      .controller
                                                      .player
                                                      .setFilePath(
                                                        temp.filePath,
                                                      );
                                                  setState(() {
                                                    temp.startTime =
                                                        Duration.zero;
                                                    temp.stopTime =
                                                        d ?? Duration.zero;
                                                    _startController.text =
                                                        formatDuration(
                                                          temp.startTime,
                                                        );
                                                    _endController.text =
                                                        formatDuration(
                                                          temp.stopTime,
                                                        );
                                                  });
                                                }
                                              },
                                              child: Container(
                                                key: const Key(
                                                  'Browse_btn_frame',
                                                ),
                                                width: 100,
                                                height: 40,
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: ShapeDecoration(
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Browse',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Inter',
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      key: Key('Play_Mode_frame'),

                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 10,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  temp.playMode =
                                                      PlayMode.playStop;
                                                });
                                              },
                                              child: Container(
                                                key: Key('Playstop_btn_frame'),
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 6,
                                                    ),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color:
                                                      temp.playMode ==
                                                          PlayMode.playStop
                                                      ? const Color(0xFFB0B0B0)
                                                      : const Color(0xFFD9D9D9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 17,
                                                  children: [
                                                    const Text(
                                                      'Play/Stop',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  temp.playMode =
                                                      PlayMode.playPause;
                                                });
                                              },
                                              child: Container(
                                                key: Key('Playpause_btn_frame'),
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 6,
                                                    ),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color:
                                                      temp.playMode ==
                                                          PlayMode.playPause
                                                      ? const Color(0xFFB0B0B0)
                                                      : const Color(0xFFD9D9D9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 17,
                                                  children: [
                                                    const Text(
                                                      'Play/Pause',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  temp.playMode =
                                                      PlayMode.retrigger;
                                                });
                                              },
                                              child: Container(
                                                key: Key('Retrigger_btn_frame'),
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 6,
                                                    ),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color:
                                                      temp.playMode ==
                                                          PlayMode.retrigger
                                                      ? const Color(0xFFB0B0B0)
                                                      : const Color(0xFFD9D9D9),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 17,
                                                  children: [
                                                    const Text(
                                                      'Retrigger',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      key: Key('Loop_frame'),

                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            Container(
                                              key: Key('Off_btn_frame'),
                                              width: 88,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                  Text(
                                                    'Off',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              key: Key('On_btn_frame'),
                                              width: 88,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                  Text(
                                                    'On',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Fade In
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: IntrinsicWidth(
                                          child: Container(
                                            height: double.infinity,
                                            key: const Key('Fade_In_row'),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD9D9D9),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Поле
                                                SizedBox(
                                                  width: 50,
                                                  height: 36,
                                                  child: TextField(
                                                    key: const Key(
                                                      'Fade_In_frame',
                                                    ),
                                                    controller:
                                                        _fadeInController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                    ),
                                                    onChanged: (value) {
                                                      final newValue =
                                                          double.tryParse(
                                                            value,
                                                          ) ??
                                                          0;
                                                      temp.fadeInSeconds =
                                                          newValue;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 6),

                                                // Кнопка <
                                                SizedBox(
                                                  width: 32,
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                    onPressed: () {
                                                      final current =
                                                          double.tryParse(
                                                            _fadeInController
                                                                .text,
                                                          ) ??
                                                          0;
                                                      final newValue =
                                                          (current - 1)
                                                              .clamp(0, 60)
                                                              .toDouble();
                                                      _fadeInController.text =
                                                          newValue
                                                              .toInt()
                                                              .toString();
                                                      temp.fadeInSeconds =
                                                          newValue;
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_left,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),

                                                // Кнопка >
                                                SizedBox(
                                                  width: 32,
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                    onPressed: () {
                                                      final current =
                                                          double.tryParse(
                                                            _fadeInController
                                                                .text,
                                                          ) ??
                                                          0;
                                                      final newValue =
                                                          (current + 1)
                                                              .clamp(0, 60)
                                                              .toDouble();
                                                      _fadeInController.text =
                                                          newValue
                                                              .toInt()
                                                              .toString();
                                                      temp.fadeInSeconds =
                                                          newValue;
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_right,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                const Text(
                                                  'seconds (0 – off, 60 – max)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Fade Out
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: IntrinsicWidth(
                                          child: Container(
                                            height: double.infinity,
                                            key: const Key('Fade_Out_row'),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD9D9D9),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Поле
                                                SizedBox(
                                                  width: 50,
                                                  height: 36,
                                                  child: TextField(
                                                    key: const Key(
                                                      'Fade_Out_frame',
                                                    ),
                                                    controller:
                                                        _fadeOutController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                    ),
                                                    onChanged: (value) {
                                                      temp.fadeOutSeconds =
                                                          double.tryParse(
                                                            value,
                                                          ) ??
                                                          0;
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 6),

                                                // Кнопка <
                                                SizedBox(
                                                  width: 32,
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                    onPressed: () {
                                                      final current =
                                                          double.tryParse(
                                                            _fadeOutController
                                                                .text,
                                                          ) ??
                                                          0;
                                                      final newValue =
                                                          (current - 1)
                                                              .clamp(0, 60)
                                                              .toDouble();
                                                      _fadeOutController.text =
                                                          newValue
                                                              .toInt()
                                                              .toString();
                                                      temp.fadeOutSeconds =
                                                          newValue;
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_left,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),

                                                // Кнопка >
                                                SizedBox(
                                                  width: 32,
                                                  height: 36,
                                                  child: ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                    onPressed: () {
                                                      final current =
                                                          double.tryParse(
                                                            _fadeOutController
                                                                .text,
                                                          ) ??
                                                          0;
                                                      final newValue =
                                                          (current + 1)
                                                              .clamp(0, 60)
                                                              .toDouble();
                                                      _fadeOutController.text =
                                                          newValue
                                                              .toInt()
                                                              .toString();
                                                      temp.fadeOutSeconds =
                                                          newValue;
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_right,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                const Text(
                                                  'seconds (0 – off, 60 – max)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      key: Key('Playback_Mode_frame'),
                                      // left: 10,
                                      // top: 394.22,
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 4,
                                          children: [
                                            Container(
                                              key: Key('Single_btn_frame'),
                                              width: 100,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 7,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                  Text(
                                                    'Single',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              key: Key('Multi_btn_frame'),
                                              width: 100,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 7,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                  Text(
                                                    'Multi',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      key: Key('Play_Range_frame'),
                                      // left: 10,
                                      // top: 449.11,
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 10,
                                          children: [
                                            Container(
                                              key: Key('Start_textedit_frame'),
                                              width: 100,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 7,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),

                                              child: TextField(
                                                controller: _startController,
                                                inputFormatters: [
                                                  timeFormatter,
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              key: Key('End_textedit_frame'),
                                              width: 100,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 7,
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),

                                              child: TextField(
                                                controller: _endController,
                                                inputFormatters: [
                                                  timeFormatter,
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      WaveformEditorDialog(
                                                        channel: temp,
                                                      ),
                                                );
                                              },
                                              child: Container(
                                                key: const Key(
                                                  'Edit_btn_frame',
                                                ),
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 7,
                                                    ),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Edit...',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final player =
                                                    temp.controller.player;

                                                // Устанавливаем файл напрямую — это вернёт duration
                                                Duration? duration =
                                                    await player.setFilePath(
                                                      temp.filePath,
                                                    );

                                                if (duration == null) {
                                                  debugPrint(
                                                    "Ошибка: не удалось измерить длительность файла",
                                                  );
                                                  return;
                                                }

                                                setState(() {
                                                  temp.startTime =
                                                      Duration.zero;
                                                  temp.stopTime = duration;
                                                  _startController.text =
                                                      formatDuration(
                                                        temp.startTime,
                                                      );
                                                  _endController.text =
                                                      formatDuration(
                                                        temp.stopTime,
                                                      );
                                                });
                                              },
                                              child: Container(
                                                key: Key('Reset_btn_frame'),
                                                height: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 7,
                                                    ),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: const Color(
                                                    0xFFD9D9D9,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  spacing: 10,
                                                  children: const [
                                                    Text(
                                                      'Reset',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      key: Key('Buttons_frame'),
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 17,
                        children: [
                          GestureDetector(
                            onTap: () {
                              temp.startTime = parseDuration(
                                _startController.text,
                              );
                              temp.stopTime = parseDuration(
                                _endController.text,
                              );

                              temp.controller.player.stop();

                              context.read<ChannelBankModel>().updateChannel(
                                widget.index,
                                temp,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              key: Key('Save_btn_frame'),
                              width: 120,
                              height: double.infinity,
                              padding: const EdgeInsets.all(4),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              key: Key('Cancel_btn_frame'),
                              width: 120,
                              height: double.infinity,
                              padding: const EdgeInsets.all(4),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
