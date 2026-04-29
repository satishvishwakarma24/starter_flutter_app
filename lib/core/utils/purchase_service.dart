import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// In-App Purchase Service
/// Handles: consumables, non-consumables, subscriptions
class PurchaseService extends ChangeNotifier {
  // ── Product IDs ──────────────────────────────────────────────────────────
  static const String kRemoveAds = 'remove_ads'; // non-consumable
  static const String kPremiumMonthly = 'premium_monthly'; // subscription
  static const String kPremiumYearly = 'premium_yearly'; // subscription
  static const String kCoinsPack100 = 'coins_100'; // consumable

  static const Set<String> _productIds = {
    kRemoveAds,
    kPremiumMonthly,
    kPremiumYearly,
    kCoinsPack100,
  };

  // ── State ────────────────────────────────────────────────────────────────
  List<ProductDetails> _products = [];
  bool _isPurchasing = false;
  bool _isPremium = false;
  bool _adsRemoved = false;

  List<ProductDetails> get products => _products;
  bool get isPurchasing => _isPurchasing;
  bool get isPremium => _isPremium;
  bool get adsRemoved => _adsRemoved;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ── Initialize ───────────────────────────────────────────────────────────
  Future<void> initialize() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      debugPrint('❌ IAP not available on this device');
      return;
    }

    // Listen to purchase updates
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (err) => debugPrint('❌ IAP stream error: $err'),
    );

    await _loadProducts();
    await _restorePurchases();
  }

  Future<void> _loadProducts() async {
    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('❌ Product query error: ${response.error}');
    }
    _products = response.productDetails;
    notifyListeners();
    debugPrint('✅ Loaded ${_products.length} products');
  }

  // ── Purchase ─────────────────────────────────────────────────────────────
  Future<void> purchase(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    _isPurchasing = true;
    notifyListeners();

    try {
      if (product.id == kCoinsPack100) {
        await InAppPurchase.instance
            .buyConsumable(purchaseParam: purchaseParam);
      } else {
        await InAppPurchase.instance
            .buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      _isPurchasing = false;
      notifyListeners();
    }
  }

  // ── Restore ──────────────────────────────────────────────────────────────
  Future<void> _restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> restorePurchases() => _restorePurchases();

  // ── Handle Updates ───────────────────────────────────────────────────────
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
    _isPurchasing = false;
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _verifyAndGrant(purchase);
        break;
      case PurchaseStatus.error:
        debugPrint('❌ Purchase failed: ${purchase.error}');
        break;
      case PurchaseStatus.canceled:
        debugPrint('🚫 Purchase canceled: ${purchase.productID}');
        break;
      case PurchaseStatus.pending:
        debugPrint('⏳ Purchase pending: ${purchase.productID}');
        break;
    }

    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  void _verifyAndGrant(PurchaseDetails purchase) {
    // TODO: For production, verify receipt with your backend before granting.
    switch (purchase.productID) {
      case kRemoveAds:
        _adsRemoved = true;
        break;
      case kPremiumMonthly:
      case kPremiumYearly:
        _isPremium = true;
        break;
      case kCoinsPack100:
        // TODO: Credit coins to user account
        debugPrint('🪙 100 coins granted');
        break;
    }
    notifyListeners();
  }

  // ── Dispose ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
