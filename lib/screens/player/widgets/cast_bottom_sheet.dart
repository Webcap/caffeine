import 'dart:math' as math;

import 'package:reelriot/services/cast_service.dart';
import 'package:cast_plus/cast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CastBottomSheet extends StatefulWidget {
  const CastBottomSheet({
    super.key,
    required this.streamUrl,
    required this.title,
    this.posterUrl,
    this.elapsedSeconds = 0,
    this.headers,
  });

  final String streamUrl;
  final String title;
  final String? posterUrl;
  final int elapsedSeconds;
  final Map<String, String>? headers;

  @override
  State<CastBottomSheet> createState() => _CastBottomSheetState();
}

class _CastBottomSheetState extends State<CastBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cast = context.read<CastService>();
      if (!cast.isConnected && !cast.isScanning) {
        cast.scanForDevices();
      }
    });
  }

  Future<void> _connectToDevice(CastService cast, CastDevice device) async {
    await cast.connectAndPlay(
      device: device,
      streamUrl: widget.streamUrl,
      title: widget.title,
      posterUrl: widget.posterUrl,
      elapsedSeconds: widget.elapsedSeconds,
      headers: widget.headers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<CastService>(
      builder: (context, cast, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _DragHandle(),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: cast.isConnected
                            ? _ConnectedView(
                                key: const ValueKey('connected'),
                                cast: cast,
                                posterUrl: widget.posterUrl,
                              )
                            : _ScanView(
                                key: const ValueKey('scan'),
                                cast: cast,
                                onScan: () => cast.scanForDevices(),
                                onConnect: (d) => _connectToDevice(cast, d),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan / device-list view
// ─────────────────────────────────────────────────────────────────────────────
class _ScanView extends StatelessWidget {
  const _ScanView({
    super.key,
    required this.cast,
    required this.onScan,
    required this.onConnect,
  });

  final CastService cast;
  final VoidCallback onScan;
  final void Function(CastDevice) onConnect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isWorking = cast.isScanning || cast.state == CastState.connecting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ─────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cast, color: cs.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cast to a device',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      'Devices on your Wi-Fi network',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── scanning indicator or device list ───────────────────────────────
          if (cast.isScanning)
            _ScanningIndicator()
          else if (cast.devices.isEmpty)
            _EmptyState(onScan: onScan)
          else ...[
            _SectionLabel('Available devices'),
            const SizedBox(height: 6),
            ...cast.devices.map(
              (d) => _DeviceCard(
                device: d,
                isConnecting: cast.state == CastState.connecting &&
                    cast.connectedDeviceName == d.name,
                onTap: () => onConnect(d),
              ),
            ),
            const SizedBox(height: 8),
            _RescanRow(onScan: onScan, enabled: !isWorking),
          ],

          // ── error chip ──────────────────────────────────────────────────────
          if (cast.state == CastState.error && cast.lastError != null) ...[
            const SizedBox(height: 12),
            _ErrorChip(message: cast.lastError!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connected view
// ─────────────────────────────────────────────────────────────────────────────
class _ConnectedView extends StatelessWidget {
  const _ConnectedView({
    super.key,
    required this.cast,
    this.posterUrl,
  });

  final CastService cast;
  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── now-casting card ────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Blurred poster backdrop
                if (posterUrl != null)
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: posterUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      memCacheHeight: 450,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                // Scrim
                if (posterUrl != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.black.withOpacity(0.82),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pulsing cast icon
                      _PulsingCastIcon(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _NowPlayingChip(),
                            const SizedBox(height: 6),
                            Text(
                              cast.nowPlayingTitle ?? 'Playing',
                              style: tt.titleSmall?.copyWith(
                                color: posterUrl != null
                                    ? Colors.white
                                    : cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.tv_rounded,
                                  size: 14,
                                  color: posterUrl != null
                                      ? Colors.white70
                                      : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    cast.connectedDeviceName ?? '',
                                    style: tt.bodySmall?.copyWith(
                                      color: posterUrl != null
                                          ? Colors.white70
                                          : cs.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── stop button ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.tonalIcon(
              onPressed: () {
                cast.disconnect();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cast, size: 20),
              label: const Text('Stop casting'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.errorContainer,
                foregroundColor: cs.onErrorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isConnecting,
    required this.onTap,
  });

  final CastDevice device;
  final bool isConnecting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isConnecting ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isConnecting
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: cs.onSecondaryContainer,
                          ),
                        )
                      : Icon(Icons.tv_rounded,
                          color: cs.onSecondaryContainer, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name,
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        isConnecting ? 'Connecting…' : 'Chromecast',
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (!isConnecting)
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          _RippleIcon(color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Looking for devices…',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cast, size: 36, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Text('No devices found',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Make sure your Chromecast is on\nthe same Wi-Fi network.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.wifi_find_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RescanRow extends StatelessWidget {
  const _RescanRow({required this.onScan, required this.enabled});
  final VoidCallback onScan;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: enabled ? onScan : null,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Refresh'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _ErrorChip extends StatelessWidget {
  const _ErrorChip({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 18, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onErrorContainer),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Now Playing" badge chip.
class _NowPlayingChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'NOW CASTING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pulsing cast icon shown while connected.
class _PulsingCastIcon extends StatefulWidget {
  @override
  State<_PulsingCastIcon> createState() => _PulsingCastIconState();
}

class _PulsingCastIconState extends State<_PulsingCastIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cast_connected, color: Colors.white, size: 24),
      ),
    );
  }
}

/// Animated ripple rings used in the scanning state.
class _RippleIcon extends StatefulWidget {
  const _RippleIcon({required this.color});
  final Color color;

  @override
  State<_RippleIcon> createState() => _RippleIconState();
}

class _RippleIconState extends State<_RippleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              _ring(
                progress: _ctrl.value,
                maxRadius: 44,
                color: widget.color,
              ),
              // Inner ring (offset by half)
              _ring(
                progress: (_ctrl.value + 0.5) % 1.0,
                maxRadius: 44,
                color: widget.color,
              ),
              // Centre icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cast, color: Colors.white, size: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(
      {required double progress,
      required double maxRadius,
      required Color color}) {
    final radius = progress * maxRadius;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    return Positioned.fill(
      child: CustomPaint(
        painter: _RingPainter(
          radius: radius,
          color: color.withOpacity(opacity * 0.4),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, math.max(0, radius), paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.radius != radius || old.color != color;
}
