# AudioDrop v1 — Technical Recommendation

## Executive Recommendation

**Ship AudioDrop v1 with System Audio only.**

Rationale: System Audio solves the core product promise with the lowest UX and App Review risk.
Selected App Audio is technically possible with public Core Audio taps, but it adds more moving
parts, more failure modes, and a less stable picker experience than this v1 should carry.

## Official Apple API Decision

### Chosen Framework: Core Audio Process Taps (macOS 15.0+)

Core Audio provides public APIs for capturing outgoing system audio through process taps and
aggregate devices. For AudioDrop's narrow utility scope, this is the cleanest audio-only path.

- `AudioHardwareSystem.makeProcessTap(description:)`
- `AudioHardwareSystem.makeAggregateDevice(description:)`
- `AudioDeviceCreateIOProcIDWithBlock`
- `AudioDeviceStart` / `AudioDeviceStop`

### Why Core Audio Taps Are the Safest Choice

1. **Official Apple API** — built for outgoing audio capture
2. **Audio-only architecture** — no screen capture stack, no misleading permission story
3. **Lower user confusion** — matches the product promise directly
4. **App Store compatible** — public APIs, sandbox-safe save flow, no virtual drivers
5. **Simpler v1 scope** — stable System Audio capture without picker complexity

### Rejected Alternatives

| Alternative | Reason for Rejection |
|---|---|
| ScreenCaptureKit | Works, but adds screen-related permission friction to an audio-only app |
| Selected App Audio in v1 | Technically possible, but current picker/capture stability is not strong enough for shipping |
| Virtual Audio Drivers | Not App Store compatible |
| Private APIs / hacks | Rejection risk |
| Microphone capture APIs | Not for system output capture |

### Minimum macOS Target: 15.0 (Sequoia)

- Required for the public Swift Core Audio process tap APIs used here
- Avoids workarounds, drivers, or unsupported compatibility layers
- Smaller support matrix, higher implementation confidence

## Permission Implications

### Required Permission: Audio Capture

- macOS may prompt for audio capture permission the first time AudioDrop records system audio
- AudioDrop should explain clearly that it records audio only and stores files locally
- No Screen Recording permission is required in this v1 path

### Entitlements Required

- `com.apple.security.app-sandbox` — required for Mac App Store
- `com.apple.security.files.user-selected.read-write` — for saving recordings

### No Additional Entitlements Needed

- No microphone entitlement needed (we don't capture mic input)
- No network entitlement needed (fully offline)

## App Review Risk Assessment

### Low Risk (Proceed Confidently)
- Using public Core Audio APIs as intended
- Clear audio capture purpose string
- Local-only, no network, no account
- Honest UI messaging about what is captured

### Medium Risk (Mitigate Carefully)
- macOS 15 minimum support should be stated clearly in metadata
- Reviewer note should explain that capture is system-audio only
- App must show visible recording indicator

### Mitigation Strategy
- Include reviewer notes explaining the Core Audio tap implementation
- Keep the UI focused on one mode only
- Display prominent recording indicator during capture
- Never market the app as a screen recorder or per-app recorder

## Implementation Architecture

### System Audio Mode
- Create a private system audio tap that excludes AudioDrop itself
- Create a private aggregate device bound to the tap
- Read PCM buffers from the aggregate device IO proc
- Forward PCM buffers into `AudioFileWriter`

### Audio File Writing
- **M4A (AAC)**: capture to CAF, then export to Apple M4A
- **WAV (PCM)**: write directly with `AVAudioFile`
- Both formats stay local until the user chooses a save destination

### Recording Flow
1. User launches AudioDrop
2. User clicks Start Recording
3. Core Audio tap starts capturing outgoing audio
4. AudioFileWriter writes buffers to the chosen format
6. User clicks Stop Recording
7. App finalizes file and presents save dialog
8. File is saved to user-chosen location
