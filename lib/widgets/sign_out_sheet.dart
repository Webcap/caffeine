import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/utils/routes/app_pages.dart';

class SignOutBottomSheet extends StatelessWidget {
  const SignOutBottomSheet({
    super.key,
    required this.sp,
  });

  final SignInProvider sp;

  static const _primary = Color(0xFFDC2626);
  static const _bgSurfaceDark = Color(0xFF0B0F14);
  static const _bgSurfaceLight = Color(0xFFFFFFFF);
  static const _textPrimDark = Color(0xFFFFFFFF);
  static const _textPrimLight = Color(0xFF0B0F14);
  static const _textTertDark = Color(0x80FFFFFF);
  static const _textTertLight = Color(0xFF94A3B8);
  static const _borderDark = Color(0x14FFFFFF);
  static const _borderLight = Color(0x140F172A);

  static void show(BuildContext context, SignInProvider sp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? _bgSurfaceDark : _bgSurfaceLight;

    Get.bottomSheet(
      SignOutBottomSheet(sp: sp),
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = isDark ? _textPrimDark : _textPrimLight;
    final border = isDark ? _borderDark : _borderLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isDark ? _textTertDark : _textTertLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr('sign_out'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _primary,
              fontFamily: 'PoppinsSB',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('want_to_sign_out'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: textPrim,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    tr('cancel'),
                    style: TextStyle(
                      color: textPrim,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await sp.userSignOut();
                    Get.back();
                    Get.offNamed(Routes.login);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    tr('yes_sign_out'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
