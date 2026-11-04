# Age Calculator (Private Vault)

একটি ছদ্মবেশী অ্যাপ — বাইরে থেকে সাধারণ **Age Calculator**, ভিতরে গল্প/উপন্যাস + DoodStream ভিডিও ভল্ট।

## ফিচার

- **Fake UI**: অ্যাপ খুললেই ক্যালকুলেটর দেখায়
- **সিক্রেট পাসকোড**: সেটিংস থেকে সেট করুন (যেমন `25*52`) → ক্যালকুলেটরে লিখে `=` চাপলে ভল্ট আনলক
- **MongoDB** থেকে গল্প/উপন্যাস (ডাইরেক্ট ইমেজ লিংক সহ)
- **DoodStream API** থেকে ভিডিও লিস্ট ও প্লে
- **অটো সিঙ্ক**: অ্যাপ খুললেই + ম্যানুয়াল Sync বাটন → নতুন ডেটা লাইভ আসে (রিবিল্ড লাগে না)
- সার্চ, রিডিং মোড, ভিডিও প্লেয়ার

## সেটআপ

### ১. API Key সেট করুন

`lib/config/api_config.dart` ফাইল খুলুন এবং নিচের জায়গায় আপনার Key বসান:

```dart
defaultValue: 'YOUR_MONGODB_DATA_API_KEY',   // ← MongoDB Data API Key
defaultValue: 'YOUR_DOODSTREAM_API_KEY',     // ← DoodStream API Key
```

MongoDB Base URL-ও আপনার App Services থেকে কপি করে বসান।

**অথবা** (আরও নিরাপদ) build করার সময়:

```bash
flutter run --dart-define=MONGO_API_KEY=your_mongo_key --dart-define=DOOD_API_KEY=your_dood_key --dart-define=MONGO_BASE_URL=https://your-region...
```

### ২. ডিপেন্ডেন্সি ইনস্টল

```bash
flutter pub get
```

### ৩. অ্যাপ আইকন (ঐচ্ছিক)

`assets/images/app_icon.png` এ ১০২৪×১০২৪ ক্যালকুলেটর আইকন রাখুন, তারপর:

```bash
dart run flutter_launcher_icons
```

### ৪. রান / বিল্ড

```bash
flutter run
# অথবা
flutter build apk --release
```

## MongoDB ডকুমেন্ট স্ট্রাকচার (উদাহরণ)

```json
{
  "title": "গল্পের নাম",
  "description": "সংক্ষিপ্ত বিবরণ",
  "content": "সম্পূর্ণ গল্পের টেক্সট...",
  "imageUrl": "https://i.ibb.co/xxxx/image.jpg",
  "author": "লেখক",
  "category": "গল্প"
}
```

## গুরুত্বপূর্ণ নোট

- একবার APK বানিয়ে দিলেই হবে। নতুন গল্প/ভিডিও MongoDB বা DoodStream-এ যোগ করলে অ্যাপে Sync করলেই চলে আসবে।
- API Key কোডে রাখলে GitHub পাবলিক রিপোতে পুশ করবেন না।
- পাসকোড ডিফল্ট: `25*52` (সেটিংস থেকে পরিবর্তন করা যাবে)

## ফোল্ডার স্ট্রাকচার

```
lib/
├── config/api_config.dart     ← API Key এখানে
├── models/
├── screens/
├── services/
└── main.dart
assets/images/                 ← অ্যাপ আইকন ও ছবি রাখুন
```
