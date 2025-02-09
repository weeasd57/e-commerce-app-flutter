import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/pages/auth/auth_page.dart';
import 'package:ecommerce/providers/theme_provider.dart';
import 'package:ecommerce/pages/wishlist_page.dart';
import 'package:ecommerce/pages/color_settings_page.dart';

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
                        ? NetworkImage(user.photoURL!)
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
              title: 'تغيير الاسم',
              onTap: () {
                // Handle name change
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.lock_outline,
              title: 'تغيير كلمة المرور',
              onTap: () {
                // Handle password change
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'طلباتي',
              onTap: () {
                // Navigate to orders
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.favorite_border,
              title: 'المفضلة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.color_lens_outlined,
              title: 'تغيير لون التطبيق',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ColorSettingsPage(),
                  ),
                );
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => SwitchListTile(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الليلي'),
              ),
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'المساعدة',
              onTap: () {
                // Show help
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.info_outline,
              title: 'من نحن',
              onTap: () {
                // Show about
              },
            ),
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
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white),
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
}
