<?php
/**
 * React Native Mobil Uygulama Eklentisi - Ana Dosya
 * 
 * Bu eklenti, Flutter yerine React Native tabanlı mobil uygulama geliştirmeyi sağlar.
 */

// Eklenti aktif edildiğinde çalışacak işlevler
function react_native_app_init() {
    // Eklenti kurulumu tamamlandı, gerekli sayfaları oluştur
    error_log("React Native Mobil Uygulama eklentisi başlatıldı");
    
    // Admin panel için mobil app sayfasını kopyala (varsa)
    if (!file_exists(__DIR__ . '/../../pages/mobile_app.php')) {
        if (file_exists(__DIR__ . '/templates/admin_page.php')) {
            copy(__DIR__ . '/templates/admin_page.php', __DIR__ . '/../../pages/mobile_app.php');
            error_log("React Native mobil uygulama yönetim sayfası oluşturuldu");
        }
    }
}

// Eklenti devre dışı bırakıldığında çalışacak temizleme işlevi
function react_native_app_cleanup() {
    error_log("React Native Mobil Uygulama eklentisi devre dışı bırakıldı");
}

// Eklenti ayarlarını alma fonksiyonu
function get_app_settings($db) {
    global $plugin_config;
    
    // Veritabanında kayıtlı ayarları al veya varsayılanları kullan
    if (!isset($plugin_config) || empty($plugin_config)) {
        // Ayarlar dosyasını dahil et
        require_once __DIR__ . '/settings.php';
        
        // Veritabanından eklenti yapılandırmasını al
        $plugin_config = getPluginConfig($db, 'react_native_app');
        
        // Varsayılan değerleri ayarlanmayan alanlar için kullan
        foreach ($plugin_settings as $key => $setting) {
            if (!isset($plugin_config[$key])) {
                $plugin_config[$key] = $setting['default'] ?? '';
            }
        }
    }
    
    return $plugin_config;
}

// React Native projesi oluşturacak fonksiyon
function create_react_native_project($settings) {
    $app_name = preg_replace('/[^a-zA-Z0-9]/', '', $settings['app_name']);
    $output_dir = __DIR__ . '/../../../react_native_app';
    
    // Klasör yoksa oluştur
    if (!file_exists($output_dir)) {
        mkdir($output_dir, 0755, true);
    }
    
    // Proje yapısını oluştur
    create_project_structure($output_dir, $settings);
    
    return [
        'success' => true,
        'message' => 'React Native proje yapısı oluşturuldu',
        'path' => $output_dir
    ];
}

// Proje yapısını oluşturacak fonksiyon
function create_project_structure($output_dir, $settings) {
    // src klasörü
    mkdir($output_dir . '/src', 0755, true);
    
    // src altındaki klasörler
    $folders = [
        '/src/api',
        '/src/assets',
        '/src/components',
        '/src/screens',
        '/src/navigation',
        '/src/hooks',
        '/src/utils',
        '/src/context',
        '/src/config',
        '/src/styles',
        '/src/assets/images',
        '/src/assets/fonts'
    ];
    
    foreach ($folders as $folder) {
        if (!file_exists($output_dir . $folder)) {
            mkdir($output_dir . $folder, 0755, true);
        }
    }
    
    // Proje dosyalarını oluştur
    create_project_files($output_dir, $settings);
}

