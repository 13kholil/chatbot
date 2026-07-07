import 'dart:async';
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

    // Create a streaming message placeholder
    final streamMsg = ChatMessage(
      role: 'assistant',
      content: '',
      isStreaming: true,
    );
    _messages.add(streamMsg);
    notifyListeners();

    http.Client? client;
    try {
      client = http.Client();
      final request = http.Request('POST', Uri.parse(ApiConfig.chatStreamEndpoint));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'query': text.trim(),
        'top_k': 5,
        'use_rag': true,
        'temperature': 0.3,
      });

      final response = await client.send(request);

      if (response.statusCode != 200) {
        _finalizeStreamingMessage(
          '⚠️ **Error ${response.statusCode}**\n\nServer mengembalikan error. Silakan coba lagi nanti.',
          null,
          true,
        );
        return;
      }

      String fullAnswer = '';
      List<String> streamSources = [];
      String lastEvent = '';
      final lineStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('event: ')) {
          lastEvent = trimmed.substring(7);
          continue;
        }

        if (trimmed.startsWith('data: ')) {
          final jsonStr = trimmed.substring(6);
          try {
            if (lastEvent == 'sources') {
              final parsed = jsonDecode(jsonStr) as List<dynamic>;
              streamSources = parsed.map((s) {
                if (s is Map<String, dynamic>) {
                  return '${s['source'] ?? 'Sumber'} (${s['relevance'] ?? ''})';
                }
                return s.toString();
              }).toList();
              lastEvent = '';
              continue;
            }

            final data = jsonDecode(jsonStr) as Map<String, dynamic>;

            if (data.containsKey('token')) {
              final token = data['token'] as String? ?? '';
              if (token.isNotEmpty) {
                fullAnswer += token;
                _updateStreamingMessage(fullAnswer);
              }
            }
          } catch (_) {
            // Ignore JSON parse errors from incomplete lines
          }
        }
      }

      _finalizeStreamingMessage(fullAnswer, streamSources, false);
    } catch (e) {
      String errorMsg;
      if (e is http.ClientException) {
        errorMsg = '⚠️ **Koneksi gagal**\n\nTidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e is TimeoutException) {
        errorMsg = '⚠️ **Waktu habis**\n\nServer tidak merespons tepat waktu. Silakan coba lagi.';
      } else {
        errorMsg = '⚠️ **Terjadi kesalahan**\n\n$e';
      }
      _finalizeStreamingMessage(errorMsg, null, true);
    } finally {
      client?.close();
    }
  }

  void _updateStreamingMessage(String accumulatedText) {
    final index = _messages.length - 1;
    if (index >= 0 && _messages[index].isStreaming) {
      _messages[index] = _messages[index].copyWith(
        content: accumulatedText,
      );
      notifyListeners();
    }
  }

  void _finalizeStreamingMessage(String fullContent, List<String>? sources, bool isError) {
    final index = _messages.length - 1;
    if (index >= 0 && _messages[index].isStreaming) {
      _messages[index] = _messages[index].copyWith(
        content: fullContent,
        sources: sources,
        isError: isError,
        isStreaming: false,
      );
    } else {
      _messages.add(ChatMessage(
        role: 'assistant',
        content: fullContent,
        sources: sources,
        isError: isError,
      ));
    }
    _isLoading = false;
    notifyListeners();
  }
}
