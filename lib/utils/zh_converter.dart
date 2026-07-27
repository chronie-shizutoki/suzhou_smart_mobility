import 'package:flutter/material.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

/// Thin wrapper around the `flutter_open_chinese_convert` (OpenCC) library.
/// Conversion is fully delegated to the library; no custom mapping is used.
class ZhConverter {
  // Active locale used to decide whether conversion is required.
  static Locale? _locale;

  // In-memory cache keyed by "option: text" to avoid repeated async calls.
  static final Map<String, String> _cache = {};

  /// Update the active locale. Call this whenever the app locale changes.
  static void setLocale(Locale locale) {
    _locale = locale;
  }

  /// Build the OpenCC option for the given locale, or null if no conversion needed.
  static ConverterOption? _optionFor(Locale? locale) {
    if (locale == null || locale.languageCode != 'zh') return null;
    switch (locale.countryCode) {
      case 'TW':
        return S2TW();
      case 'HK':
        return S2HK();
      default:
        return null;
    }
  }

  /// Synchronous best-effort conversion using the active BuildContext locale.
  /// Returns the cached converted text when available, otherwise the original.
  /// Safe to call inside build methods.
  static String of(BuildContext context, String text) {
    final locale = Localizations.localeOf(context);
    return _convertSync(text, locale);
  }

  /// Synchronous conversion using the globally set locale (no BuildContext needed).
  static String convertSync(String text) {
    return _convertSync(text, _locale);
  }

  static String _convertSync(String text, Locale? locale) {
    final option = _optionFor(locale);
    if (option == null || text.isEmpty) return text;
    return _cache[_key(text, option)] ?? text;
  }

  /// Asynchronous conversion. Fills the cache and returns the converted text.
  /// On platforms without a native OpenCC bridge (e.g. desktop during dev) it
  /// gracefully falls back to the original text instead of throwing.
  static Future<String> convert(String text) async {
    final option = _optionFor(_locale);
    if (option == null || text.isEmpty) return text;
    final key = _key(text, option);
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final result = await ChineseConverter.convert(text, option);
      _cache[key] = result;
      return result;
    } catch (_) {
      // Native bridge unavailable, keep the original text.
      return text;
    }
  }

  static String _key(String text, ConverterOption option) =>
      '${option.runtimeType}:$text';
}

/// A [Text] widget that converts its content to Traditional Chinese (when the
/// active locale requires it) without blocking the first frame. It uses the
/// cached value synchronously and updates itself once the async conversion
/// completes, so call sites stay free of Future/await boilerplate.
class ConvertedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDirection? textDirection;

  const ConvertedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textDirection,
  });

  @override
  State<ConvertedText> createState() => _ConvertedTextState();
}

class _ConvertedTextState extends State<ConvertedText> {
  late String _display;

  @override
  void initState() {
    super.initState();
    _display = ZhConverter.convertSync(widget.text);
    _warm();
  }

  @override
  void didUpdateWidget(covariant ConvertedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _display = ZhConverter.convertSync(widget.text);
      _warm();
    }
  }

  Future<void> _warm() async {
    final converted = await ZhConverter.convert(widget.text);
    if (converted != _display && mounted) {
      setState(() => _display = converted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textDirection: widget.textDirection,
    );
  }
}
