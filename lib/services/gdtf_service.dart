import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// GDTF Fixture Type from GDTF.info API
class GDTFFixture {
  final String id;
  final String name;
  final String manufacturer;
  final String category; // e.g., "Moving Light", "Wash", "Spot", "Strobe", "LED Bar"
  final List<String> modes; // DMX modes: 16ch, 8ch, etc
  final String description;
  final String? imageUrl;
  final DateTime fetchedAt;

  const GDTFFixture({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.category,
    required this.modes,
    required this.description,
    this.imageUrl,
    required this.fetchedAt,
  });

  factory GDTFFixture.fromJson(Map<String, dynamic> json) {
    return GDTFFixture(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? 'Other',
      modes: List<String>.from(json['modes'] ?? []),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'manufacturer': manufacturer,
    'category': category,
    'modes': modes,
    'description': description,
    'imageUrl': imageUrl,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  GDTFFixture copyWith({
    String? id,
    String? name,
    String? manufacturer,
    String? category,
    List<String>? modes,
    String? description,
    String? imageUrl,
    DateTime? fetchedAt,
  }) {
    return GDTFFixture(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      modes: modes ?? this.modes,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  String toString() => '$manufacturer $name ($category)';
}

/// Manages GDTF fixture database from gdtf.info
class GDTFService with ChangeNotifier {
  static const String _gdtfBaseUrl = 'https://gdtf.info/api/v1';
  static const int _cacheExpireHours = 24;

  final http.Client _httpClient;
  
  List<GDTFFixture> _cachedFixtures = [];
  DateTime? _lastFetchTime;
  bool _isLoading = false;
  String? _lastError;

  GDTFService({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();

  List<GDTFFixture> get fixtures => _cachedFixtures;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!).inHours < _cacheExpireHours;
  }

  /// Fetch all fixtures from GDTF API with pagination
  Future<void> fetchAllFixtures({bool force = false}) async {
    if (_isLoading) return;
    if (isCacheValid && !force) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final fixtures = <GDTFFixture>[];
      int page = 1;
      const pageSize = 100;
      bool hasMore = true;

      while (hasMore) {
        final url = Uri.parse(
          '$_gdtfBaseUrl/fixtures?page=$page&limit=$pageSize',
        );
        
        final response = await _httpClient.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> items = data['fixtures'] ?? [];
          
          if (items.isEmpty) {
            hasMore = false;
          } else {
            for (var item in items) {
              fixtures.add(GDTFFixture.fromJson(item));
            }
            page++;
          }
        } else {
          throw Exception('Failed to fetch fixtures: ${response.statusCode}');
        }
      }

      _cachedFixtures = fixtures;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      _lastError = 'Error fetching fixtures: $e';
      if (kDebugMode) print(_lastError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search fixtures by query (name, manufacturer)
  List<GDTFFixture> search(String query) {
    if (query.isEmpty) return _cachedFixtures;
    
    final lowerQuery = query.toLowerCase();
    return _cachedFixtures.where((fixture) {
      return fixture.name.toLowerCase().contains(lowerQuery) ||
          fixture.manufacturer.toLowerCase().contains(lowerQuery) ||
          fixture.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get fixtures by category
  List<GDTFFixture> getByCategory(String category) {
    return _cachedFixtures
        .where((f) => f.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get fixtures by manufacturer
  List<GDTFFixture> getByManufacturer(String manufacturer) {
    return _cachedFixtures
        .where((f) => f.manufacturer.toLowerCase() == manufacturer.toLowerCase())
        .toList();
  }

  /// Get unique manufacturers sorted
  List<String> getManufacturers() {
    final manufacturers = <String>{};
    for (var fixture in _cachedFixtures) {
      manufacturers.add(fixture.manufacturer);
    }
    return manufacturers.toList()..sort();
  }

  /// Get unique categories sorted
  List<String> getCategories() {
    final categories = <String>{};
    for (var fixture in _cachedFixtures) {
      categories.add(fixture.category);
    }
    return categories.toList()..sort();
  }

  /// Get top N most common fixtures (for offline fallback)
  List<GDTFFixture> getTopFixtures(int count) {
    // Sort by some popularity metric if available, otherwise return first N
    return _cachedFixtures.take(count).toList();
  }

  /// Fetch fixture details (if available)
  Future<GDTFFixture?> fetchFixtureDetails(String fixtureId) async {
    try {
      final url = Uri.parse('$_gdtfBaseUrl/fixtures/$fixtureId');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GDTFFixture.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching fixture details: $e');
    }
    return null;
  }

  /// Clear cache
  void clearCache() {
    _cachedFixtures = [];
    _lastFetchTime = null;
    _lastError = null;
    notifyListeners();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'fixtureCount': _cachedFixtures.length,
      'manufacturerCount': getManufacturers().length,
      'categoryCount': getCategories().length,
      'lastFetch': _lastFetchTime?.toIso8601String(),
      'cacheAge': _lastFetchTime != null
          ? DateTime.now().difference(_lastFetchTime!).inMinutes
          : null,
      'isCacheValid': isCacheValid,
    };
  }
}
