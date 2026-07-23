import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _searchController = TextEditingController();

  List<Event> _events = <Event>[];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedTimeFilter = 'upcoming';
  String _selectedPriceFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final response = await _eventService.fetchEvents(
        filter: _selectedTimeFilter,
        priceFilter: _selectedPriceFilter,
        search: _searchController.text,
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> eventsList =
            data['data'] as List<dynamic>? ?? <dynamic>[];

        setState(() {
          _events = eventsList
              .whereType<Map<String, dynamic>>()
              .map<Event>(Event.fromJson)
              .toList();
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _errorMessage = context.l10n.eventFailedLoad;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = context.l10n.eventFetchError;
        _isLoading = false;
      });
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _EventFilterSheet(
        initialTimeFilter: _selectedTimeFilter,
        initialPriceFilter: _selectedPriceFilter,
        onApplyFilters: (_EventFilterSelection selection) {
          setState(() {
            _selectedTimeFilter = selection.timeFilter;
            _selectedPriceFilter = selection.priceFilter;
          });
          _fetchEvents();
        },
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return '';
    }

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    // We already handle this in AppBar/SliverAppBar typically but for standard Scaffold:
    // final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Search Bar
            Container(
              color: AppTheme.getBackgroundColor(context),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _SearchBar(
                controller: _searchController,
                onSearch: _fetchEvents,
                onFilterTap: () => _showFilterSheet(context),
              ),
            ),
            // Events List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : _events.isEmpty
                  ? _EmptyEventsState(filterType: _selectedTimeFilter)
                  : RefreshIndicator(
                      onRefresh: _fetchEvents,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _events.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (BuildContext context, int index) {
                          final Event event = _events[index];
                          return _EventCard(
                            event: event,
                            formattedDate: _formatDate(
                              context,
                              event.startDate,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailScreen(event: event),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentTab: BottomNavTab.events,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.formattedDate,
    required this.onTap,
  });

  final Event event;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Event Image
            Stack(
              children: <Widget>[
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: AppTheme.mint200,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: event.featuredImage != null
                        ? Image.network(
                            AppConfig.getImageUrl(event.featuredImage!),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.calendar_today,
                            color: AppTheme.getPrimaryColor(context),
                            size: 40,
                          ),
                  ),
                ),
                // Booked Badge (Hide for now as we don't have isBooked in model yet)
                /* if (event.isBooked)
                   ... */
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Date & Time
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.startTime ?? '',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Venue
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.locationDescription ??
                              event.location ??
                              context.l10n.online,
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Attendees & Price
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAiUser,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.eventAttendeesCount(
                          event.confirmedBookingsCount,
                        ),
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        event.price == 0.00 || event.price == null
                            ? context.l10n.free
                            : settingsProvider.formatPrice(event.price),
                        style: TextStyle(
                          color: event.price == 0.00 || event.price == null
                              ? Colors.green
                              : AppTheme.getTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventsState extends StatelessWidget {
  const _EmptyEventsState({required this.filterType});

  final String filterType;

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    switch (filterType) {
      case 'upcoming':
        title = context.l10n.noUpcomingEvents;
        message = context.l10n.checkBackLaterForNewEvents;
        break;
      case 'past':
        title = context.l10n.noPastEvents;
        message = context.l10n.noAttendedEventsYet;
        break;
      default:
        title = context.l10n.noEventsAvailable;
        message = context.l10n.noEventsAvailableNow;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar01,
                  size: 60,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.getCardColor(context),
                hintText: l10n.eventSearchHint,
                hintStyle: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.65),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ).copyWith(right: 52),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: onSearch,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFilterHorizontal,
                  size: 20,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.getTextColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFilterSelection {
  const _EventFilterSelection({
    required this.timeFilter,
    required this.priceFilter,
  });

  final String timeFilter;
  final String priceFilter;
}

class _EventFilterSheet extends StatefulWidget {
  const _EventFilterSheet({
    required this.initialTimeFilter,
    required this.initialPriceFilter,
    required this.onApplyFilters,
  });

  final String initialTimeFilter;
  final String initialPriceFilter;
  final ValueChanged<_EventFilterSelection> onApplyFilters;

  @override
  State<_EventFilterSheet> createState() => _EventFilterSheetState();
}

class _EventFilterSheetState extends State<_EventFilterSheet> {
  late String _selectedTimeFilter;
  late String _selectedPriceFilter;

  @override
  void initState() {
    super.initState();
    _selectedTimeFilter = widget.initialTimeFilter;
    _selectedPriceFilter = widget.initialPriceFilter;
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settingsProvider = Provider.of<SettingsProvider>(
      context,
    );
    final AppLocalizations l10n = context.l10n;

    final List<_EventPriceOption> priceOptions = <_EventPriceOption>[
      _EventPriceOption(value: 'all', label: l10n.all),
      _EventPriceOption(value: 'free', label: l10n.free),
      _EventPriceOption(value: 'paid', label: l10n.eventFilterPaid),
      _EventPriceOption(
        value: 'under_50',
        label: l10n.eventFilterUnderPrice(settingsProvider.formatPrice(50)),
      ),
      _EventPriceOption(
        value: 'between_50_100',
        label: l10n.eventFilterPriceRange(
          settingsProvider.formatPrice(50),
          settingsProvider.formatPrice(100),
        ),
      ),
      _EventPriceOption(
        value: 'over_100',
        label: l10n.eventFilterOverPrice(settingsProvider.formatPrice(100)),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.45,
        maxChildSize: 0.82,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      l10n.eventFilterTitle,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTimeFilter = 'upcoming';
                          _selectedPriceFilter = 'all';
                        });
                      },
                      child: Text(
                        l10n.reset,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    Text(
                      l10n.time,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _FilterChipButton(
                            label: l10n.upcoming,
                            isSelected: _selectedTimeFilter == 'upcoming',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'upcoming';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterChipButton(
                            label: l10n.eventFilterPast,
                            isSelected: _selectedTimeFilter == 'past',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'past';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterChipButton(
                            label: l10n.all,
                            isSelected: _selectedTimeFilter == 'all',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'all';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.price,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: priceOptions.map<Widget>((
                        _EventPriceOption option,
                      ) {
                        final bool isSelected =
                            _selectedPriceFilter == option.value;

                        return FilterChip(
                          label: Text(option.label),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedPriceFilter = option.value;
                            });
                          },
                          selectedColor: AppTheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.getTextColor(context),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.2),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      _EventFilterSelection(
                        timeFilter: _selectedTimeFilter,
                        priceFilter: _selectedPriceFilter,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.eventApplyFilters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventPriceOption {
  const _EventPriceOption({required this.value, required this.label});

  final String value;
  final String label;
}
