import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reelriot/utils/helpers/check_internet.dart';

/// Non-intrusive floating status banner that warns the user when connectivity is lost
/// and informs them that cached/downloaded media is still available, without destroying navigation.
class OfflineIndicatorBanner extends StatelessWidget {
  const OfflineIndicatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NetworkStatusService>()) {
      return const SizedBox.shrink();
    }

    final netService = Get.find<NetworkStatusService>();

    return Obx(() {
      final offline = netService.isOffline.value;
      final reconnecting = netService.isReconnecting.value;

      if (!offline && !reconnecting) {
        return const SizedBox.shrink();
      }

      final isBackOnline = !offline && reconnecting;
      final bgColor = isBackOnline
          ? const Color(0xFF16A34A).withValues(alpha: 0.95)
          : const Color(0xFFDC2626).withValues(alpha: 0.95);
      final icon = isBackOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
      final text = isBackOnline
          ? 'Back online — syncing library...'
          : 'Offline mode — browsing cached & downloaded library';

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: Offset(0, 0),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PoppinsSB',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
