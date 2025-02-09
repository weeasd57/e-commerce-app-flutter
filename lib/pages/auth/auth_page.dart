import 'package:flutter/material.dart';
import 'package:ecommerce/pages/auth/login_page.dart';
import 'package:ecommerce/pages/auth/register_page.dart';

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
    final safeAreaPadding = MediaQuery.of(context).padding;
    final availableHeight =
        screenHeight - safeAreaPadding.top - safeAreaPadding.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: availableHeight * 0.05),
                  Image.asset(
                    'assets/images/logo.png',
                    height: availableHeight * 0.15,
                  ),
                  SizedBox(height: availableHeight * 0.02),
                  Text(
                    _showLogin ? 'مرحباً بعودتك' : 'إنشاء حساب جديد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showLogin
                        ? 'سجل دخولك للمتابعة'
                        : 'قم بإنشاء حساب للوصول إلى جميع المميزات',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: availableHeight * 0.05),
                  Container(
                    height: availableHeight * 0.6,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
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
                  SizedBox(height: availableHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
