import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashup/services/update/update_settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<UpdateSettingsService> build() async =>
      UpdateSettingsService(await SharedPreferences.getInstance());

  test('il check automatico è attivo di default', () async {
    final settings = await build();
    expect(settings.autoCheckEnabled, isTrue);
    expect(settings.lastCheck, isNull);
  });

  test('senza controlli precedenti si controlla subito', () async {
    final settings = await build();
    expect(settings.shouldAutoCheck(), isTrue);
  });

  test('disattivato non si controlla mai', () async {
    final settings = await build();
    settings.setAutoCheckEnabled(false);
    expect(settings.shouldAutoCheck(), isFalse);
  });

  test('la preferenza sopravvive alla riapertura dell\'app', () async {
    final first = await build();
    first.setAutoCheckEnabled(false);

    final second = await build();
    expect(second.autoCheckEnabled, isFalse);
  });

  test('entro 24 ore dall\'ultimo controllo non si ricontrolla', () async {
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markChecked(now: now);

    expect(settings.lastCheck, now);
    expect(settings.shouldAutoCheck(now: now.add(const Duration(hours: 1))),
        isFalse);
    expect(
      settings.shouldAutoCheck(now: now.add(const Duration(hours: 23, minutes: 59))),
      isFalse,
    );
  });

  test('dopo 24 ore si ricontrolla', () async {
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markChecked(now: now);

    expect(
      settings.shouldAutoCheck(now: now.add(const Duration(hours: 24))),
      isTrue,
    );
  });

  test('se l\'orologio torna indietro non resta bloccato', () async {
    // Cambio di fuso o data sistemata a mano: senza la gestione del delta
    // negativo il check automatico non ripartirebbe più.
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markChecked(now: now);

    expect(
      settings.shouldAutoCheck(now: now.subtract(const Duration(days: 3))),
      isTrue,
    );
  });

  test('un tentativo fallito non consuma la finestra delle 24 ore', () async {
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markAttemptFailed(now: now);

    expect(settings.lastCheck, isNull, reason: 'nessun controllo riuscito');
    expect(settings.lastAttempt, now);
    // Passata l'ora di retry si riprova, senza aspettare 24 ore.
    expect(
      settings.shouldAutoCheck(now: now.add(const Duration(hours: 1))),
      isTrue,
    );
  });

  test('dopo un errore non si riprova a ogni avvio', () async {
    // Un errore permanente (repo rinominato, nessuna release) farebbe partire
    // una richiesta a GitHub a ogni singola apertura dell'app.
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markAttemptFailed(now: now);

    expect(
      settings.shouldAutoCheck(now: now.add(const Duration(minutes: 5))),
      isFalse,
    );
  });

  test('il retry non aggira il limite delle 24 ore dopo un controllo riuscito',
      () async {
    final settings = await build();
    final now = DateTime(2026, 8, 5, 12);
    await settings.markChecked(now: now);

    // Passata l'ora di retry, ma il controllo riuscito e' di 2 ore fa:
    // non si ricontrolla.
    expect(
      settings.shouldAutoCheck(now: now.add(const Duration(hours: 2))),
      isFalse,
    );
  });
}
