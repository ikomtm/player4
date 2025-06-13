import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path_provider/path_provider.dart';
import '../models/channel_strip_model.dart';
import 'dart:math';

class WaveformEditorDialog extends StatefulWidget {
  final ChannelStripModel channel;
  const WaveformEditorDialog({super.key, required this.channel});

  @override
  State<WaveformEditorDialog> createState() => _WaveformEditorDialogState();
}

class _WaveformEditorDialogState extends State<WaveformEditorDialog> {
  Waveform? _waveform;
  Duration _start = Duration.zero;
  Duration _end = Duration.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _start = widget.channel.startTime;
    _end = widget.channel.stopTime;
    _loadWaveform();
  }

  Future<void> _loadWaveform() async {
    final tempDir = await getTemporaryDirectory();
    final waveOut = File('${tempDir.path}/${widget.channel.name}_waveform.wave');

    final waveformStream = JustWaveform.extract(
    audioInFile: File(widget.channel.filePath),
    waveOutFile: waveOut,
  );

  waveformStream.listen((progress) {
    if (progress.waveform != null) {
      setState(() {
        _waveform = progress.waveform;
        _loading = false;
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Sample Boundaries'),
      content: _loading || _waveform == null
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start: ${_start.inSeconds}s  |  End: ${_end.inSeconds}s'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  width: 300,
                  child: WaveformWidget(
                    waveform: _waveform!,
                    start: _start,
                    end: _end,
                    duration: widget.channel.controller.player.duration ?? const Duration(seconds: 1),
                    onChanged: (start, end) {
                      setState(() {
                        _start = start;
                        _end = end;
                      });
                    },
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              widget.channel.startTime = _start;
              widget.channel.stopTime = _end;
            });
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class WaveformWidget extends StatefulWidget {
  final Waveform waveform;
  final Duration start;
  final Duration end;
  final Duration duration;
  final void Function(Duration, Duration) onChanged;

  const WaveformWidget({
    super.key,
    required this.waveform,
    required this.start,
    required this.end,
    required this.duration,
    required this.onChanged,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  double? dragStart;
  double? dragEnd;

  @override
  void initState() {
    super.initState();
    dragStart = widget.start.inMilliseconds.toDouble();
    dragEnd = widget.end.inMilliseconds.toDouble();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints, bool isStart) {
    final dx = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
    final percent = dx / constraints.maxWidth;
    final newMs = percent * widget.duration.inMilliseconds;

    setState(() {
      if (isStart) {
        dragStart = min(newMs, dragEnd ?? newMs);
      } else {
        dragEnd = max(newMs, dragStart ?? newMs);
      }
      widget.onChanged(
        Duration(milliseconds: dragStart!.round()),
        Duration(milliseconds: dragEnd!.round()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final startX = (dragStart ?? 0) / widget.duration.inMilliseconds * constraints.maxWidth;
        final endX = (dragEnd ?? constraints.maxWidth) / widget.duration.inMilliseconds * constraints.maxWidth;

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, constraints, true),
          child: Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.grey[300],
                child: CustomPaint(
                  painter: _WaveformPainter(widget.waveform),
                ),
              ),
              Positioned(
                left: startX,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) => _onPanUpdate(details, constraints, true),
                  child: Container(
                    width: 4,
                    color: Colors.green,
                  ),
                ),
              ),
              Positioned(
                left: endX,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) => _onPanUpdate(details, constraints, false),
                  child: Container(
                    width: 4,
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                left: startX,
                width: endX - startX,
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Waveform waveform;
  _WaveformPainter(this.waveform);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final samples = waveform.data;
  if (samples.isEmpty) return;

  final samplePerPixel = samples.length / size.width;

  for (int i = 0; i < size.width; i++) {
    final start = (i * samplePerPixel).floor();
    final end = ((i + 1) * samplePerPixel).floor().clamp(0, samples.length);

    if (start >= samples.length || end <= start) continue;

    final segment = samples.sublist(start, end);
    final maxVal = segment.reduce((a, b) => a > b ? a : b);
    final minVal = segment.reduce((a, b) => a < b ? a : b);

    final centerY = size.height / 2;
    final y1 = centerY * (1 - minVal.clamp(-1.0, 1.0));
    final y2 = centerY * (1 - maxVal.clamp(-1.0, 1.0));

    canvas.drawLine(Offset(i.toDouble(), y1), Offset(i.toDouble(), y2), paint);
  }
}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
