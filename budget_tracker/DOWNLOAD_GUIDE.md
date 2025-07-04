# 📱 Budget Tracker - Download & Installation Guide

> **Get the Budget Tracker app on your device with these simple steps**

## 🎯 Quick Download Options

### Option 1: 🔧 Build from Source (Recommended for Developers)

#### Prerequisites
- Flutter SDK 3.24.5+
- Android Studio or VS Code
- Android SDK (API 21+)

#### Steps
```bash
# 1. Clone the repository
git clone https://github.com/devara1983ntr/Budget-Tracker-.git

# 2. Navigate to project directory
cd Budget-Tracker-/budget_tracker

# 3. Get dependencies
flutter pub get

# 4. Run on your device/emulator
flutter run
```

#### Build APK
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (optimized)
flutter build apk --release
```
APK will be available at: `build/app/outputs/flutter-apk/`

### Option 2: 📦 Download Source Code ZIP

1. **Visit GitHub Repository**: [Budget-Tracker](https://github.com/devara1983ntr/Budget-Tracker-)
2. **Click "Code"** → **"Download ZIP"**
3. **Extract** the ZIP file to your desired location
4. **Open** in Android Studio or VS Code
5. **Run** `flutter pub get` in terminal
6. **Build** the app using the steps above

### Option 3: 🚀 Pre-built APK (Coming Soon)

*Pre-built APK files will be available in the GitHub Releases section once the build environment is properly configured. Check back soon!*

## 📋 System Requirements

### Android Device Requirements
- **Android Version**: 5.0 (API 21) or higher
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 100MB free space
- **Permissions**: Camera, Storage (for receipt photos)

### Development Requirements
- **Flutter**: 3.24.5 or higher
- **Dart**: 3.5.0 or higher
- **Android SDK**: 21-34
- **Java**: JDK 17 or higher

## 🛠️ Installation Instructions

### For Android Devices

#### Method A: Install from APK
1. **Download** the APK file to your device
2. **Enable** "Install from Unknown Sources" in Settings
3. **Open** the APK file using a file manager
4. **Follow** the installation prompts
5. **Grant** necessary permissions when prompted

#### Method B: Direct Install via ADB
```bash
# Make sure your device is connected via USB debugging
adb install budget_tracker.apk
```

### For Development

#### Android Studio
1. **Open** Android Studio
2. **Select** "Open an existing project"
3. **Navigate** to the extracted/cloned folder
4. **Select** the `budget_tracker` directory
5. **Wait** for indexing to complete
6. **Run** the app using the play button

#### VS Code
1. **Open** VS Code
2. **Install** Flutter and Dart extensions
3. **Open** the `budget_tracker` folder
4. **Open** terminal in VS Code
5. **Run** `flutter pub get`
6. **Press** F5 to run the app

## 🔧 Build Configuration

### Debug Build (For Testing)
```bash
flutter build apk --debug
```
- **Size**: ~50MB
- **Performance**: Not optimized
- **Debugging**: Enabled
- **Use Case**: Development and testing

### Release Build (For Distribution)
```bash
flutter build apk --release
```
- **Size**: ~25MB (optimized)
- **Performance**: Fully optimized
- **Debugging**: Disabled
- **Use Case**: Production deployment

### Custom Build Options
```bash
# Build for specific architecture
flutter build apk --target-platform android-arm64

# Build with specific flavor
flutter build apk --flavor production

# Build with custom name
flutter build apk --build-name=1.0.0 --build-number=1
```

## 📂 File Structure After Download

```
Budget-Tracker-/
├── budget_tracker/           # Main Flutter project
│   ├── lib/                 # Dart source code
│   ├── android/             # Android configuration
│   ├── assets/              # App assets
│   ├── pubspec.yaml         # Dependencies
│   └── README.md            # Project documentation
├── docs/                    # Additional documentation
└── .github/                 # GitHub workflows
```

## 🎮 First Run Setup

### Initial Configuration
1. **Launch** the app after installation
2. **Complete** the onboarding tutorial
3. **Set up** security (PIN + optional biometrics)
4. **Choose** your preferred currency
5. **Start** adding transactions and budgets

### Default Features Available
- ✅ **20+ expense categories**
- ✅ **Multiple account types**
- ✅ **50+ supported currencies**
- ✅ **Sample data** for testing
- ✅ **Dark/Light themes**

## 🔍 Troubleshooting

### Common Issues

#### App Won't Install
- **Solution**: Enable "Install from Unknown Sources"
- **Check**: Device has enough storage space
- **Verify**: Android version compatibility

#### App Crashes on Launch
- **Clear**: App data and cache
- **Restart**: Device and try again
- **Check**: Permissions are granted

#### Can't Build from Source
- **Verify**: Flutter doctor shows no issues
- **Update**: Flutter to latest stable version
- **Clean**: Run `flutter clean` and `flutter pub get`

#### Camera Not Working
- **Grant**: Camera permission in app settings
- **Check**: Device camera functionality
- **Restart**: App after granting permissions

### Getting Help

#### Developer Support
- **GitHub Issues**: [Report problems](https://github.com/devara1983ntr/Budget-Tracker-/issues)
- **Documentation**: Check `TESTING_REPORT.md` for known issues
- **Community**: GitHub Discussions for questions

#### Build Issues
- **Flutter Doctor**: Run `flutter doctor -v` for diagnostics
- **SDK Issues**: Ensure Android SDK is properly configured
- **Dependency Issues**: Try `flutter pub deps` to check conflicts

## 📊 Download Statistics

| Download Method | Difficulty | Size | Time Required |
|----------------|------------|------|---------------|
| Source Build | Medium | ~200MB | 10-15 minutes |
| ZIP Download | Easy | ~50MB | 5-10 minutes |
| Pre-built APK | Easy | ~25MB | 2-3 minutes |

## 🔐 Security Information

### APK Verification
- **Signature**: All APKs will be signed with developer certificate
- **Checksum**: SHA-256 hashes provided for verification
- **Source**: Only download from official GitHub repository

### Permissions Required
```xml
<!-- Essential Permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Security Permissions -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

## 🚀 Performance Tips

### For Best Experience
- **Close** unnecessary background apps
- **Ensure** at least 1GB free RAM
- **Use** latest Android version when possible
- **Enable** hardware acceleration

### Storage Management
- **Initial Size**: ~25MB
- **With Data**: Up to 100MB (depending on usage)
- **Receipt Photos**: Additional space as needed
- **Database**: Grows with transaction history

## 📱 Next Steps After Installation

1. **Explore Features**: Try adding transactions and budgets
2. **Customize Settings**: Set up your preferred currency and theme
3. **Security Setup**: Configure PIN and biometric authentication
4. **Add Data**: Import or manually add your financial data
5. **Set Goals**: Create savings goals and budgets

## 🌟 Additional Resources

- **User Guide**: See README.md for detailed usage instructions
- **Feature Testing**: Check TESTING_REPORT.md for feature status
- **Build Guide**: Review BUILD_GUIDE.md for advanced building
- **GitHub Repository**: [Budget-Tracker](https://github.com/devara1983ntr/Budget-Tracker-)

---

**Need help?** Create an issue on [GitHub](https://github.com/devara1983ntr/Budget-Tracker-/issues) or check our documentation!

**Built with ❤️ by Roshan** - Making personal finance management accessible to everyone.