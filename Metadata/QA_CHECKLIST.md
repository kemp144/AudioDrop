# AudioDrop — QA and Submission Checklist

## Pre-Submission Checklist

### Build
- [ ] App builds successfully in Release configuration
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

### Functionality — App Audio Mode
- [ ] App list populates with running applications
- [ ] Selecting an app shows it in the UI
- [ ] Recording captures audio from selected app only
- [ ] If selected app closes during recording, app handles gracefully
- [ ] Changing selected app while not recording works
- [ ] Cannot start recording without selecting an app

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
- [ ] First launch triggers permission explanation view
- [ ] "Open System Settings" button works
- [ ] "I've Granted Permission" button rechecks correctly
- [ ] App works after granting permission
- [ ] App shows correct state when permission is denied
- [ ] Permission denied → re-granting → restarting app works

### UI / UX
- [ ] App launches to correct initial state
- [ ] Light mode looks correct
- [ ] Dark mode looks correct
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
- [ ] Japanese (ja) — correct script, no layout issues
- [ ] Arabic (ar) — RTL layout functions (if applicable)
- [ ] Chinese Simplified (zh-Hans) — correct characters
- [ ] All 20 target languages have no missing keys

### App Store Readiness
- [ ] Bundle ID is correct
- [ ] Version and build numbers are set
- [ ] App icon is present (all sizes)
- [ ] Info.plist has all required keys
- [ ] Entitlements are correct (sandbox + user-selected files)
- [ ] NSScreenCaptureUsageDescription is set
- [ ] Privacy policy URL is live
- [ ] Support URL is live
- [ ] App Store description is finalized
- [ ] Screenshots are prepared for all required sizes
- [ ] Review notes are complete and accurate
- [ ] App Privacy answers are submitted
- [ ] Category is set (Utilities)
- [ ] Price is set

### Edge Cases
- [ ] Launch with no displays connected (unlikely but handle)
- [ ] Launch with multiple displays
- [ ] Record very long session (30+ minutes)
- [ ] Record very short session (<1 second)
- [ ] Rapid start/stop/start/stop
- [ ] Close window during recording (app should handle)
- [ ] System sleep during recording
