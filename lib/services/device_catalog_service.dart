import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DeviceCatalogService {
  Future<Map<String, dynamic>> loadLocalCatalog() async {
    final data = await rootBundle.loadString('assets/data/device_catalog.json');
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Placeholders for future automated imports
  Future<void> importFromOFL() async {
    // TODO: Download OFL JSON and normalize to internal models
  }

  Future<void> importVendorPanelsCSV(String csvPath) async {
    // TODO: Parse vendor-provided CSV into led_panels entries
  }
}
