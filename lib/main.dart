// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:ecommerce/firebase_options.dart';
import 'package:ecommerce/providers/color_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/theme_provider.dart';
import 'package:ecommerce/providers/language_provider.dart';
import 'package:ecommerce/utils/app_themes.dart';
import 'package:ecommerce/providers/product_provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/navigation_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/providers/order_provider.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/widgets/exit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/gradient_app_bar.dart';
import 'widgets/gradient_bottom_nav_bar.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecommerce/pages/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: MyApp(prefs: prefs),
    ),
  );
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLandingPageSeen = false;

  @override
  void initState() {
    super.initState();
    _loadLandingPageStatus();
  }

  Future<void> _loadLandingPageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLandingPageSeen = prefs.getBool('landingPageSeen') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageProvider, ColorProvider>(
      builder:
          (context, themeProvider, languageProvider, colorProvider, child) {
        final selectedOption = colorProvider.selectedColorOption;
        final primaryColor = selectedOption?.solidColor ?? Colors.blue;
        final gradientColors = selectedOption?.gradientColors;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          title: 'elkoshk',
          theme: AppThemes.getTheme(
            isDark: false,
            primaryColor: primaryColor,
            gradientColors: gradientColors,
          ),
          darkTheme: AppThemes.getTheme(
            isDark: true,
            primaryColor: primaryColor,
            gradientColors: gradientColors,
          ),
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _isLandingPageSeen
              ? PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (didPop) {
                      await ExitDialog.show(context);
                    }
                  },
                  child: const Home(),
                )
              : const LandingPage(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Consumer2<ColorProvider, NavigationProvider>(
      builder: (context, colorProvider, navigationProvider, _) {
        final selectedColor = colorProvider.selectedColorOption;
        final isGradient = selectedColor?.isGradient ?? false;

        PreferredSizeWidget appBar;
        if (isGradient) {
          appBar = GradientAppBar(
            colors: selectedColor!.gradientColors!,
            title: Text(navigationProvider.currentPageTitle(localization)),
          );
        } else {
          appBar = AppBar(
              title: Text(navigationProvider.currentPageTitle(localization)));
        }

        Widget bottomNav;
        if (isGradient) {
          bottomNav = GradientBottomNavBar(
            colors: selectedColor!.gradientColors!,
            items: navigationProvider.getNavigationItems(localization),
            currentIndex: navigationProvider.currentIndex,
            onTap: navigationProvider.setPage,
          );
        } else {
          bottomNav = BottomNavigationBar(
            items: navigationProvider.getNavigationItems(localization),
            currentIndex: navigationProvider.currentIndex,
            onTap: navigationProvider.setPage,
            type: BottomNavigationBarType.fixed,
          );
        }

        return Scaffold(
          appBar: appBar,
          body: navigationProvider.currentPage,
          bottomNavigationBar: bottomNav,
        );
      },
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Search Page'));
  }
}
