import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    
    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<String?> pickImageFromCamera() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Camera permission not granted');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<String?> pickImageFromGallery() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission not granted');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return await _saveImage(image);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<String> _saveImage(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(path.join(appDir.path, 'receipts'));
      
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(receiptsDir.path, fileName);
      
      await image.saveTo(filePath);
      return filePath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<File?> getImageFile(String? imagePath) async {
    if (imagePath == null) return null;
    
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getAllReceiptImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(path.join(appDir.path, 'receipts'));
      
      if (!await receiptsDir.exists()) {
        return [];
      }

      final files = await receiptsDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalImageSize() async {
    try {
      final images = await getAllReceiptImages();
      double totalSize = 0;
      
      for (final imagePath in images) {
        final file = File(imagePath);
        if (await file.exists()) {
          final size = await file.length();
          totalSize += size;
        }
      }
      
      return totalSize / (1024 * 1024); // Return size in MB
    } catch (e) {
      return 0;
    }
  }

  Future<void> cleanupOrphanedImages(List<String> validImagePaths) async {
    try {
      final allImages = await getAllReceiptImages();
      
      for (final imagePath in allImages) {
        if (!validImagePaths.contains(imagePath)) {
          await deleteImage(imagePath);
        }
      }
    } catch (e) {
      // Handle cleanup errors silently
    }
  }

  String formatImageSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(1)} KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  Future<void> showImagePickerDialog(
    Function(String) onImageSelected,
    Function(String) onError,
  ) async {
    // This method will be used by UI components to show image picker options
    // Implementation will be in UI layer
  }
}