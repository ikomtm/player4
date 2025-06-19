import 'package:flutter/material.dart';
import 'package:player3/settings.dart';
import 'package:provider/provider.dart';
import 'models/channel_bank_model.dart';
import 'package:just_audio/just_audio.dart'; 


// Константы для дизайна канала
class ChannelTheme {
  // Цвета
  static const backgroundColor = Color(0xFF1E1E1E);    // Темный фон
  static const surfaceColor = Color(0xFF2D2D2D);      // Поверхность элементов
  static const primaryColor = Color(0xFF007AFF);      // Синий акцент
  static const textColor = Colors.white;              // Белый текст
  static const faderBgColor = Color(0xFF404040);      // Фон фейдера
  static const knobColor = Color(0xFF333333);         // Цвет кнопки

  // Размеры
  static const headerHeight = 32.0;
  static const buttonSize = 28.0;
  static const knobSize = 120.0;
  static const faderTrackWidth = 8.0;
  static const thumbSize = 25.0;

  // Стили
  static final channelDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: surfaceColor,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(26),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const textStyle = TextStyle(
    color: textColor,
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static final buttonStyle = BoxDecoration(
    color: knobColor,
    borderRadius: BorderRadius.circular(17),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(26),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: surfaceColor,
      width: 1,
    ),
  );

  // Стили для фейдера
  static final sliderTheme = SliderThemeData(
    trackHeight: faderTrackWidth,
    activeTrackColor: primaryColor,
    inactiveTrackColor: faderBgColor,
    thumbColor: Colors.white,
    overlayColor: Colors.transparent,
    trackShape: _CustomTrackShape(),
    thumbShape: _CustomThumbShape(),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
  );
}

// Вспомогательные функции
String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final h = twoDigits(d.inHours);
  final m = twoDigits(d.inMinutes.remainder(60));
  final s = twoDigits(d.inSeconds.remainder(60));
  return '$h:$m:$s';
}

// Компоненты канала
class ChannelHeader extends StatelessWidget {
  final String name;
  final VoidCallback onSettingsTap;

  const ChannelHeader({
    required this.name,
    required this.onSettingsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      key: const Key('Name_frame'),
      width: double.infinity,
      height: ChannelTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            key: const Key('Name_label'),
            style: ChannelTheme.textStyle,
          ),
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return InkWell(
      onTap: onSettingsTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        key: const Key('settings_frame'),
        width: ChannelTheme.buttonSize,
        height: ChannelTheme.buttonSize,
        decoration: BoxDecoration(
          color: ChannelTheme.surfaceColor,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '...',
            style: ChannelTheme.textStyle,
          ),
        ),
      ),
    );
  }
}

class ChannelFader extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const ChannelFader({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('Fader_frame'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: ChannelTheme.faderTrackWidth,
                  activeTrackColor: ChannelTheme.primaryColor,
                  inactiveTrackColor: ChannelTheme.faderBgColor,
                  thumbColor: Colors.white,
                  overlayColor: Colors.transparent,
                  thumbShape: _CustomThumbShape(),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  trackShape: _CustomTrackShape(),
                ),
                child: Slider(
                  value: value,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: ChannelTheme.textStyle,
          ),
        ],
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final Duration currentTime;
  final Duration endTime;

  const TimeDisplay({
    required this.currentTime,
    required this.endTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('range_tc_frame'),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(currentTime),
            key: const Key('Start_timecode'),
            style: ChannelTheme.textStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            formatDuration(endTime),
            key: const Key('Stop_timecode'),
            style: ChannelTheme.textStyle,
            textAlign: TextAlign.center, 
          ),
        ],
      ),
    ),
    );
  }
}

class PlayButton extends StatefulWidget {
  final int channelNumber;
  final VoidCallback onTap;
  final bool hasFile;
  final bool isPlaying;  // New parameter

