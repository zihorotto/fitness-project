import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_mobile/providers/wod_provider.dart';
import 'package:fitness_mobile/core/colors.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _sortBy = 'newest'; // newest, oldest, duration
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WodProvider>().fetchWods();
    });
  }

  List<Map<String, dynamic>> _getPaginatedWods(
    List<Map<String, dynamic>> wods,
  ) {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= wods.length) return [];
    return wods.sublist(start, end > wods.length ? wods.length : end);
  }

  int _getTotalPages(List<Map<String, dynamic>> wods) {
    return (wods.length / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> _getSortedWods(List<dynamic> wods) {
    List<Map<String, dynamic>> sorted = wods.cast<Map<String, dynamic>>();

    switch (_sortBy) {
      case 'oldest':
        sorted.sort(
          (a, b) => (a['createdAt'] ?? '').compareTo(b['createdAt'] ?? ''),
        );
        break;
      case 'duration':
        sorted.sort(
          (a, b) => (b['durationInSeconds'] ?? 0).compareTo(
            a['durationInSeconds'] ?? 0,
          ),
        );
        break;
      case 'newest':
      default:
        sorted.sort(
          (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''),
        );
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WODboard'),
        elevation: 0,
        backgroundColor: AppColors.primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: Consumer<WodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchWods();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(provider),
                const SizedBox(height: 24),

                // Completed WODs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WODS Completed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryViolet.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryViolet.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text('Newest'),
                          ),
                          DropdownMenuItem(
                            value: 'oldest',
                            child: Text('Oldest'),
                          ),
                          DropdownMenuItem(
                            value: 'duration',
                            child: Text('Longest'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (provider.wods.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No completed workouts yet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _getPaginatedWods(
                          _getSortedWods(provider.wods),
                        ).length,
                        itemBuilder: (context, index) {
                          final wod = _getPaginatedWods(
                            _getSortedWods(provider.wods),
                          )[index];
                          return _buildWorkoutCard(wod);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Pagination Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Page ${_currentPage + 1} of ${_getTotalPages(_getSortedWods(provider.wods)).toString()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed:
                                _currentPage <
                                    (_getTotalPages(
                                          _getSortedWods(provider.wods),
                                        ) -
                                        1)
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next',
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(WodProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatistic('Total WODS', '${provider.wods.length}'),
                _buildStatistic(
                  'This Week',
                  '${(provider.wods.length / 3).toStringAsFixed(0)}',
                ),
                _buildStatistic('Streak', '3'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> wod) {
    final duration = wod['durationInSeconds'] ?? 0;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    final durationDisplay = wod['durationDisplay'] ?? '${minutes}m ${seconds}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.primaryViolet.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryViolet.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryViolet.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryViolet.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_circle,
                color: AppColors.primaryViolet,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Workout details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wod['name'] ?? 'Workout',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getFormatType(wod['type'] ?? ''),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryViolet,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          wod['category'] ?? 'General',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  durationDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryViolet,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatType(String type) {
    if (type.toLowerCase().contains('amrap')) return 'AMRAP';
    if (type.toLowerCase().contains('rft')) return 'RFT';
    if (type.toLowerCase().contains('emom')) return 'EMOM';
    if (type.toLowerCase().contains('tabata')) return 'Tabata';
    if (type.toLowerCase().contains('fortime')) return 'For Time';
    return 'Workout';
  }
}
