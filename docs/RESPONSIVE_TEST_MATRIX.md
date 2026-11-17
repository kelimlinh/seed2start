# Phase 10C — Responsive Test Matrix

Test the release-like website at these viewports in both Vietnamese and English:

| ID | Viewport | Target |
|---|---:|---|
| R1 | 360 × 800 | small phone |
| R2 | 390 × 844 | modern phone |
| R3 | 768 × 1024 | tablet portrait |
| R4 | 1024 × 768 | tablet landscape |
| R5 | 1366 × 768 | laptop |
| R6 | 1440 × 900 | desktop |

For each viewport verify:

- Home/AppShell: no overflow, navigation correct, Mầm not cropped, access-code card fits.
- Auth: login/register/forgot-password fields and buttons fit.
- Workbook: long titles wrap, resource cards expand, scenario/media/reflection buttons remain reachable.
- Media: YouTube/image/video do not create horizontal scrolling.
- Mầm AI: context banner and quick prompts wrap, bubbles readable, composer visible, thinking/auto-scroll stable.
- Goals/Reflection/Journey/Gamification/Profile: cards/forms/dialogs fit.
- Typography: Baloo 2 + Be Vietnam Pro render Vietnamese correctly with no clipping.
- Mascot: official proportions, `BoxFit.contain`, no stretching/cropping.

PASS only when:
- no yellow/black Flutter overflow stripe;
- no unexpected horizontal page scrolling;
- all primary CTAs are reachable;
- VI and EN both fit.