  const PlayButton({
    required this.channelNumber,
    required this.onTap,
    required this.hasFile,
    required this.isPlaying,  // Add to constructor
    super.key,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(17),
      splashColor: Colors.black12,
      child: Container(
        key: const Key('knob_frame'),
        height: ChannelTheme.knobSize + 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: ChannelTheme.knobSize,
                  height: ChannelTheme.knobSize,
                  decoration: BoxDecoration(
                    color: widget.hasFile 
                        ? ChannelTheme.primaryColor.withOpacity(
                            widget.isPlaying 
                                ? _opacityAnimation.value 
                                : 0.1
                          )
                        : ChannelTheme.knobColor,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: widget.hasFile 
                          ? ChannelTheme.primaryColor 
                          : ChannelTheme.surfaceColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
            Text(
              '${widget.channelNumber}',
              style: ChannelTheme.textStyle.copyWith(
                fontSize: 36,
                color: widget.hasFile 
                    ? ChannelTheme.primaryColor 
                    : ChannelTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



class Channel1 extends StatelessWidget {
  final int index;
  
  const Channel1({
    required this.index,
    super.key,
  });

  

  @override
  Widget build(BuildContext context) {
    final channel = context.watch<ChannelBankModel>().channels[index];
    
    return Container(
      key: Key('Channel1_$index'),
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: ChannelTheme.channelDecoration.copyWith(
        color: channel.color == Colors.grey
            ? ChannelTheme.backgroundColor
            : channel.color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChannelHeader(
            name: channel.name,
            onSettingsTap: () => _showSettings(context),
          ),
          Expanded(
            flex: 3,
            child: ChannelFader(
              value: channel.volume,
              onChanged: (value) {
                context.read<ChannelBankModel>().updateVolume(index, value);
                channel.controller.setVolume(value);
              },
            ),
          ),
          StreamBuilder<Duration>(
            stream: channel.controller.positionStream,
            initialData: channel.controller.position,
            builder: (context, snapshot) {
              return TimeDisplay(
                currentTime: snapshot.data ?? Duration.zero,
                endTime: channel.stopTime,
              );
            },
          ),
          StreamBuilder<bool>(
            stream: channel.controller.playingStream,
            initialData: channel.controller.isPlaying,
            builder: (context, snapshot) {
              return PlayButton(
                channelNumber: index + 1,
                onTap: () => _handlePlayTap(context, channel),
                hasFile: channel.filePath.isNotEmpty,
                isPlaying: snapshot.data ?? false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SettingsWindow(index: index),
    );
  }

  Future<void> _handlePlayTap(BuildContext context, channel) async {
    if (channel.filePath.isEmpty) return;
    debugPrint('[Channel ${channel.name}] === Button Pressed ===');
    await channel.controller.toggle();
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(ChannelTheme.thumbSize / 2);
  }

  @override
  void paint(PaintingContext context, Offset center, 
    {required Animation<double> activationAnimation,
     required Animation<double> enableAnimation,
     required bool isDiscrete,
     required TextPainter labelPainter,
     required RenderBox parentBox,
     required SliderThemeData sliderTheme,
     required TextDirection textDirection,
     required double value,
     required double textScaleFactor,
     required Size sizeWithOverflow}) {
    
    final canvas = context.canvas;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Тень
    canvas.drawCircle(
      center.translate(2, 2),
      ChannelTheme.thumbSize / 2,
      paint..color = Colors.black.withOpacity(0.2),
    );

    // Основной круг
    canvas.drawCircle(
      center,
      ChannelTheme.thumbSize / 2,
      paint..color = Colors.white,
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double? additionalActiveTrackHeight,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = true,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == null || !parentBox.hasSize) return;

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final splitX = thumbCenter.dx;
    
    // Активная часть (синяя)
    final activeTrackRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      splitX,
      trackRect.bottom,
    );

    // Неактивная часть (серая)
    final inactiveTrackRect = Rect.fromLTRB(
      splitX,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    final radius = Radius.circular(trackRect.height / 2);

    // Рисуем части трека
    final inactivePaint = Paint()
      ..color = ChannelTheme.faderBgColor
      ..style = PaintingStyle.fill;
    
    final activePaint = Paint()
      ..color = ChannelTheme.primaryColor
      ..style = PaintingStyle.fill;
    
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveTrackRect, radius),
      inactivePaint,
    );
    
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, radius),
      activePaint,
    );
  }
}