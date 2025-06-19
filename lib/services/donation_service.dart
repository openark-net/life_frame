import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:talker/talker.dart';

enum DonationStatus { idle, loading, success, error, cancelled }

class InAppPurchaseService extends GetxService {
  static const String donation1CAD = 'donation_1_cad';
  static const String donation5CAD = 'donation_5_cad';
  static const String donation10CAD = 'donation_10_cad';
  static const String donation50CAD = 'donation_50_cad';

  static const List<String> productIds = [
    donation1CAD,
    donation5CAD,
    donation10CAD,
    donation50CAD,
  ];

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Talker _talker = Get.find<Talker>();

  final RxList<ProductDetails> availableProducts = <ProductDetails>[].obs;
  final Rx<DonationStatus> purchaseStatus = DonationStatus.idle.obs;
  final RxBool isStoreAvailable = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeService();
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  Future<void> initializeService() async {
    try {
      _talker.info('Initializing in-app purchase service');

      final bool available = await _inAppPurchase.isAvailable();
      isStoreAvailable.value = available;

      if (!available) {
        _talker.warning('In-app purchase store is not available');
        errorMessage.value = 'Store not available';
        return;
      }

      await _loadProducts();
      _setupPurchaseListener();

      isInitialized.value = true;
      _talker.info('In-app purchase service initialized successfully');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to initialize in-app purchase service');
      errorMessage.value = 'Failed to initialize payment system';
      isInitialized.value = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      _talker.info('Loading donation products');

      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds.toSet());

      if (response.error != null) {
        throw Exception('Failed to load products: ${response.error!.message}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        _talker.warning('Products not found: ${response.notFoundIDs}');
      }

      availableProducts.value = response.productDetails
        ..sort((a, b) => _extractPrice(a.id).compareTo(_extractPrice(b.id)));

      _talker.info('Loaded ${availableProducts.length} donation products');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to load products');
      throw Exception('Failed to load donation options');
    }
  }

  int _extractPrice(String productId) {
    switch (productId) {
      case donation1CAD:
        return 1;
      case donation5CAD:
        return 5;
      case donation10CAD:
        return 10;
      case donation50CAD:
        return 50;
      default:
        return 0;
    }
  }

  void _setupPurchaseListener() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        _talker.error('Purchase stream error: $error');
        _updatePurchaseStatus(DonationStatus.error, 'Payment system error');
      },
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      await _processPurchase(purchase);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    try {
      _talker.info(
        'Processing purchase: ${purchase.productID} - ${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _updatePurchaseStatus(DonationStatus.loading, '');
          break;

        case PurchaseStatus.purchased:
          await _completePurchase(purchase);
          break;

        case PurchaseStatus.error:
          _handlePurchaseError(purchase);
          break;

        case PurchaseStatus.canceled:
          _updatePurchaseStatus(DonationStatus.cancelled, 'Payment cancelled');
          break;

        case PurchaseStatus.restored:
          _talker.info('Purchase restored: ${purchase.productID}');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    } catch (e, st) {
      _talker.handle(e, st, 'Error processing purchase');
      _updatePurchaseStatus(DonationStatus.error, 'Failed to process payment');
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    try {
      _talker.info('Completing donation: ${purchase.productID}');

      // For consumable donations, we just mark as complete
      // In a real app, you might want to:
      // - Verify receipt with your backend
      // - Update user's donation history
      // - Send analytics events

      _updatePurchaseStatus(
        DonationStatus.success,
        'Thank you for your donation!',
      );

      _talker.info('Donation completed successfully: ${purchase.productID}');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to complete purchase');
      _updatePurchaseStatus(
        DonationStatus.error,
        'Failed to complete donation',
      );
    }
  }

  void _handlePurchaseError(PurchaseDetails purchase) {
    final errorMessage = purchase.error?.message ?? 'Payment failed';
    _talker.error('Purchase error for ${purchase.productID}: $errorMessage');
    _updatePurchaseStatus(DonationStatus.error, errorMessage);
  }

  void _updatePurchaseStatus(DonationStatus status, String message) {
    purchaseStatus.value = status;
    errorMessage.value = message;
  }

  Future<bool> makeDonation(String productId) async {
    try {
      if (!isInitialized.value || !isStoreAvailable.value) {
        _updatePurchaseStatus(
          DonationStatus.error,
          'Payment system not available',
        );
        return false;
      }

      final product = availableProducts.firstWhereOrNull(
        (p) => p.id == productId,
      );

      if (product == null) {
        _updatePurchaseStatus(
          DonationStatus.error,
          'Donation option not available',
        );
        return false;
      }

      _talker.info('Initiating donation: $productId');
      _updatePurchaseStatus(DonationStatus.loading, '');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _updatePurchaseStatus(
          DonationStatus.error,
          'Failed to initiate payment',
        );
        return false;
      }

      return true;
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to make donation');
      _updatePurchaseStatus(DonationStatus.error, 'Payment failed');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      _talker.info('Restoring purchases');
      await _inAppPurchase.restorePurchases();
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to restore purchases');
      _updatePurchaseStatus(
        DonationStatus.error,
        'Failed to restore purchases',
      );
    }
  }

  ProductDetails? getProductById(String productId) {
    return availableProducts.firstWhereOrNull((p) => p.id == productId);
  }

  String getDonationAmount(String productId) {
    final price = _extractPrice(productId);
    return '\$$price';
  }

  void clearError() {
    errorMessage.value = '';
    if (purchaseStatus.value == DonationStatus.error ||
        purchaseStatus.value == DonationStatus.cancelled) {
      purchaseStatus.value = DonationStatus.idle;
    }
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get isLoading => purchaseStatus.value == DonationStatus.loading;
  bool get canMakePurchases =>
      isInitialized.value &&
      isStoreAvailable.value &&
      availableProducts.isNotEmpty;
}
