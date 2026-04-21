import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:caffiene/services/player/caffeine_player_controller.dart';
import 'package:caffiene/utils/globlal_methods.dart';

class GlassPlayerControls extends StatefulWidget {
  final CaffeinePlayerController controller;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback onSubtitlePressed;
  final VoidCallback onResolutionPressed;
  final bool isLive;

  const GlassPlayerControls({
    super.key,
    required this.controller,
    required this.title,
    this.subtitle,
    required this.onBack,
    required this.onSubtitlePressed,
    required this.onResolutionPressed,
    this.isLive = false,
  });

  @override
  State<GlassPlayerControls> createState() => _GlassPlayerControlsState();
}

class _GlassPlayerControlsState extends State<GlassPlayerControls> {
  bool _isVisible = true;
  Timer? _hideTimer;

  String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    if (_isVisible) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleVisibility,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !_isVisible,
          child: Stack(
            children: [
              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(),
              ),
              // Center Controls
              Center(
                child: _buildCenterControls(),
              ),
              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.isLive) ...[
          _GlassIconButton(
            icon: Icons.replay_10_rounded,
            size: 48,
            onPressed: () {
              final pos = widget.controller.player.state.position;
              widget.controller.player.seek(pos - const Duration(seconds: 10));
              _startHideTimer();
            },
          ),
          const SizedBox(width: 48),
        ],
        StreamBuilder<bool>(
          stream: widget.controller.player.stream.playing,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return _GlassIconButton(
              icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 72,
              onPressed: () {
                if (isPlaying) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
                _startHideTimer();
              },
            );
          },
        ),
        if (!widget.isLive) ...[
          const SizedBox(width: 48),
          _GlassIconButton(
            icon: Icons.forward_10_rounded,
            size: 48,
            onPressed: () {
              final pos = widget.controller.player.state.position;
              widget.controller.player.seek(pos + const Duration(seconds: 10));
              _startHideTimer();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isLive) ...[
            _buildSeekBar(),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              if (widget.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else ...[
                StreamBuilder<Duration>(
                  stream: widget.controller.player.stream.position,
                  builder: (context, snapshot) {
                    final pos = snapshot.data ?? Duration.zero;
                    return Text(
                      formatDuration(pos.inMilliseconds),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    );
                  },
                ),
                const Text(
                  ' / ',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                StreamBuilder<Duration>(
                  stream: widget.controller.player.stream.duration,
                  builder: (context, snapshot) {
                    final dur = snapshot.data ?? Duration.zero;
                    return Text(
                      formatDuration(dur.inMilliseconds),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    );
                  },
                ),
              ],
              const Spacer(),
              _GlassIconButton(
                icon: Icons.subtitles_rounded,
                onPressed: widget.onSubtitlePressed,
              ),
              const SizedBox(width: 16),
              _GlassIconButton(
                icon: Icons.settings_rounded,
                onPressed: widget.onResolutionPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    return StreamBuilder<Duration>(
      stream: widget.controller.player.stream.position,
      builder: (context, posSnapshot) {
        return StreamBuilder<Duration>(
          stream: widget.controller.player.stream.duration,
          builder: (context, durSnapshot) {
            final position = posSnapshot.data ?? Duration.zero;
            final duration = durSnapshot.data ?? Duration.zero;
            
            double value = 0.0;
            if (duration.inMilliseconds > 0) {
              value = position.inMilliseconds / duration.inMilliseconds;
            }
            
            return SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white.withOpacity(0.2),
                thumbColor: Colors.white,
                overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
              child: Slider(
                value: value.clamp(0.0, 1.0),
                onChanged: (v) {
                  final seekTo = duration * v;
                  widget.controller.seekTo(seekTo);
                  _startHideTimer();
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: size * 0.6),
            onPressed: onPressed,
            iconSize: size,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: size, height: size),
          ),
        ),
      ),
    );
  }
}
