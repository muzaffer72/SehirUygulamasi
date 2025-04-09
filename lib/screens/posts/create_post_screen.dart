import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/utils/validators.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  PostType _selectedType = PostType.problem;
  List<String> _imageUrls = [];
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return const Center(
        child: Text('Gönderi oluşturmak için lütfen giriş yapın'),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Gönderi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Post type selection
            const Text(
              'Gönderi Tipi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PostType>(
              segments: const [
                ButtonSegment(
                  value: PostType.problem,
                  label: Text('Şikayet'),
                  icon: Icon(Icons.warning_rounded),
                ),
                ButtonSegment(
                  value: PostType.general,
                  label: Text('Öneri'),
                  icon: Icon(Icons.lightbulb_outline),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<PostType> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                hintText: 'Gönderi başlığını giriniz',
                border: OutlineInputBorder(),
              ),
              validator: validatePostTitle,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            
            // Content field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'İçerik',
                hintText: 'Gönderinizi detaylı olarak açıklayınız',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: validatePostContent,
              maxLength: 1000,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            
            // Category selection
            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: apiService.getCategories(),
              builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Kategori verisi bulunamadı');
                }
                
                final categories = snapshot.data!;
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateRequired(value, 'Kategori'),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedSubCategoryId = null; // Reset sub-category
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Sub-category selection (only if category is selected)
            if (_selectedCategoryId != null)
              FutureBuilder(
                future: apiService.getCategories(),
                builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  final categories = snapshot.data!;
                  final selectedCategory = categories.firstWhere(
                    (category) => category.id == _selectedCategoryId,
                    orElse: () => Category(
                      id: _selectedCategoryId!,
                      name: 'Bilinmeyen',
                    ),
                  );
                  
                  if (selectedCategory.subCategories == null || selectedCategory.subCategories!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alt Kategori',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSubCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Alt Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: selectedCategory.subCategories!.map((subCategory) {
                          return DropdownMenuItem<String>(
                            value: subCategory.id,
                            child: Text(subCategory.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCategoryId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            
            // Image upload section
            // Note: For simplicity, we're using placeholder for image upload
            const Text(
              'Fotoğraflar (Opsiyonel)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement image upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fotoğraf yükleme özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Fotoğraf Ekle'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Anonymous posting option
            SwitchListTile(
              title: const Text('İsimimi Gizle'),
              subtitle: const Text('Gönderiniz isminiz gizlenerek paylaşılacak'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Gönderiyi Paylaş',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }
      
      final newPost = Post(
        id: '', // Will be assigned by the server
        userId: currentUser.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        categoryId: _selectedCategoryId!,
        subCategoryId: _selectedSubCategoryId,
        type: _selectedType,
        status: _selectedType == PostType.problem ? PostStatus.awaitingSolution : null,
        cityId: currentUser.cityId,
        districtId: currentUser.districtId,
        imageUrls: _imageUrls,
        likeCount: 0,
        commentCount: 0,
        highlightCount: 0,
        isAnonymous: _isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdPost = await ref.read(postsProvider.notifier).createPost(newPost);
      
      if (!mounted) return;
      
      if (createdPost != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gönderi başarıyla oluşturuldu')),
        );
        
        // Clear form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _selectedCategoryId = null;
          _selectedSubCategoryId = null;
          _selectedType = PostType.problem;
          _imageUrls = [];
          _isAnonymous = false;
        });
        
        // Navigate to home tab
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gönderi oluşturulurken bir hata oluştu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}