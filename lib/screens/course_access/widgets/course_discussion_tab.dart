import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/course_discussion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/course_discussion.dart';
import '../../../theme/app_theme.dart';
import '../course_discussion_detail_screen.dart';

class CourseDiscussionTab extends StatefulWidget {
  final int courseId;

  const CourseDiscussionTab({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDiscussionTab> createState() => _CourseDiscussionTabState();
}

class _CourseDiscussionTabState extends State<CourseDiscussionTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CourseDiscussionProvider>().fetchDiscussions(
            widget.courseId,
            filter: _selectedFilter,
            search: _searchController.text,
          );
    }
  }

  Future<void> _loadData({bool refresh = false}) async {
    await context.read<CourseDiscussionProvider>().fetchDiscussions(
          widget.courseId,
          refresh: refresh,
          filter: _selectedFilter,
          search: _searchController.text,
        );
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadData(refresh: true);
  }

  void _onSearch() {
    _loadData(refresh: true);
  }

  void _openCreateThreadBottomSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask a Question / Post Topic',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'What is your question about?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Content / Details',
                  hintText: 'Provide details about your question...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Content details are required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          await this.context.read<CourseDiscussionProvider>().createDiscussion(
                                widget.courseId,
                                titleController.text,
                                contentController.text,
                              );
                          if (mounted) Navigator.pop(context);
                          _loadData(refresh: true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to post: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Post Thread'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseDiscussionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateThreadBottomSheet,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search discussions...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                _buildFilterChip('all', 'All Threads'),
                _buildFilterChip('announcements', 'Announcements'),
                _buildFilterChip('pinned', 'Pinned'),
                _buildFilterChip('my_questions', 'My Questions'),
              ],
            ),
          ),

          const Divider(height: 12),

          // Discussions List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadData(refresh: true),
              child: provider.discussions.isEmpty && !provider.isLoading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: provider.discussions.length + (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.discussions.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final discussion = provider.discussions[index];
                        return _buildDiscussionCard(discussion);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        selectedColor: AppTheme.primary,
        backgroundColor: Colors.grey[100],
        onSelected: (val) {
          if (val) _onFilterChanged(filter);
        },
      ),
    );
  }

  Widget _buildDiscussionCard(CourseDiscussion d) {
    final dateStr = DateFormat('MMM dd').format(d.createdAt);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDiscussionDetailScreen(
                courseId: widget.courseId,
                discussionId: d.id,
              ),
            ),
          ).then((_) => _loadData(refresh: true));
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: d.userPhoto != null && d.userPhoto!.isNotEmpty
                        ? NetworkImage(d.userPhoto!)
                        : null,
                    child: d.userPhoto == null || d.userPhoto!.isEmpty
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(color: Colors.grey[500], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (d.isPinned)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(4)),
                      child: Text('Pinned', style: TextStyle(color: Colors.amber[900], fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  if (d.isAnnouncement)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)),
                      child: Text('Announce', style: TextStyle(color: Colors.blue[900], fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                d.title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                d.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.read<CourseDiscussionProvider>().toggleLikeDiscussion(
                            widget.courseId,
                            d.id,
                          );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            d.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 14,
                            color: d.isLiked ? AppTheme.primary : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${d.likesCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: d.isLiked ? AppTheme.primary : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.comment_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${d.repliesCount}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'No Discussions Yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to ask a question or start a topic in this course module!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
