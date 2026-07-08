import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = true;
  bool _showSources = true;

  final List<String> _quickActions = [
    'Cari tender terbaru',
    'Jadwal pengadaan',
    'Cara daftar LPSE',
    'Syarat dokumen',
    'Info lelang',
  ];

  final List<Map<String, String>> _chatHistory = [
    {'title': 'Tender konstruksi 2025', 'date': '2 jam lalu'},
    {'title': 'Syarat perusahaan', 'date': 'Kemarin'},
    {'title': 'Jadwal lelang Q3', 'date': '3 hari lalu'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = context.read<ChatService>();
      chatService.addWelcomeMessage();
      chatService.addListener(_onMessagesChanged);
    _controller.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    context.read<ChatService>().removeListener(_onMessagesChanged);
    _controller.removeListener(() => setState(() {}));
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onMessagesChanged() {
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final chatService = context.read<ChatService>();
    chatService.sendMessage(text.trim());
    _controller.clear();
    _showSuggestions = false;
    _focusNode.unfocus();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400, size: 28)),
          const SizedBox(width: 12),
          const Text('Hapus Percakapan?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ]),
        content: const Text('Semua riwayat chat akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () {
            context.read<ChatService>().clearMessages();
            setState(() => _showSuggestions = true);
            Navigator.pop(ctx);
          }, style: FilledButton.styleFrom(backgroundColor: Colors.red.shade500),
            child: const Text('Hapus Semua')),
        ],
      ),
    );
  }

  void _exportChat() {
    final chatService = context.read<ChatService>();
    final messages = chatService.messages;
    if (messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada pesan untuk diexport')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('=== LPSE Bulukumba Chat Export ===');
    buffer.writeln('Tanggal: \${DateTime.now().toString().substring(0, 19)}');
    buffer.writeln('---');
    buffer.writeln('');;
    for (final msg in messages) {
      final role = msg.isUser ? 'Anda' : 'AI';
    buffer.writeln('[$role]');
      buffer.writeln(msg.content);
      buffer.writeln('');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Percakapan disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildSidebar(context),
      appBar: _buildGradientAppBar(context),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_showSuggestions) _buildSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildGradientAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.forum_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LPSE Bulukumba', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('Online', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_showSources ? Icons.source_rounded : Icons.toggle_off_rounded, color: Colors.white.withOpacity(0.8)),
          tooltip: 'Toggle sumber',
          onPressed: () => setState(() => _showSources = !_showSources),
        ),
        IconButton(
          icon: Icon(Icons.ios_share_rounded, color: Colors.white.withOpacity(0.8)),
          tooltip: 'Export chat',
          onPressed: _exportChat,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.8)),
          tooltip: 'Hapus percakapan',
          onPressed: _clearChat,
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riwayat Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Percakapan terakhir', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _chatHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Belum ada riwayat', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _chatHistory.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final chat = _chatHistory[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.indigo.shade400, size: 20),
                          ),
                          title: Text(chat['title']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text(chat['date']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onTap: () => Navigator.pop(context),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text('LPSE Bulukumba v1.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatService>(
      builder: (context, chatService, _) {
        final messages = chatService.messages;
        if (messages.isEmpty) {
          return _buildWelcomeScreen();
        }
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 100, bottom: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageBubble(
              key: ValueKey('${message.hashCode}_${message.timestamp}'),
              message: message,
              showSources: _showSources,
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA855F7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: const Center(child: Icon(Icons.forum_rounded, size: 48, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Text('LPSE Bulukumba', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(
              'Asisten Virtual Pengadaan Barang & Jasa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.8)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureChip(Icons.search_rounded, 'Cari Tender'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(Icons.calendar_month_rounded, 'Jadwal'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureChip(Icons.description_rounded, 'Syarat'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(Icons.help_outline_rounded, 'Panduan'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.shade100.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.indigo.shade500),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.indigo.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.explore_rounded, size: 14, color: Colors.indigo.shade400),
                const SizedBox(width: 6),
                Text('Coba tanyakan:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_quickActions[index], style: const TextStyle(fontSize: 12)),
                  avatar: Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.indigo.shade400),
                  onPressed: () => _sendMessage(_quickActions[index]),
                  backgroundColor: Colors.indigo.shade50,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade500),
              onPressed: () => _showMoreOptions(context),
              tooltip: 'Lainnya', splashRadius: 20,
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller, focusNode: _focusNode,
                      maxLines: null, textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...', border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey.shade400),
                      onPressed: () => _controller.clear(), splashRadius: 16,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _sendMessage(_controller.text),
                child: Container(
                  width: 44, height: 44, alignment: Alignment.center,
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.source_rounded, color: Colors.indigo.shade500)),
                title: const Text('Sumber Informasi'),
                subtitle: const Text('Toggle tampilan sumber jawaban'),
                trailing: Switch(value: _showSources, onChanged: (v) { setState(() => _showSources = v); Navigator.pop(ctx); }),
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.ios_share_rounded, color: Colors.green.shade500)),
                title: const Text('Export Chat'),
                subtitle: const Text('Salin percakapan ke clipboard'),
                onTap: () { Navigator.pop(ctx); _exportChat(); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade500)),
                title: const Text('Hapus Percakapan'),
                subtitle: const Text('Semua pesan akan dihapus'),
                onTap: () { Navigator.pop(ctx); _clearChat(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
