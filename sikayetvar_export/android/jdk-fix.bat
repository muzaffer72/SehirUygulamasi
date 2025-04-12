@echo off
echo Flutter ve Gradle JDK Sorunlari Duzeltme Araci
echo ---------------------------------------------

echo 1. Gradle cache temizleniyor...
rmdir /s /q %USERPROFILE%\.gradle\caches
rmdir /s /q %USERPROFILE%\.android\.gradle
echo Gradle cache temizlendi.

echo 2. Proje temizleniyor...
cd ..
flutter clean
del pubspec.lock
rmdir /s /q .dart_tool
rmdir /s /q build
echo Proje temizlendi.

echo 3. Gradle dosyalari temizleniyor...
cd android
rmdir /s /q .gradle
rmdir /s /q build
echo Gradle dosyalari temizlendi.

echo 4. Bagimliliklari yeniden yukluyor...
cd ..
flutter pub get
echo Bagimliliklari yeniden yuklendi.

echo 5. Java JDK 17 ayarlaniyor...
echo Lutfen JDK 17 kurulu oldugunu dogrulayin.
echo Android Studio'da gradle ayarlarini JDK 17'ye ayarlamayi unutmayin.

echo ---------------------------------------------
echo Islemler tamamlandi.
echo Android Studio'yu yeniden baslatarak projeyi acin.
echo Herhangi bir tusa basarak cikin...
pause > nul