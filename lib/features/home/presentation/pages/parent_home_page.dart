import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileUser) {
            context
                .read<ProfileBloc>()
                .add(GetStudentsbyParent(uid: state.user.uid));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.primaryContainer.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIconsFill.house, color: cs.onPrimaryContainer, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Welcome to Dhairya',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor and support your child\'s learning journey',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),

                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(child: _statCard(cs, tt,
                      icon: PhosphorIconsRegular.graduationCap,
                      title: 'Children', value: '0', color: cs.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard(cs, tt,
                      icon: PhosphorIconsRegular.clipboardText,
                      title: 'Assignments', value: '0', color: cs.secondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard(cs, tt,
                      icon: PhosphorIconsRegular.calendarCheck,
                      title: 'Upcoming', value: '0', color: cs.tertiary)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard(cs, tt,
                      icon: PhosphorIconsRegular.trendUp,
                      title: 'Progress', value: '100%', color: cs.primary)),
                  ],
                ),

                const SizedBox(height: 28),

                Text('Quick Actions', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                _actionTile(cs, tt,
                  icon: PhosphorIconsRegular.users,
                  title: 'View Students',
                  subtitle: 'Monitor your children\'s performance',
                  color: cs.primary,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _actionTile(cs, tt,
                  icon: PhosphorIconsRegular.videoCamera,
                  title: 'Join Lecture',
                  subtitle: 'Attend live sessions with your child',
                  color: cs.secondary,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _actionTile(cs, tt,
                  icon: PhosphorIconsRegular.calendarBlank,
                  title: 'View Schedule',
                  subtitle: 'Check upcoming classes and events',
                  color: cs.tertiary,
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                Text('Recent Activities', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIconsRegular.clockCounterClockwise, size: 40, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Text('No Recent Activities', style: tt.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        'Activities will appear here once your\nchild starts using the platform',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(ColorScheme cs, TextTheme tt, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(value, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(ColorScheme cs, TextTheme tt, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(PhosphorIconsRegular.caretRight, size: 16, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
