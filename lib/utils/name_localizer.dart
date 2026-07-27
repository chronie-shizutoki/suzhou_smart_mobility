import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show Locale;
import 'package:lpinyin/lpinyin.dart';

/// Localized representation of a single station / route name.
///
/// - [original] is always the Simplified-Chinese source name (or its
///   Traditional variant when the active locale is TW/HK).
/// - [translation] is the dictionary translation for the active locale, or
///   null when no entry exists.
/// - [pinyin] is the romanized reading of [original], used as a subtitle for
///   matched translations.
/// - [matched] is true only when a dictionary entry was found for the active
///   non-Chinese locale.
class LocalizedName {
  final String original;
  final String? translation;
  final String? pinyin;
  final bool matched;

  const LocalizedName({
    required this.original,
    this.translation,
    this.pinyin,
    this.matched = false,
  });
}

/// Loads and indexes the per-language translation dictionaries.
///
/// Dictionaries are plain JSON objects keyed by the Simplified-Chinese name
/// with the translation as the value. One file per language:
///   assets/i18n/names_en.json
///   assets/i18n/names_ja.json
///   assets/i18n/names_ko.json
///
/// The backend is third-party and cannot be changed, so translations live
/// entirely on the client and are matched by exact (full) Chinese name.
class NameDictionary {
  static final NameDictionary instance = NameDictionary._();

  NameDictionary._();

  Locale? _locale;

  final Map<String, String> _en = <String, String>{};
  final Map<String, String> _ja = <String, String>{};
  final Map<String, String> _ko = <String, String>{};

  // Reverse indexes (translation -> chinese) for search by translated term.
  final Map<String, String> _enRev = <String, String>{};
  final Map<String, String> _jaRev = <String, String>{};
  final Map<String, String> _koRev = <String, String>{};

  // Pinyin cache keyed by the chinese name.
  final Map<String, String> _pinyinCache = <String, String>{};

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    await _loadFile('assets/i18n/names_en.json', _en, _enRev);
    await _loadFile('assets/i18n/names_ja.json', _ja, _jaRev);
    await _loadFile('assets/i18n/names_ko.json', _ko, _koRev);
    _loaded = true;
  }

  Future<void> _loadFile(
    String path,
    Map<String, String> forward,
    Map<String, String> reverse,
  ) async {
    try {
      final content = await rootBundle.loadString(path);
      final data = jsonDecode(content);
      if (data is Map) {
        data.forEach((key, value) {
          final k = key.toString();
          final v = value?.toString() ?? '';
          if (v.isNotEmpty) {
            forward[k] = v;
            reverse[v.toLowerCase()] = k;
          }
        });
      }
    } catch (_) {
      // Missing or empty file: keep this language's dictionary empty so the
      // rest of the app keeps working.
    }
  }

  void setLocale(Locale locale) => _locale = locale;

  Map<String, String>? _forwardMap(Locale? locale) {
    if (locale == null) return null;
    switch (locale.languageCode) {
      case 'en':
        return _en;
      case 'ja':
        return _ja;
      case 'ko':
        return _ko;
      default:
        return null;
    }
  }

  Map<String, String>? _reverseMap(Locale? locale) {
    if (locale == null) return null;
    switch (locale.languageCode) {
      case 'en':
        return _enRev;
      case 'ja':
        return _jaRev;
      case 'ko':
        return _koRev;
      default:
        return null;
    }
  }

  /// Exact (full-name) match of a Simplified-Chinese name to its translation.
  String? lookup(String chinese, Locale? locale) => _forwardMap(locale)?[chinese];

  /// Find chinese names whose translation contains [query] (case-insensitive).
  /// Used so users can search by the translated term.
  List<String> reverseLookup(String query, Locale? locale) {
    final rev = _reverseMap(locale);
    if (rev == null || query.isEmpty) return const [];
    final q = query.toLowerCase();
    return rev.entries
        .where((e) => e.key.contains(q))
        .map((e) => e.value)
        .toList();
  }

  /// Romanized reading of a chinese name, cached. Falls back to the original
  /// text if a character cannot be romanized.
  String pinyin(String chinese) {
    return _pinyinCache.putIfAbsent(chinese, () {
      try {
        return PinyinHelper.getPinyin(
          chinese,
          separator: ' ',
          format: PinyinFormat.WITH_TONE_MARK,
        );
      } catch (_) {
        return chinese;
      }
    });
  }
}
