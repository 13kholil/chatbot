class ApiConfig {
  // Production
  static const String baseUrl = 'https://callunk.my.id';
  static const String ragUrl = '$baseUrl/rag';
  static const String sirupUrl = baseUrl;

  // For Android emulator (uncomment when testing locally)
  // static const String baseUrl = 'http://10.0.2.2';
  // static const String ragUrl = 'http://10.0.2.2:8000';
  // static const String sirupUrl = 'http://10.0.2.2:5005';

  // For iOS simulator
  // static const String baseUrl = 'http://127.0.0.1';
  // static const String ragUrl = 'http://127.0.0.1:8000';
  // static const String sirupUrl = 'http://127.0.0.1:5005';

  // RAG endpoints
  static const String chatEndpoint = '$ragUrl/chat';
  static const String chatStreamEndpoint = '$ragUrl/chat/stream';
  static const String searchEndpoint = '$ragUrl/search';
  static const String healthEndpoint = '$ragUrl/health';

  // SIRUP endpoints
  static const String statsEndpoint = '$sirupUrl/api/stats';
  static const String tableEndpoint = '$sirupUrl/api/table';
  static const String penyediaEndpoint = '$sirupUrl/api/penyedia';
  static const String penyediaDetailEndpoint = '$sirupUrl/api/penyedia_detail';

  // Timeouts
  static const Duration chatTimeout = Duration(seconds: 120);
  static const Duration apiTimeout = Duration(seconds: 30);
}
