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
import 'package:aparna_education/features/home/presentation/pages/parent_layout_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ParentProfileCompletion extends StatefulWidget {
  const ParentProfileCompletion({super.key});

  @override
  State<ParentProfileCompletion> createState() =>
      _ParentProfileCompletionState();
}

class _ParentProfileCompletionState extends State<ParentProfileCompletion> {
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
          'Parent Profile Completion',
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
                    enabled: city != null,
                    text: "Street/Locality",
                    controller: streetController,
                    onSubmitted: (val) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectTextfield(
                    enabled: streetController.text.isNotEmpty,
                    text: "Apt, suite, etc.",
                    controller: aptController,
                    onSubmitted: (val) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectTextfield(
                    enabled: aptController.text.isNotEmpty,
                    text: "Postcode",
                    controller: postcodeController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    onSubmitted: (val) {
                      setState(() {});
                    },
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
                              postcodeController.text.isNotEmpty;
                        }

                        if (_validateFields()) {
                          context.read<ProfileBloc>().add(CreateParentProfile(
                              firstName: firstNameController.text,
                              middleName: middleNameController.text,
                              lastName: lastNameController.text,
                              profilePic: image!,
                              occupation: occupationController.text,
                              gender: selectedGender,
                              dob: selectedDate!,
                              phoneNumber: phoneController.text,
                              address: streetController.text,
                              city: city!,
                              state: State!,
                              country: country!,
                              pincode: postcodeController.text));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Profile Completed Successfully.'),
                            backgroundColor: Pallete.primaryColor,
                          ));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ParentLayoutPage()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
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
