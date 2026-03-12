# AudioDrop — App Store Locale Matrix

Use these locale codes when checking App Store Connect localizations against the shipping binary.

| Locale | Language |
|---|---|
| `ar` | Arabic |
| `ca` | Catalan |
| `hr` | Croatian |
| `cs` | Czech |
| `da` | Danish |
| `de` | German |
| `el` | Greek |
| `en` | English (US / default) |
| `en-AU` | English (Australia) |
| `en-CA` | English (Canada) |
| `en-GB` | English (UK) |
| `es-ES` | Spanish (Spain) |
| `es-MX` | Spanish (Mexico) |
| `fi` | Finnish |
| `fr` | French |
| `fr-CA` | French (Canada) |
| `he` | Hebrew |
| `hi` | Hindi |
| `hu` | Hungarian |
| `id` | Indonesian |
| `it` | Italian |
| `ja` | Japanese |
| `ko` | Korean |
| `ms` | Malay |
| `nb` | Norwegian Bokmål |
| `nl` | Dutch |
| `pl` | Polish |
| `pt-BR` | Portuguese (Brazil) |
| `pt-PT` | Portuguese (Portugal) |
| `ro` | Romanian |
| `ru` | Russian |
| `sk` | Slovak |
| `sv` | Swedish |
| `th` | Thai |
| `tr` | Turkish |
| `uk` | Ukrainian |
| `vi` | Vietnamese |
| `zh-Hans` | Chinese (Simplified) |
| `zh-Hant` | Chinese (Traditional) |

Submission note:

- The app bundle now declares all locales above in `CFBundleLocalizations`.
- `Localizable.xcstrings` covers the shipping UI/error surface for every locale above.
- `InfoPlist.xcstrings` localizes `NSAudioCaptureUsageDescription` for every locale above.
