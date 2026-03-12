# AudioDrop v1 — Technical Recommendation

## Executive Recommendation

**Ship AudioDrop v1 with both System Audio and Selected App Audio.**

Rationale: Both modes use the same Apple framework (ScreenCaptureKit), require the same
permission (Screen Recording), and share 90% of the implementation. The marginal complexity
of adding Selected App Audio is low, and it significantly increases the product's value
proposition. Both modes are well-supported public APIs since macOS 14.0.

## Official Apple API Decision

### Chosen Framework: ScreenCaptureKit (macOS 14.0+)

ScreenCaptureKit is Apple's official framework for capturing screen content including audio.
It provides:

- `SCShareableContent` — enumerates displays, applications, and windows
- `SCContentFilter` — defines what to capture (display, app, or window)
- `SCStream` — performs the actual capture with audio/video buffers
- `SCStreamConfiguration` — configures audio/video capture parameters
- `SCContentSharingPicker` — system-provided UI for content selection (macOS 14+)

### Why ScreenCaptureKit is the Safest Choice

1. **Official Apple API** — explicitly designed for audio/screen capture use cases
2. **Clear permission model** — uses the Screen Recording TCC permission
3. **App Store approved** — many shipping Mac App Store apps use it
4. **Audio-only capture** — supports capturing audio without meaningful video overhead
5. **App-level filtering** — can filter capture to specific applications
6. **macOS 14+ maturity** — stable, well-documented, with system picker UI

### Rejected Alternatives

| Alternative | Reason for Rejection |
|---|---|
| Core Audio Process Taps (`AudioHardwareCreateProcessTap`) | macOS 15+ only — too new, small install base |
| Virtual Audio Drivers (e.g., Soundflower approach) | Not App Store compatible, requires kernel/system extension |
| Private APIs / IOKit audio taps | Would be rejected in App Review |
| `AVCaptureSession` with audio | Designed for mic/camera capture, not system audio |
| Aggregate/Multi-Output Audio Devices | Fragile, requires AudioServerPlugin — not sandboxed |

### Minimum macOS Target: 14.0 (Sonoma)

- Required for `SCContentSharingPicker` and mature ScreenCaptureKit APIs
- Good install base (macOS 14 released October 2023)
- Avoids workarounds needed for macOS 12/13 limitations

## Permission Implications

### Required Permission: Screen Recording (TCC)

- ScreenCaptureKit requires Screen Recording permission even for audio-only capture
- This is a one-time system prompt — once granted, it persists
- On macOS 15+, Screen Recording permission resets monthly (Apple policy)
- The app should show a pre-permission explanation before triggering the system prompt

### Entitlements Required

- `com.apple.security.app-sandbox` — required for Mac App Store
- `com.apple.security.files.user-selected.read-write` — for saving recordings

### No Additional Entitlements Needed

- ScreenCaptureKit does NOT require a special entitlement beyond sandbox
- No microphone entitlement needed (we don't capture mic input)
- No network entitlement needed (fully offline)

## App Review Risk Assessment

### Low Risk (Proceed Confidently)
- Using public ScreenCaptureKit APIs as intended
- Clear Screen Recording permission purpose string
- Local-only, no network, no account
- Honest UI messaging about what is captured

### Medium Risk (Mitigate Carefully)
- Screen Recording permission may prompt extra reviewer scrutiny
- Reviewer note should clearly explain why permission is needed
- App must show visible recording indicator
- Selected App Audio captures at app level, not window level — UI must be honest

### Mitigation Strategy
- Include detailed reviewer notes explaining recording behavior
- Show clear pre-permission explanation in the app
- Display prominent recording indicator during capture
- Accurately describe capture scope (app-level, not window/tab-level)

## Implementation Architecture

### System Audio Mode
- Capture the primary display's audio stream
- `SCContentFilter(display:excludingApplications:exceptingWindows:)` with empty exclusions
- Audio from all apps is captured
- Video frames are minimized (2x2px, 1fps) to reduce overhead

### Selected App Audio Mode
- User selects an app from running applications list
- `SCContentFilter(display:including:[selectedApp]:exceptingWindows:[])` filters to one app
- Only that app's audio is captured
- UI clearly states: "Audio is captured at the app level"

### Audio File Writing
- **M4A (AAC)**: AVAssetWriter with AAC encoding — consumer-friendly, small files
- **WAV (PCM)**: AVAudioFile with linear PCM — lossless, universal compatibility
- Both formats are stable and well-tested on macOS

### Recording Flow
1. User selects mode and format
2. User clicks Start Recording
3. App checks/requests Screen Recording permission
4. SCStream starts capturing audio buffers
5. AudioFileWriter writes buffers to chosen format
6. User clicks Stop Recording
7. App finalizes file and presents save dialog
8. File is saved to user-chosen location
