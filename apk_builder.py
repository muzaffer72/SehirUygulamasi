#!/usr/bin/env python3
import os
import shutil
import zipfile
import json
import sys
import datetime

print("ŞikayetVar APK Generator - Basitleştirilmiş sürüm")
print("===============================================")

# Proje klasörü
project_dir = os.getcwd()
output_dir = os.path.join(project_dir, "apk_output")
os.makedirs(output_dir, exist_ok=True)

# APK bilgisi
app_name = "ŞikayetVar"
version = "1.0.0"
build_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# APK info dosyası
apk_info = {
    "appName": app_name,
    "version": version, 
    "buildDate": build_date,
    "platform": "Android",
    "minSdkVersion": 21,
    "targetSdkVersion": 33,
    "buildMode": "Debug (Placeholder)",
    "note": "Bu bir placeholder APK bilgi dosyasıdır. Gerçek APK derleme işlemi daha fazla bellek gerektirir."
}

# APK bilgi dosyasını oluştur
with open(os.path.join(output_dir, "apk_info.json"), "w") as f:
    json.dump(apk_info, f, indent=2)

# HTML rapor oluştur
html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{app_name} APK Bilgileri</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #1976d2;
            margin-top: 0;
        }}
        .card {{
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            background-color: #fff;
        }}
        .info-row {{
            display: flex;
            margin-bottom: 8px;
            border-bottom: 1px solid #eee;
            padding-bottom: 8px;
        }}
        .info-label {{
            font-weight: bold;
            width: 40%;
        }}
        .info-value {{
            width: 60%;
        }}
        .note {{
            margin-top: 20px;
            padding: 10px;
            background-color: #fff9c4;
            border-left: 4px solid #fbc02d;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{app_name} APK Bilgileri</h1>
        
        <div class="card">
            <h2>APK Detayları</h2>
            
            <div class="info-row">
                <div class="info-label">Uygulama Adı:</div>
                <div class="info-value">{app_name}</div>
            </div>
            
            <div class="info-row">
                <div class="info-label">Versiyon:</div>
                <div class="info-value">{version}</div>
            </div>
            
            <div class="info-row">
                <div class="info-label">Derleme Tarihi:</div>
                <div class="info-value">{build_date}</div>
            </div>
            
            <div class="info-row">
                <div class="info-label">Platform:</div>
                <div class="info-value">{apk_info['platform']}</div>
            </div>
            
            <div class="info-row">
                <div class="info-label">Minimum SDK Versiyon:</div>
                <div class="info-value">{apk_info['minSdkVersion']}</div>
            </div>
            
            <div class="info-row">
                <div class="info-label">Hedef SDK Versiyon:</div>
                <div class="info-value">{apk_info['targetSdkVersion']}</div>
            </div>
            
            <div class="note">
                <p><strong>Not:</strong> {apk_info['note']}</p>
                <p>ŞikayetVar uygulaması, kaynak kodlarından oluşturulabilir. APK derlemek için:</p>
                <ol>
                    <li>Projeyi Flutter SDK olan bir ortama (Android Studio veya VS Code) aktarın</li>
                    <li>Terminal'de <code>flutter build apk --release</code> komutunu çalıştırın</li>
                    <li>APK dosyası <code>build/app/outputs/flutter-apk/</code> klasöründe oluşturulacaktır</li>
                </ol>
                <p>Replit ortamında bellek sınırlamaları nedeniyle APK derleme işlemi tamamlanamıyor.</p>
            </div>
        </div>
    </div>
</body>
</html>
"""

with open(os.path.join(output_dir, "apk_info.html"), "w") as f:
    f.write(html_content)

print(f"APK bilgileri oluşturuldu: {output_dir}/apk_info.html")
print("APK dosyasının Replit ortamında derlenmesi bellek sınırlamaları nedeniyle mümkün değil.")
print("Derleme yapılabilmesi için projeyi Android Studio veya benzeri bir ortama aktarmanız gerekiyor.")
