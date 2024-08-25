import 'dart:io';

import 'package:file_picker/file_picker.dart';


Future<File?> pickFile() async {
  try {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);
    if (pickedFile != null) {
      return File(pickedFile.files.single.path!);
    }
    return null;
  } catch (e) {
    return null;
  }
}