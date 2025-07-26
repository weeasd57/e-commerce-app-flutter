import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterPage({super.key, required this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
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
            SizedBox(height: Responsive.getHeight(context, 20)),
            // حقل الاسم
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localization.name,
                labelStyle: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.isDesktop(context) ? 20 : 15,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localization.pleaseEnterName;
                }
                return null;
              },
            ),
            SizedBox(height: Responsive.getHeight(context, 16)),

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
                if (value.length < 6) {
                  return localization.passwordLengthError;
                }
                return null;
              },
            ),
            SizedBox(height: Responsive.getHeight(context, 24)),

            // زر إنشاء حساب
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AuthProvider>().signUp(
                                _emailController.text,
                                _passwordController.text,
                                _nameController.text,
                                context,
                              );
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
                      localization.createAccount,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            SizedBox(height: Responsive.getHeight(context, 20)),

            // رابط تسجيل الدخول
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  localization.alreadyHaveAccount,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14),
                  ),
                ),
                TextButton(
                  onPressed: widget.onLoginTap,
                  child: Text(
                    localization.signIn,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.getHeight(context, 20)),
          ],
        ),
      ),
    );
  }
}
