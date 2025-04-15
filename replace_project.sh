#!/bin/bash

# Yeni proje hazır, eski projeyi yedekleyelim ve yenisini kullanalım
echo "Eski projeyi yedekleniyor..."
mkdir -p old_project_backup
cp -r android old_project_backup/
cp -r ios old_project_backup/ 2>/dev/null || true
cp -r web old_project_backup/ 2>/dev/null || true
cp -r test old_project_backup/ 2>/dev/null || true
cp pubspec.yaml old_project_backup/
cp -r .metadata old_project_backup/ 2>/dev/null || true

# Eski android klasörünü kaldır ve yerine yenisini koy
echo "Yeni projeyi ana dizine taşınıyor..."
rm -rf android
cp -r new_project/android ./

# Flutter dosyalarını ana projeye taşı
cp -r new_project/.metadata ./ 2>/dev/null || true
cp new_project/pubspec.yaml ./

# Android Studio plugin dosyalarını kopyala/güncelle
cp -r new_project/.dart_tool ./ 2>/dev/null || true
cp -r new_project/.flutter-plugins ./ 2>/dev/null || true
cp -r new_project/.flutter-plugins-dependencies ./ 2>/dev/null || true

echo "Yeni proje başarıyla kuruldu!"
echo "Not: Eski proje old_project_backup klasöründe yedeklendi."