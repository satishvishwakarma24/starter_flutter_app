#!/bin/bash

# chmod +x build_app.sh
# ./build_app.sh

set -e

echo "Setting app name..."
flutter pub run rename setAppName --value "GSTmate"

echo "Changing package name..."
flutter pub run change_app_package_name:main com.yourcompany.gstmate

echo "Generating launcher icons..."
flutter pub run flutter_launcher_icons

echo "Removing old widget provider if it exists..."
rm -f android/app/src/main/kotlin/com/example/starterapp/StarterAppWidgetProvider.kt

echo "Cleaning Flutter project..."
flutter clean

echo "Getting packages..."
flutter pub get

echo "Cleaning Android build..."
cd android
./gradlew clean
cd ..

echo "Running app..."
flutter run

echo "Done!"