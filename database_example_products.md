# أمثلة على إنشاء منتجات مع التخفيضات

## فهم نظام التخفيضات الجديد:

### الطريقة الأولى: `salePrice` كسعر نهائي
```sql
INSERT INTO products (name, price, on_sale, sale_price, is_hot, is_new) VALUES
('منتج مخفض', 350, true, 300, false, false);
-- السعر الأصلي: 350
-- السعر النهائي: 300 (سعر التخفيض)
-- مقدار التوفير: 50
-- نسبة التخفيض: 14%
```

### الطريقة الثانية: `salePrice` كمقدار خصم
```sql
INSERT INTO products (name, price, on_sale, sale_price, is_hot, is_new) VALUES
('منتج مخفض', 350, true, 50, false, false);
-- السعر الأصلي: 350
-- مقدار الخصم: 50
-- السعر النهائي: 300 (350 - 50)
-- نسبة التخفيض: 14%
```

## أمثلة شاملة:

### 1. منتج عادي بدون تخفيض:
```sql
INSERT INTO products (name, description, price, on_sale, sale_price, is_hot, is_new, image_urls, category_id) VALUES
('هاتف ذكي', 'هاتف ذكي متطور', 800, false, null, true, false, 
ARRAY['https://example.com/phone1.jpg', 'https://example.com/phone2.jpg'], 1);
```

### 2. منتج مع تخفيض (salePrice = السعر النهائي):
```sql
INSERT INTO products (name, description, price, on_sale, sale_price, is_hot, is_new, image_urls, category_id) VALUES
('لابتوب جيمنج', 'لابتوب للألعاب بمواصفات عالية', 1500, true, 1200, false, true, 
ARRAY['https://example.com/laptop1.jpg', 'https://example.com/laptop2.jpg'], 2);
-- سيظهر: 1500 مشطوب → 1200 (20% خصم)
```

### 3. منتج مع تخفيض (salePrice = مقدار الخصم):
```sql
INSERT INTO products (name, description, price, on_sale, sale_price, is_hot, is_new, image_urls, category_id) VALUES
('سماعات لاسلكية', 'سماعات بتقنية إلغاء الضوضاء', 300, true, 75, false, false, 
ARRAY['https://example.com/headphones1.jpg'], 3);
-- سيظهر: 300 مشطوب → 225 (25% خصم)
```

## كيف يعمل النظام:

### في الكود:
```dart
// Product model سيحسب السعر النهائي تلقائياً
double get finalPrice {
  if (onSale && salePrice != null) {
    if (salePrice! < price) {
      return price - salePrice!; // salePrice = مقدار الخصم
    } else {
      return salePrice!; // salePrice = السعر النهائي
    }
  }
  return price; // لا يوجد تخفيض
}
```

### النتائج في التطبيق:

1. **في CarouselSlider:**
   - المنتج العادي: `800 USD`
   - المنتج المخفض: `~~1500~~ 1200 USD` مع شارة `20% OFF`

2. **في ProductCard:**
   - نفس العرض مع تفاصيل أكثر وأيقونة سلة التسوق

3. **في سلة التسوق:**
   - يتم حفظ السعر النهائي (1200 بدلاً من 1500)
   - المجموع الكلي يحسب بالأسعار النهائية

## ميزات النظام الجديد:

✅ **مرونة في التعامل مع التخفيضات**
✅ **عرض واضح للسعر الأصلي والمخفض**
✅ **حفظ السعر الصحيح في سلة التسوق**
✅ **حساب نسبة التخفيض تلقائياً**
✅ **دعم كلا الطريقتين في تعريف التخفيض**

## تحديث المنتجات الموجودة:

```sql
-- تحديث منتج ليصبح مخفضاً
UPDATE products 
SET on_sale = true, sale_price = 250 
WHERE id = 1; -- إذا كان السعر الأصلي 350، سيصبح النهائي 250

-- إزالة التخفيض
UPDATE products 
SET on_sale = false, sale_price = null 
WHERE id = 1;
```
