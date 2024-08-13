import 'dart:io';

import 'package:file_picker/file_picker.dart';


Future<File?> pickImage() async {
  try {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (pickedFile != null) {
      return File(pickedFile.files.single.path!);
    }
    return null;
  } catch (e) {
    return null;
  }
}
