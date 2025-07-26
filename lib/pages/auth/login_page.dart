import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/navigation_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;

  const LoginPage({super.key, required this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.getPadding(context, 20)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // إضافة مساحة إضافية في الأعلى للشاشات الصغيرة
            SizedBox(height: Responsive.getHeight(context, 20)),
            
            // حقل البريد الإلكتروني
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: localization.email,
                labelStyle: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.isDesktop(context) ? 20 : 15,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  size: Responsive.getFontSize(context, 24),
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.getPadding(context, 16),
                  vertical: Responsive.getPadding(context, 16),
                ),
              ),
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 16),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localization.pleaseEnterEmail;
                }
                return null;
              },
            ),
            SizedBox(height: Responsive.getHeight(context, 16)),
            
            // حقل كلمة المرور
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: localization.password,
                labelStyle: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.isDesktop(context) ? 20 : 15,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: Responsive.getFontSize(context, 24),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: Responsive.getFontSize(context, 24),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.getPadding(context, 16),
                  vertical: Responsive.getPadding(context, 16),
                ),
              ),
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 16),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localization.pleaseEnterPassword;
                }
                return null;
              },
            ),
            SizedBox(height: Responsive.getHeight(context, 24)),
            
            // زر تسجيل الدخول
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AuthProvider>().signIn(
                                _emailController.text,
                                _passwordController.text,
                                context,
                              );
                          if (mounted) {
                            final cartProvider = context.read<CartProvider>();
                            final navigationProvider =
                                context.read<NavigationProvider>();

                            cartProvider.onLoginComplete(context);
                            if (cartProvider.returnToIndex != null) {
                              navigationProvider
                                  .setPage(cartProvider.returnToIndex!);
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  double.infinity, 
                  Responsive.getHeight(context, 50),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.isDesktop(context) ? 20 : 15,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.getPadding(context, 12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: Responsive.getHeight(context, 20),
                      width: Responsive.getWidth(context, 20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      localization.signIn,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            SizedBox(height: Responsive.getHeight(context, 20)),
            
            // زر تسجيل الدخول باستخدام Google
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        await context
                            .read<AuthProvider>()
                            .signInWithGoogle(context);
                        if (mounted) {
                          context.read<NavigationProvider>().setPage(0);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  double.infinity, 
                  Responsive.getHeight(context, 50),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.isDesktop(context) ? 20 : 15,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.getPadding(context, 12),
                ),
              ),
              icon: Image.asset(
                'assets/images/google_logo.png',
                height: Responsive.getHeight(context, 24),
              ),
              label: Text(
                localization.signInWithGoogle,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: Responsive.getHeight(context, 20)),
            
            // رابط إنشاء حساب جديد
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  localization.dontHaveAccount,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14),
                  ),
                ),
                TextButton(
                  onPressed: widget.onRegisterTap,
                  child: Text(
                    localization.createAccount,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            // مساحة إضافية في الأسفل
            SizedBox(height: Responsive.getHeight(context, 20)),
          ],
        ),
      ),
    );
  }
}
