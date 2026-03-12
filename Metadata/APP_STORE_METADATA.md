# SonicDroplet — App Store Metadata

## App Name
SonicDroplet

## Supported App Localizations

Binary localization is prepared for all current App Store Connect locales supported by Apple for app metadata:

- ar
- ca
- hr
- cs
- da
- de
- el
- en
- en-AU
- en-CA
- en-GB
- es-ES
- es-MX
- fi
- fr
- fr-CA
- he
- hi
- hu
- id
- it
- ja
- ko
- ms
- nb
- nl
- pl
- pt-BR
- pt-PT
- ro
- ru
- sk
- sv
- th
- tr
- uk
- vi
- zh-Hans
- zh-Hant

## Subtitle Options (30 chars max)
1. "Record Your Mac's Audio" (24 chars) ← RECOMMENDED
2. "Capture Mac System Audio" (25 chars)
3. "Save Mac Audio Locally" (22 chars)

## Keywords (100 chars max, comma-separated)
audio recorder,system audio,mac audio,sound capture,audio capture,mac recorder,m4a,wav,local,offline

## Short Description (for promotional text field, 170 chars)
SonicDroplet records the audio playing on your Mac and saves it locally as M4A or WAV. Simple, private, and focused. No account required.

## Full App Store Description

Record the audio playing on your Mac with a single click.

SonicDroplet is a simple, focused utility that records the audio currently playing on your Mac and saves it locally on your Mac.

RECORD SYSTEM AUDIO
Capture everything playing through your Mac's speakers. Music, podcasts, video calls, game audio — if your Mac is playing it, SonicDroplet can record it.

SAVE YOUR WAY
Export recordings in M4A (AAC) or WAV format. Choose where to save — your files, your choice.

PRIVATE BY DESIGN
• Recordings stay on your Mac
• No account required
• No cloud upload
• No data collection
• Works completely offline

SIMPLE AND NATIVE
Built with native macOS technologies. Clean interface, light presentation, and full keyboard and VoiceOver accessibility.

Note: SonicDroplet uses Apple's public Core Audio APIs to record system audio on macOS 15 or later. If macOS asks for audio capture permission, SonicDroplet uses it only to record audio and never uploads your files.

## Category
Primary: Utilities
Secondary: Music

## Price
Paid (recommended: $4.99 USD)

## Age Rating
4+ (no objectionable content)

## Review Notes (for App Review Team)

SonicDroplet is a simple macOS utility that records audio output.

WHAT IT DOES:
- Records system-wide audio playing on the Mac
- Saves recordings locally as M4A or WAV files

HOW IT WORKS:
- Uses Apple's public Core Audio process tap APIs
- Requires macOS audio capture permission if prompted
- Does NOT record the screen
- Saves only to a user-selected location through the standard save panel

PERMISSIONS:
- Audio capture: Used only to record the sound currently playing on the Mac
- File access: User-selected read/write for saving recordings via NSSavePanel

IMPORTANT NOTES:
- All recordings stay on-device unless the user manually saves/exports them
- No network access, no accounts, no analytics, no cloud
- The app uses only public Apple frameworks: Core Audio, AVFoundation, SwiftUI
- Minimum supported version is macOS 15.0
- The shipping build includes localized UI and permission strings for all supported App Store locales listed above

TO TEST:
1. Launch SonicDroplet
2. If macOS prompts for audio capture permission, allow SonicDroplet
3. Play audio on your Mac (e.g., music in Apple Music)
4. Click "Start Recording"
5. After a few seconds, click "Stop Recording"
6. Choose a save location — the file should play back correctly

## Privacy Policy Outline

SonicDroplet Privacy Policy

1. Data Collection: SonicDroplet does not collect, store, or transmit any personal data.

2. Audio Recordings: All audio recordings are stored locally on your Mac at locations you choose. SonicDroplet never uploads, shares, or transmits your recordings.

3. Permissions: SonicDroplet requests audio capture permission solely to record audio output using Apple's public Core Audio APIs. No screen content is recorded or stored.

4. Network Access: SonicDroplet does not access the internet. The app works fully offline.

5. Analytics: SonicDroplet does not include any analytics, tracking, or telemetry.

6. Third-Party Services: SonicDroplet does not integrate with any third-party services.

7. Contact: https://kemp144.github.io/AudioDrop/support/

## Manual App Store Connect Fields Still Required

- Privacy Policy URL: https://kemp144.github.io/AudioDrop/privacy/
- Support URL: https://kemp144.github.io/AudioDrop/support/
- Marketing URL (optional): https://kemp144.github.io/AudioDrop/
- Support email: not used; support handled through the support URL / GitHub Issues
- Localized screenshots for required Mac App Store sizes

## Release Status

Verified locally before submit:
- Project identity is `SonicDroplet`
- Bundle ID is `com.kemp144.sonicdroplet`
- `xcodebuild` project listing and app build succeed
- Privacy/support/marketing pages exist in `docs/` for GitHub Pages deployment

Still required outside the repo:
- Push `main` with `docs/` and confirm GitHub Pages publishes successfully
- Confirm the final App Store app name is accepted in App Store Connect
- Upload the Archive from `SonicDroplet.xcodeproj`
- Provide App Store screenshots

## Support URL Content Outline

SonicDroplet Support

  - FAQ:
  - Why does SonicDroplet need audio capture permission?
    → macOS may require permission before an app can record system audio.
      SonicDroplet uses that permission only to record audio.
  - What formats are supported?
    → M4A (AAC) and WAV
  - Where are my recordings saved?
    → You choose the save location each time. SonicDroplet does not auto-save to a hidden folder.
  - Does SonicDroplet work offline?
    → Yes, SonicDroplet works completely offline.
  - Does SonicDroplet record my screen?
    → No. SonicDroplet records audio only.
  - I granted permission but recording doesn't work?
    → Confirm you are running macOS 15 or later and try launching SonicDroplet again.

- Contact: https://kemp144.github.io/AudioDrop/support/

## What's New — v1.0

Initial release of SonicDroplet.
• Record system-wide audio from your Mac
• Save as M4A or WAV
• Simple, private, and local-only

## Screenshot Text Recommendations (first 5 screenshots)

1. "Record the audio playing on your Mac" — Show main UI in idle state
2. "One click to start recording" — Show recording state with timer
3. "Save as M4A or WAV" — Show format picker and save dialog
4. "Private by design. No cloud. No account." — Show light main UI with status card
5. "Choose where to save every recording" — Show save dialog

## App Privacy Answers (App Store Connect)

Data Linked to You: None
Data Used to Track You: None
Data Not Linked to You: None
Data Not Collected: Select this option

Justification: SonicDroplet does not collect any data. All audio recordings are stored locally
at user-chosen locations. No analytics, no network access, no accounts.
