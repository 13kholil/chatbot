import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/chat_message.dart';

class ChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const List<String> _suggestedQuestions = [
    'Berapa total paket pengadaan di Bulukumba tahun 2025?',
    'Apa syarat jadi penyedia di SIRUP?',
    'Bagaimana proses pengadaan langsung?',
    'Siapa saja penyedia terdaftar?',
    'Apa itu SIRUP?',
  ];

  List<String> get suggestedQuestions => _suggestedQuestions;

  void addWelcomeMessage() {
    _messages.add(ChatMessage(
      role: 'system',
      content:
          '👋 Selamat datang di **LPSE Chatbot Bulukumba**!\n\n'
          'Saya adalah asisten AI yang siap membantu Anda menjawab pertanyaan '
          'seputar pengadaan barang dan jasa di Kabupaten Bulukumba.\n\n'
          '💡 **Saya bisa membantu:**\n'
          '• 📋 Data paket pengadaan SIRUP\n'
          '• 📜 Regulasi & Peraturan PBJ\n'
          '• 🏢 Informasi penyedia terdaftar\n'
          '• 📊 Statistik realisasi anggaran\n\n'
          'Silakan tanyakan apa saja! 👇',
    ));
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(role: 'user', content: text.trim()));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.chatEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': text.trim(),
              'top_k': 5,
              'temperature': 0.3,
            }),
          )
          .timeout(ApiConfig.chatTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final answer = data['answer'] as String? ?? 'Tidak ada jawaban.';
        final rawSources = data['sources'] as List<dynamic>?;
        final sources = rawSources
            ?.map((s) => s is Map<String, dynamic>
                ? '${s['source'] ?? 'Sumber'} (${s['relevance'] ?? ''})'
                : s.toString())
            .toList();

        _messages.add(ChatMessage(
          role: 'assistant',
          content: answer,
          sources: sources,
        ));
      } else {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: '⚠️ **Error ${response.statusCode}**\n\n'
              'Server mengembalikan error. Silakan coba lagi nanti.',
          isError: true,
        ));
      }
    } catch (e) {
      String errorMsg;
      if (e is http.ClientException) {
        errorMsg = '⚠️ **Koneksi gagal**\n\n'
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else {
        errorMsg = '⚠️ **Terjadi kesalahan**\n\n'
            '$e';
      }
      _messages.add(ChatMessage(
        role: 'assistant',
        content: errorMsg,
        isError: true,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }
}
