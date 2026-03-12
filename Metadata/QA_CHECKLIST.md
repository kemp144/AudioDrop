# SonicDroplet — QA and Submission Checklist

## Pre-Submission Checklist

### Build
- [x] App builds successfully in Release configuration
- [ ] No compiler warnings
- [ ] No analyzer warnings
- [ ] Archive builds successfully
- [ ] App validates for App Store distribution

### Functionality — System Audio Mode
- [ ] Start recording captures system audio
- [ ] Stop recording finalizes file correctly
- [ ] Recorded file plays back correctly in QuickTime/Music
- [ ] Repeated start/stop cycles are stable (10+ times)
- [ ] Recording with no audio playing produces a valid (silent) file
- [ ] Recording while switching audio sources works correctly

### File Output
- [ ] M4A files are valid and playable
- [ ] WAV files are valid and playable
- [ ] File names include timestamp
- [ ] Save dialog appears after stopping
- [ ] Cancel in save dialog returns to idle state
- [ ] Overwrite existing file works correctly
- [ ] Saving to Desktop works
- [ ] Saving to Documents works
- [ ] Invalid destination (read-only) shows error gracefully

### Permissions
- [ ] macOS audio capture permission prompt appears if required
- [ ] App works after granting permission
- [ ] Permission denied state shows a clear, accurate message
- [ ] App never asks for Screen Recording permission

### UI / UX
- [ ] App launches to correct initial state
- [ ] Light mode looks correct
- [ ] Window size is appropriate
- [ ] All buttons have correct enabled/disabled states
- [ ] Recording indicator (red dot) pulses during recording
- [ ] Elapsed time updates during recording
- [ ] Status messages are clear and accurate
- [ ] No raw localization keys visible in any state

### Accessibility
- [ ] VoiceOver reads all controls correctly
- [ ] All buttons have accessibility labels
- [ ] All controls have accessibility hints
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] Cmd+Return stops recording

### Localization (spot-check per language)
- [ ] German (de) — no clipped text, correct translations
- [ ] French (fr) — no clipped text, correct translations
- [ ] French Canada (fr-CA) — terminology fits Québec/French Canada expectations
- [ ] Japanese (ja) — correct script, no layout issues
- [ ] Arabic (ar) — RTL layout functions (if applicable)
- [ ] Hebrew (he) — RTL layout functions (if applicable)
- [ ] Chinese Simplified (zh-Hans) — correct characters
- [ ] English regional variants (en-AU, en-CA, en-GB) load correctly
- [ ] Newly added locales (ca, hr, el, hi, hu, id, ms, ro, ru, sk, th, uk, vi) render without clipping
- [ ] Info.plist permission string is localized for all supported locales
- [ ] All 39 target locales have no missing keys

### App Store Readiness
- [x] Bundle ID is correct
- [ ] Version and build numbers are set
- [ ] App icon is present (all sizes)
- [ ] Info.plist has all required keys
- [ ] Entitlements are correct (sandbox + user-selected files)
- [ ] NSAudioCaptureUsageDescription is set
- [ ] Privacy policy URL is live
- [ ] Support URL is live
- [ ] App Store description is finalized
- [ ] Screenshots are prepared for all required sizes
- [ ] Review notes are complete and accurate
- [ ] App Privacy answers are submitted
- [ ] Category is set (Utilities)
- [ ] Price is set

### Verified Locally
- [x] Project, target, and app product are renamed to `SonicDroplet`
- [x] Bundle identifier is `com.kemp144.sonicdroplet`
- [x] GitHub Pages source exists in `docs/`
- [x] App Store metadata is aligned with `SonicDroplet`

### Still Manual Before Submit
- [ ] Push the repo so GitHub Pages URLs are publicly live
- [ ] Confirm App Store Connect accepts the chosen public app name
- [ ] Create a fresh Archive from `SonicDroplet.xcodeproj`
- [ ] Upload screenshots in accepted Mac App Store sizes

### Edge Cases
- [ ] Launch with no displays connected (unlikely but handle)
- [ ] Launch with multiple displays
- [ ] Record very long session (30+ minutes)
- [ ] Record very short session (<1 second)
- [ ] Rapid start/stop/start/stop
- [ ] Close window during recording (app should handle)
- [ ] System sleep during recording
