import 'dart:io';

import 'package:address_form/address_form.dart';
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/format_date.dart';
import 'package:aparna_education/core/utils/pickimage.dart';
import 'package:aparna_education/core/widgets/csc_picker.dart';
import 'package:aparna_education/core/widgets/dropdownwithsearch.dart';
import 'package:aparna_education/core/widgets/project_button.dart';
import 'package:aparna_education/core/widgets/project_textfield.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LanguageLearnerProfileCompletion extends StatefulWidget {
  const LanguageLearnerProfileCompletion({super.key});

  @override
  State<LanguageLearnerProfileCompletion> createState() =>
      _LanguageLearnerProfileCompletionState();
}

class _LanguageLearnerProfileCompletionState
    extends State<LanguageLearnerProfileCompletion> {
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController aptController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  String? country;
  String? State;
  String? city;
  String selectedGender = "Gender";
  DateTime? selectedDate;
  final mainKey = GlobalKey<AddressFormState>();
  File? image;
  User? user;
  List<String> languages = [
    "English",
    "Hindi",
    "Marathi",
    "Gujarati",
    "Bengali",
    "Punjabi",
    "Kannada",
    "Odia",
    "Malayalam",
    "Assamese",
    "Maithili",
    "Sanskrit",
    "Sindhi",
    "Urdu",
    "Tamil",
    "Telugu",
    "French",
    "German",
    "Spanish",
    "Italian",
  ];
  List<String> selectedLanguagesKnown = [];
  List<String> selectedLanguagesToLearn = [];
  void selectImage() async {
    final file = await pickImage();
    if (file == null) return;
    setState(() {
      image = file;
    });
  }

  @override
  void initState() {
    context.read<ProfileBloc>().add(GetCurrentUser());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Language Learner Profile Completion',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUser) {
            user = state.user;
            firstNameController.text = user!.firstName;
            middleNameController.text = user!.middleName;
            lastNameController.text = user!.lastName;
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
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
                              selectedDate = date;
                              ageController.text = formatDateMMYYYY(date);
                            });
                          },
                          child: ProjectTextfield(
                            enabled: false,
                            borderColor: Pallete.primaryColor,
                            text: "Date of Birth",
                            controller: ageController,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
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
                      border:
                          Border.all(color: Pallete.inactiveColor, width: 2),
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
                      enabled: true,
                      text: "Street/Locality",
                      controller: streetController),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectTextfield(
                      enabled: true,
                      text: "Apt, suite, etc.",
                      controller: aptController),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectTextfield(
                    enabled: true,
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
                      text: "Occupation", controller: occupationController),
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownWithSearch(
                      disabledDecoration: BoxDecoration(
                        color: Pallete.whiteColor,
                        border:
                            Border.all(color: Pallete.inactiveColor, width: 2),
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
                        border:
                            Border.all(color: Pallete.primaryColor, width: 2),
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
                      title: "Select Lanuages to learn",
                      placeHolder: "Select Languages",
                      items: languages,
                      selected: "Languages to Learn",
                      onChanged: (val) {
                        setState(() {
                          if (selectedLanguagesToLearn.contains(val)) return;
                          selectedLanguagesToLearn.add(val);
                          print(selectedLanguagesToLearn);
                        });
                      },
                      label: "Select Languages"),
                  SizedBox(
                    height: 20,
                  ),
                  if (selectedLanguagesToLearn.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: selectedLanguagesToLearn.map((e) {
                        return Chip(
                          side: const BorderSide(
                              color: Pallete.primaryColor, width: 2),
                          color: WidgetStatePropertyAll(Pallete.primaryColor),
                          onDeleted: () {
                            setState(() {
                              selectedLanguagesToLearn.remove(e);
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
                        border:
                            Border.all(color: Pallete.inactiveColor, width: 2),
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
                        border:
                            Border.all(color: Pallete.primaryColor, width: 2),
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
                      title: "Select Lanuages Already Known",
                      placeHolder: "Select Languages",
                      items: languages,
                      selected: "Languages Known",
                      onChanged: (val) {
                        setState(() {
                          if (selectedLanguagesKnown.contains(val)) return;
                          selectedLanguagesKnown.add(val);
                          print(selectedLanguagesKnown);
                        });
                      },
                      label: "Select Languages"),
                  SizedBox(
                    height: 20,
                  ),
                  if (selectedLanguagesKnown.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: selectedLanguagesKnown.map((e) {
                        return Chip(
                          side: const BorderSide(
                              color: Pallete.primaryColor, width: 2),
                          color: WidgetStatePropertyAll(Pallete.primaryColor),
                          onDeleted: () {
                            setState(() {
                              selectedLanguagesKnown.remove(e);
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
                  Center(
                    child: ProjectButton(
                      text: "Submit",
                      onPressed: () {
                        bool _validateFields() {
                          return firstNameController.text.isNotEmpty &&
                              lastNameController.text.isNotEmpty &&
                              image != null &&
                              occupationController.text.isNotEmpty &&
                              selectedGender != null &&
                              selectedDate != null &&
                              phoneController.text.isNotEmpty &&
                              streetController.text.isNotEmpty &&
                              city != null &&
                              State != null &&
                              country != null &&
                              postcodeController.text.isNotEmpty &&
                              selectedLanguagesToLearn.isNotEmpty &&
                              selectedLanguagesKnown.isNotEmpty;
                        }

                        if (_validateFields()) {
                          context.read<ProfileBloc>().add(
                              CreateLanguageLearnerProfile(
                                  firstName: firstNameController.text.trim(),
                                  middleName: middleNameController.text.trim(),
                                  lastName: lastNameController.text.trim(),
                                  profilePic: image!,
                                  gender: genderController.text,
                                  dob: selectedDate!,
                                  occupation: occupationController.text.trim(),
                                  phoneNumber: phoneController.text.trim(),
                                  address: addressController.text.trim(),
                                  city: city!,
                                  state: State!,
                                  country: country!,
                                  pincode: postcodeController.text.trim(),
                                  languagesKnown: selectedLanguagesKnown,
                                  languagesToLearn: selectedLanguagesToLearn));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill in all fields.'),
                              backgroundColor: Pallete.primaryColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
