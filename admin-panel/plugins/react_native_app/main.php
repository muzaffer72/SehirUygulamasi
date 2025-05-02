<?php
/**
 * React Native Mobil Uygulama Eklentisi
 * 
 * Bu eklenti, ŞikayetVar platformu için React Native tabanlı mobil uygulama oluşturma desteği ekler.
 * Flutter yerine daha yaygın ve daha kolay geliştirilebilir bir çözüm sunar.
 * 
 * @version 1.0.0
 * @author ŞikayetVar Ekibi
 */

// Eklenti fonksiyonlarını tanımla
if (!function_exists('get_app_settings')) {
    /**
     * Mobil uygulama ayarlarını getirir
     *
     * @param object $db Veritabanı bağlantısı
     * @return array Ayarlar
     */
    function get_app_settings($db) {
        $result = $db->query("SELECT value FROM settings WHERE name='react_native_app_settings'");
        
        if ($result && $result->num_rows > 0) {
            $row = $result->fetch_assoc();
            return json_decode($row['value'], true);
        } else {
            // Varsayılan ayarlar
            return [
                'app_name' => 'ŞikayetVar',
                'app_version' => '1.0.0',
                'api_url' => 'https://workspace.mail852.repl.co/api',
                'primary_color' => '#1976d2',
                'features' => 'complaints,surveys,pharmacies,profile',
                'enable_push_notifications' => '1',
                'debug_mode' => '1'
            ];
        }
    }
}

if (!function_exists('save_app_settings')) {
    /**
     * Mobil uygulama ayarlarını kaydeder
     *
     * @param object $db Veritabanı bağlantısı
     * @param array $settings Ayarlar
     * @return bool Başarılı mı?
     */
    function save_app_settings($db, $settings) {
        // Mevcut ayarları kontrol et
        $result = $db->query("SELECT * FROM settings WHERE name='react_native_app_settings'");
        
        if ($result && $result->num_rows > 0) {
            // Güncelle
            $json_settings = json_encode($settings);
            $stmt = $db->prepare("UPDATE settings SET value = ? WHERE name = 'react_native_app_settings'");
            $stmt->bind_param('s', $json_settings);
            return $stmt->execute();
        } else {
            // Yeni ekle
            $json_settings = json_encode($settings);
            $stmt = $db->prepare("INSERT INTO settings (name, value) VALUES ('react_native_app_settings', ?)");
            $stmt->bind_param('s', $json_settings);
            return $stmt->execute();
        }
    }
}

if (!function_exists('create_react_native_project')) {
    /**
     * React Native projesi oluşturur
     *
     * @param array $settings Uygulama ayarları
     * @return array Sonuç
     */
    function create_react_native_project($settings) {
        // React Native proje klasörü yolunu belirle
        $project_path = __DIR__ . '/../../../react_native_app';
        
        // Klasör yoksa oluştur
        if (!file_exists($project_path)) {
            mkdir($project_path, 0755, true);
        }
        
        // Temel dosyaları oluştur
        // package.json
        $package_json = [
            'name' => strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $settings['app_name']))),
            'version' => $settings['app_version'],
            'private' => true,
            'scripts' => [
                'android' => 'react-native run-android',
                'ios' => 'react-native run-ios',
                'start' => 'react-native start',
                'test' => 'jest',
                'lint' => 'eslint .'
            ],
            'dependencies' => [
                'react' => '18.2.0',
                'react-native' => '0.73.0',
                'react-native-safe-area-context' => '^4.8.0',
                'react-native-screens' => '^3.29.0',
                '@react-navigation/native' => '^6.1.9',
                '@react-navigation/native-stack' => '^6.9.17',
                '@react-navigation/bottom-tabs' => '^6.5.11',
                'axios' => '^1.6.2',
                'react-native-vector-icons' => '^10.0.2',
                'react-native-maps' => '^1.8.0'
            ],
            'devDependencies' => [
                '@babel/core' => '^7.20.0',
                '@babel/preset-env' => '^7.20.0',
                '@babel/runtime' => '^7.20.0',
                '@react-native/babel-preset' => '^0.73.0',
                '@react-native/eslint-config' => '^0.73.0',
                '@react-native/metro-config' => '^0.73.0',
                '@react-native/typescript-config' => '^0.73.0',
                '@types/react' => '^18.2.6',
                'eslint' => '^8.19.0',
                'jest' => '^29.2.1',
                'typescript' => '^5.0.4'
            ]
        ];
        
        // App.js dosyası
        $app_js = <<<EOT
