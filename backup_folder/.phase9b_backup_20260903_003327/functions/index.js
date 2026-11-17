const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onInit} = require('firebase-functions/v2/core');
const {initializeApp} = require('firebase-admin/app');

initializeApp();

const MODES = new Set(['companion', 'goal', 'reflection', 'hero']);
const VERTEX_LOCATION = 'global';
const MODEL = 'gemini-3.5-flash';

let ai = null;

// IMPORTANT:
// @google/genai is intentionally loaded inside onInit().
// Firebase CLI loads this file during deployment discovery. Importing and
// initializing the GenAI SDK in global scope can exceed the CLI's 10-second
// discovery timeout. onInit() runs only in the deployed runtime before the
// function handles requests.
onInit(() => {
  const {GoogleGenAI} = require('@google/genai');

  const projectId =
    process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    'psycapweb';

  ai = new GoogleGenAI({
    vertexai: true,
    project: projectId,
    location: VERTEX_LOCATION,
  });

  console.log(
    `PsyCapNote AI initialized with Vertex AI (${projectId}, ${VERTEX_LOCATION}, ${MODEL}).`,
  );
});

exports.aiCoach = onCall(
  {
    region: 'asia-southeast1',
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    if (!ai) {
      console.error('Vertex AI client was not initialized.');
      throw new HttpsError('unavailable', 'AI provider is not ready.');
    }

    const data = request.data || {};
    const message =
      typeof data.message === 'string' ? data.message.trim() : '';

    if (!message || message.length > 2000) {
      throw new HttpsError('invalid-argument', 'Invalid message.');
    }

    const locale = data.locale === 'en' ? 'en' : 'vi';
    const mode = MODES.has(data.mode) ? data.mode : 'companion';
    const rawHistory = Array.isArray(data.history)
      ? data.history.slice(-10)
      : [];

    const history = rawHistory
      .filter(
        (m) =>
          m &&
          ['user', 'assistant'].includes(m.role) &&
          typeof m.content === 'string',
      )
      .map((m) => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{text: m.content.slice(0, 2000)}],
      }));

    // Always append the current message even when history already exists.
    const contents = [
      ...history,
      {
        role: 'user',
        parts: [{text: message}],
      },
    ];

    const language = locale === 'en' ? 'English' : 'Vietnamese';

    const modeGuide = {
      companion:
        'Help the student think clearly and choose a small constructive next step.',
      goal:
        'Help clarify a goal, make it realistic, and break it into small steps. Never create or edit app goals yourself.',
      reflection:
        'Ask concise reflective questions, summarize carefully, and suggest one small learning or next action.',
      hero:
        'Use HERO lenses when useful: Hope=goals/pathways, Efficacy=evidence of capability, Resilience=recovery/learning, Optimism=balanced controllable perspective. Never score or label PsyCap.',
    }[mode];

    const systemInstruction = [
      'You are PsyCapNote AI, a personal-growth and learning companion for high-school students.',
      `Reply in ${language}.`,
      modeGuide,
      'Keep replies warm, concrete, age-appropriate, and usually 1-3 short paragraphs.',
      'Ask at most one useful follow-up question at a time.',
      'Do not lecture, shame, judge, diagnose mental health, calculate PsyCap scores, claim to be a therapist or doctor, create emotional dependency, or act as a romantic companion.',
      'Do not provide dangerous instructions.',
      'Encourage the student to make their own decisions.',
      'Stay within personal development, goals, reflection, HERO/Psychological Capital, problem solving, future orientation, and entrepreneurial thinking.',
      'If a request is outside scope, briefly redirect to what you can help with.',
    ].join(' ');

    try {
      const response = await ai.models.generateContent({
        model: MODEL,
        contents,
        config: {
          systemInstruction,
          temperature: 0.7,
          maxOutputTokens: 500,
        },
      });

      const reply =
        typeof response.text === 'string' ? response.text.trim() : '';

      if (!reply) {
        console.error('Vertex AI returned an empty response.');
        throw new HttpsError('unavailable', 'Empty AI response.');
      }

      return {reply};
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      console.error('Vertex AI error', error);
      throw new HttpsError('unavailable', 'AI provider unavailable.');
    }
  },
);
