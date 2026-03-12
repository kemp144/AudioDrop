# AudioDrop — App Store Metadata

## App Name
AudioDrop

## Subtitle Options (30 chars max)
1. "Record Your Mac's Audio" (24 chars) ← RECOMMENDED
2. "Capture Mac System Audio" (25 chars)
3. "Record Audio from Any App" (26 chars)

## Keywords (100 chars max, comma-separated)
audio recorder,system audio,screen recording,sound capture,app audio,mac recorder,m4a,wav,local

## Short Description (for promotional text field, 170 chars)
AudioDrop records the audio playing on your Mac — system-wide or from a specific app. Simple, private, and local-only. No account required.

## Full App Store Description

Record the audio playing on your Mac with a single click.

AudioDrop is a simple, focused utility that captures system audio or audio from a specific app — and saves it locally on your Mac.

RECORD SYSTEM AUDIO
Capture everything playing through your Mac's speakers. Music, podcasts, video calls, game audio — if your Mac is playing it, AudioDrop can record it.

RECORD APP AUDIO
Choose a specific app to record from. Only the audio from that app is captured. Perfect for recording audio from a single source.

SAVE YOUR WAY
Export recordings in M4A (AAC) or WAV format. Choose where to save — your files, your choice.

PRIVATE BY DESIGN
• Recordings stay on your Mac
• No account required
• No cloud upload
• No data collection
• Works completely offline

SIMPLE AND NATIVE
Built with native macOS technologies. Clean interface, dark mode support, and full keyboard and VoiceOver accessibility.

Note: AudioDrop requires Screen Recording permission to capture audio. This is an Apple system requirement for any app that captures audio output. AudioDrop does not record your screen — it uses this permission solely to access audio.

When recording a selected app, audio is captured at the app level — not per individual window or browser tab.

## Category
Primary: Utilities
Secondary: Music

## Price
Paid (recommended: $4.99 USD)

## Age Rating
4+ (no objectionable content)

## Review Notes (for App Review Team)

AudioDrop is a simple macOS utility that records audio output.

WHAT IT DOES:
- Records system-wide audio playing on the Mac
- Records audio from a user-selected app
- Saves recordings locally as M4A or WAV files

HOW IT WORKS:
- Uses Apple's ScreenCaptureKit framework (public API)
- Requires Screen Recording permission (NSScreenCaptureUsageDescription)
- Does NOT record the screen — only captures audio streams
- Video capture is set to minimum (2x2px, 1fps) to minimize overhead

PERMISSIONS:
- Screen Recording: Required by ScreenCaptureKit to access system/app audio
- File access: User-selected read/write for saving recordings via NSSavePanel

IMPORTANT NOTES:
- All recordings stay on-device unless the user manually saves/exports them
- No network access, no accounts, no analytics, no cloud
- "App Audio" mode captures audio at the application level — not per-window or per-tab. The UI clearly communicates this to the user.
- The app uses only public Apple frameworks: ScreenCaptureKit, AVFoundation, SwiftUI

TO TEST:
1. Launch AudioDrop
2. Grant Screen Recording permission when prompted
3. Play audio on your Mac (e.g., music in Apple Music)
4. Click "Start Recording"
5. After a few seconds, click "Stop Recording"
6. Choose a save location — the file should play back correctly
7. Try "App Audio" mode: select an app, start recording, verify only that app's audio is captured

## Privacy Policy Outline

AudioDrop Privacy Policy

1. Data Collection: AudioDrop does not collect, store, or transmit any personal data.

2. Audio Recordings: All audio recordings are stored locally on your Mac at locations you choose. AudioDrop never uploads, shares, or transmits your recordings.

3. Permissions: AudioDrop requests Screen Recording permission solely to capture audio output using Apple's ScreenCaptureKit framework. No screen content is recorded or stored.

4. Network Access: AudioDrop does not access the internet. The app works fully offline.

5. Analytics: AudioDrop does not include any analytics, tracking, or telemetry.

6. Third-Party Services: AudioDrop does not integrate with any third-party services.

7. Contact: [support email to be added]

## Support URL Content Outline

AudioDrop Support

- FAQ:
  - Why does AudioDrop need Screen Recording permission?
    → Apple requires this permission for any app that captures audio output.
      AudioDrop does not record your screen.
  - What formats are supported?
    → M4A (AAC) and WAV
  - Where are my recordings saved?
    → You choose the save location each time. AudioDrop does not auto-save to a hidden folder.
  - Does AudioDrop work offline?
    → Yes, AudioDrop works completely offline.
  - What does "app-level audio" mean?
    → When recording a selected app, all audio from that app is captured — not just one window or browser tab.
  - I granted permission but recording doesn't work?
    → Try restarting AudioDrop after granting Screen Recording permission. On macOS 15+, you may need to re-approve periodically.

- Contact: [support email]

## What's New — v1.0

Initial release of AudioDrop.
• Record system-wide audio from your Mac
• Record audio from a selected app
• Save as M4A or WAV
• Simple, private, and local-only

## Screenshot Text Recommendations (first 5 screenshots)

1. "Record the audio playing on your Mac" — Show main UI in idle state
2. "Choose System Audio or App Audio" — Show mode picker with both options
3. "One click to start recording" — Show recording state with timer
4. "Save as M4A or WAV" — Show format picker and save dialog
5. "Private by design. No cloud. No account." — Show permission explanation view

## App Privacy Answers (App Store Connect)

Data Linked to You: None
Data Used to Track You: None
Data Not Linked to You: None
Data Not Collected: Select this option

Justification: AudioDrop does not collect any data. All audio recordings are stored locally
at user-chosen locations. No analytics, no network access, no accounts.
