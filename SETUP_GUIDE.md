# دليل إعداد Admin AI Dashboard

## المتطلبات الأساسية

قبل البدء، تأكد من توفر:
- Node.js 18 أو أحدث
- pnpm (مدير الحزم)
- حساب Firebase
- حساب Supabase

## خطوات الإعداد

### 1. إعداد Firebase

#### إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. انقر على "Create a project"
3. أدخل اسم المشروع واتبع الخطوات

#### تفعيل Authentication
1. في لوحة تحكم Firebase، اذهب إلى "Authentication"
2. انقر على "Get started"
3. اذهب إلى تبويب "Sign-in method"
4. فعّل "Email/Password"

#### الحصول على معلومات التكوين
1. اذهب إلى "Project settings" (أيقونة الترس)
2. في تبويب "General"، انزل إلى "Your apps"
3. انقر على "Add app" واختر "Web"
4. أدخل اسم التطبيق وانقر "Register app"
5. انسخ معلومات التكوين

#### تحديث ملف Firebase
افتح ملف `src/lib/firebase.js` وأضف معلومات التكوين:

```javascript
const firebaseConfig = {
  apiKey: "your-api-key-here",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id-here"
};
```

### 2. إعداد Supabase

#### إنشاء مشروع Supabase
1. اذهب إلى [Supabase](https://supabase.com/)
2. انقر على "Start your project"
3. أنشئ حساب جديد أو سجل دخول
4. انقر على "New project"
5. اختر المؤسسة وأدخل تفاصيل المشروع

#### إنشاء قاعدة البيانات
1. في لوحة تحكم Supabase، اذهب إلى "SQL Editor"
2. انسخ والصق الكود التالي لإنشاء الجداول:

create bucket "images";

```sql
-- إنشاء جدول الفئات
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول المنتجات
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  sale_price DECIMAL(10,2),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  image_urls TEXT[],
  is_hot BOOLEAN DEFAULT FALSE,
  is_new BOOLEAN DEFAULT FALSE,
  on_sale BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول المستخدمين
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  photo_url TEXT,
  role VARCHAR(50) DEFAULT 'user',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول الطلبات
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_name VARCHAR(255),
  phone VARCHAR(50),
  address TEXT,
  total DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  payment_method VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول عناصر الطلبات
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول إعدادات التطبيق
CREATE TABLE app_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  currency_code VARCHAR(10) DEFAULT 'USD',
  delivery_cost DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إدراج إعدادات افتراضية
INSERT INTO app_settings (currency_code, delivery_cost) 
VALUES ('USD', 0.00);


-- السماح برفع ملفات إلى الباكت images لكل المستخدمين (anon أو authenticated)
create policy "public upload images"
on storage.objects
for insert
to anon, authenticated
with check (bucket_id = 'images');

-- السماح بالقراءة كذلك (اختياري لو محتاج تعرض الصور للكل)
create policy "public read images"
on storage.objects
for select
to anon, authenticated
using ( bucket_id = 'images' );

-- السماح بحذف الصور (لحذف الصور عند حذف الفئات والمنتجات)
create policy "public delete images"
on storage.objects
for delete
to anon, authenticated
using ( bucket_id = 'images' );

-- دالة لحذف الصور المرتبطة بالفئة عند حذف الفئة
CREATE OR REPLACE FUNCTION delete_category_image()
RETURNS TRIGGER AS $$
BEGIN
  -- حذف الصورة من Storage إذا كانت موجودة
  IF OLD.image_url IS NOT NULL THEN
    -- استخراج اسم الملف من URL
    DECLARE
      file_name TEXT;
    BEGIN
      file_name := split_part(OLD.image_url, '/', -1);
      -- حذف الملف من bucket images
      DELETE FROM storage.objects 
      WHERE bucket_id = 'images' 
      AND name = file_name;
    END;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- إنشاء trigger لحذف صورة الفئة عند حذف الفئة
CREATE TRIGGER delete_category_image_trigger
  BEFORE DELETE ON categories
  FOR EACH ROW
  EXECUTE FUNCTION delete_category_image();

-- دالة لحذف الصور المرتبطة بالمنتج عند حذف المنتج
CREATE OR REPLACE FUNCTION delete_product_images()
RETURNS TRIGGER AS $$
DECLARE
  image_url TEXT;
  file_name TEXT;
BEGIN
  -- حذف جميع الصور المرتبطة بالمنتج
  IF OLD.image_urls IS NOT NULL THEN
    FOREACH image_url IN ARRAY OLD.image_urls
    LOOP
      IF image_url IS NOT NULL THEN
        -- استخراج اسم الملف من URL
        file_name := split_part(image_url, '/', -1);
        -- حذف الملف من bucket images
        DELETE FROM storage.objects 
        WHERE bucket_id = 'images' 
        AND name = file_name;
      END IF;
    END LOOP;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- إنشاء trigger لحذف صور المنتج عند حذف المنتج
CREATE TRIGGER delete_product_images_trigger
  BEFORE DELETE ON products
  FOR EACH ROW
  EXECUTE FUNCTION delete_product_images();

```

3. انقر على "Run" لتنفيذ الكود

#### إعداد Storage للصور
1. اذهب إلى "Storage" في لوحة تحكم Supabase
2. انقر على "Create a new bucket"
3. أدخل اسم "images" واتركه public
4. انقر على "Create bucket"

#### الحصول على معلومات الاتصال
1. اذهب إلى "Settings" > "API"
2. انسخ "Project URL" و "anon public key"

#### تحديث ملف Supabase
افتح ملف `src/lib/supabase.js` وأضف معلومات الاتصال:

```javascript
const supabaseUrl = 'your-supabase-url-here';
const supabaseKey = 'your-supabase-anon-key-here';
```

### 3. تشغيل التطبيق

```bash
# تثبيت التبعيات
pnpm install

# تشغيل خادم التطوير
pnpm run dev
```

سيتم تشغيل التطبيق على `http://localhost:5173`

## استخدام الميزات

### إضافة فئة جديدة
1. اذهب إلى صفحة "Categories"
2. انقر على "Add Category"
3. أدخل اسم الفئة
4. اختر صورة (اختياري)
5. انقر على "حفظ"

### إضافة منتج جديد
1. اذهب إلى صفحة "Products"
2. انقر على "Add Product"
3. املأ تفاصيل المنتج:
   - اسم المنتج (مطلوب)
   - الوصف
   - السعر (مطلوب)
   - سعر التخفيض (اختياري)
   - الفئة
   - الصور
   - الخصائص (Hot, New, Sale)
4. انقر على "حفظ"

### تحديث الإعدادات
1. اذهب إلى صفحة "Settings"
2. حدث:
   - رمز العملة (مثل USD, EUR)
   - تكلفة التوصيل
3. انقر على "Save Settings"

## استكشاف الأخطاء

### مشكلة الاتصال بـ Firebase
- تأكد من صحة معلومات التكوين في `firebase.js`
- تأكد من تفعيل Authentication في Firebase Console

### مشكلة الاتصال بـ Supabase
- تأكد من صحة URL و API Key في `supabase.js`
- تأكد من إنشاء الجداول بشكل صحيح
- تأكد من إنشاء bucket للصور

### مشكلة رفع الصور
- تأكد من إنشاء bucket "images" في Supabase Storage
- تأكد من أن البucket public
- تحقق من صلاحيات الوصول

## النشر

### بناء التطبيق
```bash
pnpm run build
```

### معاينة البناء
```bash
pnpm run preview
```

يمكنك نشر التطبيق على منصات مثل Vercel أو Netlify أو Firebase Hosting.

## الدعم

إذا واجهت أي مشاكل:
1. تحقق من وحدة التحكم في المتصفح للأخطاء
2. تأكد من صحة جميع معلومات التكوين
3. تحقق من حالة الاتصال بالإنترنت
4. راجع وثائق Firebase و Supabase الرسمية

