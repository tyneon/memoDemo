import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'package:memo/api/local_storage.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => Locale(Storage.instance.getString('locale') ??
      AppLocalizations.supportedLocales.first.languageCode);

  void toggle(String code) {
    Storage.instance.setString('locale', code);
    state = Locale(code);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
