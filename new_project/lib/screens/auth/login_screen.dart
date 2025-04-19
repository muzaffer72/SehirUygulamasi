import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/screens/auth/register_screen.dart';
import 'package:belediye_iletisim_merkezi/utils/validators.dart';
import 'package:belediye_iletisim_merkezi/models/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    // Form doğrulama
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _errorMessage = null;
    });
    
    // Riverpod ile login işlemi
    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
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
        _errorMessage = 'Giriş yapılırken bir hata oluştu: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Başarılı giriş kontrolü
    if (authState.isLoggedIn && authState.user != null) {
      // Widget ağacını yeniden oluşturma talebi gönder
      // Ana ekrana otomatik yönlendirme için
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    
    return Scaffold(
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
                  height: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Belediye İletişim',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
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
                
                // Giriş formu
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Şifremi unuttum
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Şifre sıfırlama ekranı
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifre sıfırlama özelliği yakında eklenecek'),
                              ),
                            );
                          },
                          child: const Text('Şifremi Unuttum'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Giriş yap butonu
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Kayıt ol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabınız yok mu?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Uygulamaya dön
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Uygulamaya Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}