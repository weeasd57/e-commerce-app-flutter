import 'package:ecommerce/pages/categories_page.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'category_provider.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  Widget get currentPage => _pages[_currentIndex];
  int get currentIndex => _currentIndex;

  String currentPageTitle(AppLocalizations localization) {
    switch (_currentIndex) {
      case 0:
        return localization.home;
      case 1:
        return localization.categories;
      case 2:
        return localization.cart;
      case 3:
        return localization.profile;
      default:
        return '';
    }
  }

  List<BottomNavigationBarItem> getNavigationItems(
      AppLocalizations localization) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: localization.home,
        backgroundColor: Colors.transparent,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.grid_view_outlined),
        activeIcon: const Icon(Icons.grid_view),
        label: localization.categories,
        backgroundColor: Colors.transparent,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.shopping_cart_outlined),
        activeIcon: const Icon(Icons.shopping_cart),
        label: localization.cart,
        backgroundColor: Colors.transparent,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: localization.profile,
        backgroundColor: Colors.transparent,
      ),
    ];
  }

  void setPage(int index, {BuildContext? context}) {
    int previousIndex = _currentIndex;
    _currentIndex = index;
    
    // إذا انتقل المستخدم إلى الصفحة الرئيسية أو صفحة الفئات، تحديث الفئات إذا لزم الأمر
    if (context != null && (index == 0 || index == 1) && previousIndex != index) {
      _refreshCategoriesIfNeeded(context);
    }
    
    notifyListeners();
  }

  // دعم التعامل مع القيم القديمة بدون context
  void setPageIndex(int index) {
    setPage(index);
  }
  
  // تحديث الفئات تلقائياً عند العودة للصفحة الرئيسية
  void _refreshCategoriesIfNeeded(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final categoryProvider = context.read<CategoryProvider>();
        categoryProvider.refreshIfNeeded();
      }
    });
  }
}