// Proje dosyalarını oluşturacak fonksiyon
function create_project_files($output_dir, $settings) {
    // package.json
    $package_json = [
        'name' => strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $settings['app_name'])),
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
            'react-native' => '0.73.3',
            'react-native-gesture-handler' => '^2.15.0',
            'react-native-reanimated' => '^3.6.1',
            'react-native-safe-area-context' => '^4.8.2',
            'react-native-screens' => '^3.29.0',
            '@react-navigation/native' => '^6.1.9',
            '@react-navigation/stack' => '^6.3.20',
            '@react-navigation/bottom-tabs' => '^6.5.11',
            'axios' => '^1.6.7',
            'react-hook-form' => '^7.50.0',
            'zustand' => '^4.4.7'
        ],
        'devDependencies' => [
            '@babel/core' => '^7.20.0',
            '@babel/preset-env' => '^7.20.0',
            '@babel/runtime' => '^7.20.0',
            '@react-native/eslint-config' => '^0.73.2',
            '@react-native/metro-config' => '^0.73.4',
            '@tsconfig/react-native' => '^3.0.3',
            '@types/react' => '^18.2.48',
            '@types/react-test-renderer' => '^18.0.7',
            'babel-jest' => '^29.7.0',
            'eslint' => '^8.56.0',
            'jest' => '^29.7.0',
            'metro-react-native-babel-preset' => '0.77.0',
            'prettier' => '^3.2.4',
            'react-test-renderer' => '18.2.0',
            'typescript' => '^5.3.3'
        ]
    ];
    
    // Seçilen özellikleri kontrol et
    $features = explode(',', $settings['features']);
    
    // Harita özelliği aktifse
    if (in_array('map', $features) || in_array('pharmacies', $features)) {
        if ($settings['map_type'] === 'google') {
            $package_json['dependencies']['react-native-maps'] = '^1.10.0';
        } else if ($settings['map_type'] === 'mapbox') {
            $package_json['dependencies']['@rnmapbox/maps'] = '^10.1.8';
        }
    }
    
    // Push bildirimler aktifse
    if ($settings['enable_push_notifications'] === '1') {
        $package_json['dependencies']['@react-native-firebase/app'] = '^18.8.0';
        $package_json['dependencies']['@react-native-firebase/messaging'] = '^18.8.0';
    }
    
    file_put_contents($output_dir . '/package.json', json_encode($package_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
    
    // App.tsx
    $app_tsx = "import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import MainNavigator from './src/navigation/MainNavigator';
import { AppContextProvider } from './src/context/AppContext';

const App = () => {
  return (
    <SafeAreaProvider>
      <AppContextProvider>
        <NavigationContainer>
          <MainNavigator />
        </NavigationContainer>
      </AppContextProvider>
    </SafeAreaProvider>
  );
};

export default App;
";
    file_put_contents($output_dir . '/App.tsx', $app_tsx);
    
    // API yapılandırması
    $api_config = "import axios from 'axios';

const API_URL = '" . $settings['api_url'] . "';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for API calls
api.interceptors.request.use(
  async (config) => {
    // You can retrieve the token from storage and set it here
    // const token = await AsyncStorage.getItem('auth_token');
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for API calls
api.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    // Handle 401 or other errors here
    return Promise.reject(error);
  }
);

export default api;
";
    file_put_contents($output_dir . '/src/api/api.ts', $api_config);
    
    // Tema yapılandırması
    $theme_config = "import { Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');

export const COLORS = {
  primary: '" . $settings['primary_color'] . "',
  secondary: '#FF6B6B',
  accent: '#4ECDC4',
  
  // Neutral colors
  white: '#FFFFFF',
  black: '#000000',
  gray: '#9DA3B4',
  lightGray: '#F1F4F8',
  darkGray: '#6B7280',
  
  // Status colors
  success: '#06D6A0',
  warning: '#FFD166',
  error: '#EF476F',
  info: '#118AB2',
  
  // Component colors
  background: '#F8FAFC',
  card: '#FFFFFF',
  text: '#1F2937',
  border: '#E2E8F0',
  notification: '#EF476F',
};

export const SIZES = {
  // Global sizes
  base: 8,
  font: 14,
  radius: 12,
  padding: 24,
  
  // Font sizes
  largeTitle: 40,
  h1: 30,
  h2: 22,
  h3: 18,
  h4: 16,
  body1: 30,
  body2: 22,
  body3: 16,
  body4: 14,
  body5: 12,
  
  // App dimensions
  width,
  height,
};

export const FONTS = {
  largeTitle: { fontSize: SIZES.largeTitle, lineHeight: 55 },
  h1: { fontSize: SIZES.h1, lineHeight: 36 },
  h2: { fontSize: SIZES.h2, lineHeight: 30 },
  h3: { fontSize: SIZES.h3, lineHeight: 22 },
  h4: { fontSize: SIZES.h4, lineHeight: 20 },
  body1: { fontSize: SIZES.body1, lineHeight: 36 },
  body2: { fontSize: SIZES.body2, lineHeight: 30 },
  body3: { fontSize: SIZES.body3, lineHeight: 22 },
  body4: { fontSize: SIZES.body4, lineHeight: 20 },
  body5: { fontSize: SIZES.body5, lineHeight: 18 },
};

const appTheme = { COLORS, SIZES, FONTS };

export default appTheme;
";
    file_put_contents($output_dir . '/src/config/theme.ts', $theme_config);
    
    // Ana navigasyon
    $main_navigator = "import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import Icon from 'react-native-vector-icons/Ionicons';

// Screens
import HomeScreen from '../screens/HomeScreen';
import ProfileScreen from '../screens/ProfileScreen';
import AuthScreen from '../screens/AuthScreen';

// Context
import { useAppContext } from '../context/AppContext';
import { COLORS } from '../config/theme';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

const AuthStack = () => {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name=\"Auth\" component={AuthScreen} />
    </Stack.Navigator>
  );
};

const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: COLORS.primary,
        tabBarInactiveTintColor: COLORS.gray,
        tabBarLabelStyle: {
          fontSize: 12,
        },
        tabBarStyle: {
          backgroundColor: COLORS.white,
          borderTopWidth: 1,
          borderTopColor: COLORS.lightGray,
        },
      })}
    >
      <Tab.Screen name=\"Home\" component={HomeScreen} options={{ title: 'Ana Sayfa' }} />
      <Tab.Screen name=\"Profile\" component={ProfileScreen} options={{ title: 'Profilim' }} />
    </Tab.Navigator>
  );
};

