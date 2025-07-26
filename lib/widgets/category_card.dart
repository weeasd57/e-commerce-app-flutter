import 'package:flutter/material.dart';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/widgets/offline_cached_image_provider.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: OfflineCachedImage(
                      imageUrl: category.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      cacheKey:
                          'category_${category.id}_${category.imageUrl?.hashCode ?? 0}',
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      showOfflineIndicator: false,
                      placeholder: Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: _buildDefaultIcon(),
                      offlineWidget: _buildDefaultIcon(),
                    ),
                  ),
                ),
              ),

              // Category name section
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Center(
                    child: Text(
                      category.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Builder(
      builder: (context) {
        IconData iconData;

        // تحديد الأيقونة المناسبة حسب اسم الفئة
        switch (category.name.toLowerCase()) {
          case 'public':
            iconData = Icons.public;
            break;
          case 'المدارس':
          case 'school':
          case 'schools':
            iconData = Icons.school;
            break;
          case 'المنزل والحديقة':
          case 'home':
          case 'home and garden':
            iconData = Icons.home;
            break;
          case 'الملابس':
          case 'clothes':
          case 'clothing':
            iconData = Icons.checkroom;
            break;
          case 'الإلكترونيات':
          case 'electronics':
            iconData = Icons.devices;
            break;
          case 'الكتب':
          case 'books':
            iconData = Icons.book;
            break;
          case 'الرياضة':
          case 'sports':
            iconData = Icons.sports;
            break;
          case 'الألعاب':
          case 'games':
          case 'toys':
            iconData = Icons.games;
            break;
          default:
            iconData = Icons.category;
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.3),
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Icon(
            iconData,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}
