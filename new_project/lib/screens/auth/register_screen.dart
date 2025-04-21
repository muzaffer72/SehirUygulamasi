import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/auth_state.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';
import 'package:belediye_iletisim_merkezi/utils/validators.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // Kullanıcı adı alanı eklendi
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  
  // Form verileri
  int? _selectedCityId;
  String? _selectedDistrictId;
  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  bool _isLoadingCities = false;
  
  @override
  void initState() {
    super.initState();
    _loadCities();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose(); // Kullanıcı adı controller'ını da temizle
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCities() async {
    setState(() {
      _isLoadingCities = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final cities = await apiService.getCities();
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Şehirler yüklenirken bir hata oluştu: $e';
        _isLoadingCities = false;
      });
    }
  }
  
  Future<void> _loadDistricts(int cityId) async {
    setState(() {
      _districts = [];
      _selectedDistrictId = null;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final districts = await apiService.getDistrictsByCityId(cityId.toString());
      setState(() {
        _districts = districts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'İlçeler yüklenirken bir hata oluştu: $e';
      });
    }
  }
  
  Future<void> _register() async {
    // Form doğrulama
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Şehir seçimi kontrolü
    if (_selectedCityId == null) {
      setState(() {
        _errorMessage = 'Lütfen bir şehir seçin';
      });
      return;
    }
    
    setState(() {
      _errorMessage = null;
    });
    
    // Riverpod ile kayıt işlemi
    try {
      await ref.read(authProvider.notifier).register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        cityId: _selectedCityId!.toString(), // String olarak dönüştür
        districtId: _selectedDistrictId ?? "",
      );
      
      // Hata kontrolü
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.error && authState.errorMessage != null) {
        setState(() {
          _errorMessage = authState.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kayıt olurken bir hata oluştu: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Başarılı kayıt kontrolü
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      // Widget ağacını yeniden oluşturma talebi gönder
      // Ana ekrana otomatik yönlendirme için
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ve başlık
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Şehrinize sesinizi duyurmak için aramıza katılın!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Hata mesajı
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Kayıt formu
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // İsim alanı
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          hintText: 'Ahmet Yılmaz',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateName(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Kullanıcı adı alanı
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          hintText: 'ahmet_yilmaz',
                          prefixIcon: Icon(Icons.alternate_email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // Kullanıcı adı opsiyonel
                          }
                          if (value.length < 3) {
                            return 'Kullanıcı adı en az 3 karakter olmalı';
                          }
                          // Sadece harf, rakam, alt çizgi ve nokta içerebilir
                          if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                            return 'Kullanıcı adı sadece harf, rakam, alt çizgi ve nokta içerebilir';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // E-posta alanı
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          hintText: 'ornek@mail.com',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validateEmail(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Telefon alanı (opsiyonel)
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefon (İsteğe bağlı)',
                          hintText: '05XX XXX XX XX',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validatePhone(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Şehir seçimi
                      DropdownButtonFormField<int>(
                        value: _selectedCityId,
                        decoration: const InputDecoration(
                          labelText: 'Şehir',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        items: _isLoadingCities
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Yükleniyor...'),
                                ),
                              ]
                            : _cities.map((city) {
                                return DropdownMenuItem(
                                  value: int.parse(city['id'].toString()),
                                  child: Text(city['name']),
                                );
                              }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCityId = value;
                          });
                          if (value != null) {
                            _loadDistricts(value);
                          }
                        },
                        validator: (value) => value == null ? 'Lütfen bir şehir seçin' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // İlçe seçimi (şehir seçildikten sonra aktif)
                      DropdownButtonFormField<String>(
                        value: _selectedDistrictId,
                        decoration: const InputDecoration(
                          labelText: 'İlçe (İsteğe bağlı)',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        items: _selectedCityId == null
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Önce şehir seçin'),
                                ),
                              ]
                            : [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Seçiniz'),
                                ),
                                ..._districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district['id'].toString(),
                                    child: Text(district['name']),
                                  );
                                }).toList(),
                              ],
                        onChanged: _selectedCityId == null
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedDistrictId = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      
                      // Şifre alanı
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.validatePassword(value),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Şifre tekrar alanı
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre Tekrar',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.validatePasswordMatch(
                          _passwordController.text,
                          value,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _register(),
                      ),
                      const SizedBox(height: 32),
                      
                      // Kayıt ol butonu
                      ElevatedButton(
                        onPressed: authState.status == AuthStatus.authenticating ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: authState.status == AuthStatus.authenticating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Giriş sayfasına dön
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Zaten hesabınız var mı?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}