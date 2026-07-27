import 'package:flutter/material.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

import 'name_localizer.dart';

/// Name localizer for station / route names.
///
/// Two kinds of transformation are unified here so call sites stay unchanged:
///  - Traditional Chinese (TW/HK) via OpenCC (character-set conversion).
///  - English / Japanese / Korean via the client-side [NameDictionary]
///    (exact Chinese-name match). When a translation is found the caller can
///    render it together with the Simplified-Chinese original and its pinyin.
class ZhConverter {
  // Active locale used to decide whether conversion is required.
  static Locale? _locale;

  // In-memory cache keyed by "option: text" to avoid repeated async calls.
  static final Map<String, String> _cache = {};

  /// Expose the active locale (used by search normalization).
  static Locale? get locale => _locale;

  /// Update the active locale. Call this whenever the app locale changes.
  static void setLocale(Locale locale) {
    _locale = locale;
    // Keep the dictionary in sync so search/reverse-lookup uses the right file.
    NameDictionary.instance.setLocale(locale);
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

  /// Synchronous best-effort localization. Returns the converted / translated
  /// [LocalizedName] when available, otherwise the original text. Safe to call
  /// inside build methods.
  static LocalizedName localizeSync(String text) {
    final locale = _locale;
    final option = _optionFor(locale);
    if (option != null) {
      final converted = _cache[_key(text, option)] ?? text;
      return LocalizedName(original: converted, matched: false);
    }

    if (locale != null &&
        (locale.languageCode == 'en' ||
            locale.languageCode == 'ja' ||
            locale.languageCode == 'ko')) {
      final translation = NameDictionary.instance.lookup(text, locale);
      if (translation != null) {
        final py = NameDictionary.instance.pinyin(text);
        return LocalizedName(
          original: text,
          translation: translation,
          pinyin: py,
          matched: true,
        );
      }
      return LocalizedName(original: text, matched: false);
    }

    return LocalizedName(original: text, matched: false);
  }

  /// Asynchronous localization. Fills the OpenCC cache and returns the result.
  /// For non-Chinese locales the work is already synchronous, but the same
  /// return type is kept for a uniform call site.
  static Future<LocalizedName> localize(String text) async {
    final locale = _locale;
    final option = _optionFor(locale);
    if (option != null) {
      final key = _key(text, option);
      final cached = _cache[key];
      final converted = cached ?? await _convert(text, option);
      return LocalizedName(original: converted, matched: false);
    }
    return localizeSync(text);
  }

  /// Compatibility shim for existing call sites: a single string. Returns the
  /// translation when matched, otherwise the original (or Traditional) text.
  static String convertSync(String text) {
    final ln = localizeSync(text);
    return ln.translation ?? ln.original;
  }

  /// Asynchronous variant of [convertSync].
  static Future<String> convert(String text) async {
    final ln = await localize(text);
    return ln.translation ?? ln.original;
  }

  static Future<String> _convert(String text, ConverterOption option) async {
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

/// A [Text] widget that localizes its content (Traditional Chinese, or a
/// translated name with its Simplified-Chinese original and pinyin) without
/// blocking the first frame. It uses the cached value synchronously and
/// updates itself once the async conversion completes.
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
  late LocalizedName _display;

  @override
  void initState() {
    super.initState();
    _display = ZhConverter.localizeSync(widget.text);
    _warm();
  }

  @override
  void didUpdateWidget(covariant ConvertedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _display = ZhConverter.localizeSync(widget.text);
      _warm();
    }
  }

  Future<void> _warm() async {
    final result = await ZhConverter.localize(widget.text);
    if (result.original != _display.original ||
        result.translation != _display.translation ||
        result.pinyin != _display.pinyin) {
      if (mounted) setState(() => _display = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainText = _display.translation ?? _display.original;
    final showSubtitle =
        _display.matched && _display.translation != null && _display.pinyin != null;

    if (!showSubtitle) {
      return Text(
        mainText,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textDirection: widget.textDirection,
      );
    }

    final baseColor =
        widget.style?.color ?? Theme.of(context).colorScheme.onSurface;
    final subtitleStyle = (widget.style ?? const TextStyle()).copyWith(
      fontSize: ((widget.style?.fontSize ?? 13) * 0.78),
      fontWeight: FontWeight.normal,
      color: baseColor.withValues(alpha: 0.6),
    );

    return Column(
      crossAxisAlignment: widget.textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mainText,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          textDirection: widget.textDirection,
        ),
        const SizedBox(height: 2),
        Text(
          '${_display.original} (${_display.pinyin})',
          style: subtitleStyle,
          textDirection: widget.textDirection,
        ),
      ],
    );
  }
}
