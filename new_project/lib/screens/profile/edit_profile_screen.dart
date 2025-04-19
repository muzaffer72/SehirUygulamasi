import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/city_provider.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const EditProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _contactInfoController;
  late TextEditingController _hiddenNameController;
  
  XFile? _selectedAvatar;
  final _picker = ImagePicker();
  
  String? _selectedCityId;
  String? _selectedDistrictId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _contactInfoController = TextEditingController(text: widget.user.contactInfo ?? '');
    _hiddenNameController = TextEditingController(text: widget.user.hiddenName ?? '');
    
    _selectedCityId = widget.user.cityId;
    _selectedDistrictId = widget.user.districtId;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _contactInfoController.dispose();
    _hiddenNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = pickedFile;
      });
    }
  }

  Future<void> _updateProfile() async {
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
      // In a real app, we would upload the avatar first if selected
      // and then get the avatar URL from the server
      
      // For now, we'll just simulate updating the user profile
      final updatedUser = User(
        id: widget.user.id,
        email: widget.user.email,
        username: _usernameController.text.trim(),
        avatar: _selectedAvatar != null ? 'new_avatar_url' : widget.user.avatar,
        bio: _bioController.text.trim(),
        hiddenName: _hiddenNameController.text.trim().isEmpty ? null : _hiddenNameController.text.trim(),
        cityId: _selectedCityId!,
        districtId: _selectedDistrictId!,
        contactInfo: _contactInfoController.text.trim(),
        createdAt: widget.user.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(authControllerProvider.notifier).updateProfile(updatedUser);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenirken hata: ${e.toString()}')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedAvatar != null
                          ? FileImage(File(_selectedAvatar!.path)) as ImageProvider
                          : widget.user.avatar != null
                              ? NetworkImage(widget.user.avatar!) as ImageProvider
                              : null,
                      child: widget.user.avatar == null && _selectedAvatar == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _isLoading ? null : _pickAvatar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
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
              
              // Bio field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Hakkımda',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // Contact info field
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'İletişim Bilgileri',
                  prefixIcon: Icon(Icons.contact_phone),
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // Hidden name field
              TextFormField(
                controller: _hiddenNameController,
                decoration: const InputDecoration(
                  labelText: 'Gizli Ad (Anonim paylaşımlar için)',
                  prefixIcon: Icon(Icons.masks),
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 24),
              
              // Update button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Profili Güncelle',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