const MainNavigator = () => {
  const { state } = useAppContext();
  
  return state.user ? <MainTabs /> : <AuthStack />;
};

export default MainNavigator;
";
    file_put_contents($output_dir . '/src/navigation/MainNavigator.tsx', $main_navigator);
    
    // Context
    $app_context = "import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// Define the state type
interface AppState {
  user: any | null; // Replace 'any' with a more specific user type
  isLoading: boolean;
  darkMode: boolean;
}

// Define action types
type AppAction =
  | { type: 'SET_USER'; payload: any }
  | { type: 'CLEAR_USER' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'TOGGLE_DARK_MODE' };

// Initial state
const initialState: AppState = {
  user: null,
  isLoading: false,
  darkMode: false,
};

// Create the context
interface AppContextProps {
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
}

const AppContext = createContext<AppContextProps | undefined>(undefined);

// Reducer function
const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'SET_USER':
      return {
        ...state,
        user: action.payload,
      };
    case 'CLEAR_USER':
      return {
        ...state,
        user: null,
      };
    case 'SET_LOADING':
      return {
        ...state,
        isLoading: action.payload,
      };
    case 'TOGGLE_DARK_MODE':
      return {
        ...state,
        darkMode: !state.darkMode,
      };
    default:
      return state;
  }
};

// Context provider
export const AppContextProvider = ({ children }: { children: ReactNode }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
};

// Custom hook to use the context
export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppContextProvider');
  }
  return context;
};
";
    file_put_contents($output_dir . '/src/context/AppContext.tsx', $app_context);
    
    // Örnek ekranlar
    
    // HomeScreen
    $home_screen = "import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, RefreshControl, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import api from '../api/api';
import { COLORS, FONTS, SIZES } from '../config/theme';

