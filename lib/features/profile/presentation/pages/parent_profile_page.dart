import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/format_date.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({Key? key}) : super(key: key);

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  @override
  void initState() {
    super.initState();
    // Get current user ID and fetch parent data
    final userId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
    context.read<ProfileBloc>().add(GetParentData(uid: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parent Profile',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileFailure) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ParentDataLoaded) {
            final parent = state.parent;
            return ParentProfileContent(parent: parent);
          }
          return const Center(child: Text('No profile data available'));
        },
      ),
    );
  }
}

class ParentProfileContent extends StatelessWidget {
  final Parent parent;

  const ParentProfileContent({Key? key, required this.parent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with image
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: parent.profilePic.isNotEmpty
                      ? NetworkImage(parent.profilePic)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  '${parent.firstName} ${parent.middleName} ${parent.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  parent.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Personal Information
          _buildSectionHeader('Personal Information'),
          _buildInfoCard([
            _buildInfoRow('Occupation', parent.occupation),
            _buildInfoRow('Gender', parent.gender),
            _buildInfoRow('Date of Birth', formatDateMMYYYY(parent.dob)),
            _buildInfoRow('Phone Number', parent.phoneNumber),
          ]),

          const SizedBox(height: 24),

          // Address Information
          _buildSectionHeader('Address'),
          _buildInfoCard([
            _buildInfoRow('Street', parent.address),
            _buildInfoRow('City', parent.city),
            _buildInfoRow('State', parent.state),
            _buildInfoRow('Country', parent.country),
            _buildInfoRow('Pincode', parent.pincode),
          ]),

          const SizedBox(height: 24),

          // Students Information (if any)
          _buildSectionHeader('Students'),
          parent.students.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No students linked to this account yet'),
                  ),
                )
              : Column(
                  children: parent.students.map((student) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${student.firstName} ${student.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Standard: ${student.standard}'),
                            Text('Board: ${student.board}'),
                            Text('Medium: ${student.medium}'),
                            const SizedBox(height: 8),
                            const Text('Subjects:'),
                            Wrap(
                              spacing: 8.0,
                              children: student.subjects
                                  .map((subject) => Chip(label: Text(subject)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Pallete.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
