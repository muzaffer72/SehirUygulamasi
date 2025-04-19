import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/utils/api_key_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyScreen extends StatefulWidget {
  static const String routeName = '/settings/api-key';

  const ApiKeyScreen({Key? key}) : super(key: key);

  @override
  _ApiKeyScreenState createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = await ApiKeyManager.getApiKey();
      setState(() {
        _currentApiKey = apiKey;
        if (apiKey != null) {
          _apiKeyController.text = apiKey;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API anahtarı yüklenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API anahtarı boş olamaz')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiKeyManager.saveApiKey(apiKey);
      setState(() {
        _currentApiKey = apiKey;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API anahtarı başarıyla kaydedildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API anahtarı kaydedilirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiKeyManager.clearApiKey();
      setState(() {
        _currentApiKey = null;
        _apiKeyController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API anahtarı başarıyla temizlendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API anahtarı temizlenirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Anahtarı Ayarları'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Anahtarı',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'API anahtarı, uygulamanın API\'ye erişmesini sağlar. '
                            'Admin panelinden aldığınız API anahtarını aşağıya girin.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _apiKeyController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'API Anahtarı',
                              hintText: 'Admin panelinden aldığınız API anahtarını girin',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_currentApiKey != null)
                                OutlinedButton(
                                  onPressed: _clearApiKey,
                                  child: const Text('Temizle'),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _saveApiKey,
                                child: const Text('Kaydet'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Anahtarı Nasıl Alınır?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Admin paneline giriş yapın\n'
                            '2. Ayarlar sayfasına gidin\n'
                            '3. API Ayarları bölümünde "Yeni API Anahtarı Oluştur" butonuna tıklayın\n'
                            '4. Oluşturulan API anahtarını kopyalayın\n'
                            '5. Bu sayfada ilgili alana yapıştırın ve kaydedin',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}