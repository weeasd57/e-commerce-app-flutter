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
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: OfflineCachedImage(
                    imageUrl: category.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                    cacheKey: 'category_${category.id}_${category.imageUrl?.hashCode ?? 0}',
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    showOfflineIndicator: false,
                    placeholder: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                    errorWidget: _buildDefaultIcon(),
                    offlineWidget: _buildDefaultIcon(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
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
