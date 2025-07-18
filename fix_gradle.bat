@echo off
echo Fixing Gradle timeout issue...

echo Killing Java processes...
taskkill /f /im java.exe >nul 2>&1

echo Waiting 3 seconds...
timeout /t 3 >nul

echo Removing Gradle wrapper cache...
rmdir /s /q "%USERPROFILE%\.gradle\wrapper\dists\gradle-8.4-all" >nul 2>&1

echo Removing Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" >nul 2>&1

echo Cleaning Flutter build...
flutter clean

echo Re-getting dependencies...
flutter pub get

echo Done! You can now try running 'flutter run' again.
pause