/**
 * ŞikayetVar React Native Uygulaması
 * @version {$settings['app_version']}
 */

import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/Ionicons';

// Ekranlar
import HomeScreen from './src/screens/HomeScreen';
import ComplaintsScreen from './src/screens/ComplaintsScreen';
import PharmaciesScreen from './src/screens/PharmaciesScreen';
import ProfileScreen from './src/screens/ProfileScreen';

// API ve yardımcılar
import { API_CONFIG } from './src/config/api';

const Tab = createBottomTabNavigator();

const App = () => {
  // API konfigürasyonunu ayarla
  API_CONFIG.BASE_URL = '{$settings['api_url']}';
  API_CONFIG.DEBUG = {$settings['debug_mode'] ? 'true' : 'false'};

  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <Tab.Navigator
          screenOptions={{
            tabBarActiveTintColor: '{$settings['primary_color']}',
            tabBarInactiveTintColor: 'gray',
            headerStyle: {
              backgroundColor: '{$settings['primary_color']}',
            },
            headerTintColor: '#fff',
            headerTitleStyle: {
              fontWeight: 'bold',
            },
          }}
        >
          <Tab.Screen 
            name="Ana Sayfa" 
            component={HomeScreen} 
            options={{
              tabBarIcon: ({ color, size }) => (
                <Icon name="home-outline" color={color} size={size} />
              ),
            }}
          />
          <Tab.Screen 
            name="Şikayetler" 
            component={ComplaintsScreen} 
            options={{
              tabBarIcon: ({ color, size }) => (
                <Icon name="chatbubble-outline" color={color} size={size} />
              ),
            }}
          />
          <Tab.Screen 
            name="Eczaneler" 
            component={PharmaciesScreen} 
            options={{
              tabBarIcon: ({ color, size }) => (
                <Icon name="medkit-outline" color={color} size={size} />
              ),
            }}
          />
          <Tab.Screen 
            name="Profil" 
            component={ProfileScreen} 
            options={{
              tabBarIcon: ({ color, size }) => (
                <Icon name="person-outline" color={color} size={size} />
              ),
            }}
          />
        </Tab.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
};

export default App;
EOT;

        // API konfigürasyon dosyası
        $api_config_js = <<<EOT
/**
 * API Konfigürasyonu
 */

export const API_CONFIG = {
  BASE_URL: '{$settings['api_url']}',
  TIMEOUT: 10000,
  DEBUG: {$settings['debug_mode'] ? 'true' : 'false'},
};

export const ENDPOINTS = {
  LOGIN: '/login',
  REGISTER: '/register',
  PROFILE: '/profile',
  COMPLAINTS: '/complaints',
  SURVEYS: '/surveys',
  PHARMACIES: '/pharmacies',
};

export default {
  API_CONFIG,
  ENDPOINTS,
};
EOT;

        // Eczane ekranı örneği
        $pharmacy_screen_js = <<<EOT
/**
 * Nöbetçi Eczaneler Ekranı
 */

import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, ActivityIndicator, TouchableOpacity, Alert } from 'react-native';
import { fetchPharmacies } from '../services/pharmacyService';
import { Linking } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

