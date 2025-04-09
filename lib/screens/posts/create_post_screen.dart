import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/utils/constants.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final PostType type;
  
  const CreatePostScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  late final ApiService _apiService;
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedCategoryId;
  String? _selectedCityId;
  String? _selectedDistrictId;
  
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  List<XFile> _selectedImages = [];
  
  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserLocation();
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserLocation() async {
    final user = await _apiService.getCurrentUser();
    
    if (user != null && user.cityId != null) {
      setState(() {
        _selectedCityId = user.cityId;
        _selectedDistrictId = user.districtId;
      });
    }
  }
  
  Future<void> _pickImages() async {
    try {
      final pickedImages = await _picker.pickMultiImage();
      
      if (pickedImages.isNotEmpty) {
        final currentImageCount = _selectedImages.length;
        final availableSlots = Constants.maxImagesPerPost - currentImageCount;
        
        if (availableSlots <= 0) {
          _showErrorSnackBar('En fazla ${Constants.maxImagesPerPost} resim ekleyebilirsiniz.');
          return;
        }
        
        final imagesToAdd = pickedImages.length > availableSlots
            ? pickedImages.sublist(0, availableSlots)
            : pickedImages;
        
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
        
        if (pickedImages.length > availableSlots) {
          _showErrorSnackBar(
            'Maksimum resim sayısına ulaşıldığı için sadece $availableSlots resim eklendi.',
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Resim seçilirken bir hata oluştu: $e');
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (widget.type == PostType.problem && _selectedCategoryId == null) {
      _showErrorSnackBar('Lütfen bir kategori seçin');
      return;
    }
    
    if (_selectedCityId == null) {
      _showErrorSnackBar('Lütfen bir şehir seçin');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final images = _selectedImages.map((xFile) => File(xFile.path)).toList();
      
      await _apiService.createPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        widget.type,
        categoryId: _selectedCategoryId,
        cityId: _selectedCityId,
        districtId: _selectedDistrictId,
        images: images,
        isAnonymous: _isAnonymous,
      );
      
      if (mounted) {
        Navigator.pop(context, true);
        
        // Show a scaffold messenger in previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.type == PostType.problem
                  ? 'Şikayetiniz başarıyla gönderildi'
                  : 'Öneriniz başarıyla gönderildi',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gönderi oluşturulurken bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final bool isLoggedIn = currentUser != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == PostType.problem ? 'Şikayet Oluştur' : 'Öneri Paylaş',
        ),
      ),
      body: !isLoggedIn
          ? _buildLoginPrompt()
          : _buildPostForm(),
    );
  }
  
  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Önce Giriş Yapmalısınız',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Şikayet veya öneri oluşturmak için lütfen giriş yapın veya kayıt olun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
              Navigator.pop(context);
            },
            child: const Text('Giriş Ekranına Git'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Post type indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: widget.type == PostType.problem
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.type == PostType.problem
                      ? Icons.warning_rounded
                      : Icons.lightbulb_outline,
                  color: widget.type == PostType.problem
                      ? Colors.red
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.type == PostType.problem
                      ? 'Şikayet'
                      : 'Öneri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.type == PostType.problem
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              hintText: 'Kısa ve açıklayıcı bir başlık girin',
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: Constants.maxTitleLength,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Başlık zorunludur';
              }
              if (value.trim().length < 5) {
                return 'Başlık en az 5 karakter olmalıdır';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Content
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'İçerik',
              hintText: 'Detaylı açıklama yazın',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLength: Constants.maxContentLength,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'İçerik zorunludur';
              }
              if (value.trim().length < 10) {
                return 'İçerik en az 10 karakter olmalıdır';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Category (only for problem type)
          if (widget.type == PostType.problem)
            FutureBuilder<List<Category>>(
              future: _apiService.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                }
                
                final categories = snapshot.data ?? [];
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Şikayet kategorisini seçin',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  },
                );
              },
            ),
          if (widget.type == PostType.problem)
            const SizedBox(height: 16),
          
          // Location
          FutureBuilder<List<City>>(
            future: _apiService.getCities(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              }
              
              final cities = snapshot.data ?? [];
              
              return Column(
                children: [
                  // City
                  DropdownButtonFormField<String>(
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
                    validator: (value) {
                      if (value == null) {
                        return 'Şehir seçimi zorunludur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // District
                  if (_selectedCityId != null)
                    FutureBuilder<List<District>>(
                      future: _apiService.getDistrictsByCityId(_selectedCityId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        }
                        
                        final districts = snapshot.data ?? [];
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedDistrictId,
                          decoration: const InputDecoration(
                            labelText: 'İlçe',
                            hintText: 'İlçe seçin',
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
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Images
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fotoğraflar (İsteğe bağlı)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'En fazla ${Constants.maxImagesPerPost} resim ekleyebilirsiniz',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              
              // Image preview list
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(_selectedImages[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Add image button
              OutlinedButton.icon(
                onPressed: _selectedImages.length >= Constants.maxImagesPerPost
                    ? null
                    : _pickImages,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Resim Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Anonymous posting option
          CheckboxListTile(
            title: const Text('Anonim olarak gönder'),
            subtitle: const Text(
              'İsminiz diğer kullanıcılar tarafından görülmeyecektir',
              style: TextStyle(fontSize: 12),
            ),
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          
          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitPost,
              icon: Icon(
                widget.type == PostType.problem
                    ? Icons.send
                    : Icons.lightbulb,
              ),
              label: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.type == PostType.problem
                          ? 'Şikayeti Gönder'
                          : 'Öneriyi Paylaş',
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}