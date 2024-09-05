import 'dart:io';

import 'package:address_form/address_form.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/format_date.dart';
import 'package:aparna_education/core/utils/loader.dart';
import 'package:aparna_education/core/utils/pickFile.dart';
import 'package:aparna_education/core/utils/pickimage.dart';
import 'package:aparna_education/core/utils/view_pdf.dart';
import 'package:aparna_education/core/widgets/csc_picker.dart';
import 'package:aparna_education/core/widgets/dropdownwithsearch.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/widgets/project_dropdown.dart';
import 'package:aparna_education/core/widgets/project_textfield.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class TeacherProfileCompletion extends StatefulWidget {
  const TeacherProfileCompletion({super.key});

  @override
  State<TeacherProfileCompletion> createState() =>
      _TeacherProfileCompletionState();
}

class _TeacherProfileCompletionState extends State<TeacherProfileCompletion> {
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController aptController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController workExpController = TextEditingController();
  String? country;
  String? State;
  String? city;
  File? resume;
  bool resumeLoading = false;
  String selectedGender = "Gender";
  List<String> selectedAcademicBoard = [];
  List<String> academicBoards = [
    "CBSE",
    "ICSE",
    "MSBSHSE",
    "WBBSE",
    "UPBSE",
    "BSEB",
    "GSEB",
    "RBSE",
    "MPBSE",
    "KSEEB",
    "PSEB",
    "HPSOS",
    "NIOS",
    "IGCSE",
    "IB",
    "Others"
  ];
  List<String> selectedSubjects = [];
  List<String> subjects = [
    "Maths",
    "Science",
    "English",
    "Hindi",
    "History",
    "Geography",
    "Civics",
    "Economics",
    "Biology",
    "Physics",
    "Chemistry",
    "Computer Science"
  ];
  String? selected = "Subjects";
  String? selectedBoard = "Academic Board";
  void uploadResume() async {
    setState(() {
      resumeLoading = true;
    });
    final file = await pickFile();
    if (file == null) {
      setState(() {
        resumeLoading = false;
      });
      return;
    }
    setState(() {
      resume = file;
      resumeLoading = false;
    });
  }

  final mainKey = GlobalKey<AddressFormState>();
  File? image;
  void selectImage() async {
    final file = await pickImage();
    if (file == null) return;
    setState(() {
      image = file;
    });
  }