// Ekran görüntüsü
const HomeScreen = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');

  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await api.get('/posts');
      setPosts(response.data || []);
      setError('');
    } catch (err) {
      console.error('Post verileri alınamadı:', err);
      setError('Gönderiler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchPosts();
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  const renderPostItem = ({ item }) => (
    <TouchableOpacity style={styles.postCard}>
      <View style={styles.postHeader}>
        <Text style={styles.postTitle}>{item.title}</Text>
        <Text style={styles.postLocation}>{item.city_name || 'Bilinmeyen Şehir'}{item.district_name ? `, ${item.district_name}` : ''}</Text>
      </View>
      <Text style={styles.postContent} numberOfLines={3}>{item.content}</Text>
      <View style={styles.postFooter}>
        <View style={styles.postStat}>
          <Text style={styles.postStatIcon}>👍</Text>
          <Text style={styles.postStatValue}>{item.likes || 0}</Text>
        </View>
        <View style={styles.postStat}>
          <Text style={styles.postStatIcon}>💬</Text>
          <Text style={styles.postStatValue}>{item.comment_count || 0}</Text>
        </View>
        <View style={[styles.postStat, styles.postStatus]}>
          <Text style={styles.postStatusText}>{getStatusText(item.status)}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  const getStatusText = (status) => {
    switch (status) {
      case 'awaitingSolution': return 'Çözüm Bekliyor';
      case 'inProgress': return 'İşlemde';
      case 'solved': return 'Çözüldü';
      case 'rejected': return 'Reddedildi';
      default: return 'Bilinmiyor';
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>ŞikayetVar</Text>
      </View>

      {error ? (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={fetchPosts}>
            <Text style={styles.retryButtonText}>Tekrar Dene</Text>
          </TouchableOpacity>
        </View>
      ) : loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size=\"large\" color={COLORS.primary} />
          <Text style={styles.loadingText}>Gönderiler yükleniyor...</Text>
        </View>
      ) : (
        <FlatList
          data={posts}
          renderItem={renderPostItem}
          keyExtractor={(item) => item.id.toString()}
          contentContainerStyle={styles.listContainer}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={[COLORS.primary]} />
          }
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>Gösterilecek gönderi bulunmuyor</Text>
            </View>
          }
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    backgroundColor: COLORS.primary,
    padding: SIZES.padding,
    paddingTop: SIZES.padding / 2,
    paddingBottom: SIZES.padding / 2,
  },
  headerTitle: {
    ...FONTS.h2,
    color: COLORS.white,
    textAlign: 'center',
  },
  listContainer: {
    padding: SIZES.padding,
  },
  postCard: {
    backgroundColor: COLORS.white,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    marginBottom: SIZES.padding,
    shadowColor: COLORS.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  postHeader: {
    marginBottom: 10,
  },
  postTitle: {
    ...FONTS.h3,
    color: COLORS.text,
    marginBottom: 5,
  },
  postLocation: {
    ...FONTS.body5,
    color: COLORS.primary,
  },
  postContent: {
    ...FONTS.body4,
    color: COLORS.text,
    marginBottom: 10,
  },
  postFooter: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: COLORS.lightGray,
    paddingTop: 10,
  },
  postStat: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 15,
  },
  postStatIcon: {
    marginRight: 5,
  },
  postStatValue: {
    ...FONTS.body5,
    color: COLORS.darkGray,
  },
  postStatus: {
    marginLeft: 'auto',
  },
  postStatusText: {
    ...FONTS.body5,
    color: COLORS.primary,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    ...FONTS.body4,
    color: COLORS.darkGray,
    marginTop: 10,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: SIZES.padding,
  },
  errorText: {
    ...FONTS.body3,
    color: COLORS.error,
    textAlign: 'center',
    marginBottom: 20,
  },
  retryButton: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: SIZES.radius,
  },
  retryButtonText: {
    ...FONTS.body4,
    color: COLORS.white,
  },
  emptyContainer: {
    padding: SIZES.padding * 2,
    alignItems: 'center',
  },
  emptyText: {
    ...FONTS.body3,
    color: COLORS.darkGray,
  },
});

