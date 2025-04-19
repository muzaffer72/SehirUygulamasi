import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final PostType postType;
  
  const CreatePostScreen({
    Key? key,
    required this.postType,
  }) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final apiService = ref.watch(apiServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık alanı
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Başlık zorunludur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // İçerik alanı
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'İçerik',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'İçerik zorunludur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Şehir seçimi
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Şehir',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      value: _selectedCityId,
                      items: const [
                        // Şimdilik demo şehirler
                        DropdownMenuItem(value: '1', child: Text('İstanbul')),
                        DropdownMenuItem(value: '2', child: Text('Ankara')),
                        DropdownMenuItem(value: '3', child: Text('İzmir')),
                        DropdownMenuItem(value: '4', child: Text('Bursa')),
                        DropdownMenuItem(value: '5', child: Text('Antalya')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                          // Şehir değişince ilçe sıfırlanmalı
                          _selectedDistrictId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şehir seçimi zorunludur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // İlçe seçimi (eğer şehir seçiliyse göster)
                    if (_selectedCityId != null)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'İlçe',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        value: _selectedDistrictId,
                        items: const [
                          // Demo ilçeler
                          DropdownMenuItem(value: '101', child: Text('Kadıköy')),
                          DropdownMenuItem(value: '102', child: Text('Beşiktaş')),
                          DropdownMenuItem(value: '103', child: Text('Üsküdar')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrictId = value;
                          });
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Kategori seçimi
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      value: _selectedCategoryId,
                      items: const [
                        // Demo kategoriler
                        DropdownMenuItem(value: '1', child: Text('Altyapı')),
                        DropdownMenuItem(value: '2', child: Text('Ulaşım')),
                        DropdownMenuItem(value: '3', child: Text('Çevre')),
                        DropdownMenuItem(value: '4', child: Text('Güvenlik')),
                        DropdownMenuItem(value: '5', child: Text('Sosyal Hizmetler')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Anonim gönderme seçeneği
                    CheckboxListTile(
                      title: const Text('Anonim Olarak Gönder'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Gönderme butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submitPost,
                        child: const Text('Gönder'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Ekran başlığını gönderi tipine göre ayarla
  String _getAppBarTitle() {
    switch (widget.postType) {
      case PostType.problem:
        return 'Sorun Bildir';
      case PostType.suggestion:
        return 'Öneri Yap';
      case PostType.announcement:
        return 'Duyuru Ekle';
      case PostType.general:
        return 'Teşekkür Et';
      default:
        return 'Yeni Gönderi';
    }
  }

  // Form gönderme fonksiyonu
  void _submitPost() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir şehir seçin')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Post oluştur
      await apiService.createPost(
        title: _titleController.text,
        content: _contentController.text,
        cityId: _selectedCityId!,
        districtId: _selectedDistrictId,
        categoryId: _selectedCategoryId,
        anonymous: _isAnonymous,
      );
      
      // Başarılı yanıt
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gönderi başarıyla oluşturuldu')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderi oluşturulurken hata: $e')),
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