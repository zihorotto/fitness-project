import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_mobile/providers/wod_provider.dart';
import 'package:fitness_mobile/screens/wod_detail_screen.dart';
import 'package:fitness_mobile/core/colors.dart';

class WodListScreen extends StatefulWidget {
  const WodListScreen({super.key});

  @override
  State<WodListScreen> createState() => _WodListScreenState();
}

class _WodListScreenState extends State<WodListScreen> {
  late TextEditingController _searchController;
  late TextEditingController _filterController;
  String _searchQuery = '';
  List<String> _selectedFilters = []; // Combined filters: types + movements
  String _sortBy = 'name_asc'; // Default sort
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WodProvider>().fetchWods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 0;
    });
  }

  Set<String> _getAllMovements(List<dynamic> wods) {
    final movements = <String>{};
    for (var wod in wods) {
      if (wod['movements'] != null) {
        final movementStr = wod['movements'] as String;
        movements.addAll(movementStr.split(',').map((m) => m.trim()));
      }
    }
    return movements;
  }

  List<Map<String, dynamic>> _getFilteredAndSortedWods(List<dynamic> wods) {
    // Cast to Map<String, dynamic>
    final wodsList = wods.cast<Map<String, dynamic>>();

    // Filter by search query and filters
    var filtered = wodsList.where((wod) {
      final name = (wod['name'] ?? '').toString().toLowerCase();
      final type = (wod['type'] ?? '').toString().toLowerCase();
      final description = (wod['description'] ?? '').toString().toLowerCase();
      final fullDescription = (wod['fullDescription'] ?? '')
          .toString()
          .toLowerCase();
      final movements = (wod['movements'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          name.contains(query) ||
          type.contains(query) ||
          description.contains(query) ||
          fullDescription.contains(query) ||
          movements.contains(query);

      // All filters must match (AND logic)
      final matchesAllFilters =
          _selectedFilters.isEmpty ||
          _selectedFilters.every((filter) {
            final filterLower = filter.toLowerCase();
            return type.contains(filterLower) ||
                movements.contains(filterLower);
          });

      return matchesSearch && matchesAllFilters;
    }).toList();

    // Sort based on selected option
    switch (_sortBy) {
      case 'name_asc':
        filtered.sort(
          (a, b) => (a['name'] ?? '').toString().compareTo(b['name'] ?? ''),
        );
        break;
      case 'name_desc':
        filtered.sort(
          (a, b) => (b['name'] ?? '').toString().compareTo(a['name'] ?? ''),
        );
        break;
      case 'type_asc':
        filtered.sort(
          (a, b) => (a['type'] ?? '').toString().compareTo(b['type'] ?? ''),
        );
        break;
      case 'type_desc':
        filtered.sort(
          (a, b) => (b['type'] ?? '').toString().compareTo(a['type'] ?? ''),
        );
        break;
      case 'duration_asc':
        filtered.sort((a, b) {
          final aDuration = a['durationInMinutes'] as int? ?? 0;
          final bDuration = b['durationInMinutes'] as int? ?? 0;
          return aDuration.compareTo(bDuration);
        });
        break;
      case 'duration_desc':
        filtered.sort((a, b) {
          final aDuration = a['durationInMinutes'] as int? ?? 0;
          final bDuration = b['durationInMinutes'] as int? ?? 0;
          return bDuration.compareTo(aDuration);
        });
        break;
    }

    return filtered;
  }

  String _getSortLabel(String sortValue) {
    switch (sortValue) {
      case 'name_asc':
        return 'Sort by: Name (A-Z)';
      case 'name_desc':
        return 'Sort by: Name (Z-A)';
      case 'type_asc':
        return 'Sort by: Type (A-Z)';
      case 'type_desc':
        return 'Sort by: Type (Z-A)';
      case 'duration_asc':
        return 'Sort by: Duration (Shortest)';
      case 'duration_desc':
        return 'Sort by: Duration (Longest)';
      default:
        return 'Sort by: Name (A-Z)';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WODS'),
        elevation: 0,
        backgroundColor: AppColors.primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: Consumer<WodProvider>(
        builder: (context, provider, child) {
          final filteredWods = _getFilteredAndSortedWods(provider.wods);
          final allTypes =
              provider.wods
                  .map((w) => w['type'] as String?)
                  .whereType<String>()
                  .toSet()
                  .toList()
                ..sort();
          final allMovements = _getAllMovements(provider.wods).toList()..sort();

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

          if (provider.wods.isEmpty) {
            return const Center(child: Text('No workouts available'));
          }

          return Column(
            children: [
              // Search and Filter Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search name, type, movements...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    // Filter Search - Smart Filter Input
                    TextField(
                      controller: _filterController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Filter (e.g., pull-ups, AMRAP)...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        suffixIcon: _filterController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _filterController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    // Available Filters Dropdown
                    if (_filterController.text.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Builder(
                            builder: (context) {
                              final allTags =
                                  [
                                        ...allTypes.where(
                                          (t) => t.toLowerCase().contains(
                                            _filterController.text
                                                .toLowerCase(),
                                          ),
                                        ),
                                        ...allMovements.where(
                                          (m) => m.toLowerCase().contains(
                                            _filterController.text
                                                .toLowerCase(),
                                          ),
                                        ),
                                      ]
                                      .where(
                                        (tag) =>
                                            !_selectedFilters.contains(tag),
                                      )
                                      .toList();

                              if (allTags.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'No filters match "${_filterController.text}"',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: allTags.length,
                                itemBuilder: (context, index) {
                                  final tag = allTags[index];
                                  return ListTile(
                                    title: Text(tag),
                                    onTap: () {
                                      setState(() {
                                        _selectedFilters.add(tag);
                                        _filterController.clear();
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Active Filters - Chips
                    if (_selectedFilters.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: _selectedFilters.map((filter) {
                          return Chip(
                            label: Text(
                              filter,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedFilters.remove(filter);
                              });
                            },
                            backgroundColor: AppColors.primaryViolet,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            deleteIconColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          );
                        }).toList(),
                      ),
                    // Sort Section
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      color: AppColors.primaryVioletDark,
                      offset: const Offset(0, 48),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'name_asc',
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort_by_alpha,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Name (A-Z)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'name_desc',
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort_by_alpha,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Name (Z-A)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'type_asc',
                          child: Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Type (A-Z)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'type_desc',
                          child: Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Type (Z-A)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duration_asc',
                          child: Row(
                            children: [
                              Icon(Icons.timer, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Duration (Short)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duration_desc',
                          child: Row(
                            children: [
                              Icon(Icons.timer, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Duration (Long)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _getSortLabel(_sortBy),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Workouts List
              Expanded(
                child: filteredWods.isEmpty
                    ? Center(
                        child: Text(
                          'No workouts found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _getPaginatedWods(filteredWods).length,
                              itemBuilder: (context, index) {
                                final wod = _getPaginatedWods(
                                  filteredWods,
                                )[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WodDetailScreen(wod: wod),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      wod['name'] ?? 'Workout',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryViolet
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      child: Text(
                                                        wod['type'] ?? 'N/A',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .primaryViolet,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward,
                                                color: AppColors.primaryViolet,
                                              ),
                                            ],
                                          ),
                                          if (wod['description'] != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              wod['description'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Pagination Controls
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
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
                                  'Page ${_currentPage + 1} of ${_getTotalPages(filteredWods).toString()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed:
                                      _currentPage <
                                          (_getTotalPages(filteredWods) - 1)
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  tooltip: 'Next',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
