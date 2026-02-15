import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const String _iosApiKey = 'appl_eFbAhvmBlBhhlNIGyWtFEzyRKvB';
  static const String _androidApiKey = 'goog_coxtzlwtgaylYVJjfnicpgjzOuG';

  static const String _entitlementId = 'simple handwriting chat Pro';

  final ValueNotifier<bool> isPro = ValueNotifier(false);

  Future<void> initialize() async {
    final config = PurchasesConfiguration(
      Platform.isIOS ? _iosApiKey : _androidApiKey,
    );
    await Purchases.configure(config);

    await _refreshStatus();

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateProStatus(customerInfo);
    });
  }

  Future<void> _refreshStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
    }
  }

  void _updateProStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[_entitlementId];
    isPro.value = entitlement?.isActive ?? false;
  }

  Future<Package?> getRemoveAdsPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.lifetime;
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  Future<bool> purchaseRemoveAds() async {
    final package = await getRemoveAdsPackage();
    if (package == null) return false;

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _updateProStatus(customerInfo);
      return isPro.value;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      // StoreKit may have completed the transaction even if RevenueCat threw.
      // Re-check customer info to see if the entitlement is now active.
      await _refreshStatus();
      return isPro.value;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);
      return isPro.value;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }
}
