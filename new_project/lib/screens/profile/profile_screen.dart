import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/utils/matrix_fix.dart';
import 'package:belediye_iletisim_merkezi/utils/ticker_fix.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/models/district.dart';
import 'package:belediye_iletisim_merkezi/models/auth_state.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';
import 'package:belediye_iletisim_merkezi/screens/profile/location_settings_screen.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SafeSingleTickerProviderStateMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TabController>('_tabController', null));
  }
  
  @override
  void activate() {
    super.activate();
  }
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _isLoggingIn = true;
  bool _isLoading = false;
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  
  // Helper method to build body based on auth state
  Widget _buildBody(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.unauthenticated:
        return _buildAuthForm();
      case AuthStatus.authenticating:
        return const Center(child: CircularProgressIndicator());
      case AuthStatus.authenticated:
        if (authState.user != null) {
          return _buildProfileView(authState.user!);
        } else {
          return _buildAuthForm();
        }
      case AuthStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu: ${authState.errorMessage ?? "Bilinmeyen hata"}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(authProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        );
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: _buildBody(authState),
    );
  }
  
  Widget _buildAuthForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          
          // App Logo or Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // App Name
          Center(
            child: Text(
              'ŞikayetVar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // App Slogan
          Center(
            child: Text(
              'Sesini duyur, değişime katkı sağla',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Auth Tabs
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isLoggingIn = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _isLoggingIn
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Giriş Yap',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _isLoggingIn ? FontWeight.bold : FontWeight.normal,
                        color: _isLoggingIn
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isLoggingIn = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !_isLoggingIn
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Kayıt Ol',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: !_isLoggingIn ? FontWeight.bold : FontWeight.normal,
                        color: !_isLoggingIn
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Form Fields
          if (!_isLoggingIn) ... [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
          ],
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            textInputAction: _isLoggingIn ? TextInputAction.done : TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          if (!_isLoggingIn) ... [
            // City selection
            FutureBuilder<List<City>>(
              future: ref.read(apiServiceProvider).getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Şehir verisi bulunamadı');
                }
                
                final cities = snapshot.data!;
                
                return DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'Şehir',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city.id,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCityId = newValue;
                      _selectedDistrictId = null; // Reset district when city changes
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // District selection (only if city is selected)
            if (_selectedCityId != null)
              FutureBuilder<List<District>>(
                future: ref.read(apiServiceProvider).getDistrictsByCityId(int.parse(_selectedCityId!)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('İlçe verisi bulunamadı');
                  }
                  
                  final districts = snapshot.data!;
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedDistrictId,
                    decoration: const InputDecoration(
                      labelText: 'İlçe',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('İlçe seçin (İsteğe bağlı)'),
                      ),
                      ...districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district.id,
                          child: Text(district.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrictId = newValue;
                      });
                    },
                  );
                },
              ),
              
            if (_selectedCityId != null)
              const SizedBox(height: 16),
          ],
          
          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitAuthForm,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isLoggingIn ? 'Giriş Yap' : 'Kayıt Ol'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Demo Login
          if (_isLoggingIn)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _emailController.text = 'test@example.com';
                      _passwordController.text = 'password';
                    },
              child: const Text('Demo hesabı kullan'),
            ),
        ],
      ),
    );
  }
  
  Future<void> _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta ve şifre gereklidir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_isLoggingIn) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad Soyad alanı gereklidir'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isLoggingIn) {
        await ref.read(authProvider.notifier).login(email, password);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Giriş başarılı!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final name = _nameController.text.trim();
        
        await ref.read(authProvider.notifier).register(
          name: name,
          email: email,
          password: password,
          cityId: _selectedCityId ?? "0",
          districtId: _selectedDistrictId ?? "",
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Giriş yapıldı.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Widget _buildProfileView(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          
          // Profile picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  )
                : null,
            backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                ? NetworkImage(user.profileImageUrl!)
                : null,
          ),
          const SizedBox(height: 16),
          
          // User name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // User email
          Text(
            user.email,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          
          // Verification badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.isVerified ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isVerified ? Icons.verified_user : Icons.warning,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isVerified ? 'Doğrulanmış Hesap' : 'Doğrulanmamış',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          
          // User location
          if (user.cityId != null)
            FutureBuilder<List<dynamic>>(
              future: Future.wait([
                ref.read(apiServiceProvider).getCityById(user.cityId!),
                if (user.districtId != null)
                  ref.read(apiServiceProvider).getDistrictById(user.districtId!)
                else
                  Future.value(null),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Konum yükleniyor...'),
                  );
                }
                
                final city = snapshot.data![0];
                final district = snapshot.data!.length > 1 && snapshot.data![1] != null
                    ? snapshot.data![1]
                    : null;
                
                final locationText = district != null
                    ? '${district.name}, ${city.name}'
                    : city.name;
                
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Konum'),
                  subtitle: Text(locationText),
                );
              },
            ),
          
          // User stats
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Gönderiler'),
            subtitle: const Text('15 gönderi'),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '15',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Çözülen Sorunlar'),
            subtitle: const Text('7 şikayet çözüldü'),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '7',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          
          const Divider(),
          
          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ayarlar'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar yakında eklenecek')),
              );
            },
          ),
          
          // Konum Ayarları
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.orange,
              ),
            ),
            title: const Text('Konum Ayarları'),
            subtitle: const Text('Varsayılan şehir ve ilçe tercihlerinizi belirleyin'),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const LocationSettingsScreen(),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Yardım'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yardım sayfası yakında eklenecek')),
              );
            },
          ),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Çıkış Yap'),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}