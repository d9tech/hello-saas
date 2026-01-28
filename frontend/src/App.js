import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [selectedLanguage, setSelectedLanguage] = useState('en');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const languages = [
    { code: 'en', name: 'English' },
    { code: 'es', name: 'Spanish' },
    { code: 'fr', name: 'French' },
    { code: 'de', name: 'German' },
    { code: 'ja', name: 'Japanese' },
    { code: 'zh', name: 'Chinese' }
  ];

  const handleShowMessage = async () => {
    setLoading(true);
    setError('');

    try {
      const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';
      const response = await fetch(`${API_URL}/api/greeting?lang=${selectedLanguage}`);

      if (!response.ok) {
        throw new Error('Failed to fetch message');
      }

      const data = await response.json();
      setMessage(data.message);
    } catch (err) {
      setError('Failed to load message. Please try again.');
      console.error('Error fetching message:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🌍 Hello SaaS</h1>
        <p className="subtitle">Multilingual Greeting Application</p>

        <div className="controls">
          <div className="language-selector">
            <label htmlFor="language">Select Language:</label>
            <select
              id="language"
              value={selectedLanguage}
              onChange={(e) => setSelectedLanguage(e.target.value)}
              className="language-dropdown"
            >
              {languages.map(lang => (
                <option key={lang.code} value={lang.code}>
                  {lang.name}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={handleShowMessage}
            disabled={loading}
            className="show-button"
          >
            {loading ? 'Loading...' : 'Show Greeting'}
          </button>
        </div>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {message && !error && (
          <div className="message-display">
            {message}
          </div>
        )}

        <div className="info">
          <p>Works on Web, iPhone, and Android!</p>
          <p className="install-hint">
            Tap the share button and "Add to Home Screen" to install
          </p>
        </div>
      </header>
    </div>
  );
}

export default App;
