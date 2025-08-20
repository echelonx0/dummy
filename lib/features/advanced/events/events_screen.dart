// lib/features/events/screens/events_screen.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/events_models.dart';
import 'components/events_header.dart';
import 'event_detail_screen.dart';
import 'events_service.dart';
import 'v2_widgets/rebuilt_event_card.dart';
// import 'widgets/event_card_widget.dart'; // deprecated

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  List<Event> _userEvents = [];

  bool _isLoading = true;
  bool _isLoadingUserEvents = false;

  EventCategory? _selectedCategory;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 2 &&
        _userEvents.isEmpty &&
        !_isLoadingUserEvents) {
      _loadUserEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final events = await EventsService.getEvents(limit: 50);
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserEvents() async {
    setState(() => _isLoadingUserEvents = true);

    try {
      final userEvents = await EventsService.getUserEvents();
      setState(() {
        _userEvents = userEvents;
        _isLoadingUserEvents = false;
      });
    } catch (e) {
      setState(() => _isLoadingUserEvents = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load your events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterEvents() {
    List<Event> filtered = _allEvents;

    // Filter by category
    if (_selectedCategory != null) {
      filtered =
          filtered
              .where((event) => event.category == _selectedCategory)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((event) {
            return event.title.toLowerCase().contains(query) ||
                event.description.toLowerCase().contains(query) ||
                event.venue.name.toLowerCase().contains(query) ||
                event.venue.city.toLowerCase().contains(query);
          }).toList();
    }

    setState(() {
      _filteredEvents = filtered;
    });
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
    if (_tabController.index == 2) {
      await _loadUserEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Header
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return EnhancedEventsHeader(
                  tabController: _tabController,
                  categoryFilter:
                      _tabController.index == 0 ? _buildCategoryFilter() : null,
                  onSearchPressed: _showSearchDialog,
                );
              },
            ),
            // Tab bar
            _buildTabBar(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllEventsTab(),
                  _buildCategoriesTab(),
                  _buildUserEventsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primarySageGreen,
        unselectedLabelColor: AppColors.textMedium,
        indicatorColor: AppColors.primarySageGreen,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'All Events'),
          Tab(text: 'Categories'),
          Tab(text: 'My Events'),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(null, 'All'),
          ...EventCategory.values.map(
            (category) => _buildCategoryChip(category, category.displayName),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          _filterEvents();
        },
        label: Text(label),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primarySageGreen : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        selectedColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAllEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredEvents.isEmpty) {
      return _buildEmptyState(
        'No events found',
        _searchQuery.isNotEmpty || _selectedCategory != null
            ? 'Try adjusting your filters'
            : 'Check back soon for upcoming events',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return EventCard(
            event: event,
            showRegistrationStatus: true,
            onTap: () => _navigateToEventDetail(event),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          EventCategory.values.map((category) {
            return _buildCategorySection(category);
          }).toList(),
    );
  }

  Widget _buildCategorySection(EventCategory category) {
    final categoryEvents =
        _allEvents
            .where((event) => event.category == category)
            .take(3)
            .toList();

    if (categoryEvents.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.displayName,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     setState(() {
              //       _selectedCategory = category;
              //       _tabController.animateTo(0);
              //     });
              //     _filterEvents();
              //   },
              //   child: Text('See all'),
              // ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal event list
          SizedBox(
            height: 380, // Increased from 300 to 350
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoryEvents.length,
              itemBuilder: (context, index) {
                final event = categoryEvents[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: EventCard(
                    event: event,
                    showRegistrationStatus: true,
                    isCompact: true, // Add this
                    onTap: () => _navigateToEventDetail(event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserEventsTab() {
    if (_isLoadingUserEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userEvents.isEmpty) {
      return _buildEmptyState(
        'No registered events',
        'Register for events to see them here',
        actionText: 'Browse Events',
        onAction: () => _tabController.animateTo(0),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _userEvents.length,
        itemBuilder: (context, index) {
          final event = _userEvents[index];
          return EventCard(
            event: event,
            showRegistrationStatus: true,
            onTap: () => _navigateToEventDetail(event),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySageGreen,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Events'),
            content: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title, location, or description...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                Navigator.of(context).pop();
                _performSearch(value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performSearch(_searchController.text);
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _selectedCategory = null; // Clear category filter when searching
    });
    _filterEvents();

    // Switch to All Events tab to show results
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  void _navigateToEventDetail(Event event) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        )
        .then((_) {
          // Refresh events when returning from detail screen
          _refreshEvents();
        });
  }
}
