import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 简化的国际化支持类
/// 待完善：可以使用flutter_gen或者intl来生成完整的国际化支持
class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of(context, S);
  }

  // 临时的字符串定义，后续可以通过工具生成
  String get appName => '打卡习惯';
  String get home => '首页';
  String get habits => '习惯';
  String get statistics => '统计';
  String get journals => '日志';
  String get settings => '设置';
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  
  @override
  Future<S> load(Locale locale) => S.load(locale);
  
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

// 占位符函数
Future<bool> initializeMessages(String localeName) async {
  return true;
}

// Intl类的简化版本
class Intl {
  static String? _defaultLocale;
  static String? get defaultLocale => _defaultLocale;
  static set defaultLocale(String? locale) => _defaultLocale = locale;
  
  static String canonicalizedLocale(String? locale) {
    return locale ?? 'zh_CN';
  }
}