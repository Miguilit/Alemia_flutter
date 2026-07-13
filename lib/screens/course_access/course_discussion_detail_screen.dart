import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/course_discussion.dart';
import '../../providers/course_discussion_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CourseDiscussionDetailScreen extends StatefulWidget {
  final int courseId;
  final int discussionId;

  const CourseDiscussionDetailScreen({
    super.key,
    required this.courseId,
    required this.discussionId,
  });

  @override
  State<CourseDiscussionDetailScreen> createState() => _CourseDiscussionDetailScreenState();
}

class _CourseDiscussionDetailScreenState extends State<CourseDiscussionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseDiscussionProvider>().fetchDiscussionDetails(
            widget.courseId,
            widget.discussionId,
          );
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    try {
      await context.read<CourseDiscussionProvider>().createReply(
            widget.courseId,
            widget.discussionId,
            text,
          );
      _replyController.clear();
      FocusScope.of(context).unfocus();
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit reply: $e')),
      );
    }
  }

  void _deleteReply(int replyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<CourseDiscussionProvider>().deleteReply(
              widget.courseId,
              widget.discussionId,
              replyId,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseDiscussionProvider>();
    final currentUser = context.watch<AuthProvider>().user;
    final discussion = provider.selectedDiscussion;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Discussion Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: provider.isLoading && discussion == null
          ? const Center(child: CircularProgressIndicator())
          : discussion == null
              ? Center(child: Text(provider.error ?? 'Thread not found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // Main Post
                          _buildMainPost(discussion, currentUser?.id),
                          const SizedBox(height: 24),
                          
                          // Replies Header
                          Text(
                            'Replies (${discussion.replies.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Replies List
                          ...discussion.replies.map((reply) => _buildReplyCard(reply, currentUser?.id)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    
                    // Chat-style persistent reply input bar
                    _buildReplyInputBar(provider.isActionLoading),
                  ],
                ),
    );
  }

  Widget _buildMainPost(CourseDiscussion discussion, int? currentUserId) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm A').format(discussion.createdAt);

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: discussion.userPhoto != null && discussion.userPhoto!.isNotEmpty
                      ? NetworkImage(discussion.userPhoto!)
                      : null,
                  child: discussion.userPhoto == null || discussion.userPhoto!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (discussion.isPinned)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(4)),
                    child: Text('Pinned', style: TextStyle(color: Colors.amber[900], fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                if (discussion.isAnnouncement)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(4)),
                    child: Text('Announcement', style: TextStyle(color: Colors.blue[900], fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              discussion.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              discussion.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    context.read<CourseDiscussionProvider>().toggleLikeDiscussion(
                          widget.courseId,
                          discussion.id,
                        );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: discussion.isLiked ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: discussion.isLiked ? AppTheme.primary : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          discussion.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 14,
                          color: discussion.isLiked ? AppTheme.primary : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${discussion.likesCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: discussion.isLiked ? AppTheme.primary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (discussion.userId == currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Thread'),
                          content: const Text('Are you sure you want to delete this discussion thread?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await context.read<CourseDiscussionProvider>().deleteDiscussion(
                                widget.courseId,
                                discussion.id,
                              );
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete thread: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(CourseDiscussionReply reply, int? currentUserId) {
    // Check if reply user is instructor/staff. (Ideally backend flags this or we check user role if available. 
    // For now we check if profile photo or details look like instructor, but let's just make it a clean default view.)
    final isInstructor = reply.userName.toLowerCase().contains('instructor') || reply.userName.toLowerCase().contains('teacher');
    final dateStr = reply.createdAt.toLocal().toString().substring(0, 16);

    return Card(
      color: isInstructor ? Colors.blue[50]?.withOpacity(0.5) : Colors.white,
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInstructor 
            ? BorderSide(color: AppTheme.primary.withOpacity(0.3), width: 1)
            : BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: reply.userPhoto != null && reply.userPhoto!.isNotEmpty
                      ? NetworkImage(reply.userPhoto!)
                      : null,
                  child: reply.userPhoto == null || reply.userPhoto!.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (isInstructor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Instructor', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        dateStr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (reply.userId == currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () => _deleteReply(reply.id),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              reply.content,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    context.read<CourseDiscussionProvider>().toggleLikeReply(
                          widget.courseId,
                          reply.id,
                        );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reply.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 12,
                          color: reply.isLiked ? AppTheme.primary : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reply.likesCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: reply.isLiked ? AppTheme.primary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInputBar(bool isSending) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _replyController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Type a reply...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _submitReply,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
