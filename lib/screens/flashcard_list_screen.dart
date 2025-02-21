import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/flashcard.dart';
import '../services/firebase_service.dart';
import '../widgets/flashcard_widget.dart';

// PUBLIC_INTERFACE
/// A screen that displays a list of flashcards with search, filter, and sorting capabilities.
/// 
/// Features:
/// - Search functionality
/// - List/Grid view toggle
/// - Filter and sort options
/// - Pull-to-refresh
/// - Real-time updates from Firebase
/// - Loading state with shimmer effect
/// - Empty state handling
class FlashcardListScreen extends StatefulWidget {
  const FlashcardListScreen({Key? key}) : super(key: key);

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  String _sortBy = 'created';
  bool _sortAscending = true;
  Set<String> _selectedTags = {};
  int? _selectedDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterOptionsSheet(
        selectedTags: _selectedTags,
        selectedDifficulty: _selectedDifficulty,
        onApplyFilters: (tags, difficulty) {
          setState(() {
            _selectedTags = tags;
            _selectedDifficulty = difficulty;
          });
        },
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortOptionsSheet(
        currentSortBy: _sortBy,
        isAscending: _sortAscending,
        onApplySort: (sortBy, ascending) {
          setState(() {
            _sortBy = sortBy;
            _sortAscending = ascending;
          });
        },
      ),
    );
  }

  List<Flashcard> _filterAndSortFlashcards(List<Flashcard> flashcards) {
    var filtered = flashcards.where((card) {
      final matchesSearch = _searchController.text.isEmpty ||
          card.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          card.content.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesTags = _selectedTags.isEmpty ||
          card.tags.any((tag) => _selectedTags.contains(tag));

      final matchesDifficulty = _selectedDifficulty == null ||
          card.difficultyLevel == _selectedDifficulty;

      return matchesSearch && matchesTags && matchesDifficulty;
    }).toList();

    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'difficulty':
          comparison = a.difficultyLevel.compareTo(b.difficultyLevel);
          break;
        case 'review_count':
          comparison = a.reviewCount.compareTo(b.reviewCount);
          break;
        case 'created':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search flashcards...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Switch to list view' : 'Switch to grid view',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter flashcards',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort flashcards',
          ),
        ],
      ),
      body: StreamBuilder<List<Flashcard>>(
        stream: context.read<FirebaseService>().getUserFlashcards(
              context.read<String>(), // Assuming user ID is provided via Provider
            ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return _LoadingState(isGridView: _isGridView);
          }

          final flashcards = _filterAndSortFlashcards(snapshot.data!);

          if (flashcards.isEmpty) {
            return _EmptyState(
              hasFilters: _searchController.text.isNotEmpty ||
                  _selectedTags.isNotEmpty ||
                  _selectedDifficulty != null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Firebase handles real-time updates, but we'll add a small delay
              // to show the refresh indicator
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) => FlashcardWidget(
                      flashcard: flashcards[index],
                      size: const Size(160, 160),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FlashcardWidget(
                        flashcard: flashcards[index],
                        size: const Size(double.infinity, 200),
                      ),
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add flashcard screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new flashcard',
      ),
    );
  }
}

class FilterOptionsSheet extends StatefulWidget {
  const FilterOptionsSheet({
    Key? key,
    required this.selectedTags,
    required this.selectedDifficulty,
    required this.onApplyFilters,
  }) : super(key: key);

  final Set<String> selectedTags;
  final int? selectedDifficulty;
  final void Function(Set<String> tags, int? difficulty) onApplyFilters;

  @override
  State<FilterOptionsSheet> createState() => _FilterOptionsSheetState();
}

class _FilterOptionsSheetState extends State<FilterOptionsSheet> {
  late Set<String> _tags;
  late int? _difficulty;

  @override
  void initState() {
    super.initState();
    _tags = Set.from(widget.selectedTags);
    _difficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter Options',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Easy'),
                selected: _difficulty == 1,
                onSelected: (selected) {
                  setState(() => _difficulty = selected ? 1 : null);
                },
              ),
              FilterChip(
                label: const Text('Medium'),
                selected: _difficulty == 3,
                onSelected: (selected) {
                  setState(() => _difficulty = selected ? 3 : null);
                },
              ),
              FilterChip(
                label: const Text('Hard'),
                selected: _difficulty == 5,
                onSelected: (selected) {
                  setState(() => _difficulty = selected ? 5 : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tags.clear();
                    _difficulty = null;
                  });
                },
                child: const Text('Clear All'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_tags, _difficulty);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SortOptionsSheet extends StatefulWidget {
  const SortOptionsSheet({
    Key? key,
    required this.currentSortBy,
    required this.isAscending,
    required this.onApplySort,
  }) : super(key: key);

  final String currentSortBy;
  final bool isAscending;
  final void Function(String sortBy, bool ascending) onApplySort;

  @override
  State<SortOptionsSheet> createState() => _SortOptionsSheetState();
}

class _SortOptionsSheetState extends State<SortOptionsSheet> {
  late String _sortBy;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentSortBy;
    _ascending = widget.isAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sort Options',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text('Date Created'),
            value: 'created',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          RadioListTile<String>(
            title: const Text('Title'),
            value: 'title',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          RadioListTile<String>(
            title: const Text('Difficulty'),
            value: 'difficulty',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          RadioListTile<String>(
            title: const Text('Review Count'),
            value: 'review_count',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          SwitchListTile(
            title: Text(_ascending ? 'Ascending' : 'Descending'),
            value: _ascending,
            onChanged: (value) => setState(() => _ascending = value),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortBy = 'created';
                    _ascending = true;
                  });
                },
                child: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApplySort(_sortBy, _ascending);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({
    Key? key,
    required this.isGridView,
  }) : super(key: key);

  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    Key? key,
    required this.hasFilters,
  }) : super(key: key);

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.note_add,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No flashcards match your filters'
                  : 'No flashcards yet',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Create your first flashcard by tapping the + button',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}