// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ecommerce App';

  @override
  String get changeName => 'Change Name';

  @override
  String get changePassword => 'Change Password';

  @override
  String get myOrders => 'My Orders';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get changeAppColor => 'Change App Color';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get signOut => 'Sign Out';

  @override
  String get noEmailFound => 'No email found for this account.';

  @override
  String get passwordResetLinkSent =>
      'Password reset link has been sent to your email.';

  @override
  String get userNotFound => 'User not found.';

  @override
  String get wrongPassword => 'Wrong password.';

  @override
  String get emailAlreadyInUse => 'Email already in use.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get weakPassword => 'Password is too weak.';

  @override
  String get operationNotAllowed => 'Operation not allowed.';

  @override
  String get userDisabled => 'User account has been disabled.';

  @override
  String get anUnknownErrorOccurred => 'An unknown error occurred.';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterName => 'Please enter your name.';

  @override
  String get pleaseEnterEmail => 'Please enter your email.';

  @override
  String get pleaseEnterPassword => 'Please enter your password.';

  @override
  String get passwordLengthError =>
      'Password must be at least 6 characters long.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get yourCartIsEmpty => 'Your cart is empty';

  @override
  String get total => 'Total';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryCost => 'Delivery Cost';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get categories => 'Categories';

  @override
  String get home => 'Home';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get nameUpdatedSuccessfully => 'Name updated successfully!';

  @override
  String errorUpdatingName(Object error) {
    return 'Error updating name: $error';
  }

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty.';

  @override
  String itemAddedToCart(Object name) {
    return 'Item $name added to cart';
  }

  @override
  String get addedToWishlist => 'Added to wishlist';

  @override
  String get removedFromWishlist => 'Removed from wishlist';

  @override
  String get welcome => 'Welcome';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginToAddCart =>
      'You must be logged in to add items to the cart.';

  @override
  String get tutorialTitle1 => 'Browse Our Amazing Products';

  @override
  String get tutorialDescription1 =>
      'Discover a wide range of products from various categories. Find exactly what you\'re looking for or explore new arrivals.';

  @override
  String get tutorialTitle2 => 'Easy and Secure Shopping Cart';

  @override
  String get tutorialDescription2 =>
      'Add your favorite items to the cart with a single tap. Enjoy a seamless and secure checkout process.';

  @override
  String get tutorialTitle3 => 'Personalized Profile and Orders';

  @override
  String get tutorialDescription3 =>
      'Manage your profile, track your orders, and keep a wishlist of your desired products all in one place.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get chooseAppColor => 'Choose App Color';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get loginToContinue => 'Log in to continue';

  @override
  String get createAccountToAccessFeatures =>
      'Create an account to access all features.';

  @override
  String get noProductsInCategory => 'No products in this category';

  @override
  String get noOrders => 'No orders yet.';

  @override
  String orderNumber(Object id) {
    return 'Order #: $id';
  }

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String orderTotal(Object currency, Object total) {
    return 'Total: $total $currency';
  }

  @override
  String get allProducts => 'All Products';

  @override
  String get filters => 'Filters';

  @override
  String get sortBy => 'Sort By';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get newest => 'Newest';

  @override
  String get onSale => 'On Sale';

  @override
  String get hotItems => 'Hot Items';

  @override
  String get newArrivals => 'New Arrivals';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get apply => 'Apply';

  @override
  String get search => 'Search';

  @override
  String get popularSearches => 'Popular Searches';

  @override
  String noResultsFound(Object searchQuery) {
    return 'No results found for \"$searchQuery\"';
  }

  @override
  String get sale => 'SALE';

  @override
  String get age => 'Age';

  @override
  String get quantity => 'Quantity';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get deleteConfirmation => 'Delete Confirmation';

  @override
  String get confirmDeleteOrder =>
      'Are you sure you want to delete this order?';

  @override
  String get delete => 'Delete';

  @override
  String get orderDeletedSuccess => 'Order deleted successfully';

  @override
  String get orderDeleteFailed => 'Failed to delete order';

  @override
  String get undo => 'Undo';

  @override
  String get orderConfirmedSuccess => 'Order confirmed successfully';

  @override
  String get orderConfirmationFailed => 'Error occurred. Please try again';

  @override
  String get orderInformation => 'Order Information';

  @override
  String get phone => 'Phone Number';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get pleaseEnterDeliveryAddress => 'Please enter your delivery address';

  @override
  String get confirmExitTitle => 'Confirm Exit';

  @override
  String get confirmExitContent => 'Are you sure you want to exit the app?';

  @override
  String get exit => 'Exit';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noProductsForCarousel => 'No products available for carousel';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get noProductsAvailable => 'No products available';
}