const PharmaciesScreen = () => {
  const [loading, setLoading] = useState(true);
  const [pharmacies, setPharmacies] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadPharmacies();
  }, []);

  const loadPharmacies = async () => {
    try {
      setLoading(true);
      const city = 'Ankara'; // Varsayılan şehir
      const district = 'Çankaya'; // Varsayılan ilçe
      const result = await fetchPharmacies(city, district);
      
      if (result.pharmacies) {
        setPharmacies(result.pharmacies);
      } else {
        setError('Eczane verisi bulunamadı');
      }
    } catch (err) {
      setError('Eczane verileri yüklenirken bir hata oluştu: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const openMaps = (pharmacy) => {
    const { latitude, longitude, name } = pharmacy;
    if (latitude && longitude) {
      const url = `https://www.google.com/maps/dir/?api=1&destination=\${latitude},\${longitude}&travelmode=driving`;
      Linking.canOpenURL(url).then(supported => {
        if (supported) {
          Linking.openURL(url);
        } else {
          Alert.alert('Hata', 'Harita uygulaması açılamadı');
        }
      });
    } else {
      Alert.alert('Bilgi', 'Bu eczane için konum bilgisi bulunamadı');
    }
  };

  const callPharmacy = (phone) => {
    const url = `tel:\${phone}`;
    Linking.canOpenURL(url).then(supported => {
      if (supported) {
        Linking.openURL(url);
      } else {
        Alert.alert('Hata', 'Telefon uygulaması açılamadı');
      }
    });
  };

  const renderPharmacy = ({ item, index }) => (
    <View style={styles.pharmacyCard}>
      <Text style={styles.pharmacyName}>{index + 1}. {item.name}</Text>
      <Text style={styles.pharmacyAddress}>{item.address}</Text>
      <Text style={styles.pharmacyPhone}>{item.phone}</Text>
      <View style={styles.actionButtons}>
        <TouchableOpacity style={styles.actionButton} onPress={() => openMaps(item)}>
          <Icon name="navigate-outline" size={16} color="#1976d2" />
          <Text style={styles.actionButtonText}>Yol Tarifi</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton} onPress={() => callPharmacy(item.phone)}>
          <Icon name="call-outline" size={16} color="#1976d2" />
          <Text style={styles.actionButtonText}>Ara</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="{$settings['primary_color']}" />
        <Text style={styles.loadingText}>Nöbetçi eczaneler yükleniyor...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centered}>
        <Icon name="alert-circle-outline" size={48} color="#f44336" />
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={loadPharmacies}>
          <Text style={styles.retryButtonText}>Tekrar Dene</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={pharmacies}
        renderItem={renderPharmacy}
        keyExtractor={(item, index) => index.toString()}
        ListHeaderComponent={() => (
          <View style={styles.headerContainer}>
            <Text style={styles.headerTitle}>Nöbetçi Eczaneler</Text>
            <Text style={styles.headerSubtitle}>Ankara / Çankaya</Text>
          </View>
        )}
        ListEmptyComponent={() => (
          <View style={styles.emptyContainer}>
            <Icon name="medkit-outline" size={48} color="#757575" />
            <Text style={styles.emptyText}>Nöbetçi eczane bulunamadı</Text>
          </View>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  errorText: {
    marginTop: 10,
    fontSize: 16,
    color: '#f44336',
    textAlign: 'center',
  },
  retryButton: {
    marginTop: 20,
    paddingVertical: 10,
    paddingHorizontal: 20,
    backgroundColor: '{$settings['primary_color']}',
    borderRadius: 4,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  headerContainer: {
    padding: 15,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
    marginBottom: 10,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  pharmacyCard: {
    backgroundColor: '#fff',
    padding: 15,
    marginHorizontal: 10,
    marginBottom: 10,
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
  },
  pharmacyName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  pharmacyAddress: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  pharmacyPhone: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  actionButtons: {
    flexDirection: 'row',
    marginTop: 5,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
    borderRadius: 4,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    marginRight: 10,
  },
  actionButtonText: {
    fontSize: 12,
    color: '#1976d2',
    marginLeft: 4,
  },
  emptyContainer: {
    padding: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyText: {
    marginTop: 10,
    fontSize: 16,
    color: '#757575',
    textAlign: 'center',
  },
});

export default PharmaciesScreen;
EOT;

        // Eczane servisi
        $pharmacy_service_js = <<<EOT
/**
 * Eczane Servis API
 */
import axios from 'axios';
import { API_CONFIG } from '../config/api';

export const fetchPharmacies = async (city, district = null) => {
  try {
    let url = `\${API_CONFIG.BASE_URL}/pharmacies?city=\${encodeURIComponent(city)}`;
    
    if (district) {
      url += `&district=\${encodeURIComponent(district)}`;
    }
    
    const response = await axios.get(url, {
      timeout: API_CONFIG.TIMEOUT
    });
    
    return response.data;
  } catch (error) {
    if (API_CONFIG.DEBUG) {
      console.error('Eczane API hatası:', error);
    }
    throw new Error('Eczane bilgileri alınamadı');
  }
};

export const fetchPharmaciesByLocation = async (city, lat, lng, district = null) => {
  try {
    let url = `\${API_CONFIG.BASE_URL}/pharmacies/by_distance?city=\${encodeURIComponent(city)}&lat=\${lat}&lng=\${lng}`;
    
    if (district) {
      url += `&district=\${encodeURIComponent(district)}`;
    }
    
    const response = await axios.get(url, {
      timeout: API_CONFIG.TIMEOUT
    });
    
    return response.data;
  } catch (error) {
    if (API_CONFIG.DEBUG) {
      console.error('Eczane API hatası:', error);
    }
    throw new Error('Konum bazlı eczane bilgileri alınamadı');
  }
};
EOT;

        // Projeyi kopyalama veya oluşturma işlemini yap
        try {
            // Ana proje dosyalarını oluştur
            file_put_contents($project_path . '/package.json', json_encode($package_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
            file_put_contents($project_path . '/App.js', $app_js);
            
            // src klasörü ve alt klasörlerini oluştur
            if (!file_exists($project_path . '/src')) {
                mkdir($project_path . '/src', 0755, true);
            }
            
            if (!file_exists($project_path . '/src/config')) {
                mkdir($project_path . '/src/config', 0755, true);
            }
            
            if (!file_exists($project_path . '/src/screens')) {
                mkdir($project_path . '/src/screens', 0755, true);
            }
            
            if (!file_exists($project_path . '/src/services')) {
                mkdir($project_path . '/src/services', 0755, true);
            }
            
            // Dosyaları oluştur
            file_put_contents($project_path . '/src/config/api.js', $api_config_js);
            file_put_contents($project_path . '/src/screens/PharmaciesScreen.js', $pharmacy_screen_js);
            file_put_contents($project_path . '/src/services/pharmacyService.js', $pharmacy_service_js);
            
            // Diğer gerekli ekranlar için iskelet dosyalar oluştur
            $screens = ['HomeScreen', 'ComplaintsScreen', 'ProfileScreen'];
            foreach ($screens as $screen) {
                $screen_content = <<<EOT
/**
 * {$screen} Ekranı
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const {$screen} = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>{$screen} İçeriği</Text>
      <Text style={styles.subText}>Bu ekran React Native projesi içinde geliştirilecek</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  text: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
});

export default {$screen};
EOT;
                file_put_contents($project_path . '/src/screens/' . $screen . '.js', $screen_content);
            }
            
            // README dosyası oluştur
            $readme_content = <<<EOT
# {$settings['app_name']} React Native Uygulaması

Bu proje, ŞikayetVar platformunun React Native versiyonudur.

## Kurulum

1. Node.js 18 veya üstü yükleyin
2. `npm install` komutunu çalıştırın
3. Android için: Android Studio'yu yükleyin ve bir emülatör oluşturun
4. iOS için (sadece macOS): `cd ios && pod install` komutunu çalıştırın

## Çalıştırma

- Android: `npm run android`
- iOS: `npm run ios`
- Metro sunucusu: `npm start`

## Özellikler

- Şikayet gönderme ve takip etme
- Anketlere katılma
- Nöbetçi eczane bulma
- Kullanıcı profili yönetimi

## API Bağlantısı

API URL: {$settings['api_url']}

## Sürüm Geçmişi

- {$settings['app_version']}: İlk sürüm
EOT;
            file_put_contents($project_path . '/README.md', $readme_content);
            
            return [
                'success' => true,
                'message' => 'React Native Projesi başarıyla oluşturuldu!',
                'path' => $project_path
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Proje oluşturulurken hata: ' . $e->getMessage()
            ];
        }
    }
}

// Eklenti menülerini kaydeder
function register_react_native_menus() {
    $main_menu = [
        'page' => 'react_native_app',
        'title' => 'Mobil Uygulama',
        'icon' => 'fa-solid fa-mobile-screen',
        'order' => 60
    ];
    
    add_menu_item($main_menu);
}

// Admin paneli için sayfayı yükle
function load_react_native_admin_page() {
    include __DIR__ . '/templates/admin_page.php';
}

// Sayfa yönlendirmelerini kaydet
add_page_route('react_native_app', 'load_react_native_admin_page');

// Menüleri kaydet
register_react_native_menus();