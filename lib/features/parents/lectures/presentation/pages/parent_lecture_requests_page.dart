import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:intl/intl.dart';

class ParentLectureRequestsPage extends StatefulWidget {
  final String parentUid;

  const ParentLectureRequestsPage({
    Key? key,
    required this.parentUid,
  }) : super(key: key);

  @override
  State<ParentLectureRequestsPage> createState() => _ParentLectureRequestsPageState();
}

class _ParentLectureRequestsPageState extends State<ParentLectureRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  void _loadRequests() {
    context.read<LecturesBloc>().add(GetLectureRequestsEvent(parentUid: widget.parentUid));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Requests'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.onPrimary,
          labelColor: cs.onPrimary,
          unselectedLabelColor: cs.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: BlocConsumer<LecturesBloc, LecturesState>(
        listener: (context, state) {
          if (state is LectureRequestCancelled) {
            showSnackbar(context, 'Request cancelled');
            _loadRequests();
          } else if (state is LecturesError) {
            showSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is LecturesLoading) {
            return const Center(child: AppLoading());
          }

          if (state is LectureRequestsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(state.requests.where((r) => r.status == 'Pending').toList()),
                _buildRequestsList(state.requests.where((r) => r.status == 'Approved').toList()),
                _buildRequestsList(state.requests),
              ],
            );
          }

          return const Center(child: Text('No requests found'));
        },
      ),
    );
  }

  Widget _buildRequestsList(List<dynamic> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests'));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          request.subjects.join(', '),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusChip(request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(request.createdAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  if (request.status == 'Pending') ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.read<LecturesBloc>().add(CancelLectureRequestEvent(request.id));
                        },
                        child: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Approved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
