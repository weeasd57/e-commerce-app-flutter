# دليل استخدام نظام الصور في الوضع غير المتصل

## نظرة عامة

تم تطوير نظام شامل لإدارة الصور في الوضع غير المتصل يتيح للتطبيق عرض الصور المحفوظة مؤقتاً حتى عند انقطاع الإنترنت.

## المكونات الرئيسية

### 1. OfflineCachedImage Widget
Widget مخصص يحل محل `CachedNetworkImage` مع دعم للوضع غير المتصل.

**المميزات:**
- عرض الصور المحفوظة مؤقتاً عند انقطاع الإنترنت
- مؤشر بصري للوضع غير المتصل
- Widget افتراضي قابل للتخصيص عند عدم توفر الصورة
- إدارة ذكية لحالات الخطأ

**طريقة الاستخدام:**
```dart
OfflineCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  memCacheWidth: 400,
  memCacheHeight: 400,
  cacheKey: 'unique_key',
  borderRadius: BorderRadius.circular(12),
  showOfflineIndicator: true,
  placeholder: Container(
    color: Colors.grey[300],
    child: CircularProgressIndicator(),
  ),
  errorWidget: Container(
    color: Colors.grey[300],
    child: Icon(Icons.broken_image),
  ),
  offlineWidget: Container(
    color: Colors.grey[300],
    child: Icon(Icons.wifi_off),
  ),
)
```

### 2. CustomImageCacheManager
مدير التخزين المؤقت المحسّن للصور.

**المميزات:**
- فترة انتهاء صلاحية 30 يوماً
- دعم لـ 1000 صورة كحد أقصى
- وظائف تنظيف وإدارة التخزين المؤقت
- إحصائيات مفصلة

### 3. OfflineImageService
خدمة شاملة لإدارة تحميل الصور مسبقاً.

**الوظائف الرئيسية:**
- `preloadProductImages()` - تحميل صور المنتجات مسبقاً
- `preloadCategoryImages()` - تحميل صور الفئات مسبقاً
- `preloadPriorityImages()` - تحميل الصور عالية الأولوية
- `preloadCartImages()` - تحميل صور عربة التسوق
- `isImageCached()` - فحص وجود الصورة في التخزين المؤقت
- `cleanOldImages()` - تنظيف الصور القديمة
- `getCacheStats()` - الحصول على إحصائيات التخزين المؤقت

## التطبيق في المشروع

### الملفات المحدّثة:
1. `lib/widgets/product_card.dart` - استخدام OfflineCachedImage
2. `lib/pages/product_details_page.dart` - دعم الوضع غير المتصل في تفاصيل المنتج
3. `lib/pages/cart_page.dart` - صور عربة التسوق في الوضع غير المتصل
4. `lib/widgets/category_card.dart` - صور الفئات مع دعم غير متصل

### إعداد التحميل المسبق

يمكن إضافة التحميل المسبق للصور في provider المنتجات:

```dart
// في ProductProvider
final offlineImageService = OfflineImageService();

// تحميل الصور عالية الأولوية أولاً
await offlineImageService.preloadPriorityImages(products);

// ثم تحميل باقي الصور في الخلفية
Future.microtask(() async {
  await offlineImageService.preloadProductImages(products);
});
```

## الإعدادات والتخصيص

### تخصيص فترة انتهاء الصلاحية:
```dart
// في CustomImageCacheManager
stalePeriod: const Duration(days: 30), // يمكن تعديلها
```

### تخصيص عدد الصور المحفوظة:
```dart
maxNrOfCacheObjects: 1000, // يمكن تعديلها حسب الحاجة
```

### تخصيص حجم دفعة التحميل:
```dart
// في OfflineImageService
const batchSize = 5; // يمكن تعديلها
```

## مراقبة الأداء

### فحص إحصائيات التخزين المؤقت:
```dart
final stats = await OfflineImageService().getCacheStats();
print('حجم التخزين المؤقت: ${stats['sizeFormatted']}');
print('حالة التحميل المسبق: ${stats['isPreloading']}');
```

### تنظيف التخزين المؤقت:
```dart
await OfflineImageService().cleanOldImages();
```

## أفضل الممارسات

### 1. تحميل الصور بذكاء:
- ابدأ بالصور عالية الأولوية (الصفحة الرئيسية)
- حمل صور المنتجات في مجموعات صغيرة
- تجنب التحميل أثناء استخدام البيانات المحدودة

### 2. إدارة الذاكرة:
- استخدم `memCacheWidth` و `memCacheHeight` مناسبين
- نظف التخزين المؤقت دورياً
- راقب حجم التخزين المؤقت

### 3. تحسين تجربة المستخدم:
- اعرض مؤشرات التحميل واضحة
- استخدم placeholder مناسب
- أعلم المستخدم عن حالة الاتصال

## استكشاف الأخطاء

### مشاكل شائعة وحلولها:

1. **الصور لا تظهر في الوضع غير المتصل:**
   - تأكد من تحميل الصور مسبقاً
   - تحقق من صحة روابط الصور
   - فحص إعدادات التخزين المؤقت

2. **بطء في التحميل:**
   - قلل من حجم دفعة التحميل
   - استخدم صور أصغر حجماً
   - حمل الصور عالية الأولوية أولاً

3. **استهلاك مرتفع للذاكرة:**
   - قلل من `memCacheWidth` و `memCacheHeight`
   - نظف التخزين المؤقت بانتظام
   - قلل من `maxNrOfCacheObjects`

## الميزات المستقبلية

- [ ] ضغط الصور التلقائي
- [ ] تحميل انتقائي حسب جودة الشبكة
- [ ] إحصائيات مفصلة للاستخدام
- [ ] تزامن التخزين المؤقت عبر الأجهزة
- [ ] تحسين الذكاء الاصطناعي لتحديد أولوية التحميل

## الدعم

لأي استفسارات أو مشاكل تقنية، يرجى مراجعة الكود أو التواصل مع فريق التطوير.