export default HomeScreen;
";
    file_put_contents($output_dir . '/src/screens/HomeScreen.tsx', $home_screen);
    
    // ProfileScreen
    $profile_screen = "import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Image, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppContext } from '../context/AppContext';
import { COLORS, FONTS, SIZES } from '../config/theme';

const ProfileScreen = () => {
  const { state, dispatch } = useAppContext();
  
  // Örnek çıkış işlevi
  const handleLogout = () => {
    dispatch({ type: 'CLEAR_USER' });
  };
  
  // Örnek kullanıcı verisi
  const user = state.user || {
    name: 'Demo Kullanıcı',
    username: 'demouser',
    email: 'demo@example.com',
    profile_image_url: 'https://ui-avatars.com/api/?name=Demo+Kullanıcı&background=random',
    post_count: 5,
    comment_count: 12,
    points: 120,
    level: 'contributor',
    city_name: 'İstanbul',
    district_name: 'Kadıköy'
  };
  
  const getLevelLabel = (level) => {
    switch (level) {
      case 'newUser': return 'Yeni Kullanıcı';
      case 'contributor': return 'Katkıda Bulunan';
      case 'active': return 'Aktif Kullanıcı';
      case 'expert': return 'Uzman';
      case 'master': return 'Usta';
      default: return 'Bilinmiyor';
    }
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Profil</Text>
      </View>
      
      <ScrollView style={styles.scrollView}>
        <View style={styles.profileHeader}>
          <View style={styles.avatarContainer}>
            <Image
              source={{ uri: user.profile_image_url }}
              style={styles.avatar}
              defaultSource={require('../assets/images/default-avatar.png')}
            />
          </View>
          <View style={styles.userInfo}>
            <Text style={styles.userName}>{user.name}</Text>
            <Text style={styles.userUsername}>@{user.username}</Text>
            <View style={styles.levelBadge}>
              <Text style={styles.levelText}>{getLevelLabel(user.level)}</Text>
            </View>
          </View>
        </View>
        
        <View style={styles.statsContainer}>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{user.post_count}</Text>
            <Text style={styles.statLabel}>Gönderiler</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{user.comment_count}</Text>
            <Text style={styles.statLabel}>Yorumlar</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{user.points}</Text>
            <Text style={styles.statLabel}>Puanlar</Text>
          </View>
        </View>
        
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionTitle}>Kişisel Bilgiler</Text>
          <View style={styles.detailItem}>
            <Text style={styles.detailLabel}>E-posta</Text>
            <Text style={styles.detailValue}>{user.email}</Text>
          </View>
          <View style={styles.detailItem}>
            <Text style={styles.detailLabel}>Konum</Text>
            <Text style={styles.detailValue}>{user.city_name}{user.district_name ? `, ${user.district_name}` : ''}</Text>
          </View>
        </View>
        
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionTitle}>Hesap Ayarları</Text>
          <TouchableOpacity style={styles.settingItem}>
            <Text style={styles.settingText}>Profili Düzenle</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.settingItem}>
            <Text style={styles.settingText}>Şifre Değiştir</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.settingItem}>
            <Text style={styles.settingText}>Bildirim Ayarları</Text>
          </TouchableOpacity>
        </View>
        
        <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
          <Text style={styles.logoutButtonText}>Çıkış Yap</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    backgroundColor: COLORS.primary,
    padding: SIZES.padding,
    paddingTop: SIZES.padding / 2,
    paddingBottom: SIZES.padding / 2,
  },
  headerTitle: {
    ...FONTS.h2,
    color: COLORS.white,
    textAlign: 'center',
  },
  scrollView: {
    flex: 1,
  },
  profileHeader: {
    padding: SIZES.padding,
    backgroundColor: COLORS.white,
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatarContainer: {
    marginRight: 20,
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: COLORS.lightGray,
  },
  userInfo: {
    flex: 1,
  },
  userName: {
    ...FONTS.h3,
    color: COLORS.text,
  },
  userUsername: {
    ...FONTS.body4,
    color: COLORS.darkGray,
    marginBottom: 5,
  },
  levelBadge: {
    backgroundColor: COLORS.primary,
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 2,
    alignSelf: 'flex-start',
  },
  levelText: {
    ...FONTS.body5,
    color: COLORS.white,
  },
  statsContainer: {
    flexDirection: 'row',
    backgroundColor: COLORS.white,
    marginTop: 1,
    padding: SIZES.padding,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statValue: {
    ...FONTS.h3,
    color: COLORS.primary,
  },
  statLabel: {
    ...FONTS.body5,
    color: COLORS.darkGray,
  },
  statDivider: {
    width: 1,
    backgroundColor: COLORS.lightGray,
  },
  sectionContainer: {
    backgroundColor: COLORS.white,
    padding: SIZES.padding,
    marginTop: 20,
  },
  sectionTitle: {
    ...FONTS.h4,
    color: COLORS.text,
    marginBottom: 15,
  },
  detailItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.lightGray,
  },
  detailLabel: {
    ...FONTS.body4,
    color: COLORS.darkGray,
  },
  detailValue: {
    ...FONTS.body4,
    color: COLORS.text,
  },
  settingItem: {
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.lightGray,
  },
  settingText: {
    ...FONTS.body3,
    color: COLORS.text,
  },
  logoutButton: {
    margin: SIZES.padding,
    backgroundColor: COLORS.error,
    borderRadius: SIZES.radius,
    padding: 15,
    alignItems: 'center',
    marginBottom: 30,
  },
  logoutButtonText: {
    ...FONTS.body3,
    color: COLORS.white,
    fontWeight: '600',
  },
});

