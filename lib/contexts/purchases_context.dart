import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const String REVENUECAT_API_KEY_IOS = 'YOUR_IOS_API_KEY';
const String REVENUECAT_API_KEY_ANDROID = 'YOUR_ANDROID_API_KEY';
const String ENTITLEMENT_ID = 'premium_access';

// 🔥 Riverpod provider for managing purchases
final purchasesProvider =
    StateNotifierProvider<PurchasesNotifier, PurchasesState>((ref) {
  return PurchasesNotifier();
});

// 📌 Model for managing purchase state
class PurchasesState {
  final CustomerInfo? customerInfo;
  final bool isPremium;
  final bool loading;

  PurchasesState({
    required this.customerInfo,
    required this.isPremium,
    required this.loading,
  });

  PurchasesState copyWith({
    CustomerInfo? customerInfo,
    bool? isPremium,
    bool? loading,
  }) {
    return PurchasesState(
      customerInfo: customerInfo ?? this.customerInfo,
      isPremium: isPremium ?? this.isPremium,
      loading: loading ?? this.loading,
    );
  }
}

// 🔥 Notifier for handling RevenueCat logic
class PurchasesNotifier extends StateNotifier<PurchasesState> {
  PurchasesNotifier()
      : super(PurchasesState(
            customerInfo: null, isPremium: false, loading: true)) {
    _initRevenueCat();
    _listenAuthChanges();
  }

  Future<void> _initRevenueCat() async {
    try {
      final apiKey =
          Platform.isIOS ? REVENUECAT_API_KEY_IOS : REVENUECAT_API_KEY_ANDROID;
      await Purchases.configure(PurchasesConfiguration(apiKey));
      if (kDebugMode) {
        print('✅ RevenueCat initialized');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error initializing RevenueCat: $error');
      }
    }
  }

  // 🔥 Listen to Firebase Auth and sync RevenueCat
  void _listenAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await Purchases.logIn(user.uid);
        _fetchCustomerInfo();
      } else {
        await Purchases.logOut();
        state = state.copyWith(customerInfo: null, isPremium: false);
      }
    });
  }

  // 🔥 Fetch customer info from RevenueCat
  Future<void> _fetchCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPremium = info.entitlements.active.containsKey(ENTITLEMENT_ID);
      state = state.copyWith(customerInfo: info, isPremium: isPremium);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error fetching customer info: $error');
      }
    }
  }

  /// **Fetch & Update Customer Info**
  Future<void> _updateCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final bool isPremium =
          customerInfo.entitlements.active.containsKey(ENTITLEMENT_ID);

      state = state.copyWith(customerInfo: customerInfo, isPremium: isPremium);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching customer info: $e');
      }
    }
  }

  // 🔥 Purchase a package
  Future<void> purchasePackage(Package pack) async {
    try {
      state = state.copyWith(loading: true);
      final result = await Purchases.purchasePackage(pack);

      await _updateCustomerInfo(); // Update state after purchase
      // final isPremium =
      //     result.customerInfo.entitlements.active.containsKey(ENTITLEMENT_ID);
      // state = state.copyWith(
      //     customerInfo: result.customerInfo, isPremium: isPremium);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error purchasing package: $error');
      }
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  // 🔥 Restore purchases
  Future<void> restorePurchases() async {
    try {
      state = state.copyWith(loading: true);
      final restoredInfo = await Purchases.restorePurchases();
      await _updateCustomerInfo();
      // final isPremium =
      //     restoredInfo.entitlements.active.containsKey(ENTITLEMENT_ID);
      // state = state.copyWith(customerInfo: restoredInfo, isPremium: isPremium);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error restoring purchases: $error');
      }
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

/*
final purchasesProvider = Provider.autoDispose<PurchasesProvider>((ref) {
  return PurchasesProvider(ref);
});

class PurchasesProvider {
  final WidgetRef _ref;
  late final Purchases _purchases;
  late final User? _user;
  late CustomerInfo? _customerInfo;
  bool _loading = true;

  PurchasesProvider(this._ref);

  Future<void> init() async {
    try {
      final apiKey = _ref.watch(platformProvider).platform == TargetPlatform.iOS
          ? REVENUECAT_API_KEY_IOS
          : REVENUECAT_API_KEY_ANDROID;
      await Purchases.configure(apiKey: apiKey);
      print('RevenueCat configured successfully');
    } catch (error) {
      print('Error configuring RevenueCat: $error');
    }
  }

  void listenForAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _logIn(user.uid);
        updateCustomerInfo();
      } else {
        _logOut();
        _customerInfo = null;
      }
    });
  }

  Future<void> _logIn(String uid) async {
    await Purchases.logIn(userId: uid);
  }

  Future<void> _logOut() async {
    await Purchases.logOut();
  }

  Future<void> updateCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _ref.read(customerInfoProvider.notifier).state = _customerInfo;
    } catch (error) {
      print('Error fetching customer info: $error');
    }
  }

  bool get isPremium {
    return _customerInfo?.entitlements.isActive(ENTITLEMENT_ID) ?? false;
  }

  Future<CustomerInfo> purchasePackage(Package pack) async {
    try {
      _ref.read(loadingProvider.notifier).state = true;
      final result = await Purchases.purchasePackage(pack);
      _customerInfo = result.customerInfo;
      _ref.read(customerInfoProvider.notifier).state = _customerInfo;
      return result.customerInfo;
    } catch (error) {
      if (!error.userCancelled) {
        print('Error purchasing package: $error');
        rethrow;
      }
    } finally {
      _ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      _ref.read(loadingProvider.notifier).state = true;
      final result = await Purchases.restorePurchases();
      _customerInfo = result.customerInfo;
      _ref.read(customerInfoProvider.notifier).state = _customerInfo;
      return result.customerInfo;
    } catch (error) {
      print('Error restoring purchases: $error');
      rethrow;
    } finally {
      _ref.read(loadingProvider.notifier).state = false;
    }
  }
}

final customerInfoProvider = StateProvider<CustomerInfo?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => true);
*/
