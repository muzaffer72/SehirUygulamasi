import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/city.dart';
import '../../models/district.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  String? _selectedCityId;
  String? _selectedDistrictId;
  List<City> _cities = [];
  List<District> _districts = [];
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;
  
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose(); // Username controller'ı da temizle
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCities() async {
    setState(() {
      _isLoadingCities = true;
    });
    
    try {
      final cities = await _apiService.getCities();
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şehirler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _loadDistricts(String cityId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrictId = null;
    });
    
    try {
      final districts = await _apiService.getDistrictsByCityId(cityId);
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDistricts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlçeler yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Name validator
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad gerekli';
    }
    if (value.length < 3) {
      return 'Ad Soyad en az 3 karakter olmalıdır';
    }
    return null;
  }
  
  // Username validator
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }
    // Kullanıcı adı formatı kontrol (harf, rakam ve alt çizgi izin verilir)
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
    }
    return null;
  }

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    // Basic email format check
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  // Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  // Confirm Password validator
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre doğrulama gerekli';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  // Handle registration
  Future<void> _register() async {
    // Validate form
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanım koşullarını kabul etmelisiniz'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _selectedCityId,
          _selectedDistrictId,
        );

        // Check for registration errors
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kayıt hatası: ${authState.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (authState.status == AuthStatus.authenticated) {
          // Registration successful, navigate to home page
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Örn: ahmet_85',
                      ),
                      validator: _validateUsername,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Şifre Doğrulama',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: _validateConfirmPassword,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),

                    // City selection dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Şehir seçiniz'),
                          value: _selectedCityId,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: isLoading || _isLoadingCities
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedCityId = newValue;
                                  });
                                  if (newValue != null) {
                                    _loadDistricts(newValue);
                                  }
                                },
                          items: _isLoadingCities
                              ? [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Yükleniyor...'),
                                  )
                                ]
                              : _cities.map<DropdownMenuItem<String>>(
                                  (City city) {
                                    return DropdownMenuItem<String>(
                                      value: city.id,
                                      child: Text(city.name),
                                    );
                                  },
                                ).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // District selection dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('İlçe seçiniz'),
                          value: _selectedDistrictId,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: isLoading || _isLoadingDistricts || _selectedCityId == null
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedDistrictId = newValue;
                                  });
                                },
                          items: _selectedCityId == null
                              ? [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Önce şehir seçiniz'),
                                  )
                                ]
                              : _isLoadingDistricts
                                  ? [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Yükleniyor...'),
                                      )
                                    ]
                                  : _districts.isEmpty
                                      ? [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('İlçe bulunamadı'),
                                          )
                                        ]
                                      : _districts
                                          .map<DropdownMenuItem<String>>(
                                            (District district) {
                                              return DropdownMenuItem<String>(
                                                value: district.id,
                                                child: Text(district.name),
                                              );
                                            },
                                          )
                                          .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Terms and conditions checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: const Text(
                              'Kullanım koşullarını ve gizlilik politikasını okudum, kabul ediyorum.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register button
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('KAYIT OL'),
                    ),
                    const SizedBox(height: 16),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Zaten bir hesabın var mı?'),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}