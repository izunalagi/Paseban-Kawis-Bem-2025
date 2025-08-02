import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_app_bar.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    setState(() => _isInitializing = true);

    final token = context.read<AuthProvider>().token ?? '';
    final chatProvider = context.read<ChatProvider>();

    try {
      // Initialize chat provider (load sessions dan current session history)
      await chatProvider.initializeChat(token);

      // Jika tidak ada current session, buat session baru
      if (chatProvider.currentSession == null && !chatProvider.isLoading) {
        await _startNewSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Gagal menginisialisasi chat: $e')),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _startNewSession() async {
    try {
      final token = context.read<AuthProvider>().token ?? '';
      await context.read<ChatProvider>().startNewSession(token);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Sesi baru dimulai')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Gagal memulai sesi: $e')));
      }
    }
  }

  Future<void> _switchSession(String sessionId) async {
    try {
      final token = context.read<AuthProvider>().token ?? '';
      await context.read<ChatProvider>().switchSession(token, sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Gagal beralih sesi: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      final token = context.read<AuthProvider>().token ?? '';
      _messageController.clear();
      await context.read<ChatProvider>().sendMessage(token, message);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: const Color(0xFF043461),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'ChatBot',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ),
        endDrawer: _buildDrawer(),
        body: _isInitializing
            ? const LoadingWidget(message: 'Memuat chatbot...')
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.backgroundLight],
                    stops: [0.0, 0.3],
                  ),
                ),
                child: Column(
                  children: [
                    // Subtitle section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: const Text(
                        'Tanya apapun seputar materi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.isLoading &&
                              chatProvider.messages.isEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowMedium,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.all(16),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.accent,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Memulai percakapan...',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: chatProvider.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatProvider.messages[index];
                              return Column(
                                children: [
                                  _UserMessageBubble(message: message.prompt),
                                  _BotMessageBubble(
                                    message: message.response,
                                    isLatest:
                                        index ==
                                        chatProvider.messages.length - 1,
                                    isLoading: chatProvider.isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _buildInputSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_outlined, size: 24, color: Colors.white),
                      SizedBox(width: 16),
                      Text(
                        'Riwayat Obrolan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: chatProvider.sessionPreviews.isEmpty
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: AppColors.textLight,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat obrolan',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: chatProvider.sessionPreviews.length,
                            itemBuilder: (context, index) {
                              final sessionPreview =
                                  chatProvider.sessionPreviews[index];
                              final isActive =
                                  sessionPreview.id ==
                                  chatProvider.currentSession?.id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: isActive
                                      ? Border.all(
                                          color: AppColors.accent,
                                          width: 2,
                                        )
                                      : Border.all(
                                          color: AppColors.borderLight,
                                        ),
                                  color: isActive
                                      ? AppColors.accent.withOpacity(0.1)
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    sessionPreview.previewText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: sessionPreview.createdAt != null
                                      ? Text(
                                          _formatDate(
                                            sessionPreview.createdAt!,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _switchSession(sessionPreview.id);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
                const Divider(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Chat Baru',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.accent.withOpacity(0.3),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _startNewSession();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hari ini ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildInputSection() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  enabled: !chatProvider.isLoading,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: Icon(
                    chatProvider.isLoading ? Icons.hourglass_empty : Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: chatProvider.isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  final String message;

  const _UserMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class _BotMessageBubble extends StatefulWidget {
  final String message;
  final bool isLatest;
  final bool isLoading;

  const _BotMessageBubble({
    required this.message,
    required this.isLatest,
    required this.isLoading,
  });

  @override
  State<_BotMessageBubble> createState() => _BotMessageBubbleState();
}

class _BotMessageBubbleState extends State<_BotMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _characterCount;
  String _displayedText = '';
  bool _hasStartedTyping = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: Duration(
        milliseconds: widget.message.length * 20,
      ), // 20ms per character
      vsync: this,
    );

    _characterCount = IntTween(begin: 0, end: widget.message.length).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _characterCount.addListener(() {
      if (mounted) {
        setState(() {
          _displayedText = widget.message.substring(0, _characterCount.value);
        });
      }
    });

    // Start animation immediately if this is the latest message
    if (widget.isLatest && !widget.isLoading) {
      _startTypingAnimation();
    } else {
      // For older messages, show full text immediately
      _displayedText = widget.message;
    }
  }

  void _startTypingAnimation() {
    _hasStartedTyping = true;
    _displayedText = '';
    _animationController.forward(from: 0);
  }

  @override
  void didUpdateWidget(_BotMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.message != oldWidget.message) {
      // Message content changed, reset animation
      _animationController.dispose();
      _setupAnimation();
    } else if (widget.isLatest && !widget.isLoading && !_hasStartedTyping) {
      // Start typing effect for latest message
      _startTypingAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFormattedText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');

    int currentIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      // Add text before the match
      if (match.start > currentIndex) {
        final beforeText = text.substring(currentIndex, match.start);
        spans.add(
          TextSpan(
            text: beforeText.replaceAll('\\n', '\n'),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1)?.replaceAll('\\n', '\n') ?? '',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.add(
        TextSpan(
          text: remainingText.replaceAll('\\n', '\n'),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(_displayedText),
            if (widget.isLatest &&
                !widget.isLoading &&
                _displayedText.length < widget.message.length)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '▌',
                  style: TextStyle(color: AppColors.accent, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