export default ProfileScreen;
";
    file_put_contents($output_dir . '/src/screens/ProfileScreen.tsx', $profile_screen);
    
    // AuthScreen
    $auth_screen = "import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, Image, ScrollView, KeyboardAvoidingView, Platform, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppContext } from '../context/AppContext';
import api from '../api/api';
import { COLORS, FONTS, SIZES } from '../config/theme';

const AuthScreen = () => {
  const { dispatch } = useAppContext();
  const [isLogin, setIsLogin] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  // Login form
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  
  // Register form
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  
  const handleLogin = async () => {
    // Validation
    if (!username || !password) {
      setError('Lütfen tüm alanları doldurun');
      return;
    }
    
    setIsLoading(true);
    setError('');
    
    try {
      const response = await api.post('/login', {
        username,
        password
      });
      
      if (response.data) {
        dispatch({ type: 'SET_USER', payload: response.data });
      } else {
        setError('Giriş yapılamadı. Lütfen bilgilerinizi kontrol edin.');
      }
    } catch (err) {
      console.error('Login error:', err);
      setError('Giriş yapılamadı. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleRegister = async () => {
    // Validation
    if (!name || !username || !email || !password || !confirmPassword) {
      setError('Lütfen tüm alanları doldurun');
      return;
    }
    
    if (password !== confirmPassword) {
      setError('Şifreler eşleşmiyor');
      return;
    }
    
    setIsLoading(true);
    setError('');
    
    try {
      const response = await api.post('/register', {
        name,
        username,
        email,
        password
      });
      
      if (response.data) {
        dispatch({ type: 'SET_USER', payload: response.data });
      } else {
        setError('Kayıt yapılamadı. Lütfen bilgilerinizi kontrol edin.');
      }
    } catch (err) {
      console.error('Register error:', err);
      setError('Kayıt yapılamadı. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setIsLoading(false);
    }
  };
  
  // For demo/development purposes
  const handleDemoLogin = () => {
    dispatch({ 
      type: 'SET_USER', 
      payload: {
        id: 1,
        name: 'Demo Kullanıcı',
        username: 'demouser',
        email: 'demo@example.com',
        profile_image_url: 'https://ui-avatars.com/api/?name=Demo+Kullanıcı&background=random',
        post_count: 5,
        comment_count: 12,
        points: 120,
        level: 'contributor',
        city_name: 'İstanbul',
        district_name: 'Kadıköy'
      } 
    });
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
      >
        <ScrollView contentContainerStyle={styles.scrollContainer}>
          <View style={styles.logoContainer}>
            <Image 
              source={require('../assets/images/logo.png')} 
              style={styles.logo}
              defaultSource={require('../assets/images/logo-placeholder.png')}
            />
            <Text style={styles.appName}>ŞikayetVar</Text>
            <Text style={styles.appSlogan}>Şehrinizi iyileştirmek için sesinizi duyurun</Text>
          </View>
          
          <View style={styles.formContainer}>
            <View style={styles.tabContainer}>
              <TouchableOpacity
                style={[styles.tab, isLogin ? styles.activeTab : null]}
                onPress={() => {
                  setIsLogin(true);
                  setError('');
                }}
              >
                <Text style={[styles.tabText, isLogin ? styles.activeTabText : null]}>Giriş Yap</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.tab, !isLogin ? styles.activeTab : null]}
                onPress={() => {
                  setIsLogin(false);
                  setError('');
                }}
              >
                <Text style={[styles.tabText, !isLogin ? styles.activeTabText : null]}>Kayıt Ol</Text>
              </TouchableOpacity>
            </View>
            
            {error ? <Text style={styles.errorText}>{error}</Text> : null}
            
            {isLogin ? (
              // Login Form
              <View style={styles.form}>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Kullanıcı Adı</Text>
                  <TextInput 
                    style={styles.input}
                    value={username}
                    onChangeText={setUsername}
                    placeholder=\"Kullanıcı adınızı girin\"
                    autoCapitalize=\"none\"
                  />
                </View>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Şifre</Text>
                  <TextInput 
                    style={styles.input}
                    value={password}
                    onChangeText={setPassword}
                    placeholder=\"Şifrenizi girin\"
                    secureTextEntry
                  />
                </View>
                <TouchableOpacity style={styles.forgotPassword}>
                  <Text style={styles.forgotPasswordText}>Şifremi Unuttum</Text>
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={styles.submitButton}
                  onPress={handleLogin}
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <ActivityIndicator color={COLORS.white} />
                  ) : (
                    <Text style={styles.submitButtonText}>Giriş Yap</Text>
                  )}
                </TouchableOpacity>
              </View>
            ) : (
              // Register Form
              <View style={styles.form}>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Ad Soyad</Text>
                  <TextInput 
                    style={styles.input}
                    value={name}
                    onChangeText={setName}
                    placeholder=\"Adınızı ve soyadınızı girin\"
                  />
                </View>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Kullanıcı Adı</Text>
                  <TextInput 
                    style={styles.input}
                    value={username}
                    onChangeText={setUsername}
                    placeholder=\"Kullanıcı adı oluşturun\"
                    autoCapitalize=\"none\"
                  />
                </View>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>E-posta</Text>
                  <TextInput 
                    style={styles.input}
                    value={email}
                    onChangeText={setEmail}
                    placeholder=\"E-posta adresinizi girin\"
                    keyboardType=\"email-address\"
                    autoCapitalize=\"none\"
                  />
                </View>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Şifre</Text>
                  <TextInput 
                    style={styles.input}
                    value={password}
                    onChangeText={setPassword}
                    placeholder=\"Şifre oluşturun\"
                    secureTextEntry
                  />
                </View>
                <View style={styles.inputContainer}>
                  <Text style={styles.inputLabel}>Şifre (Tekrar)</Text>
                  <TextInput 
                    style={styles.input}
                    value={confirmPassword}
                    onChangeText={setConfirmPassword}
                    placeholder=\"Şifrenizi tekrar girin\"
                    secureTextEntry
                  />
                </View>
                
                <TouchableOpacity 
                  style={styles.submitButton}
                  onPress={handleRegister}
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <ActivityIndicator color={COLORS.white} />
                  ) : (
                    <Text style={styles.submitButtonText}>Kayıt Ol</Text>
                  )}
                </TouchableOpacity>
              </View>
            )}
            
            {/* Demo Login Button - Remove in production */}
            <TouchableOpacity style={styles.demoButton} onPress={handleDemoLogin}>
              <Text style={styles.demoButtonText}>Demo Hesabı ile Giriş</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1,
  },
  logoContainer: {
    alignItems: 'center',
    paddingTop: SIZES.padding * 2,
    paddingBottom: SIZES.padding,
  },
  logo: {
    width: 80,
    height: 80,
    marginBottom: 10,
  },
  appName: {
    ...FONTS.h1,
    color: COLORS.primary,
    marginBottom: 5,
  },
  appSlogan: {
    ...FONTS.body4,
    color: COLORS.darkGray,
    textAlign: 'center',
    paddingHorizontal: SIZES.padding,
  },
  formContainer: {
    flex: 1,
    backgroundColor: COLORS.white,
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    padding: SIZES.padding,
    marginTop: SIZES.padding,
  },
  tabContainer: {
    flexDirection: 'row',
    marginBottom: SIZES.padding,
  },
  tab: {
    flex: 1,
    paddingVertical: 15,
    alignItems: 'center',
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: COLORS.primary,
  },
  tabText: {
    ...FONTS.body3,
    color: COLORS.darkGray,
  },
  activeTabText: {
    color: COLORS.primary,
    fontWeight: '600',
  },
  form: {
    marginBottom: SIZES.padding,
  },
  inputContainer: {
    marginBottom: 15,
  },
  inputLabel: {
    ...FONTS.body4,
    color: COLORS.darkGray,
    marginBottom: 5,
  },
  input: {
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: 12,
    backgroundColor: COLORS.lightGray,
    ...FONTS.body4,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginBottom: 20,
  },
  forgotPasswordText: {
    ...FONTS.body5,
    color: COLORS.primary,
  },
  submitButton: {
    backgroundColor: COLORS.primary,
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
  },
  submitButtonText: {
    ...FONTS.body3,
    color: COLORS.white,
    fontWeight: '600',
  },
  errorText: {
    ...FONTS.body4,
    color: COLORS.error,
    marginBottom: 15,
    textAlign: 'center',
  },
  demoButton: {
    marginTop: 20,
    padding: 15,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
  },
  demoButtonText: {
    ...FONTS.body4,
    color: COLORS.darkGray,
  },
});

