import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileTypeWidget extends StatefulWidget {
  final bool isSelected;
  final ProfileType profileType;
  final String imageUrl;
  const ProfileTypeWidget(
      {super.key,
      required this.profileType,
      required this.imageUrl,
      required this.isSelected});

  @override
  State<ProfileTypeWidget> createState() => _ProfileTypeWidgetState();
}

enum ProfileType { student, teacher, languagelearner }

class _ProfileTypeWidgetState extends State<ProfileTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: Border.all(
            color:
                widget.isSelected ? Pallete.primaryColor : Pallete.whiteColor,
            width: 3.5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: AssetImage(widget.imageUrl),
              height: 130,
              width: 130,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  widget.profileType == ProfileType.teacher
                      ? 'I\'m a Teacher'
                      : widget.profileType == ProfileType.student
                          ? 'I\'m a Student'
                          : 'I\'m a Language Learner',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Pallete.secondaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  widget.profileType == ProfileType.teacher
                      ? 'I am a teacher and I want to teach students.'
                      : widget.profileType == ProfileType.student
                          ? 'I am a student and I want to learn.'
                          : 'I am a language learner and I want to learn languages.',
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
