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
import 'package:ecommerce/providers/enhanced_product_provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/navigation_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/providers/order_stream_provider.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/providers/connectivity_provider.dart';
import 'package:ecommerce/widgets/exit_dialog.dart';
import 'package:ecommerce/widgets/offline_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/gradient_app_bar.dart';
import 'widgets/gradient_bottom_nav_bar.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecommerce/pages/landing_page.dart';
import 'package:ecommerce/pages/search_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:flutter/services.dart';
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.initialize(); // Initialize Supabase

  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderStreamProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
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
    // Start real-time updates after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRealTimeUpdates();
    });
  }
  
  void _startRealTimeUpdates() {
    // Fetch initial data for products and categories
    final productProvider = context.read<EnhancedProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    productProvider.fetchProducts();
    categoryProvider.fetchCategories();
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
            locale: languageProvider.locale,
          ),
          darkTheme: AppThemes.getTheme(
            isDark: true,
            primaryColor: primaryColor,
            gradientColors: gradientColors,
            locale: languageProvider.locale,
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
          // إضافة دعم RTL للنصوص العربية
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.locale.languageCode == 'ar' 
                  ? TextDirection.rtl 
                  : TextDirection.ltr,
              child: child!,
            );
          },
          home: _isLandingPageSeen
              ? PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    final shouldExit = await ExitDialog.show(context);
                    if (shouldExit == true) {
                      SystemNavigator.pop();
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
            actions: [
              const MiniConnectivityIndicator(showText: false),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                      context, CustomPageRoute(child: const SearchPage()));
                },
              ),
            ],
          );
        } else {
          appBar = AppBar(
            title: Text(navigationProvider.currentPageTitle(localization)),
            actions: [
              const MiniConnectivityIndicator(showText: false),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                      context, CustomPageRoute(child: const SearchPage()));
                },
              ),
            ],
          );
        }

        Widget bottomNav;
        if (isGradient) {
          bottomNav = GradientBottomNavBar(
            colors: selectedColor!.gradientColors!,
            items: navigationProvider.getNavigationItems(localization),
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) => navigationProvider.setPage(index, context: context),
          );
        } else {
          bottomNav = BottomNavigationBar(
            items: navigationProvider.getNavigationItems(localization),
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) => navigationProvider.setPage(index, context: context),
            type: BottomNavigationBarType.fixed,
          );
        }

        return Scaffold(
          appBar: appBar,
          body: Stack(
            children: [
              // محتوى الصفحة
              Positioned.fill(
                child: navigationProvider.currentPage,
              ),
              // مؤشر عدم الاتصال
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: const OfflineIndicator(),
              ),
            ],
          ),
          bottomNavigationBar: bottomNav,
        );
      },
    );
  }
}

// The SearchPage class will be in lib/pages/search_page.dart
// class SearchPage extends StatelessWidget {
//   const SearchPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Search Page'));
//   }
// }


