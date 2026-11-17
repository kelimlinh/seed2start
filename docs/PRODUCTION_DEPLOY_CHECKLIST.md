# Phase 10C — Production Deploy Checklist

## Gates
- [ ] `flutter analyze` PASS
- [ ] `flutter test` PASS
- [ ] release web build PASS
- [ ] release audit FAIL = 0
- [ ] responsive matrix completed
- [ ] production preflight FAIL = 0
- [ ] Mầm AI quality matrix accepted

## Firebase project check
Before deploy:
```powershell
firebase use
firebase projects:list
```
Expected workspace project: `psycapweb`.

## Recommended deploy order
```powershell
firebase deploy --only firestore:rules
firebase deploy --only functions:aiCoach
flutter build web --release --no-wasm-dry-run
firebase deploy --only hosting
```

If rules/function are unchanged and already verified, UI-only release can deploy Hosting only.

## Production smoke test
Guest:
- [ ] root opens
- [ ] `/#/r/B06`
- [ ] `/#/access`
- [ ] `/#/access/482731`
- [ ] invalid code state
- [ ] direct refresh stays correct

Authenticated:
- [ ] login
- [ ] Home
- [ ] Workbook
- [ ] Goal create/update
- [ ] Reflection save
- [ ] Journey/HERO
- [ ] Gamification persistence
- [ ] general Mầm
- [ ] contextual Mầm

## Production QR
Current routing uses hash URLs:
```text
https://<YOUR-HOSTING-DOMAIN>/#/r/B06
https://<YOUR-HOSTING-DOMAIN>/#/access/482731
```
Do not print final QR until both URLs work on a physical phone over normal mobile/Wi-Fi internet.

## Privacy
- [ ] clean demo account
- [ ] synthetic demo reflection/chat
- [ ] no real student private data visible

## Release ready means
- static audit FAIL = 0
- analyze/test/build PASS
- responsive matrix PASS
- production preflight FAIL = 0
- production smoke test PASS
- physical QR test PASS
- contextual Mầm demo PASS
