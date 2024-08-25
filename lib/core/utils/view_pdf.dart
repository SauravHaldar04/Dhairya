import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

Future<void> viewPdf(File file, BuildContext context) async {
  String path = file.path;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFView(
        filePath: path,
        pdfData: file.readAsBytesSync(),
      ),
    ),
  );
}
