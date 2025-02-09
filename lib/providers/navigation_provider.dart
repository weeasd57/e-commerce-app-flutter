import 'package:ecommerce/pages/categories_page.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
      backgroundColor: Colors.transparent,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.grid_view_outlined),
      activeIcon: Icon(Icons.grid_view),
      label: 'الاقسام',
      backgroundColor: Colors.transparent,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      activeIcon: Icon(Icons.shopping_cart),
      label: 'السلة',
      backgroundColor: Colors.transparent,
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'حسابي',
      backgroundColor: Colors.transparent,
    ),
  ];

  Widget get currentPage => _pages[_currentIndex];
  int get currentIndex => _currentIndex;
  List<BottomNavigationBarItem> get navigationItems => _navigationItems;

  String get currentPageTitle {
    switch (_currentIndex) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'الاقسام';
      case 2:
        return 'السلة';
      case 3:
        return 'حسابي';
      default:
        return '';
    }
  }

  void setPage(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
