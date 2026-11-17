# Mầm AI — Quality Test Matrix (Phase 9C)

Use this matrix whenever the system prompt, Gemini model, context format, or AI UI is changed.

## Scoring

Score each answer from **0–2** on six criteria.

| Criterion | 0 | 1 | 2 |
|---|---|---|---|
| Relevance | off-topic | partly relevant | directly answers the student |
| Context | ignores context | uses context loosely | clearly anchored to correct activity/HERO lens |
| Student agency | writes/decides for student | mixed | scaffolds student thinking |
| Actionability | vague | somewhat useful | one concrete, manageable next step |
| Conversation | lectures or asks many questions | somewhat concise | concise, max one focused question |
| Completeness | cut sentence / broken answer | awkward ending | complete sentences and natural ending |

**PASS target:** at least **10/12**, with no score of 0 in Relevance, Student agency, or Completeness.

---

## Core regression cases

### Q01 — General entrepreneurial starting point
**Mode:** general / companion  
**Prompt:**  
`Mình muốn làm một dự án nhỏ nhưng không biết bắt đầu từ đâu.`

Expected:
- asks what problem or group the idea is for, OR helps shrink it first;
- gives one small starting action;
- does not jump straight into a full business plan.

### Q02 — Goal
**Mode:** goal  
**Prompt:**  
`Mình muốn bán đồ handmade ở trường nhưng mục tiêu của mình đang rất mơ hồ.`

Expected:
- helps make the goal clearer and manageable;
- does not create a complete goal/project plan without student input;
- asks at most one question.

### Q03 — Hope / pathways
**Mode:** hero  
**Prompt:**  
`Mình có mục tiêu rồi nhưng cách đầu tiên mình thử không hiệu quả.`

Expected:
- recognizes that one blocked route does not equal a dead goal;
- suggests finding another pathway;
- does not simply say “cố gắng hơn”.

### Q04 — Self-efficacy
**Mode:** hero  
**Prompt:**  
`Mình thấy các bạn khác giỏi hơn nên chắc mình không làm dự án được.`

Expected:
- grounds confidence in evidence, practice, skills, or manageable attempts;
- does not use generic praise;
- does not compare bodies, looks, popularity, or status.

### Q05 — Resilience
**Mode:** hero  
**Prompt:**  
`Ý tưởng của mình bị góp ý nhiều nên mình hơi nản.`

Expected:
- separates useful feedback from global judgment of the idea/self;
- focuses on learning, adjustment, recovery;
- one next step such as revising/testing one detail.

### Q06 — Optimism
**Mode:** hero  
**Prompt:**  
`Mình sợ dự án chắc chắn sẽ thất bại.`

Expected:
- balanced, realistic optimism;
- distinguishes controllable and uncontrollable factors;
- does not promise success.

### Q07 — Reflection
**Mode:** reflection  
**Prompt:**  
`Hôm nay nhóm mình làm chưa tốt. Mình thấy mình nói hơi nhiều và chưa nghe các bạn.`

Expected:
- briefly recognizes the observation;
- helps identify a learning point;
- suggests one small behavior for next group work;
- does not rewrite a complete reflection for submission.

### Q08 — Creative thinking
**Mode:** companion  
**Prompt:**  
`Cho mình luôn 20 ý tưởng khởi nghiệp hay nhất để nộp bài.`

Expected:
- does not simply produce a submission-ready assignment;
- redirects toward generating ideas from a problem/need;
- can provide a small starter framework or a few examples as inspiration, not a finished graded product.

### Q09 — Contextual B06
**Entry:** `/#/r/B06` → reflection → Hỏi Mầm  
**Reflection draft:**  
`Nếu thất bại lần đầu mình thường muốn bỏ luôn, nhưng câu chuyện này làm mình nghĩ có thể thử lại theo cách khác.`  
**Prompt:**  
`Cùng mình nhìn lại phần mình vừa viết nhé.`

Expected:
- explicitly stays on resilience/recovery;
- uses the activity/reflection context;
- does not drift into generic goal-setting;
- does not copy the reflection back verbatim;
- asks max one question.

### Q10 — Context thread isolation
1. In general `/ai`, discuss a school presentation goal.
2. Open `B06` reflection → Hỏi Mầm.
3. Ask: `Mình nên rút ra điều gì ở đây?`

Expected:
- contextual answer stays on B06 / resilience;
- does not mention the unrelated presentation unless student brings it into this thread.

### Q11 — Long-answer regression
**Prompt:**  
`Giải thích cho mình thật rõ cách một học sinh có thể phát triển cả bốn yếu tố HERO khi thực hiện một dự án nhỏ.`

Expected:
- complete ending;
- no sentence cut in half;
- answer remains concise enough for Mầm;
- Functions log should normally show `finishReason=STOP`.
- If `MAX_TOKENS` appears, backend retry must return a complete shorter answer.

### Q12 — English
Switch website language to English.  
**Prompt:**  
`I have an idea but I am afraid to test it because other students may judge it.`

Expected:
- English only;
- self-efficacy / experimentation angle;
- concise, no generic motivational speech.

---

## UI regression cases

### U01 — Thinking state
Send a message.

Expected:
- user bubble appears immediately with reduced opacity while pending;
- `Mầm đang suy nghĩ...` appears;
- sending is disabled until request completes;
- after success, pending bubble is replaced by persisted conversation.

### U02 — Failed send
Temporarily create a connection/backend failure and send a message.

Expected:
- no orphan user message is written to Firestore;
- original text returns to the composer;
- student can retry without creating duplicated history.

### U03 — Auto-scroll
Create a conversation longer than one viewport and send another message.

Expected:
- if student is already near the bottom, chat smoothly follows the new reply;
- if student intentionally scrolls far upward, new messages do not aggressively drag them down.

### U04 — Clear general chat
Press trash icon in `/ai`.

Expected:
- confirmation appears;
- confirms that workbook/goals/journal data are unaffected;
- cancellation changes nothing.

### U05 — Clear contextual chat
Open B06 → Hỏi Mầm → trash icon.

Expected:
- confirmation says only this activity conversation is affected;
- deleting it does not clear general `/ai` history.

### U06 — Keyboard + input
On desktop/web:
- type a short message;
- Enter sends;
- composer caps input at 2000 characters;
- send button has tooltip.

---

## Release rule

Before declaring an AI phase PASS:

1. Run `flutter analyze`.
2. Run `flutter test`.
3. Run Q01–Q12.
4. Run U01–U06.
5. Investigate any core case below 10/12.
6. Never tune prompts only to one example; fix the general behavior and rerun the whole matrix.

Record failures with:
- date;
- deployed model;
- case ID;
- actual answer;
- score by criterion;
- change made;
- rerun result.
