import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sikayet_var/utils/constants.dart';

class StorageService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();

  // Upload a single image
  Future<String> uploadImage(File imageFile) async {
    try {
      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/storage/upload'),
      );

      // Add the file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send the request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = 
            // ignore: unnecessary_cast
            (responseString as Map<String, dynamic>);
        return data['url'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> urls = [];
    for (final file in imageFiles) {
      final url = await uploadImage(file);
      urls.add(url);
    }
    return urls;
  }

  // Download and cache an image file
  Future<File> getImageFile(String url, {bool forceRefresh = false}) async {
    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();
    
    // Create a unique filename based on the URL
    final filename = url.split('/').last;
    final file = File('${tempDir.path}/$filename');
    
    // Check if the file exists and we're not forcing a refresh
    if (await file.exists() && !forceRefresh) {
      return file;
    }
    
    try {
      // Download the file
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }

  // Clear cached images
  Future<void> clearImageCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to clear image cache: $e');
    }
  }
}
