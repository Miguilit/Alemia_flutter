import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat_message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationId,
    this.instructorId,
    this.instructorName,
  });

  final int? conversationId;
  final int? instructorId;
  final String? instructorName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedFiles = <File>[];

  late final ChatProvider _chatProvider;

  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _messageController.addListener(_handleComposerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.conversationId != null) {
        await _chatProvider.loadMessages(widget.conversationId!);
      } else if (widget.instructorId != null) {
        await _chatProvider.startConversation(widget.instructorId!);
      }

      if (mounted) {
        _scheduleScrollToBottom(force: true);
      }
    });
  }

  @override
  void dispose() {
    _messageController
      ..removeListener(_handleComposerChanged)
      ..dispose();
    _scrollController.dispose();
    _chatProvider.clearChat();
    super.dispose();
  }

  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleScrollToBottom({bool force = false, int? messageCount}) {
    if (!force && messageCount != null && messageCount == _lastMessageCount) {
      return;
    }

    if (messageCount != null) {
      _lastMessageCount = messageCount;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _takePhoto(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();

    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
    );

    if (!mounted || photo == null) {
      return;
    }

    setState(() {
      _selectedFiles.add(File(photo.path));
    });
  }

  Future<void> _chooseImages(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();

    final List<XFile> images = await ImagePicker().pickMultiImage(
      imageQuality: 88,
    );

    if (!mounted || images.isEmpty) {
      return;
    }

    setState(() {
      _selectedFiles.addAll(images.map((XFile image) => File(image.path)));
    });
  }

  Future<void> _chooseDocuments(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const <String>[
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'zip',
      ],
    );

    if (!mounted || result == null) {
      return;
    }

    final List<File> files = result.files
        .where((PlatformFile file) => file.path != null)
        .map((PlatformFile file) => File(file.path!))
        .toList(growable: false);

    if (files.isEmpty) {
      return;
    }

    setState(() {
      _selectedFiles.addAll(files);
    });
  }

  Future<void> _showAttachmentSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.getBorderColor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.getMint100(context),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.getAccentColor(context),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      context.l10n.chooseAttachment,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AttachmentOption(
                icon: HugeIcons.strokeRoundedCamera01,
                title: context.l10n.camera,
                subtitle: context.l10n.takePhoto,
                onTap: () => _takePhoto(sheetContext),
              ),
              const SizedBox(height: 10),
              _AttachmentOption(
                icon: HugeIcons.strokeRoundedImage01,
                title: context.l10n.gallery,
                subtitle: context.l10n.chooseFromGallery,
                onTap: () => _chooseImages(sheetContext),
              ),
              const SizedBox(height: 10),
              _AttachmentOption(
                icon: HugeIcons.strokeRoundedAttachment01,
                title: context.l10n.files,
                subtitle: context.l10n.chooseFiles,
                onTap: () => _chooseDocuments(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();

    if (text.isEmpty && _selectedFiles.isEmpty) {
      return;
    }

    final List<File> files = List<File>.from(_selectedFiles);

    _messageController.clear();
    setState(() {
      _selectedFiles.clear();
    });

    final ChatProvider provider = context.read<ChatProvider>();

    if (files.isNotEmpty) {
      await provider.sendMessageWithFiles(
        message: text.isNotEmpty ? text : null,
        filePaths: files.map((File file) => file.path).toList(growable: false),
      );
    } else {
      await provider.sendMessage(text);
    }

    if (mounted) {
      _scheduleScrollToBottom(force: true);
    }
  }

  Future<void> _retryMessages() async {
    if (widget.conversationId != null) {
      await _chatProvider.loadMessages(widget.conversationId!);
      return;
    }

    if (widget.instructorId != null) {
      await _chatProvider.startConversation(widget.instructorId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentUserId = context.read<AuthProvider>().user?.id ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _buildPremiumHeader(context),
            Expanded(
              child: Consumer<ChatProvider>(
                builder:
                    (
                      BuildContext context,
                      ChatProvider provider,
                      Widget? child,
                    ) {
                      _scheduleScrollToBottom(
                        messageCount: provider.messages.length,
                      );

                      if (provider.isLoading && provider.messages.isEmpty) {
                        return const _MessageLoadingState();
                      }

                      if (provider.error != null && provider.messages.isEmpty) {
                        return _MessageState(
                          icon: Icons.cloud_off_rounded,
                          title: context.l10n.failedLoadMessages,
                          subtitle: context.l10n.checkConnectionAndRetry,
                          actionLabel: context.l10n.retry,
                          onAction: _retryMessages,
                        );
                      }

                      if (provider.messages.isEmpty) {
                        return _MessageState(
                          icon: Icons.waving_hand_outlined,
                          title: context.l10n.noMessagesTitle,
                          subtitle: context.l10n.noMessagesSubtitle,
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                        itemCount: provider.messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ChatMessage message = provider.messages[index];
                          final bool isMe = message.senderId == currentUserId;

                          return _MessageBubble(message: message, isMe: isMe);
                        },
                      );
                    },
              ),
            ),
            if (_selectedFiles.isNotEmpty) _buildSelectedFiles(context),
            _buildComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (BuildContext context, ChatProvider provider, Widget? child) {
        final dynamic instructor = provider.activeConversation?.instructor;

        final String displayName =
            (instructor?.name ?? widget.instructorName ?? '').toString().trim();

        final String safeName = displayName.isNotEmpty
            ? displayName
            : context.l10n.instructor;

        final String? profilePhoto = instructor?.profilePhoto?.toString();

        final String initial = safeName.isEmpty
            ? '?'
            : safeName.substring(0, 1).toUpperCase();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[AppTheme.black, AppTheme.blackElevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.isDark(context)
                  ? AppTheme.borderDark
                  : AppTheme.black.withValues(alpha: 0.08),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark(context) ? 0.30 : 0.14,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Material(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    context.read<ChatProvider>().clearChat();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldLight, width: 1.5),
                ),
                child: CircleAvatar(
                  backgroundColor: AppTheme.gold.withValues(alpha: 0.18),
                  backgroundImage:
                      profilePhoto != null && profilePhoto.isNotEmpty
                      ? NetworkImage(AppConfig.getImageUrl(profilePhoto))
                      : null,
                  child: profilePhoto == null || profilePhoto.isEmpty
                      ? Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.goldLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      safeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            context.l10n.instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.66),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: context.l10n.secureChat,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AppTheme.goldLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedFiles(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.attachment_rounded,
                size: 17,
                color: AppTheme.getAccentColor(context),
              ),
              const SizedBox(width: 7),
              Text(
                context.l10n.selectedAttachmentsCount(_selectedFiles.length),
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 9),
              itemBuilder: (BuildContext context, int index) {
                final File file = _selectedFiles[index];
                final bool isImage = _isImagePath(file.path);

                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 68,
                      height: 68,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppTheme.getBorderColor(context),
                        ),
                      ),
                      child: isImage
                          ? Image.file(file, fit: BoxFit.cover)
                          : Icon(
                              Icons.insert_drive_file_outlined,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                    ),
                    Positioned(
                      top: -7,
                      right: -7,
                      child: Tooltip(
                        message: context.l10n.removeAttachment,
                        child: Material(
                          color: AppTheme.danger,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (BuildContext context, ChatProvider provider, Widget? child) {
        final bool hasContent =
            _messageController.text.trim().isNotEmpty ||
            _selectedFiles.isNotEmpty;
        final bool canSend = hasContent && !provider.isSending;

        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.paddingOf(context).bottom + 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            border: Border(
              top: BorderSide(color: AppTheme.getBorderColor(context)),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark(context) ? 0.18 : 0.06,
                ),
                blurRadius: 22,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Tooltip(
                message: context.l10n.chooseAttachment,
                child: Material(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _showAttachmentSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAttachment01,
                          size: 21,
                          color: AppTheme.getAccentColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 126,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.typeMessage,
                      hintStyle: TextStyle(
                        color: AppTheme.getSecondaryTextColor(
                          context,
                        ).withValues(alpha: 0.72),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Tooltip(
                message: provider.isSending
                    ? context.l10n.messageSending
                    : context.l10n.sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: canSend
                        ? AppTheme.getPrimaryColor(context)
                        : AppTheme.getSoftGray150(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: canSend ? _sendMessage : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: provider.isSending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppTheme.getAccentColor(context),
                                ),
                              )
                            : HugeIcon(
                                icon: HugeIcons.strokeRoundedSent,
                                size: 21,
                                color: canSend
                                    ? Colors.white
                                    : AppTheme.getSecondaryTextColor(context),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isImagePath(String path) {
    final String lowerPath = path.toLowerCase();

    return <String>[
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
    ].any(lowerPath.endsWith);
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.getBackgroundColor(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    size: 21,
                    color: AppTheme.getAccentColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageLoadingState extends StatelessWidget {
  const _MessageLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      children: <Widget>[
        _LoadingBubble(alignment: Alignment.centerLeft, widthFactor: 0.62),
        const SizedBox(height: 16),
        _LoadingBubble(alignment: Alignment.centerRight, widthFactor: 0.74),
        const SizedBox(height: 16),
        _LoadingBubble(alignment: Alignment.centerLeft, widthFactor: 0.48),
        const SizedBox(height: 16),
        _LoadingBubble(alignment: Alignment.centerRight, widthFactor: 0.56),
      ],
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble({required this.alignment, required this.widthFactor});

  final Alignment alignment;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppTheme.getSoftGray150(context),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getAccentColor(
                    context,
                  ).withValues(alpha: 0.24),
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.getAccentColor(context),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 19,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final String body = message.body?.trim() ?? '';
    final Color bubbleColor = isMe
        ? AppTheme.getPrimaryColor(context)
        : AppTheme.getCardColor(context);
    final Color textColor = isMe
        ? Colors.white
        : AppTheme.getTextColor(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            if (message.attachments.isNotEmpty)
              ...message.attachments.map(
                (ChatAttachment attachment) =>
                    _buildAttachment(context, attachment),
              ),
            if (body.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 20),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: AppTheme.getBorderColor(context)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: AppTheme.isDark(context) ? 0.16 : 0.05,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  body,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 5),
            Text(
              _formatMessageTime(context, message.createdAt),
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, ChatAttachment attachment) {
    if (attachment.isImage) {
      final String imageUrl = attachment.filePath.startsWith('http')
          ? attachment.filePath
          : '${AppConfig.baseUrl}/storage/'
                '${attachment.filePath}';

      return Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _showImagePreview(context, imageUrl),
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250, maxHeight: 220),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return SizedBox(
                            height: 120,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: AppTheme.getSecondaryTextColor(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.imageUnavailable,
                                    style: TextStyle(
                                      color: AppTheme.getSecondaryTextColor(
                                        context,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.13)
            : AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? Colors.white.withValues(alpha: 0.18)
              : AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.13)
                  : AppTheme.getMint100(context),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFile02,
                size: 17,
                color: isMe ? Colors.white : AppTheme.getAccentColor(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              attachment.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.getTextColor(context),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMessageTime(BuildContext context, String rawDate) {
    try {
      final DateTime date = DateTime.parse(rawDate).toLocal();

      return MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(date),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );
    } catch (_) {
      return '';
    }
  }
}
