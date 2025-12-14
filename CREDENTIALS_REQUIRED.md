# Credentials Required for Production

This document lists all the credentials and configuration you need to provide for the app to work in production.

## 🔥 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "CryptoMiner" (or your app name)
3. Enable Google Analytics (recommended)

### 2. Add Android App
1. Click "Add app" → Select Android
2. Package name: `com.yourcompany.mining_app` (update in `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### 3. Enable Authentication
In Firebase Console → Authentication → Sign-in method:
- ✅ Enable **Google** Sign-in
- ✅ Enable **Phone** Sign-in

### 4. Enable Firestore
1. Go to Firestore Database → Create database
2. Start in **test mode** (update rules before production)
3. Choose a region close to your users (asia-south1 for India)

### 5. Firebase Config Files
- `android/app/google-services.json` - **REQUIRED**
- Update `android/app/build.gradle.kts` with applicationId

---

## 📱 Google AdMob Setup

### 1. Create AdMob Account
1. Go to [AdMob](https://admob.google.com/)
2. Create an account and add your app

### 2. Create Ad Units
Create the following ad units and note their IDs:
- **Banner Ad**: For bottom of main screen
- **Interstitial Ad**: Between screens
- **Rewarded Ad**: For claiming tap/passive rewards
- **App Open Ad**: On app launch

### 3. Update Ad Unit IDs
Edit `lib/core/constants/app_constants.dart`:
```dart
class AdMobIds {
  // Replace these with your REAL ad unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
  static const String interstitialAdUnitId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
  static const String rewardedAdUnitId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
  static const String appOpenAdUnitId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
  static const String nativeAdUnitId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
}
```

### 4. Update AndroidManifest.xml
Edit `android/app/src/main/AndroidManifest.xml` and add inside `<application>`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXX~XXXXXXXX"/>
```

---

## 💳 Razorpay Setup (Optional - for IAP)

### 1. Create Razorpay Account
1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Complete KYC verification

### 2. Get API Keys
Navigate to Settings → API Keys:
- **Key ID**: `rzp_test_XXXXXXXXXXXX` (test) or `rzp_live_XXXXXXXXXXXX` (production)
- **Key Secret**: Keep this secure!

### 3. Configure in App
Add Razorpay key in your app configuration.

---

## ☁️ Cloudflare Workers (Optional - for Backend Validation)

### 1. Create Cloudflare Account
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Navigate to Workers & Pages

### 2. Create Worker
Create a new worker for API validation endpoints.

### 3. Update Endpoint
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String cloudflareWorkerBaseUrl = 'https://your-worker.your-subdomain.workers.dev';
```

---

## 🔐 Security Checklist Before Launch

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Update Firestore security rules
- [ ] Enable Firebase App Check
- [ ] Configure proguard rules for release builds
- [ ] Update package name to your company domain
- [ ] Add SHA-1 and SHA-256 fingerprints to Firebase

---

## 📝 Files to Create/Update

| File | What to Add |
|------|-------------|
| `android/app/google-services.json` | Firebase config (download from Firebase) |
| `android/app/src/main/AndroidManifest.xml` | AdMob App ID |
| `lib/core/constants/app_constants.dart` | AdMob unit IDs, Cloudflare URL |
| `android/app/build.gradle.kts` | Your applicationId |

---

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters (if needed)
flutter packages pub run build_runner build

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

---

## ❓ Need Help?

1. Check Flutter & Firebase docs
2. Ensure all Google Play Console requirements are met
3. Test thoroughly with test ads before going live
