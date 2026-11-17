# Phase 10 — Release Checklist

This is the final integration checklist for **Website hướng dẫn khởi nghiệp cùng Mầm**.

Do not add new product modules during this phase. Fix integration, responsive, PWA, release, and demo issues only.

## A. Automated gates

- [ ] `flutter pub get`
- [ ] `flutter analyze` — zero analyzer errors
- [ ] `flutter test` — all tests pass
- [ ] `./tool/release_audit.ps1` — no blocking FAIL
- [ ] `flutter build web --release` succeeds
- [ ] production build opens without console-breaking errors

## B. Authentication

- [ ] Register
- [ ] Login
- [ ] Wrong password
- [ ] Forgot password
- [ ] Logout
- [ ] Login again
- [ ] Protected route while logged out
- [ ] Protected deep-link returns to intended destination after login

## C. Home + navigation

- [ ] Bottom navigation: Trang chủ / Hành trình / Sổ tay / Bạn
- [ ] Desktop navigation works
- [ ] Home continue card opens correct incomplete lesson
- [ ] Access-code card works
- [ ] Mầm card opens general Mầm chat
- [ ] Language switch persists as intended

## D. Goals

- [ ] Create
- [ ] Update
- [ ] Complete
- [ ] Delete
- [ ] Refresh browser
- [ ] Logout/login
- [ ] Data persists
- [ ] XP/event is not duplicated by refresh

## E. Journey / HERO

- [ ] Hope activities
- [ ] Self-efficacy activities
- [ ] Resilience activities
- [ ] Optimism activities
- [ ] Complete/incomplete toggle
- [ ] Progress persists after refresh
- [ ] No separate-curriculum confusion versus the 3-chapter workbook

## F. Reflection + Mood

- [ ] Mood check-in
- [ ] Reflection create
- [ ] Reflection edit if enabled
- [ ] Reflection delete
- [ ] Reflection history
- [ ] Refresh persistence
- [ ] Private-by-default behavior
- [ ] No PsyCap score inferred from mood/reflection

## G. Workbook

- [ ] 3 chapters / 14 lessons render
- [ ] Correct canonical lesson IDs
- [ ] Lesson completion persists
- [ ] Digital companion only extends interactive content
- [ ] Return-to-workbook wording is present where appropriate
- [ ] Public published resource works as guest
- [ ] Guest cannot save private reflection without login
- [ ] “Hỏi Mầm” appears only when `aiEnabled == true`

## H. QR + Access Code

- [ ] `/#/r/B06`
- [ ] `/#/access`
- [ ] `/#/access/482731`
- [ ] valid code
- [ ] invalid code
- [ ] disabled code
- [ ] direct resource refresh
- [ ] access-code refresh
- [ ] no first-load redirect to Home
- [ ] production QR uses the actual deployed domain

## I. Scenario / Media

- [ ] simulation
- [ ] optional response may stay blank
- [ ] real case
- [ ] YouTube
- [ ] takeaway
- [ ] reflection
- [ ] no A/B/C/D scoring
- [ ] no right/wrong implication from mascot
- [ ] media failure does not break the whole resource page

## J. Mầm AI

Use `docs/AI_QUALITY_TEST_MATRIX.md`.

- [ ] Q01–Q12 complete
- [ ] each core case >= 10/12
- [ ] no zero in Relevance
- [ ] no zero in Student agency
- [ ] no zero in Completeness
- [ ] general `/ai` history is separate from workbook contextual threads
- [ ] failed send restores draft without orphaned user message
- [ ] clear confirmation works
- [ ] long answers end in complete sentences

## K. Gamification

- [ ] XP
- [ ] Level
- [ ] Badge
- [ ] Streak
- [ ] longest streak if shown
- [ ] refresh does not award twice
- [ ] small completion does not use oversized milestone visuals

## L. Branding

User-facing UI must not use:
- [ ] PsyCapNote
- [ ] PsyCap Note
- [ ] PsyCapNote AI

Official product context:
- **Sổ tay hướng dẫn khởi nghiệp cùng Mầm** = primary product
- **Website hướng dẫn khởi nghiệp cùng Mầm** / website đồng hành = digital companion
- **Mầm** = AI + mascot companion

Technical IDs may remain when changing them would break the project:
- package `psycapnote_website`
- Firebase project `psycapweb`
- callable function `aiCoach`
- legacy internal class names if not displayed to users

## M. Typography

- [ ] Baloo 2 headings render Vietnamese correctly
- [ ] Be Vietnam Pro body renders Vietnamese correctly
- [ ] no clipping after font change
- [ ] buttons do not overflow
- [ ] chapter/lesson titles wrap naturally
- [ ] access-code UI still fits mobile
- [ ] AI bubbles remain readable

## N. Responsive

Manually test at minimum:
- [ ] 360 × 800
- [ ] 390 × 844
- [ ] 768 × 1024
- [ ] 1366 × 768
- [ ] 1440 × 900

Pay special attention to:
- [ ] Home hero
- [ ] access-code card
- [ ] 3-chapter cards
- [ ] Workbook lesson
- [ ] scenario blocks
- [ ] media embed
- [ ] AI quick prompts
- [ ] AI input
- [ ] long Vietnamese strings
- [ ] mascot is not cropped/stretched

## O. Accessibility / usability

- [ ] meaningful mascot states have useful semantics
- [ ] decorative mascot does not create noisy announcements
- [ ] keyboard navigation is usable on web
- [ ] input focus is visible
- [ ] text contrast remains readable
- [ ] no essential state communicated only by color
- [ ] long text remains selectable where useful

## P. PWA / metadata

- [ ] web title is correct
- [ ] description is correct
- [ ] manifest name is correct
- [ ] short name is `Cùng Mầm`
- [ ] theme color matches project
- [ ] favicon loads
- [ ] app icons load
- [ ] install prompt works when browser criteria are met
- [ ] no need for complex offline content caching for the competition demo

## Q. Firebase / production

- [ ] correct Firebase project selected
- [ ] Firestore rules deployed
- [ ] `aiCoach` deployed
- [ ] Vertex AI IAM still works
- [ ] no frontend API key/secret added for Gemini
- [ ] Hosting deploy succeeds
- [ ] production route refresh tested
- [ ] production QR codes tested on a phone

## R. Demo readiness

- [ ] one clean demo account prepared
- [ ] sample resource `B06` published
- [ ] code `482731` active or replace checklist with final demo code
- [ ] at least one incomplete lesson available for “Tiếp tục hành trình”
- [ ] at least one AI contextual reflection works
- [ ] no private real student data visible in demo account
- [ ] 3–5 minute demo can be completed without setup pauses
