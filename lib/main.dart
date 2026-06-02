import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:toastification/toastification.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/locale_provider.dart';
// import 'config/firebase_service.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase init
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // // Ads init (Google Mobile Ads SDK)
  // await AdsService.instance.initialize();

  // // Notifications (Firebase FCM + OneSignal)
  // await NotificationService.instance.initialize();

  FlutterNativeSplash.remove();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          // ChangeNotifierProvider(create: (_) => PurchaseService()..initialize()),
        ],
          child: const ToastificationWrapper(
            child: App(),
          ),
      ),
    ),
  );
}