  void viewResume(File file) async {
    await viewPdf(file, context);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: const Text("Complete your profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Pallete.primaryColor)),
              ),
              const SizedBox(height: 20),
              image != null
                  ? Center(
                      child: Container(
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
                        child: DropdownWithSearch(
                            disabledDecoration: BoxDecoration(
                              color: Pallete.whiteColor,
                              border: Border.all(
                                  color: Pallete.inactiveColor, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            itemStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                            dropdownHeadingStyle: const TextStyle(
                                color: Pallete.primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Pallete.primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                            title: selectedGender,
                            placeHolder: "Gender",
                            items: const [
                              "Male",
                              "Female",
                              "Other",
                              "Prefer not to say",
                              "Non-binary",
                              "Transgender"
                            ],
                            selected: selectedGender,
                            onChanged: (val) {
                              setState(() {
                                selectedGender = val;
                              });
                            },
                            label: "Gender")),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date == null) return;
                        setState(() {
                          ageController.text = formatDateMMYYYY(date);
                        });
                      },
                      child: ProjectTextfield(
                        enabled: false,
                        borderColor: Pallete.primaryColor,
                        text: "Date of Birth",
                        controller: ageController,
                        keyboardType: const TextInputType.numberWithOptions(),
                      ),
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
                    city = val;
                  });
                },
                onCountryChanged: (val) {
                  if (val == "Country") return;
                  setState(() {
                    country = val;
                  });
                },
                onStateChanged: (val) {
                  if (val == "State") return;
                  setState(() {
                    State = val;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ProjectTextfield(
                  enabled: city != null,
                  text: "Street/Locality",
                  controller: streetController),
              const SizedBox(
                height: 20,
              ),
              ProjectTextfield(
                  enabled: streetController.text.isNotEmpty,
                  text: "Apt, suite, etc.",
                  controller: aptController),
              const SizedBox(
                height: 20,
              ),
              ProjectTextfield(
                enabled: aptController.text.isNotEmpty,
                text: "Postcode",
                controller: postcodeController,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(
                height: 20,
              ),
              IntlPhoneField(
                controller: phoneController,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Pallete.primaryColor, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Pallete.primaryColor, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ProjectTextfield(
                text: "Work Experience (yy-mm)",
                controller: workExpController,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownWithSearch(
                  disabledDecoration: BoxDecoration(
                    color: Pallete.whiteColor,
                    border: Border.all(color: Pallete.inactiveColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  dropdownHeadingStyle: const TextStyle(
                      color: Pallete.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  title: "Select Academic Board",
                  placeHolder: "Search Academic Board",
                  items: academicBoards,
                  selected: selectedBoard,
                  onChanged: (val) {
                    setState(() {
                      if (selectedAcademicBoard.contains(val)) return;
                      selectedAcademicBoard.add(val);
                      print(selectedSubjects);
                    });
                  },
                  label: "Select Academic Board"),
              const SizedBox(
                height: 20,
              ),
              if (selectedAcademicBoard.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: selectedAcademicBoard.map((e) {
                    return Chip(
                      side: const BorderSide(
                          color: Pallete.primaryColor, width: 2),
                      color: WidgetStatePropertyAll(Pallete.primaryColor),
                      onDeleted: () {
                        setState(() {
                          selectedAcademicBoard.remove(e);
                        });
                      },
                      deleteIcon: Icon(Icons.close),
                      deleteIconColor: Pallete.backgroundColor,
                      padding: const EdgeInsets.all(5),
                      label: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          e,
                          style: const TextStyle(
                              color: Pallete.backgroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(
                height: 20,
              ),
              DropdownWithSearch(
                  disabledDecoration: BoxDecoration(
                    color: Pallete.whiteColor,
                    border: Border.all(color: Pallete.inactiveColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  dropdownHeadingStyle: const TextStyle(
                      color: Pallete.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  title: "Select Subjects",
                  placeHolder: "Search Subjects",
                  items: subjects,
                  selected: selected,
                  onChanged: (val) {
                    setState(() {
                      if (selectedSubjects.contains(val)) return;
                      selectedSubjects.add(val);
                      print(selectedSubjects);
                    });
                  },
                  label: "Select Subjects"),
              const SizedBox(
                height: 20,
              ),
              if (selectedSubjects.isNotEmpty)
                Wrap(
                  spacing: 10,
                  children: selectedSubjects.map((e) {
                    return Chip(
                      side: const BorderSide(
                          color: Pallete.primaryColor, width: 2),
                      color: WidgetStatePropertyAll(Pallete.primaryColor),
                      onDeleted: () {
                        setState(() {
                          selectedSubjects.remove(e);
                        });
                      },
                      deleteIcon: Icon(Icons.close),
                      deleteIconColor: Pallete.backgroundColor,
                      padding: const EdgeInsets.all(5),
                      label: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          e,
                          style: const TextStyle(
                              color: Pallete.backgroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: uploadResume,
                child: resume != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Pallete.primaryColor.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                            color: Pallete.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    viewResume(resume!);
                                  },
                                  child: Icon(Icons.file_present, size: 40)),
                              Text('Resume Uploaded Successfully'),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      resume = null;
                                    });
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        ),
                      )
                    : DottedBorder(
                        color: Pallete.primaryColor,
                        strokeWidth: 1,
                        borderType: BorderType.RRect,
                        strokeCap: StrokeCap.round,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (resumeLoading)
                                const Center(child: Loader())
                              else
                                const Icon(
                                  Icons.folder_open_rounded,
                                  size: 40,
                                  color: Pallete.greyColor,
                                ),
                              const SizedBox(height: 10),
                              const Text(
                                "Upload Your Resume",
                                style: TextStyle(
                                    color: Pallete.greyColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300),
                              )
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Pallete.primaryColor,
                        ),
                      );
                    }
                    if (state is ProfileFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return Center(child: const Loader());
                    }
                    return ProjectButton(
                      text: "Submit",
                      onPressed: () {
                        context.read<ProfileBloc>().add(CreateProfile(
                              address:
                                  '${streetController.text}, ${aptController.text}, ${city}, ${State}, ${country}, ${postcodeController.text}',
                              board: selectedAcademicBoard,
                              city: city!,
                              country: country!,
                              dob: DateTime.parse(ageController.text),
                              gender: selectedGender,
                              workExp: workExpController.text,
                              phoneNumber: phoneController.text,
                              pincode: postcodeController.text,
                              profilePic: image!.path,
                              resume: resume!,
                              state: State!,
                              subjects: selectedSubjects,
                              firstName: firstNameController.text,
                              middleName: middleNameController.text,
                              lastName: lastNameController.text,
                            ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
