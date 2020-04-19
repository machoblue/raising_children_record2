# raisingchildrenrecord2

# Usage

## Firebase
- Download google-services.json(for Android) and GoogleService-Info.plist(for iOS), and put these files in project respectively.

## Add Internationalized messages

Add a message to l10n.dart like following.

```
String get loginTitle => Intl.message('Login', name: 'loginTitle');
```

Execute intl_translation:extract_to_arb to extract `Intl.message()` to *.arb.

```
$ flutter packages pub run intl_translation:extract_to_arb \
     --locale=messages \
     --output-dir=lib/l10n/arb \
     lib/l10n/l10n.dart
```

Execute intl_translation:generate_from_arb to generate messages_*.dart.
```
$ flutter packages pub run intl_translation:generate_from_arb \
     --output-dir=lib/l10n/messages \
     --no-use-deferred-loading \
     lib/l10n/l10n.dart \
     lib/l10n/arb/intl_*.arb
```