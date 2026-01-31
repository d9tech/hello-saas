const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const mockData = {
  en: { languageCode: 'en', languageName: 'English', greeting: 'Hello SaaS!' },
  es: { languageCode: 'es', languageName: 'Spanish', greeting: '¡Hola SaaS!' },
  fr: { languageCode: 'fr', languageName: 'French', greeting: 'Bonjour SaaS!' },
  de: { languageCode: 'de', languageName: 'German', greeting: 'Hallo SaaS!' },
  ja: { languageCode: 'ja', languageName: 'Japanese', greeting: 'こんにちは SaaS!' },
  zh: { languageCode: 'zh', languageName: 'Chinese', greeting: '你好 SaaS!' },
  vi: { languageCode: 'vi', languageName: 'Vietnamese', greeting: 'Xin chào SaaS!' },
  ru: { languageCode: 'ru', languageName: 'Russian', greeting: 'Привет SaaS!' }
};

app.get('/api/greeting', (req, res) => {
  const lang = req.query.lang || 'en';
  const greeting = mockData[lang];

  if (!greeting) {
    return res.status(404).json({
      error: 'Language not found'
    });
  }

  res.json({
    message: greeting.greeting,
    languageCode: greeting.languageCode,
    languageName: greeting.languageName
  });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Local server running on http://localhost:${PORT}`);
  console.log(`Test endpoint: http://localhost:${PORT}/api/greeting?lang=en`);
});
