import 'package:aparna_education/core/widgets/animations.dart';

import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/edit_parent_profile_page.dart';
import 'package:aparna_education/core/utils/format_date.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModernParentProfilePage extends StatefulWidget {
  const ModernParentProfilePage({Key? key}) : super(key: key);

  @override
  State<ModernParentProfilePage> createState() => _ModernParentProfilePageState();
}

class _ModernParentProfilePageState extends State<ModernParentProfilePage> {
  String? currentUserId;
  Parent? currentParent;

  @override
  void initState() {
    super.initState();
    // First get current user to get the UID, then get parent data
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          print('Profile State: $state'); // Debug print
          if (state is ProfileFailure) {
            print('Profile Failure: ${state.message}'); // Debug print
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileUser) {
            print('Profile User loaded: ${state.user.uid}'); // Debug print
            setState(() {
              currentUserId = state.user.uid;
            });
            // Now get the specific parent data
            context.read<ProfileBloc>().add(GetParentData(uid: state.user.uid));
          } else if (state is ParentDataLoaded) {
            print('Parent Data Loaded: ${state.parent.firstName}'); // Debug print
            setState(() {
              currentParent = state.parent;
            });
          } else if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the profile
            context.read<ProfileBloc>().add(GetCurrentUser());
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          if (currentParent == null) {
            return Center(
              child: FadeInSlide(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUserId != null ? 'Parent Profile Not Found' : 'Profile not loaded',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUserId != null 
                        ? 'Your parent profile may not be completed yet'
                        : 'Please try refreshing',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentParent = null;
                              currentUserId = null;
                            });
                            context.read<ProfileBloc>().add(GetCurrentUser());
                          },
                          child: const Text('Refresh'),
                        ),
                        if (currentUserId != null) ...[
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to profile completion
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text('Go Back', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FadeInSlide(
                        child: Column(
                          children: [
                            // Profile Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ScaleInAnimation(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditParentProfilePage(parent: currentParent!),
                                          ),
                                        );
                                        if (result == true) {
                                          context.read<ProfileBloc>().add(GetCurrentUser());
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ScaleInAnimation(
                                  delay: const Duration(milliseconds: 100),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      onSelected: (value) async {
                                        if (value == 'logout') {
                                          _showLogoutDialog();
                                        } else if (value == 'refresh') {
                                          setState(() {
                                            currentParent = null;
                                          });
                                          context.read<ProfileBloc>().add(GetCurrentUser());
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'refresh',
                                          child: Row(
                                            children: [
                                              Icon(Icons.refresh, size: 20),
                                              SizedBox(width: 12),
                                              Text('Refresh'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'logout',
                                          child: Row(
                                            children: [
                                              Icon(Icons.logout, color: Colors.red, size: 20),
                                              SizedBox(width: 12),
                                              Text('Logout', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Profile Avatar
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    backgroundImage: currentParent!.profilePic.isNotEmpty
                                        ? NetworkImage(currentParent!.profilePic)
                                        : null,
                                    onBackgroundImageError: currentParent!.profilePic.isNotEmpty 
                                        ? (exception, stackTrace) {
                                            print('Error loading image: ${currentParent!.profilePic}');
                                            print('Error: $exception');
                                          }
                                        : null,
                                    child: currentParent!.profilePic.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey.shade400,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Name and Email
                            Text(
                              '${currentParent!.firstName} ${currentParent!.lastName}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentParent!.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Parent Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Profile Information Cards
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: StaggeredAnimation(
                    children: [
                      // Personal Information Card
                      _buildInfoCard(
                        'Personal Information',
                        Icons.person_rounded,
                        Colors.blue,
                        [
                          _buildInfoRow('First Name', currentParent!.firstName),
                          _buildInfoRow('Last Name', currentParent!.lastName),
                          _buildInfoRow('Email', currentParent!.email),
                          _buildInfoRow('Phone', currentParent!.phoneNumber),
                          _buildInfoRow('Date of Birth', formatDateMMYYYY(currentParent!.dob)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Address Information Card
                      if (currentParent!.address.isNotEmpty ||
                          currentParent!.city.isNotEmpty ||
                          currentParent!.state.isNotEmpty ||
                          currentParent!.country.isNotEmpty)
                        _buildInfoCard(
                          'Address Information',
                          Icons.location_on_rounded,
                          Colors.green,
                          [
                            if (currentParent!.address.isNotEmpty)
                              _buildInfoRow('Address', currentParent!.address),
                            if (currentParent!.city.isNotEmpty)
                              _buildInfoRow('City', currentParent!.city),
                            if (currentParent!.state.isNotEmpty)
                              _buildInfoRow('State', currentParent!.state),
                            if (currentParent!.country.isNotEmpty)
                              _buildInfoRow('Country', currentParent!.country),
                            if (currentParent!.pincode.isNotEmpty)
                              _buildInfoRow('Pincode', currentParent!.pincode),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Account Information Card
                      _buildInfoCard(
                        'Account Information',
                        Icons.info_rounded,
                        Colors.purple,
                        [
                          _buildInfoRow('User ID', currentParent!.uid),
                          _buildInfoRow('Account Type', 'Parent'),
                          _buildInfoRow('Status', 'Active'),
                        ],
                      ),

                      const SizedBox(height: 100), // Bottom padding for navbar
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaleInAnimation(
          child: AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16, color: cs.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoggedOut) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  
                  return ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
