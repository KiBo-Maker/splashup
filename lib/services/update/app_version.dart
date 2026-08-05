/// Versione dell'app in formato semver, confrontabile.
///
/// Serve per decidere se la release pubblicata su GitHub è più recente di
/// quella installata. Volutamente tollerante sui formati che girano nel
/// progetto:
///   - tag GitHub con la "v" davanti      -> `v2.5.0`
///   - versione di pubspec col build      -> `2.5.0+31` (il `+31` si ignora)
///   - pre-release                        -> `2.5.0-beta.1`
class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;

  /// Parte dopo il `-` (es. `beta.1`). Stringa vuota per una release stabile.
  final String preRelease;

  const AppVersion(
    this.major,
    this.minor,
    this.patch, {
    this.preRelease = '',
  });

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// Restituisce `null` se la stringa non è interpretabile: chi chiama deve
  /// trattare quel caso come "non lo so", non come "nessun aggiornamento".
  static AppVersion? tryParse(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    // Tag GitHub: "v2.5.0" -> "2.5.0"
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1);
    }

    // Build number di pubspec: "2.5.0+31" -> "2.5.0". Il build number non
    // partecipa al confronto (due build della stessa versione sono la stessa
    // versione per l'utente).
    final plus = s.indexOf('+');
    if (plus != -1) s = s.substring(0, plus);

    var pre = '';
    final dash = s.indexOf('-');
    if (dash != -1) {
      pre = s.substring(dash + 1);
      s = s.substring(0, dash);
    }

    final parts = s.split('.');
    if (parts.isEmpty || parts.length > 3) return null;

    final numbers = <int>[];
    for (final part in parts) {
      // Solo cifre: int.tryParse accetterebbe anche '0x10' (= 16) e un tag
      // tipo "v0x10.0.0" diventerebbe una versione 16.0.0, cioè un
      // aggiornamento fantasma che non si risolve mai.
      if (part.isEmpty || !_digitsOnly.hasMatch(part)) return null;
      final n = int.tryParse(part);
      if (n == null) return null;
      numbers.add(n);
    }
    // "2.5" viene letto come 2.5.0
    while (numbers.length < 3) {
      numbers.add(0);
    }

    return AppVersion(
      numbers[0],
      numbers[1],
      numbers[2],
      preRelease: pre,
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    // Semver: una pre-release viene PRIMA della stabile con gli stessi numeri
    // (2.5.0-beta.1 < 2.5.0). Senza questa regola, chi ha installato una beta
    // non vedrebbe la stabile corrispondente come aggiornamento.
    if (preRelease == other.preRelease) return 0;
    if (preRelease.isEmpty) return 1;
    if (other.preRelease.isEmpty) return -1;
    return _comparePreRelease(preRelease, other.preRelease);
  }

  /// Confronto della parte di pre-release come da semver §11: identificatore
  /// per identificatore, e quelli numerici si confrontano come numeri.
  ///
  /// Con un semplice `compareTo` tra stringhe, 'beta.10' risulterebbe minore
  /// di 'beta.9' e un aggiornamento reale non verrebbe proposto.
  static int _comparePreRelease(String a, String b) {
    final left = a.split('.');
    final right = b.split('.');
    for (var i = 0; i < left.length && i < right.length; i++) {
      final leftPart = left[i];
      final rightPart = right[i];
      if (leftPart == rightPart) continue;

      final leftNumber = _digitsOnly.hasMatch(leftPart) ? int.parse(leftPart) : null;
      final rightNumber =
          _digitsOnly.hasMatch(rightPart) ? int.parse(rightPart) : null;

      if (leftNumber != null && rightNumber != null) {
        return leftNumber.compareTo(rightNumber);
      }
      // Semver: un identificatore numerico ha sempre precedenza minore di
      // uno alfanumerico.
      if (leftNumber != null) return -1;
      if (rightNumber != null) return 1;
      return leftPart.compareTo(rightPart);
    }
    // Tutti gli identificatori in comune sono uguali: vince chi ne ha più
    // (es. 'beta' < 'beta.1').
    return left.length.compareTo(right.length);
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;

  @override
  String toString() {
    final base = '$major.$minor.$patch';
    return preRelease.isEmpty ? base : '$base-$preRelease';
  }

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch &&
      other.preRelease == preRelease;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);
}
