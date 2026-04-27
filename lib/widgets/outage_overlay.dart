import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:reelriot/services/outage_service.dart';

class OutageOverlay extends StatelessWidget {
  const OutageOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OutageService.instance.isApiDown,
      builder: (context, isDown, _) {
        if (!isDown) return const SizedBox.shrink();

        return ValueListenableBuilder<String?>(
          valueListenable: OutageService.instance.outageMessage,
          builder: (context, message, _) {
            return Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // 1. High-intensity blur background
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  
                  // 2. Premium Content Area
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Glowing Icon
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withValues(alpha: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              size: 80,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          Text(
                            'system_offline'.tr(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          Text(
                            message ?? 'outage_default_message'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 60),
                          
                          // Custom Glass Button
                          InkWell(
                            onTap: () {
                              debugPrint('[OutageOverlay] Manual retry triggered');
                              OutageService.instance.forceCheck();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh_rounded, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'retry_connection'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
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
            );
          },
        );
      },
    );
  }
}
