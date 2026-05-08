import 'package:flutter/material.dart';
import 'package:aparna_education/core/widgets/animations.dart';

class TeacherReportsPage extends StatefulWidget {
  const TeacherReportsPage({super.key});

  @override
  State<TeacherReportsPage> createState() => _TeacherReportsPageState();
}

class _TeacherReportsPageState extends State<TeacherReportsPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.surfaceVariant.withOpacity(0.6),
                  cs.surface,
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reports & Analytics',
                    style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.analytics_rounded, size: 28, color: cs.primary),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: StaggeredAnimation(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Student Progress',
                        value: '0',
                        subtitle: 'reports',
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.assignment_rounded,
                        title: 'Assignments',
                        value: '0',
                        subtitle: 'pending',
                        color: cs.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.schedule_rounded,
                        title: 'Attendance',
                        value: '0%',
                        subtitle: 'average',
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.grade_rounded,
                        title: 'Avg Grade',
                        value: '-',
                        subtitle: 'no data',
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverFillRemaining(
          hasScrollBody: false,
          child: FadeInSlide(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Reports Available',
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reports will be generated based on\nstudent activities and assignments',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    AnimatedCard(
                      onTap: () {},
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate Report'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return AnimatedCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final tt = Theme.of(context).textTheme;
            final cs = Theme.of(context).colorScheme;
            return Text(
              value,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
            );
          }),
          const SizedBox(height: 4),
          Builder(builder: (context) {
            final tt = Theme.of(context).textTheme;
            final cs = Theme.of(context).colorScheme;
            return Column(
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
