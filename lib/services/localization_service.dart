import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  static const String _deKey = 'de';
  static const String _enKey = 'en';

  late Map<String, dynamic> _deLocalization;
  late Map<String, dynamic> _enLocalization;

  String _currentLanguage = _deKey;

  Future<void> initialize() async {
    try {
      _deLocalization = jsonDecode(
        await rootBundle.loadString('assets/i18n/de.json'),
      );
      _enLocalization = jsonDecode(
        await rootBundle.loadString('assets/i18n/en.json'),
      );
    } catch (e) {
      print('Error loading localization: $e');
      _deLocalization = {};
      _enLocalization = {};
    }
  }

  void setLanguage(String languageCode) {
    if (languageCode == _deKey || languageCode == _enKey) {
      _currentLanguage = languageCode;
    }
  }

  String get currentLanguage => _currentLanguage;

  String translate(String key) {
    try {
      final keys = key.split('.');
      late dynamic value;

      if (_currentLanguage == _deKey) {
        value = _deLocalization;
      } else {
        value = _enLocalization;
      }

      for (final k in keys) {
        if (value is Map) {
          value = value[k];
        } else {
          return key;
        }
      }

      return value?.toString() ?? key;
    } catch (e) {
      print('Translation error for key: $key');
      return key;
    }
  }

  // Helper methods
  String get appTitle => translate('app_title');
  String get appSubtitle => translate('app_subtitle');

  String get commonSave => translate('common.save');
  String get commonCancel => translate('common.cancel');
  String get commonDelete => translate('common.delete');
  String get commonEdit => translate('common.edit');
  String get commonAdd => translate('common.add');
  String get commonLoading => translate('common.loading');
  String get commonError => translate('common.error');
  String get commonSuccess => translate('common.success');

  String get projectsTitle => translate('projects.title');
  String get projectsNewProject => translate('projects.new_project');
  String get projectsProjectName => translate('projects.project_name');
  String get projectsDescription => translate('projects.description');
  String get projectsDeleteConfirm => translate('projects.delete_confirm');

  String get ledParamsBrand => translate('led_params.brand');
  String get ledParamsModel => translate('led_params.model');
  String get ledParamsVariant => translate('led_params.variant');
  String get ledParamsWidthMm => translate('led_params.width_mm');
  String get ledParamsHeightMm => translate('led_params.height_mm');
  String get ledParamsLedDistanceMm => translate('led_params.led_distance_mm');

  String get costTitle => translate('costs.title');
  String get costModulePrice => translate('costs.module_price');
  String get costInstallation => translate('costs.installation_cost');
  String get costServiceWarranty => translate('costs.service_warranty');
  String get costShipping => translate('costs.shipping_cost');
  String get costTotal => translate('costs.total_cost');

  String get resultsTitle => translate('results.title');
  String get resultsPixelDensity => translate('results.pixel_density');
  String get resultsResolution => translate('results.resolution');
  String get resultsTotalArea => translate('results.total_area');
  String get resultsTotalPower => translate('results.total_power');
  String get resultsTotalCurrent => translate('results.total_current');

  String get syncStatusSyncing => translate('sync.status_syncing');
  String get syncStatusSynced => translate('sync.status_synced');
  String get syncStatusOffline => translate('sync.status_offline');
  String get syncStatusNotLoggedIn => translate('sync.status_not_logged_in');

  String get authEmail => translate('auth.email');
  String get authPassword => translate('auth.password');
  String get authLogin => translate('auth.sign_in');
  String get authSignUp => translate('auth.sign_up');
  String get authSkip => translate('auth.skip');

  String get communityTitle => translate('community.title');
  String get communityPublish => translate('community.publish');
  String get communityPublishConfirm => translate('community.publish_confirm');

  String get exportPdf => translate('export.pdf');
  String get exportCsv => translate('export.csv');
}

// Global localization instance
final localization = LocalizationService();

String t(String key) => localization.translate(key);
