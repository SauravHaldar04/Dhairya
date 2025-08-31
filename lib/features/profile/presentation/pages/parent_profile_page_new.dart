import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/features/profile/presentation/pages/edit_parent_profile_page.dart';
import 'package:aparna_education/core/utils/format_date.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({Key? key}) : super(key: key);

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  String? currentUserId;
  Parent? currentParent;

  @override
  void initState() {
    super.initState();
    // Get current user through clean architecture
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parent Profile',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to edit profile page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditParentProfilePage(parent: currentParent!),
                ),
              );
              // Refresh the profile if update was successful
              if (result == true) {
                context.read<ProfileBloc>().add(GetCurrentUser());
              }
            },
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the profile data
              setState(() {
                currentParent = null;
              });
              context.read<ProfileBloc>().add(GetCurrentUser());
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                      (route) => false,
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileUser) {
            setState(() {
              currentUserId = state.user.uid;
            });
            // Get parent profile if user is a parent
            context.read<ProfileBloc>().add(GetParentData(uid: state.user.uid));
          } else if (state is ParentDataLoaded) {
            setState(() {
              currentParent = state.parent;
            });
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            );
          } else if (currentParent != null) {
            return ParentProfileContent(
              parent: currentParent!,
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No profile data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(GetCurrentUser());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ParentProfileContent extends StatefulWidget {
  final Parent parent;

  const ParentProfileContent({
    Key? key,
    required this.parent,
  }) : super(key: key);

  @override
  State<ParentProfileContent> createState() => _ParentProfileContentState();
}

class _ParentProfileContentState extends State<ParentProfileContent> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(GetCurrentUser());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Pallete.primaryColor,
                      child: widget.parent.profilePic != null &&
                              widget.parent.profilePic!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                widget.parent.profilePic!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    '${widget.parent.firstName[0]}${widget.parent.lastName[0]}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              '${widget.parent.firstName[0]}${widget.parent.lastName[0]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.parent.firstName} ${widget.parent.middleName} ${widget.parent.lastName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.parent.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.parent.emailVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Not Verified',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Personal information card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Phone Number', widget.parent.phoneNumber),
                    const SizedBox(height: 12),
                    _buildInfoRow('Gender', widget.parent.gender),
                    const SizedBox(height: 12),
                    if (widget.parent.dob != null)
                      _buildInfoRow('Date of Birth',
                          formatDateMMYYYY(widget.parent.dob!)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Address information card
            if (widget.parent.address != null ||
                widget.parent.city != null ||
                widget.parent.state != null ||
                widget.parent.country != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.parent.address != null)
                        _buildInfoRow('Address', widget.parent.address!),
                      if (widget.parent.address != null)
                        const SizedBox(height: 12),
                      if (widget.parent.city != null)
                        _buildInfoRow('City', widget.parent.city!),
                      if (widget.parent.city != null)
                        const SizedBox(height: 12),
                      if (widget.parent.state != null)
                        _buildInfoRow('State', widget.parent.state!),
                      if (widget.parent.state != null)
                        const SizedBox(height: 12),
                      if (widget.parent.country != null)
                        _buildInfoRow('Country', widget.parent.country!),
                      if (widget.parent.country != null)
                        const SizedBox(height: 12),
                      if (widget.parent.pincode != null)
                        _buildInfoRow('Pincode', widget.parent.pincode!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Quick actions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          const Icon(Icons.edit, color: Pallete.primaryColor),
                      title: const Text('Edit Profile'),
                      subtitle: const Text('Update your personal information'),
                      onTap: () async {
                        // Navigate to edit profile page
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditParentProfilePage(parent: widget.parent),
                          ),
                        );
                        // Refresh the profile if update was successful
                        if (result == true) {
                          context.read<ProfileBloc>().add(GetCurrentUser());
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.people, color: Pallete.primaryColor),
                      title: const Text('Manage Students'),
                      subtitle: const Text('Add or edit student information'),
                      onTap: () {
                        // Navigate to students tab (index 1)
                        // This would be handled by the parent widget
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Go to Students tab to manage students'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.security,
                          color: Pallete.primaryColor),
                      title: const Text('Account Settings'),
                      subtitle: const Text('Security and privacy settings'),
                      onTap: () {
                        // TODO: Navigate to account settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Account settings will be implemented'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
            style: TextStyle(
              color: value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
