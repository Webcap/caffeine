import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/premium_plan.dart';
import 'app_dependency_provider.dart';
import '../utils/constant.dart';
import '../services/purchase_service.dart';

class PremiumProvider extends ChangeNotifier {
  final AppDependencyProvider appDependencyProvider;

  PremiumProvider(this.appDependencyProvider);

  List<PremiumPlan> _plans = [];
  List<PremiumPlan> get plans => _plans;

  List<PremiumFeature> _features = [];
  List<PremiumFeature> get features => _features;

  List<Package> _packages = [];
  List<Package> get packages => _packages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> fetchPremiumData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch Entitlement Status
      _isPremium = await PurchaseService.isPremium();
      if (_isPremium) {
        appDependencyProvider.enableADS = false;
      }

      // 2. Fetch Offerings from RevenueCat
      final offerings = await PurchaseService.getOfferings();
      if (offerings != null && offerings.current != null) {
        _packages = offerings.current!.availablePackages;
      }

      // 3. Fetch Plans & Features from Metadata API
      String baseUrl = appDependencyProvider.caffeineAPIURL.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      final plansResponse = await http.get(Uri.parse('$baseUrl/plans'), headers: caffeineApiHeaders);
      final featuresResponse =
          await http.get(Uri.parse('$baseUrl/premium-features'), headers: caffeineApiHeaders);

      if (plansResponse.statusCode == 200 &&
          featuresResponse.statusCode == 200) {
        final List<dynamic> plansJson = jsonDecode(plansResponse.body);
        final List<dynamic> featuresJson = jsonDecode(featuresResponse.body);

        _plans = plansJson.map((json) => PremiumPlan.fromJson(json)).toList();
        _features =
            featuresJson.map((json) => PremiumFeature.fromJson(json)).toList();
      } else {
        _error =
            'Failed to load metadata: ${plansResponse.statusCode} / ${featuresResponse.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[PremiumProvider] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchasePackage(Package package) async {
    _isLoading = true;
    notifyListeners();
    final success = await PurchaseService.purchasePackage(package);
    if (success) {
      _isPremium = true;
      appDependencyProvider.enableADS = false;
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    _isPremium = await PurchaseService.restorePurchases();
    if (_isPremium) {
      appDependencyProvider.enableADS = false;
    }
    _isLoading = false;
    notifyListeners();
  }
}
