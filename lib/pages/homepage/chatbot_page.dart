import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.currentSession == null && !chatProvider.isLoading) {
      await _startNewSession();
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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
        appBar: AppBar(
          title: const Text('Chat dengan AI'),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                    child: const Row(
                      children: [
                        Icon(Icons.chat_outlined, size: 24),
                        SizedBox(width: 16),
                        Text(
                          'Riwayat Obrolan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: chatProvider.sessionPreviews.isEmpty
                        ? const Center(child: Text('Belum ada riwayat obrolan'))
                        : ListView.builder(
                            itemCount: chatProvider.sessionPreviews.length,
                            itemBuilder: (context, index) {
                              final sessionId = chatProvider
                                  .sessionPreviews
                                  .keys
                                  .elementAt(index);
                              final preview =
                                  chatProvider.sessionPreviews[sessionId] ?? '';
                              final isActive =
                                  sessionId == chatProvider.currentSession?.id;

                              return ListTile(
                                title: Text(
                                  preview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: isActive,
                                selectedTileColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                selectedColor: Theme.of(context).primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  _switchSession(sessionId);
                                },
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Obrolan Baru'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
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
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
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
                          _BotMessageBubble(message: message.response),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
                          decoration: const InputDecoration(
                            hintText: 'Ketik pesan...',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !chatProvider.isLoading,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          chatProvider.isLoading
                              ? Icons.hourglass_empty
                              : Icons.send,
                        ),
                        onPressed: chatProvider.isLoading ? null : _sendMessage,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _BotMessageBubble extends StatelessWidget {
  final String message;

  const _BotMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(message),
      ),
    );
  }
}
