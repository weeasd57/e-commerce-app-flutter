# 🚀 Real-time Updates Guide

## كيف يعمل نظام التحديث في الوقت الفعلي

### 🎯 **الهدف:**
عرض تحديثات المنتجات فوراً عندما يتم:
- إضافة منتج جديد
- تعديل سعر منتج
- تغيير حالة التخفيض (`on_sale`)
- تعديل تفاصيل المنتج

### 🏗️ **البنية التقنية:**

#### **1. ProductProvider:**
```dart
// بدء الاستماع للتحديثات
void startRealTimeUpdates() {
  _productsStreamSubscription = _db
      .from('products')
      .stream(primaryKey: ['id'])
      .listen((data) {
        // تحديث البيانات فوراً
        _products = data.map((json) => Product.fromMap(json)).toList();
        _applyFilters(); // إعادة تطبيق الفلاتر
        notifyListeners(); // إخطار جميع المستمعين
      });
}
```

#### **2. HomePage:**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startRealTimeUpdates(); // بدء الاستماع
  });
}

@override
void dispose() {
  productProvider.stopRealTimeUpdates(); // إيقاف الاستماع
  super.dispose();
}
```

### 📱 **الصفحات التي تُحدث تلقائياً:**

#### ✅ **HomePage:**
- CarouselSlider
- ProductCard grid
- New arrivals
- Sale products

#### ✅ **CategoryProductsPage:**
- قائمة المنتجات حسب الفئة

#### ✅ **ProductCard:**
- السعر الأصلي والمخفض
- نسبة التخفيض
- شارة "ON SALE"

### 🛠️ **للاختبار:**

#### **1. من Supabase Dashboard:**
```sql
-- إضافة منتج جديد
INSERT INTO products (name, price, on_sale, sale_price) VALUES
('منتج تجريبي', 100, true, 80);

-- تعديل سعر منتج موجود
UPDATE products SET price = 150, sale_price = 120 WHERE id = 1;

-- إضافة/إزالة تخفيض
UPDATE products SET on_sale = true, sale_price = 50 WHERE id = 2;
UPDATE products SET on_sale = false, sale_price = null WHERE id = 3;
```

#### **2. ستحصل على:**
- 📱 تحديث فوري في التطبيق
- 🔄 إعادة حساب الأسعار
- 🏷️ ظهور/اختفاء شارات التخفيض
- 📊 تحديث عدادات المنتجات

### 🐛 **Debug Information:**

في الـ Debug Console ستُطبع الرسائل التالية:

```bash
🚀 بدء Real-time updates للمنتجات...
🔄 Real-time update received: 5 منتج
📊 تغيير عدد المنتجات: 4 → 5
🏷️ تغيير عدد العروض: 2 → 3
✅ Real-time update applied successfully!
```

### 🎛️ **التحكم اليدوي:**

#### **بدء التحديثات:**
```dart
context.read<ProductProvider>().startRealTimeUpdates();
```

#### **إيقاف التحديثات:**
```dart
context.read<ProductProvider>().stopRealTimeUpdates();
```

#### **تحديث يدوي:**
```dart
context.read<ProductProvider>().fetchProducts(forceRefresh: true);
```

### ⚡ **الأداء:**

- ✅ التحديثات تحدث فقط عند تغيير البيانات
- ✅ لا تؤثر على الأداء إذا لم تتغير البيانات
- ✅ إعادة تطبيق الفلاتر تلقائياً
- ✅ حفظ البيانات للـ offline cache

### 🔧 **استكشاف الأخطاء:**

#### **إذا لم تعمل التحديثات:**

1. **تحقق من الاتصال:**
```dart
final hasConnection = !productProvider.isOffline;
```

2. **تحقق من بدء التحديثات:**
```bash
// يجب أن ترى هذه الرسالة في Debug Console
🚀 بدء Real-time updates للمنتجات...
```

3. **تحقق من Supabase Connection:**
```dart
final isConnected = SupabaseService.client.auth.currentUser != null;
```

### 🎯 **نصائح للتطوير:**

#### **1. اختبار محلي:**
- استخدم Supabase Dashboard لتعديل البيانات
- راقب Debug Console للتأكد من التحديثات

#### **2. إنتاج:**
- Real-time updates يعمل تلقائياً
- لا حاجة لأي تدخل من المستخدم

#### **3. أداء أفضل:**
- التحديثات تحدث فقط للصفحات المرئية
- البيانات تُحفظ للـ offline cache تلقائياً

---

## 🎉 **النتيجة:**
عند تعديل أي منتج في قاعدة البيانات، ستُحدث جميع الصفحات فوراً بدون الحاجة لإعادة تحميل التطبيق!
