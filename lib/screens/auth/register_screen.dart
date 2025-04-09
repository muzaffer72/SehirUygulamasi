import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final ApiService _apiService = ApiService();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 24),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  hintText: 'Adınızı ve soyadınızı girin',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  
                  if (value.length < 3) {
                    return 'Ad soyad en az 3 karakter olmalıdır';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'E-posta adresinizi girin',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta adresi gerekli';
                  }
                  
                  // Basic email validation
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  hintText: 'Şifrenizi girin',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre gerekli';
                  }
                  
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Şifre Tekrar',
                  hintText: 'Şifrenizi tekrar girin',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre tekrarı gerekli';
                  }
                  
                  if (value != _passwordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon (İsteğe Bağlı)',
                  hintText: 'Telefon numaranızı girin',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic phone validation
                    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Geçerli bir telefon numarası girin';
                    }
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // City
              FutureBuilder(
                future: _apiService.getCities(),
                builder: (context, AsyncSnapshot<List<City>> snapshot) {
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
                      hintText: 'Şehir seçin',
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
              
              // District (only if city is selected)
              if (_selectedCityId != null)
                FutureBuilder(
                  future: _apiService.getDistrictsByCityId(_selectedCityId!),
                  builder: (context, AsyncSnapshot<List<District>> snapshot) {
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
                        hintText: 'İlçe seçin',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district.id,
                          child: Text(district.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDistrictId = newValue;
                        });
                      },
                    );
                  },
                ),
              
              const SizedBox(height: 32),
              
              // Register button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              // Error message
              if (authState is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Hata: ${authState.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(authNotifierProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        cityId: _selectedCityId,
        districtId: _selectedDistrictId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı, yönlendiriliyorsunuz...')),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt olurken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
}