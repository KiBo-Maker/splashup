import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferenze del controllo aggiornamenti.
///
/// Il check automatico è attivo di default ma si può disattivare: SplashUp
/// funziona interamente offline e l'unica chiamata di rete dell'app è questa,
/// quindi chi la vuole a zero traffico deve poterla spegnere.
class UpdateSettingsService with ChangeNotifier {
  static const _autoCheckKey = 'updateAutoCheckEnabled';
  static const _lastCheckKey = 'updateLastCheckMs';
  static const _lastAttemptKey = 'updateLastAttemptMs';

  /// Intervallo minimo tra due controlli automatici andati a buon fine. Il
  /// bottone manuale in Impostazioni non è soggetto a questo limite.
  static const Duration minimumInterval = Duration(hours: 24);

  /// Attesa dopo un tentativo fallito (rete assente, rate limit, nessuna
  /// release). Senza questo, un errore permanente — repo rinominato, nessuna
  /// release pubblicata — farebbe partire una richiesta a GitHub a ogni
  /// singolo avvio dell'app, per sempre.
  static const Duration retryInterval = Duration(hours: 1);

  final SharedPreferences _prefs;
  bool _autoCheckEnabled;

  UpdateSettingsService(this._prefs)
      : _autoCheckEnabled = _prefs.getBool(_autoCheckKey) ?? true;

  bool get autoCheckEnabled => _autoCheckEnabled;

  void setAutoCheckEnabled(bool value) {
    _autoCheckEnabled = value;
    _prefs.setBool(_autoCheckKey, value);
    notifyListeners();
  }

  /// Ultimo controllo andato a buon fine.
  DateTime? get lastCheck => _readDate(_lastCheckKey);

  /// Ultimo tentativo, riuscito o no.
  DateTime? get lastAttempt => _readDate(_lastAttemptKey);

  DateTime? _readDate(String key) {
    final ms = _prefs.getInt(key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// `true` se il check automatico è attivo, l'ultimo controllo riuscito è più
  /// vecchio di [minimumInterval] e l'ultimo tentativo (anche fallito) è più
  /// vecchio di [retryInterval].
  bool shouldAutoCheck({DateTime? now}) {
    if (!_autoCheckEnabled) return false;
    final reference = now ?? DateTime.now();

    // Se l'orologio del dispositivo torna indietro (cambio fuso, data
    // sistemata a mano), `difference` diventa negativa: in quel caso
    // ricontrolliamo invece di restare bloccati per sempre.
    bool elapsed(DateTime? since, Duration interval) {
      if (since == null) return true;
      final delta = reference.difference(since);
      return delta.isNegative || delta >= interval;
    }

    return elapsed(lastCheck, minimumInterval) &&
        elapsed(lastAttempt, retryInterval);
  }

  /// Controllo andato a buon fine: azzera sia la finestra delle 24 ore sia
  /// quella del retry.
  Future<void> markChecked({DateTime? now}) async {
    final timestamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
    await _prefs.setInt(_lastCheckKey, timestamp);
    await _prefs.setInt(_lastAttemptKey, timestamp);
    notifyListeners();
  }

  /// Tentativo fallito: non tocca [lastCheck], così appena la rete torna il
  /// controllo riparte dopo [retryInterval] e non dopo 24 ore.
  Future<void> markAttemptFailed({DateTime? now}) async {
    await _prefs.setInt(
      _lastAttemptKey,
      (now ?? DateTime.now()).millisecondsSinceEpoch,
    );
    notifyListeners();
  }
}
