import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

final selectedImagesProvider = StateNotifierProvider<SelectedImagesNotifier, List<File>>(
  (ref) => SelectedImagesNotifier(),
);

final selectedVideoProvider = StateNotifierProvider<SelectedVideoNotifier, File?>(
  (ref) => SelectedVideoNotifier(),
);

class SelectedImagesNotifier extends StateNotifier<List<File>> {
  SelectedImagesNotifier() : super([]);
  
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickImage({bool camera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        state = [...state, File(pickedFile.path)];
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  
  Future<void> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (pickedFiles.isNotEmpty) {
        final imageFiles = pickedFiles.map((file) => File(file.path)).toList();
        state = [...state, ...imageFiles];
      }
    } catch (e) {
      print('Error picking multiple images: $e');
    }
  }
  
  void removeImage(int index) {
    if (index < 0 || index >= state.length) return;
    
    final newList = [...state];
    newList.removeAt(index);
    state = newList;
  }
  
  void clearImages() {
    state = [];
  }
  
  String getImageFileName(int index) {
    if (index < 0 || index >= state.length) return '';
    return path.basename(state[index].path);
  }
}

class SelectedVideoNotifier extends StateNotifier<File?> {
  SelectedVideoNotifier() : super(null);
  
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickVideo({bool camera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(minutes: 1), // 1 dakika ile sınırla
      );
      
      if (pickedFile != null) {
        state = File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }
  
  void clearVideo() {
    state = null;
  }
  
  String? getVideoFileName() {
    if (state == null) return null;
    return path.basename(state!.path);
  }
}