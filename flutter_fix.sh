#!/bin/bash

# Flutter namespace sorununu düzeltmek için script

function find_notification_package() {
    echo "Flutter Local Notifications paketini arıyorum..."
    
    # Olası konumlar
    LOCATIONS=(
        "$HOME/.pub-cache/hosted/pub.dev"
        "$HOME/snap/flutter/common/flutter/.pub-cache/hosted/pub.dev"
        "/opt/hostedtoolcache/flutter/.pub-cache/hosted/pub.dev"
        "$HOME/.pub-cache/git"
        "./new_project/.dart_tool/pub/deps"
        "./new_project/.pub-cache/hosted/pub.dev"
    )
    
    # Tüm muhtemel flutter_local_notifications sürümlerini tara
    for loc in "${LOCATIONS[@]}"; do
        if [ -d "$loc" ]; then
            echo "Dizin taranıyor: $loc"
            
            # Tüm flutter_local_notifications- ile başlayan klasörleri bul
            FOUND_DIRS=$(find "$loc" -maxdepth 1 -type d -name "flutter_local_notifications-*" 2>/dev/null)
            
            if [ -n "$FOUND_DIRS" ]; then
                echo "Aşağıdaki flutter_local_notifications paket sürümleri bulundu:"
                echo "$FOUND_DIRS"
                
                # İlk bulunan paketi kullan
                for dir in $FOUND_DIRS; do
                    NOTIFICATION_DIR="$dir"
                    GRADLE_FILE="$NOTIFICATION_DIR/android/build.gradle"
                    
                    if [ -f "$GRADLE_FILE" ]; then
                        echo "build.gradle dosyası bulundu: $GRADLE_FILE"
                        return 0
                    fi
                done
            fi
        fi
    done
    
    # Eğer paket bulunamazsa
    echo "HATA: flutter_local_notifications paketi bulunamadı!"
    return 1
}

function fix_gradle_file() {
    if [ ! -f "$GRADLE_FILE" ]; then
        echo "HATA: build.gradle dosyası bulunamadı: $GRADLE_FILE"
        return 1
    fi
    
    echo "build.gradle düzenleniyor: $GRADLE_FILE"
    
    # build.gradle'yi yedekle
    cp "$GRADLE_FILE" "${GRADLE_FILE}.bak"
    
    # namespace ekle
    if grep -q "namespace" "$GRADLE_FILE"; then
        echo "Namespace zaten tanımlanmış. Değişiklik yapılmayacak."
    else
        echo "Namespace ekleniyor..."
        # defaultConfig bloğunun içine namespace ekle
        sed -i '/defaultConfig {/a \        namespace "com.dexterous.flutterlocalnotifications"' "$GRADLE_FILE"
        
        if [ $? -eq 0 ]; then
            echo "✅ Namespace başarıyla eklendi: com.dexterous.flutterlocalnotifications"
        else
            echo "❌ Namespace eklenirken hata oluştu. Yedekten geri yükleniyor."
            cp "${GRADLE_FILE}.bak" "$GRADLE_FILE"
            return 1
        fi
    fi
    
    return 0
}

function recompile_flutter_project() {
    echo "Flutter projesini yeniden derliyorum..."
    cd new_project
    
    echo "pub cache temizleniyor..."
    flutter pub cache clean
    
    echo "flutter clean çalıştırılıyor..."
    flutter clean
    
    echo "flutter pub get çalıştırılıyor..."
    flutter pub get
    
    echo "Flutter proje bağımlılıkları yenilendi."
    
    cd ..
}

# Ana işlem
echo "Flutter Local Notifications iyileştirme betiği çalışıyor..."
echo "============================================================"

# Notification paketini bul
find_notification_package

if [ $? -eq 0 ]; then
    # Gradle dosyasını düzelt
    fix_gradle_file
    
    if [ $? -eq 0 ]; then
        # Flutter projesini derle
        recompile_flutter_project
        
        echo "✅ İşlem tamamlandı."
        echo "============================================================"
        echo "Artık şu komutu kullanarak APK oluşturabilirsiniz:"
        echo "cd new_project && flutter build apk --debug"
    else
        echo "❌ Namespace düzeltme işlemi başarısız oldu."
    fi
else
    echo "❌ Flutter Local Notifications paketi bulunamadı."
    echo "Lütfen flutter pub get ile paketlerin yüklendiğinden emin olun."
fi