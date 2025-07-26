import 'package:flutter/material.dart';
import 'package:ecommerce/pages/auth/login_page.dart';
import 'package:ecommerce/pages/auth/register_page.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class AuthPage extends StatefulWidget {
  final bool showLogin;
  const AuthPage({super.key, this.showLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late PageController _pageController;
  late bool _showLogin;

  @override
  void initState() {
    super.initState();
    _showLogin = widget.showLogin;
    _pageController = PageController(initialPage: _showLogin ? 0 : 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaPadding = MediaQuery.of(context).padding;
    final availableHeight =
        screenHeight - safeAreaPadding.top - safeAreaPadding.bottom;
    final localization = AppLocalizations.of(context)!;
    
    // تحديد الحد الأقصى للعرض على الشاشات الكبيرة
    final maxWidth = Responsive.isDesktop(context) 
        ? 600.0 
        : Responsive.isTablet(context) 
            ? 500.0 
            : screenWidth;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                  maxWidth: maxWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getPadding(context, 20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: Responsive.getHeight(context, availableHeight * 0.05)),
                      Image.asset(
                        'assets/images/logo.png',
                        height: Responsive.getHeight(context, 
                          Responsive.isMobile(context) ? availableHeight * 0.12 : 120),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 16)),
                      Text(
                        _showLogin
                            ? localization.welcomeBack
                            : localization.createNewAccount,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.getFontSize(context, 28),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.getHeight(context, 8)),
                      Text(
                        _showLogin
                            ? localization.loginToContinue
                            : localization.createAccountToAccessFeatures,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: Responsive.getFontSize(context, 16),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.getHeight(context, 32)),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: Responsive.isMobile(context) 
                              ? availableHeight * 0.5 
                              : 400,
                          maxHeight: availableHeight * 0.7,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getMargin(context, 16),
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Responsive.isDesktop(context) ? 30 : 25,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: Responsive.isDesktop(context) ? 15 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Responsive.isDesktop(context) ? 30 : 25,
                          ),
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _showLogin = index == 0;
                              });
                            },
                            children: [
                              LoginPage(onRegisterTap: () {
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }),
                              RegisterPage(onLoginTap: () {
                                _pageController.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 20)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
