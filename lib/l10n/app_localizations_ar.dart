// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيق التجارة الإلكترونية';

  @override
  String get changeName => 'تغيير الاسم';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get wishlist => 'المفضلة';

  @override
  String get changeAppColor => 'تغيير لون التطبيق';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get noEmailFound => 'لا يوجد بريد إلكتروني لهذا الحساب.';

  @override
  String get passwordResetLinkSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';

  @override
  String get userNotFound => 'لم يتم العثور على المستخدم.';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get emailAlreadyInUse => 'البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get invalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً.';

  @override
  String get operationNotAllowed => 'العملية غير مسموح بها.';

  @override
  String get userDisabled => 'تم تعطيل حساب المستخدم.';

  @override
  String get anUnknownErrorOccurred => 'حدث خطأ غير معروف.';

  @override
  String get name => 'الاسم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم.';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال البريد الإلكتروني.';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور.';

  @override
  String get passwordLengthError => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بواسطة جوجل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get yourCartIsEmpty => 'سلة التسوق فارغة';

  @override
  String get total => 'المجموع:';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get deliveryCost => 'تكلفة التوصيل';

  @override
  String get grandTotal => 'المجموع الكلي';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get categories => 'فئات';

  @override
  String get home => 'الرئيسية';

  @override
  String get cart => 'السلة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get enterNewName => 'أدخل الاسم الجديد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get nameUpdatedSuccessfully => 'تم تحديث الاسم بنجاح!';

  @override
  String errorUpdatingName(Object error) {
    return 'خطأ في تحديث الاسم: $error';
  }

  @override
  String get nameCannotBeEmpty => 'لا يمكن أن يكون الاسم فارغًا.';

  @override
  String itemAddedToCart(Object name) {
    return 'تم إضافة $name إلى السلة';
  }

  @override
  String get addedToWishlist => 'تمت الإضافة إلى المفضلة.';

  @override
  String get removedFromWishlist => 'تمت الإزالة من المفضلة.';

  @override
  String get welcome => 'أهلاً بك!';

  @override
  String get selectLanguage => 'اختر لغتك';

  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get loginToAddCart => 'يجب تسجيل الدخول لإضافة المنتجات إلى السلة.';

  @override
  String get tutorialTitle1 => 'تصفح منتجاتنا الرائعة';

  @override
  String get tutorialDescription1 =>
      'اكتشف مجموعة واسعة من المنتجات من فئات متنوعة. ابحث عن ما تريده بالضبط أو استكشف أحدث المنتجات.';

  @override
  String get tutorialTitle2 => 'عربة تسوق سهلة وآمنة';

  @override
  String get tutorialDescription2 =>
      'أضف منتجاتك المفضلة إلى السلة بنقرة واحدة. استمتع بعملية دفع سلسة وآمنة.';

  @override
  String get tutorialTitle3 => 'ملف شخصي وطلبات مخصصة';

  @override
  String get tutorialDescription3 =>
      'قم بإدارة ملفك الشخصي، وتتبع طلباتك، واحتفظ بقائمة أمنياتك لمنتجاتك المفضلة في مكان واحد.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get chooseAppColor => 'اختر لون التطبيق';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get createNewAccount => 'إنشاء حساب جديد';

  @override
  String get loginToContinue => 'سجل دخولك للمتابعة';

  @override
  String get createAccountToAccessFeatures =>
      'قم بإنشاء حساب للوصول إلى جميع المميزات.';

  @override
  String get noProductsInCategory => 'لا توجد منتجات في هذا القسم';

  @override
  String get noOrders => 'لا توجد طلبات بعد.';

  @override
  String orderNumber(Object id) {
    return 'طلب رقم: $id';
  }

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get processing => 'قيد المعالجة';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'تم الإلغاء';

  @override
  String orderTotal(Object currency, Object total) {
    return 'المجموع: $total $currency';
  }

  @override
  String get allProducts => 'جميع المنتجات';

  @override
  String get filters => 'تصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get priceHighToLow => 'السعر: من الأعلى إلى الأقل';

  @override
  String get priceLowToHigh => 'السعر: من الأقل إلى الأعلى';

  @override
  String get newest => 'الأحدث';

  @override
  String get onSale => 'خصم';

  @override
  String get hotItems => 'عناصر رائجة';

  @override
  String get newArrivals => 'وصل حديثاً';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String get apply => 'تطبيق';

  @override
  String get search => 'بحث';

  @override
  String get popularSearches => 'عمليات البحث الشائعة';

  @override
  String noResultsFound(Object searchQuery) {
    return 'لا توجد نتائج بحث لـ \"$searchQuery\"';
  }

  @override
  String get sale => 'خصم';

  @override
  String get age => 'العمر';

  @override
  String get quantity => 'الكمية';

  @override
  String get addToCart => 'إضافة إلى السلة';

  @override
  String get deleteConfirmation => 'تأكيد الحذف';

  @override
  String get confirmDeleteOrder => 'هل أنت متأكد من حذف هذا الطلب؟';

  @override
  String get delete => 'حذف';

  @override
  String get orderDeletedSuccess => 'تم حذف الطلب بنجاح';

  @override
  String get orderDeleteFailed => 'فشل حذف الطلب';

  @override
  String get undo => 'تراجع';

  @override
  String get orderConfirmedSuccess => 'تم تأكيد الطلب بنجاح';

  @override
  String get orderConfirmationFailed => 'حدث خطأ. الرجاء المحاولة مرة أخرى';

  @override
  String get orderInformation => 'معلومات الطلب';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get pleaseEnterPhoneNumber => 'الرجاء إدخال رقم هاتفك';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get pleaseEnterDeliveryAddress => 'الرجاء إدخال عنوان التوصيل';

  @override
  String get confirmExitTitle => 'تأكيد الخروج';

  @override
  String get confirmExitContent => 'هل أنت متأكد أنك تريد الخروج من التطبيق؟';

  @override
  String get exit => 'خروج';
}
