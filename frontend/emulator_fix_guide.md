# Android Emulator Troubleshooting Guide

## Issue: Emulator exits with code 1 during startup

## Solutions:

### 1. Use Web Instead (Recommended for development)
```bash
cd d:/blood_bank/frontend
flutter run -d chrome
```

### 2. Fix Android Emulator

#### Option A: Enable Hardware Acceleration
1. Open Android Studio
2. Tools → AVD Manager
3. Click "Edit" next to Pixel_4
4. Click "Show Advanced Settings"
5. Set "Graphics" to "Hardware - GLES 2.0"
6. Save and try again

#### Option B: Reduce Emulator Resources
1. AVD Manager → Edit Pixel_4
2. Reduce RAM to 1024MB
3. Reduce VM Heap to 256MB
4. Set "Graphics" to "Software"
5. Save and try again

#### Option C: Create New Emulator
```bash
flutter emulators --create --name Pixel_4_New --device google_pixel_4
flutter emulators --launch Pixel_4_New
```

#### Option D: Use Physical Device
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect phone via USB
4. `flutter devices` (should show your phone)
5. `flutter run` (will use your phone)

### 3. Quick Test Commands
```bash
# Check available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on web
flutter run -d chrome

# Run on Windows desktop
flutter run -d windows
```

## Current Status
✅ Flutter: Working
✅ Chrome: Available
❌ Android Emulator: Graphics issues (using SwiftShader software rendering)

## Recommended Approach
Use Chrome for development - it's faster and more reliable for testing your Blood Bank app UI.
