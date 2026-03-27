import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:caffiene/utils/constant.dart';

class PurchaseService {
  static bool _disabled = false;
  static String _entitlementId = 'premium';

  static Future<void> init(String? appUserID,
      {required String androidKey,
      required String iosKey,
      String entitlementId = 'premium',
      bool disabled = false}) async {
    _disabled = disabled;
    if (_disabled) {
      debugPrint('[PurchaseService] Initialization skipped: Service disabled.');
      return;
    }
    _entitlementId = entitlementId;
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      if (androidKey.isEmpty) {
        debugPrint('[PurchaseService] Android API Key is empty');
        return;
      }
      configuration = PurchasesConfiguration(androidKey);
    } else {
      if (iosKey.isEmpty) {
        debugPrint('[PurchaseService] iOS API Key is empty');
        return;
      }
      configuration = PurchasesConfiguration(iosKey);
    }

    if (appUserID != null) {
      configuration.appUserID = appUserID;
    }

    await Purchases.configure(configuration);
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    if (_disabled) return null;
    try {
      return await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      debugPrint('[PurchaseService] Error fetching customer info: $e');
      return null;
    }
  }

  static Future<Offerings?> getOfferings() async {
    if (_disabled) return null;
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      debugPrint('[PurchaseService] Error fetching offerings: $e');
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    if (_disabled) return false;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo.entitlements.all[_entitlementId]?.isActive ??
          false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[PurchaseService] Purchase error: $e');
      }
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    if (_disabled) return false;
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      debugPrint('[PurchaseService] Restore error: $e');
      return false;
    }
  }

  static Future<bool> isPremium() async {
    if (_disabled) return false;
    final info = await getCustomerInfo();
    return info?.entitlements.all[_entitlementId]?.isActive ?? false;
  }
}
