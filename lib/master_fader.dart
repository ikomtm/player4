import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/channel_bank_model.dart';
import '/channel1.dart'; // для использования ChannelTheme

class MasterFader extends StatelessWidget {
  const MasterFader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channelBank = context.watch<ChannelBankModel>();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(4),
      decoration: ChannelTheme.channelDecoration,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildFader(context, channelBank),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: ChannelTheme.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ChannelTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Text(
          'MASTER',
          style: ChannelTheme.textStyle.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFader(BuildContext context, ChannelBankModel channelBank) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: ChannelTheme.sliderTheme.copyWith(
                  activeTrackColor: Colors.red, // Выделим мастер фейдер цветом
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: channelBank.masterVolume,
                  onChanged: (value) {
                    channelBank.setMasterVolume(value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(channelBank.masterVolume * 100).toInt()}%',
            style: ChannelTheme.textStyle,
          ),
        ],
      ),
    );
  }
}