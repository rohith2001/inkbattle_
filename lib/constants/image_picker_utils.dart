import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  static Future<XFile?> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    return pickedFile;
  }

  static Future<XFile?> pickVideoFromGallery() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    return pickedFile;
  }

  static Future<XFile?> pickVideoFromCamera() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    return pickedFile;
  }

  //  static Future<XFile?> _cropImage(XFile? pickedFile, CropAspectRatio? aspectRatio) async {
  //   if (pickedFile == null) return null;

  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: pickedFile.path,
  //     // aspectRatio: aspectRatio ?? const CropAspectRatio(ratioX: 16, ratioY: 9),
  //     compressFormat: ImageCompressFormat.jpg,
  //     compressQuality: 85,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: Colors.black,
  //         toolbarWidgetColor: Colors.white,
  //         lockAspectRatio: false,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //       ),
  //       IOSUiSettings(
  //         title: 'Crop Image',
  //         aspectRatioLockEnabled: true,
  //       ),
  //     ],
  //   );

  //   return croppedFile != null ? XFile(croppedFile.path) : null;
  // }
}
