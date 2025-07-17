import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/pages/auth/auth_page.dart';
import 'package:ecommerce/providers/theme_provider.dart';
import 'package:ecommerce/pages/wishlist_page.dart';
import 'package:ecommerce/pages/color_settings_page.dart';
import 'package:ecommerce/pages/orders_page.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const AuthPage(showLogin: true);
        }
        return _buildProfile(context, authProvider);
      },
    );
  }

  Widget _buildProfile(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;
    final localization = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'new name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    user.email ?? 'aa@gmail.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: localization.changeName,
              onTap: () {
                _showChangeNameDialog(context, authProvider);
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.lock_outline,
              title: localization.changePassword,
              onTap: () async {
                final email = authProvider.user?.email;
                if (email == null || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.noEmailFound)),
                  );
                  return;
                }
                try {
                  await authProvider.resetPassword(email, context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.passwordResetLinkSent)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e as String)),
                  );
                }
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.shopping_bag_outlined,
              title: localization.myOrders,
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(child: const OrdersPage()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.favorite_border,
              title: localization.wishlist,
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(child: const WishlistPage()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.color_lens_outlined,
              title: localization.changeAppColor,
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: const ColorSettingsPage(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.language,
              title: localization.changeLanguage,
              onTap: () {
                _showLanguagePickerDialog(context);
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => SwitchListTile(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(localization.darkMode),
              ),
            ),
            // تم حذف خيارات المساعدة ومن نحن بناءً على طلب المستخدم
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => authProvider.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  localization.signOut,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangeNameDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController nameController =
        TextEditingController(text: authProvider.user?.displayName ?? '');
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.changeName),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: localization.enterNewName,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localization.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(localization.save),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  try {
                    await authProvider
                        .updateUserName(nameController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(localization.nameUpdatedSuccessfully)),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    String errorMessage = localization.anUnknownErrorOccurred;
                    if (e is Exception) {
                      errorMessage =
                          authProvider.getLocalizedErrorMessage(e, context);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.nameCannotBeEmpty)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePickerDialog(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final localization = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  languageProvider.setLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('العربية'),
                onTap: () {
                  languageProvider.setLanguage('ar');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localization.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
