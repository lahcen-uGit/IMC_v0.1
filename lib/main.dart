import 'package:imc_secured/screens/auth/forgot_password_screen.dart' as custom_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ForgotPasswordScreen;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'bmi_history.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'locale_notifier.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    final localeNotifier = LocaleNotifier();
    await localeNotifier.loadLocale(); // Load saved language

    runApp(
      ChangeNotifierProvider.value(
        value: localeNotifier,
        child: const MyApp(),
      ),
    );
  } catch (err) {
    print("Firebase initialization failed: $err");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => Home()),
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const custom_auth.ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => BMIHistoryScreen(),
      ),
    ],
  );

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp.router(
      routerConfig: _router,
      locale: localeNotifier.locale,
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      builder: (context, child) {
        final isRTL = localeNotifier.locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}