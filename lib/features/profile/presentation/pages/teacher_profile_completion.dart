import 'dart:io';

import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/pickimage.dart';
import 'package:aparna_education/core/widgets/project_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TeacherProfileCompletion extends StatefulWidget {
  const TeacherProfileCompletion({super.key});

  @override
  State<TeacherProfileCompletion> createState() =>
      _TeacherProfileCompletionState();
}

class _TeacherProfileCompletionState extends State<TeacherProfileCompletion> {
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? image;
  void selectImage() async {
    final file = await pickImage();
    if (file == null) return;
    setState(() {
      image = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Profile Completion',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 20),
                image != null
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.height * 0.3,
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // border: Border.all(
                              //   color: Pallete.primaryColor,
                              //   width: 3.5,
                              // ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              'assets/images/profileImagePlaceholder.png',
                            ),
                          ),
                          Positioned(
                            left: MediaQuery.of(context).size.width * 0.25,
                            bottom: MediaQuery.of(context).size.height * 0.01,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Pallete.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 20),
                ProjectTextfield(text: "Gender", controller: genderController),
                SizedBox(height: 20),
                ProjectTextfield(
                  text: "Age",
                  controller: genderController,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
                SizedBox(height: 20),
                ProjectTextfield(
                  text: "Address",
                  controller: genderController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
