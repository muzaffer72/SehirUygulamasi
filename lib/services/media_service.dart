import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class MediaService {
  final String baseUrl;
  final http.Client _client;

  MediaService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Görsel yükleme
  Future<String> uploadImage(File image) async {
    final fileExtension = path.extension(image.path).toLowerCase();
    final mimeType = _getMimeType(fileExtension);
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/image'),
    );
    
    request.files.add(
      http.MultipartFile(
        'image',
        image.readAsBytes().asStream(),
        image.lengthSync(),
        filename: path.basename(image.path),
        contentType: mimeType,
      ),
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Başarılı - URL döndür
      final responseData = response.body;
      return responseData;
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }
  
  // Çoklu görsel yükleme
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    final List<String> imageUrls = [];
    
    for (var image in images) {
      try {
        final url = await uploadImage(image);
        imageUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
        // Hataya rağmen devam et
      }
    }
    
    return imageUrls;
  }
  
  // Video yükleme
  Future<String> uploadVideo(File video) async {
    final fileExtension = path.extension(video.path).toLowerCase();
    final mimeType = _getVideoMimeType(fileExtension);
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/video'),
    );
    
    request.files.add(
      http.MultipartFile(
        'video',
        video.readAsBytes().asStream(),
        video.lengthSync(),
        filename: path.basename(video.path),
        contentType: mimeType,
      ),
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Başarılı - URL döndür
      final responseData = response.body;
      return responseData;
    } else {
      throw Exception('Failed to upload video: ${response.body}');
    }
  }
  
  // Dosya uzantısına göre MIME türünü belirle
  MediaType _getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Varsayılan
    }
  }
  
  // Video dosya uzantısına göre MIME türünü belirle
  MediaType _getVideoMimeType(String extension) {
    switch (extension) {
      case '.mp4':
        return MediaType('video', 'mp4');
      case '.mov':
        return MediaType('video', 'quicktime');
      case '.avi':
        return MediaType('video', 'x-msvideo');
      case '.wmv':
        return MediaType('video', 'x-ms-wmv');
      case '.webm':
        return MediaType('video', 'webm');
      default:
        return MediaType('video', 'mp4'); // Varsayılan
    }
  }
}