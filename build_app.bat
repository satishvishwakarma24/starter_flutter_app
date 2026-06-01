@echo off

echo Setting app name...
flutter pub run rename setAppName --value "GSTmate"
if errorlevel 1 goto :error

echo Changing package name...
flutter pub run change_app_package_name:main com.yourcompany.gstmate
if errorlevel 1 goto :error

echo Generating launcher icons...
flutter pub run flutter_launcher_icons
if errorlevel 1 goto :error

echo Removing old widget provider if it exists...
if exist android\app\src\main\kotlin\com\example\starterapp\StarterAppWidgetProvider.kt (
    del android\app\src\main\kotlin\com\example\starterapp\StarterAppWidgetProvider.kt
)

echo Cleaning Flutter project...
flutter clean
if errorlevel 1 goto :error

echo Getting packages...
flutter pub get
if errorlevel 1 goto :error

echo Cleaning Android build...
cd android
call gradlew clean
cd ..
if errorlevel 1 goto :error

echo Running app...
flutter run
if errorlevel 1 goto :error

echo Done!
goto :eof

:error
echo Script failed.
exit /b 1