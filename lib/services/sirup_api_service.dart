import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/package_item.dart';
import '../models/penyedia.dart';

class SirupApiService extends ChangeNotifier {
  // Packages/Tenders
  List<PackageItem> _packages = [];
  List<PackageItem> get packages => _packages;

  bool _isLoadingPackages = false;
  bool get isLoadingPackages => _isLoadingPackages;

  int _totalPackages = 0;
  int get totalPackages => _totalPackages;

  int _currentPage = 1;
  int _totalPages = 1;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Stats
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  // Penyedia
  List<Penyedia> _penyediaList = [];
  List<Penyedia> get penyediaList => _penyediaList;

  bool _isLoadingPenyedia = false;
  bool get isLoadingPenyedia => _isLoadingPenyedia;

  int _totalPenyedia = 0;
  int get totalPenyedia => _totalPenyedia;

  int _penyediaPage = 1;
  int _penyediaTotalPages = 1;
  String _penyediaSearch = '';

  // Error
  String? _error;
  String? get error => _error;

  Future<void> fetchStats() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.statsEndpoint))
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        _stats = jsonDecode(response.body) as Map<String, dynamic>;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> fetchPackages({bool refresh = false}) async {
    if (_isLoadingPackages) return;

    if (refresh) {
      _currentPage = 1;
      _packages.clear();
    }

    _isLoadingPackages = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiConfig.tableEndpoint).replace(
        queryParameters: {
          'page': _currentPage.toString(),
          'per_page': '20',
          if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        },
      );

      final response = await http.get(uri).timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawPackages = data['packages'] as List<dynamic>? ?? [];

        if (refresh) {
          _packages = rawPackages
              .map((p) => PackageItem.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          _packages.addAll(rawPackages
              .map((p) => PackageItem.fromJson(p as Map<String, dynamic>)));
        }

        _totalPackages = data['filtered_count'] as int? ?? 0;
        _totalPages = data['total_pages'] as int? ?? 1;
      } else {
        _error = 'Error ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      debugPrint('Error fetching packages: $e');
    }

    _isLoadingPackages = false;
    notifyListeners();
  }

  Future<void> loadMorePackages() async {
    if (_currentPage < _totalPages && !_isLoadingPackages) {
      _currentPage++;
      await fetchPackages();
    }
  }

  Future<void> searchPackages(String query) async {
    _searchQuery = query;
    await fetchPackages(refresh: true);
  }

  Future<void> fetchPenyedia({bool refresh = false}) async {
    if (_isLoadingPenyedia) return;

    if (refresh) {
      _penyediaPage = 1;
      _penyediaList.clear();
    }

    _isLoadingPenyedia = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiConfig.penyediaEndpoint).replace(
        queryParameters: {
          'page': _penyediaPage.toString(),
          'per_page': '20',
          if (_penyediaSearch.isNotEmpty) 'search': _penyediaSearch,
        },
      );

      final response = await http.get(uri).timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawVendors = data['vendors'] as List<dynamic>? ?? [];

        if (refresh) {
          _penyediaList = rawVendors
              .map((v) => Penyedia.fromJson(v as Map<String, dynamic>))
              .toList();
        } else {
          _penyediaList.addAll(rawVendors
              .map((v) => Penyedia.fromJson(v as Map<String, dynamic>)));
        }

        _totalPenyedia = data['total_count'] as int? ?? 0;
        _penyediaTotalPages = data['total_pages'] as int? ?? 1;
      } else {
        _error = 'Error ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      debugPrint('Error fetching penyedia: $e');
    }

    _isLoadingPenyedia = false;
    notifyListeners();
  }

  Future<void> loadMorePenyedia() async {
    if (_penyediaPage < _penyediaTotalPages && !_isLoadingPenyedia) {
      _penyediaPage++;
      await fetchPenyedia();
    }
  }

  Future<void> searchPenyedia(String query) async {
    _penyediaSearch = query;
    await fetchPenyedia(refresh: true);
  }

  Future<Penyedia?> getPenyediaDetail(String nama) async {
    try {
      final response = await http
          .get(Uri.parse(
              '${ApiConfig.penyediaDetailEndpoint}?nama=${Uri.encodeComponent(nama)}'))
          .timeout(ApiConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Penyedia.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error fetching penyedia detail: $e');
    }
    return null;
  }
}
