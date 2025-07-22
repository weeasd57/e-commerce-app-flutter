import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

/// مؤشر عدم الاتصال الذي يظهر في أعلى التطبيق
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        if (!connectivityProvider.showOfflineIndicator) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: connectivityProvider.isOnline 
              ? Colors.green.shade600 
              : Colors.red.shade600,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  connectivityProvider.isOnline 
                    ? Icons.wifi 
                    : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  connectivityProvider.isOnline 
                    ? 'تم استعادة الاتصال' 
                    : 'لا يوجد اتصال بالإنترنت',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!connectivityProvider.isOnline) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showOfflineDialog(context),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// عرض نافذة معلومات حول عدم الاتصال
  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const OfflineInfoDialog();
      },
    );
  }
}

/// نافذة معلومات عدم الاتصال
class OfflineInfoDialog extends StatelessWidget {
  const OfflineInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'عدم الاتصال بالإنترنت',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'يمكنك الاستمرار في استخدام التطبيق بوظائف محدودة:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: Icons.image,
                text: 'عرض الصور المحفوظة',
                available: true,
              ),
              _buildFeatureItem(
                icon: Icons.shopping_cart,
                text: 'عرض السلة المحفوظة',
                available: true,
              ),
              _buildFeatureItem(
                icon: Icons.favorite,
                text: 'عرض المفضلة المحفوظة',
                available: true,
              ),
              _buildFeatureItem(
                icon: Icons.sync,
                text: 'تحديث البيانات',
                available: false,
              ),
              _buildFeatureItem(
                icon: Icons.payment,
                text: 'إتمام الطلبات',
                available: false,
              ),
              const SizedBox(height: 16),
              Text(
                'الحالة: ${connectivityProvider.statusMessage}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                connectivityProvider.checkConnectivity();
              },
              child: const Text('إعادة المحاولة'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool available,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: available ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر صغير للاتصال يمكن استخدامه في أي مكان
class MiniConnectivityIndicator extends StatelessWidget {
  final bool showText;
  final double iconSize;

  const MiniConnectivityIndicator({
    super.key,
    this.showText = true,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        if (connectivityProvider.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: iconSize,
              ),
              if (showText) ...[
                const SizedBox(width: 4),
                Text(
                  'غير متصل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: iconSize - 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
