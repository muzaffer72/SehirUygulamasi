import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/city_provider.dart';
import 'package:belediye_iletisim_merkezi/models/city.dart';
import 'package:belediye_iletisim_merkezi/models/district.dart';
import 'package:belediye_iletisim_merkezi/utils/validators.dart';
import 'package:belediye_iletisim_merkezi/controllers/auth_controller.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _hiddenNameController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _wantAnonymousOption = false;
  bool _isLoading = false;
  
  String? _selectedCityId;
  String? _selectedDistrictId;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _hiddenNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCityId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen şehir ve ilçe seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _selectedCityId!,
        _selectedDistrictId!,
        _wantAnonymousOption ? _hiddenNameController.text.trim() : null,
      );
      
      if (mounted) {
        Navigator.pop(context); // Go back to login screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final districtsAsync = _selectedCityId == null 
        ? const AsyncValue<List<District>>.data([]) 
        : ref.watch(districtsProvider(_selectedCityId!));

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${error.toString()}')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    hintText: 'Kullanıcı adınızı giriniz',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kullanıcı adı gerekli';
                    }
                    if (value.length < 3) {
                      return 'Kullanıcı adı en az 3 karakter olmalı';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'E-posta adresinizi giriniz',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateEmail,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    hintText: 'Şifrenizi giriniz',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: Validators.validatePassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    hintText: 'Şifrenizi tekrar giriniz',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre tekrarı gerekli';
                    }
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // City dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Şehir',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCityId,
                  hint: const Text('Şehir seçiniz'),
                  items: citiesAsync.when(
                    data: (cities) => cities.map((City city) {
                      return DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(city.name),
                      );
                    }).toList(),
                    loading: () => [],
                    error: (_, __) => [],
                  ),
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedCityId = newValue;
                            _selectedDistrictId = null; // Reset district when city changes
                          });
                        },
                ),
                if (citiesAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (citiesAsync.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Şehirler yüklenirken hata: ${citiesAsync.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // District dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'İlçe',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedDistrictId,
                  hint: const Text('İlçe seçiniz'),
                  items: districtsAsync.when(
                    data: (districts) => districts.map((District district) {
                      return DropdownMenuItem<String>(
                        value: district.id,
                        child: Text(district.name),
                      );
                    }).toList(),
                    loading: () => [],
                    error: (_, __) => [],
                  ),
                  onChanged: _isLoading || _selectedCityId == null
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedDistrictId = newValue;
                          });
                        },
                ),
                if (districtsAsync.isLoading && _selectedCityId != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (districtsAsync.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'İlçeler yüklenirken hata: ${districtsAsync.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Anonymous option
                SwitchListTile(
                  title: const Text('Anonim paylaşım yapmak istiyorum'),
                  subtitle: const Text('Gizli bir kullanıcı adı belirleyebilirsiniz'),
                  value: _wantAnonymousOption,
                  onChanged: _isLoading
                      ? null
                      : (bool value) {
                          setState(() {
                            _wantAnonymousOption = value;
                          });
                        },
                ),
                
                // Hidden name field (only shown if anonymous option is selected)
                if (_wantAnonymousOption)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      controller: _hiddenNameController,
                      decoration: const InputDecoration(
                        labelText: 'Gizli Ad',
                        hintText: 'Gizli kullanıcı adınızı giriniz',
                        prefixIcon: Icon(Icons.face),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_wantAnonymousOption && (value == null || value.isEmpty)) {
                          return 'Gizli ad gerekli';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                
                // Login link
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Zaten hesabınız var mı? Giriş yapın'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
