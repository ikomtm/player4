import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math';
import 'models/channel_strip_model.dart';
import 'models/channel_bank_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'WaveformEditorDialog.dart';
import 'package:flutter/services.dart';
import 'ChannelAudioController.dart';
import 'channel1.dart';
// Импортируем необходимые пакеты

// Константы для дизайна
class SettingsTheme {
  static const backgroundColor = Color(0xFF2C2C2C);
  static const surfaceColor = Color(0xFF3D3D3D);
  static const primaryColor = Color(0xFF007AFF);
  static const textColor = Colors.white;
  static const disabledColor = Color(0xFF666666);

  static final dialogDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: surfaceColor,
    foregroundColor: textColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static const textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
    fontFamily: 'Inter',
  );
}

// Компоненты интерфейса
class SettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final double width;

  const SettingsButton({
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.width = 100,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: SettingsTheme.buttonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(
            isSelected ? SettingsTheme.primaryColor : SettingsTheme.surfaceColor,
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: SettingsTheme.textStyle),
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const SettingsTextField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: SettingsTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: SettingsTheme.textStyle,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
}

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

  final timeFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    // Убираем все кроме цифр
    final onlyNumbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (onlyNumbers.isEmpty) return newValue.copyWith(text: '00:00:00');

    // Дополняем нулями слева до 6 цифр
    final paddedNumbers = onlyNumbers.padLeft(6, '0');
    
    // Берем последние 6 цифр если больше
    final limitedNumbers = paddedNumbers.substring(max(0, paddedNumbers.length - 6));
    
    // Форматируем в HH:MM:SS
    final hours = limitedNumbers.substring(0, 2);
    final minutes = limitedNumbers.substring(2, 4);
    final seconds = limitedNumbers.substring(4, 6);
    
    // Проверяем валидность значений
    final h = min(int.parse(hours), 23);
    final m = min(int.parse(minutes), 59);
    final s = min(int.parse(seconds), 59);
    
    final formattedTime = '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';

    return newValue.copyWith(
      text: formattedTime,
      selection: TextSelection.collapsed(offset: formattedTime.length),
    );
  });

  final Map<String, Color> colorOptions = {
    'None': ChannelTheme.backgroundColor, // Используем surfaceColor для "None"
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Yellow': Colors.yellow,
    'Purple': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    final original = context.read<ChannelBankModel>().channels[widget.index];
    temp = ChannelStripModel.copy(original);
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: temp.name);
    _startController = TextEditingController(text: formatDuration(temp.startTime));
    _endController = TextEditingController(text: formatDuration(temp.stopTime));
    _fadeInController = TextEditingController(text: temp.fadeInSeconds.toString());
    _fadeOutController = TextEditingController(text: temp.fadeOutSeconds.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1015,
        height: 612,
        decoration: SettingsTheme.dialogDecoration,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameSection(),
                    const SizedBox(height: 24),
                    _buildColorSection(),
                    const SizedBox(height: 24),
                    _buildFileSection(),
                    const SizedBox(height: 24),
                    _buildTimeSection(),
                    const SizedBox(height: 24),
                    _buildFadeSection(),
                    const SizedBox(height: 24),
                    _buildPlaybackSection(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

    Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text('Channel Settings', style: SettingsTheme.textStyle.copyWith(fontSize: 20)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: SettingsTheme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name', style: SettingsTheme.textStyle),
        const SizedBox(height: 8),
        SettingsTextField(
          controller: _nameController,
          hint: 'Enter channel name',
          onChanged: (value) => setState(() => temp.name = value),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: SettingsTheme.textStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorOptions.entries.map((entry) {
            return _buildColorButton(entry.key, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorButton(String label, Color color) {
    final isSelected = temp.color == color;
    return InkWell(
      onTap: () => setState(() => temp.color = color),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: SettingsTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: SettingsTheme.primaryColor, width: 2)
            : null,
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: SettingsTheme.textStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Audio File', style: SettingsTheme.textStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SettingsTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  shortenPath(temp.filePath),
                  style: SettingsTheme.textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SettingsButton(
              text: 'Browse',
              onPressed: _selectFile,
              width: 120,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        temp.filePath = result.files.single.path!;        
        temp.controller.loadFile(temp.filePath).then((_) {
        // После загрузки файла получаем его длительность
        final duration = temp.controller.player.duration ?? Duration.zero;
        temp.stopTime = duration;        
        // Обновляем значение в _endController
        _endController.text = formatDuration(duration);
      });
    });
  }
}



  Widget _buildTimeSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Play Range', style: SettingsTheme.textStyle),
      const SizedBox(height: 8),
      Row(
        children: [
          // Start Time Field
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: SettingsTextField(
                    controller: _startController,
                    hint: 'Start Time (HH:MM:SS)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [timeFormatter],
                    onChanged: (value) {
                      temp.startTime = parseDuration(value);
                      temp.controller.player.seek(temp.startTime);
                    },
                  ),
                ),                
              ],
            ),
          ),
          const SizedBox(width: 16),
          // End Time Field
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: SettingsTextField(
                    controller: _endController,
                    hint: 'End Time (HH:MM:SS)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [timeFormatter],
                    onChanged: (value) {
                      temp.stopTime = parseDuration(value);
                    },
                  ),
                ),                
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const SizedBox(width: 8),
                SettingsButton(
                  text: 'Edit...',
                  onPressed: _showWaveformEditor,
                  width: 80,
                ),
                const SizedBox(width: 8),
                SettingsButton(
                  text: 'Reset',
                  onPressed: _resetTimeRange,
                  width: 80,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
  Future<void> _showWaveformEditor() async {
    final result = await showDialog<_DurationRange>(
      context: context,
      builder: (context) => WaveformEditorDialog(channel: temp),
    );

    if (result != null) {
      setState(() {
        temp.startTime = result.start;
        temp.stopTime = result.end;
        _startController.text = formatDuration(temp.startTime);
        _endController.text = formatDuration(temp.stopTime);
      });
    }
  }
  void _resetTimeRange() {
    setState(() {
      temp.startTime = Duration.zero;
      temp.stopTime = temp.controller.player.duration ?? Duration.zero;
      _startController.text = formatDuration(temp.startTime);
      _endController.text = formatDuration(temp.stopTime);
    });
  }
  Widget _buildFadeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fade In/Out', style: SettingsTheme.textStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SettingsTextField(
                controller: _fadeInController,
                hint: 'Fade In (seconds)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                final fadeIn = double.tryParse(value) ?? 0;
                temp.fadeInSeconds = fadeIn;
                print('Setting fadeInSeconds to: $fadeIn');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SettingsTextField(
                controller: _fadeOutController,
                hint: 'Fade Out (seconds)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  temp.fadeOutSeconds = double.tryParse(value) ?? 0;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildPlaybackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Playback Mode', style: SettingsTheme.textStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PlayMode.values.map((mode) {
            return SettingsButton(
              text: mode.name,
              isSelected: temp.playMode == mode,
              onPressed: () => setState(() => temp.playMode = mode),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SettingsButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
          SettingsButton(
            text: 'Reset',
            onPressed: () {
              // Сбрасываем все поля к значениям оригинала
              setState(() {
                temp = ChannelStripModel.copy(context.read<ChannelBankModel>().channels[widget.index]);
                _initControllers();
              });
            },
            width: 120,
          ),
          SettingsButton(
            text: 'Normalize (EBU R128)',
            onPressed: () async {
              final filePath = temp.filePath;
              if (filePath.isEmpty) return;

              // Вызовем функцию нормализации (реализуем ниже)
              // final gainDb = await computeEbuR128Gain(filePath);
              // if (gainDb != null) {
              //   // Применяем гейн к громкости канала
              //   temp.volume = (temp.volume * dbToLinear(gainDb)).clamp(0.0, 1.0);
              //   temp.controller.setVolume(temp.volume);
              //   setState(() {});
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text('LUFS normalization applied: $gainDb dB')),
              //   );
              // }
            },
            width: 180,
          ),
          SettingsButton(
            text: 'Save',
            onPressed: () async {
            // Получаем текущий канал
            final currentChannel = context
                .read<ChannelBankModel>()
                .channels[widget.index];

            // Для отладки
            print('temp.fadeInSeconds: ${temp.fadeInSeconds}');
            
            // Обновляем все поля текущего канала
            currentChannel.name = temp.name;
            currentChannel.color = temp.color;
            currentChannel.filePath = temp.filePath;
            currentChannel.startTime = temp.startTime;
            currentChannel.stopTime = temp.stopTime;
            currentChannel.playMode = temp.playMode;
            currentChannel.fadeInSeconds = temp.fadeInSeconds;
            currentChannel.fadeOutSeconds = temp.fadeOutSeconds;

            // Для отладки
            print('currentChannel.fadeInSeconds: ${currentChannel.fadeInSeconds}');

            // Делаем seek на текущем контроллере
            await currentChannel.controller.player.seek(currentChannel.startTime);
            
            // Обновляем позицию в стриме
            currentChannel.controller.updatePosition(currentChannel.startTime);
            
            // Уведомляем об изменениях
            context.read<ChannelBankModel>().notifyListeners();
            
            Navigator.pop(context);
          },
          width: 120,
          ),
        ],
      ),
    );
  }
  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Duration parseDuration(String input) {
    final parts = input.split(':');
    if (parts.length != 3) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  String shortenPath(String path) {
    if (path.length <= 30) return path;
    return '...${path.substring(path.length - 30)}';
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
}

class _DurationRange {
  final Duration start;
  final Duration end;
  _DurationRange({required this.start, required this.end});
}