export default AuthScreen;
";
    file_put_contents($output_dir . '/src/screens/AuthScreen.tsx', $auth_screen);
    
    // Default placeholder images
    mkdir($output_dir . '/src/assets/images', 0755, true);
    
    return [
        'success' => true,
        'message' => 'React Native proje yapısı başarıyla oluşturuldu',
        'project_dir' => $output_dir
    ];
}

// Eklenti başlatma ve sonlanma fonksiyonlarını kaydet
register_plugin_hooks();

function register_plugin_hooks() {
    // Eklenti kancaları tanımla (plugin_manager.php'de kullanılacak)
    if (!function_exists('register_activation_hook')) {
        function register_activation_hook($plugin_slug, $callback) {
            // Bu sadece bir yer tutucu - gerçek uygulama plugin_manager.php'de yapılır
        }
    }
    
    if (!function_exists('register_deactivation_hook')) {
        function register_deactivation_hook($plugin_slug, $callback) {
            // Bu sadece bir yer tutucu - gerçek uygulama plugin_manager.php'de yapılır
        }
    }
    
    // Aktivasyon ve deaktivasyon kancalarını kaydet
    register_activation_hook('react_native_app', 'react_native_app_init');
    register_deactivation_hook('react_native_app', 'react_native_app_cleanup');
}

// Eklenti başlatıldı
react_native_app_init();
?>