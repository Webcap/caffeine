import 'package:reelriot/provider/premium_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _C {
  static const primary = Color(0xFFDC2626);
  static const secondary = Color(0xFF7C3AED);
  static const accent = Color(0xFFFACC15); // Gold for premium
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const borderDark = Color(0x14FFFFFF);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
}

IconData getIconData(String name) {
  switch (name) {
    case 'ban':
      return FontAwesomeIcons.ban;
    case 'football':
      return FontAwesomeIcons.football;
    case 'headset':
      return FontAwesomeIcons.headset;
    default:
      return Icons.star_rounded;
  }
}

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  State<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PremiumProvider>();
      await provider.fetchPremiumData();
      if (provider.plans.isNotEmpty) {
        setState(() {
          // Default to popular plan, or the first one
          final popular = provider.plans.firstWhere((p) => p.isPopular,
              orElse: () => provider.plans.first);
          _selectedPlanId = popular.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumProvider = context.watch<PremiumProvider>();

    return Scaffold(
      backgroundColor: _C.bgCanvasDark,
      body: Stack(
        children: [
          // ── Background Glow ───────────────────────────────────────────────
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.secondary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.primary.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _C.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _C.accent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star_rounded, color: _C.accent, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: _C.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // ── Title & Intro ─────────────────────────────────────
                        const Text(
                          'Experience Reelriot\nWithout Limits',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'PoppinsSB',
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Join thousands of premium members and get the ultimate streaming experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _C.textSecDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 40),

                        if (premiumProvider.appDependencyProvider.disableRevenueCat)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _C.primary.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: _C.primary),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Premium billing is temporarily disabled. Please check back later.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (premiumProvider.isLoading)
                          const Center(
                              child: CircularProgressIndicator(
                                  color: _C.primary))
                        else if (premiumProvider.error != null)
                          Center(
                            child: Text(
                              'Error loading plans: ${premiumProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        else ...[
                          // ── Feature List ─────────────────────────────────────
                          ...premiumProvider.features.map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _FeatureItem(
                                  icon: getIconData(f.iconName),
                                  title: f.title,
                                  description: f.description,
                                  color: Color(int.parse(
                                      f.colorHex.replaceFirst('#', '0xFF'))),
                                ),
                              )),

                          const SizedBox(height: 50),

                          // ── Plan Selector ────────────────────────────────────
                          ...premiumProvider.plans.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _PlanCard(
                                  title: p.title,
                                  price: p.price,
                                  period: p.period,
                                  isPopular: p.isPopular,
                                  saveText: p.saveText,
                                  isSelected: _selectedPlanId == p.id,
                                  onTap: () {
                                    setState(() {
                                      _selectedPlanId = p.id;
                                    });
                                  },
                                ),
                              )),
                        ],

                        const SizedBox(height: 40),
                        
                        // ── Bottom CTA ──────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: FilledButton(
                            onPressed: premiumProvider.isPremium ||
                                    premiumProvider.isLoading
                                ? null
                                : () async {
                                    if (_selectedPlanId == null) return;
                                    final selectedPlan = premiumProvider.plans
                                        .firstWhere(
                                            (p) => p.id == _selectedPlanId);

                                    // Find matching package
                                    final package = premiumProvider.packages
                                        .where((pkg) =>
                                            pkg.identifier ==
                                            selectedPlan.revenueCatIdentifier)
                                        .firstOrNull;

                                    if (package != null) {
                                      final success = await premiumProvider
                                          .purchasePackage(package);
                                      if (success) {
                                        Get.snackbar(
                                          'Success',
                                          'You are now a Premium member!',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      }
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Selected plan is not available for purchase.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: premiumProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.black),
                                  )
                                : Text(
                                    premiumProvider.isPremium
                                        ? 'Premium Active'
                                        : 'Unlock Premium Now',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'PoppinsSB',
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: premiumProvider.isLoading
                              ? null
                              : () async {
                                  await premiumProvider.restorePurchases();
                                  if (premiumProvider.isPremium) {
                                    Get.snackbar(
                                      'Success',
                                      'Premium status restored!',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Notice',
                                      'No active subscription found.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          child: Text(
                            'Restore Purchase',
                            style: TextStyle(
                              color: _C.textSecDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: _C.textSecDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    required this.isSelected,
    required this.onTap,
    this.saveText,
  });

  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onTap;
  final String? saveText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _C.bgSurfaceDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _C.primary : _C.borderDark,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (saveText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _C.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            saveText!,
                            style: const TextStyle(
                              color: _C.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Full access to all features',
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.textSecDark,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: _C.textSecDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
