import 'dart:io';

import 'package:address_form/address_form.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/pickimage.dart';
import 'package:aparna_education/core/widgets/csc_picker.dart';
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
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool isCountrySelected = false;
  bool isStateSelected = false;
  bool isCitySelected = false;

  final mainKey = GlobalKey<AddressFormState>();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text("Complete your profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Pallete.primaryColor)),
                const SizedBox(height: 20),
                image != null
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.height * 0.3,
                        child: ClipOval(
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // border: Border.all(
                              //   color: Pallete.primaryColor,
                              //   width: 3.5,
                              // ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profileImagePlaceholder.png',
                              ),
                            ),
                          ),
                          Positioned(
                            left: MediaQuery.of(context).size.width * 0.25,
                            bottom: MediaQuery.of(context).size.height * 0.01,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Pallete.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 20,
                ),
                ProjectTextfield(
                    text: "First Name", controller: firstNameController),
                const SizedBox(
                  height: 20,
                ),
                ProjectTextfield(
                    text: "Middle Name", controller: middleNameController),
                const SizedBox(
                  height: 20,
                ),
                ProjectTextfield(
                    text: "Last Name", controller: lastNameController),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ProjectTextfield(
                            text: "Gender", controller: genderController),
                      ),
                    ),
                    Expanded(
                      child: ProjectTextfield(
                        text: "Age",
                        controller: genderController,
                        keyboardType: const TextInputType.numberWithOptions(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CSCPicker(
                  unselectedItemStyle: const TextStyle(
                    color: Pallete.greyColor,
                    fontSize: 16,
                  ),
                  selectedItemStyle: const TextStyle(
                    color: Colors.black,
                    //:
                    //Pallete.greyColor,
                    fontSize: 16,
                  ),
                  disabledDropdownDecoration: BoxDecoration(
                    color: Pallete.whiteColor,
                    border: Border.all(color: Pallete.inactiveColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  dropdownItemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  dropdownHeadingStyle: const TextStyle(
                      color: Pallete.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  dropdownDecoration: BoxDecoration(
                    border: Border.all(color: Pallete.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onCityChanged: (val) {
                    if (val == "City") return;
                    setState(() {
                      isCitySelected = true;
                    });
                  },
                  onCountryChanged: (val) {
                    if (val == "Country") return;
                    setState(() {
                      isCountrySelected = true;
                    });
                  },
                  onStateChanged: (val) {
                    if (val == "State") return;
                    setState(() {
                      isStateSelected = true;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
