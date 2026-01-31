# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Hello SaaS** is a multilingual serverless SaaS application. It's a React PWA frontend that fetches multilingual greetings from an AWS Lambda backend, storing data in DynamoDB. The app is fully deployable to AWS with infrastructure as code (SAM/CDK) and works as a mobile app on iPhone and Android.

**Architecture**: Serverless JAMstack
- **Frontend**: React 18 PWA (S3 + CloudFront or Amplify)
- **Backend**: AWS Lambda (Node.js 18) with API Gateway
- **Database**: DynamoDB with pay-per-request billing
- **Infrastructure**: AWS SAM templates and CDK definitions

## Development Commands

### Local Development (No AWS)

```bash
# Run both frontend and backend on localhost
./scripts/dev-local.sh
# Frontend: http://localhost:3000
# Backend: http://localhost:3001
```

Or manually:
```bash
# Terminal 1: Backend (Express mock server)
cd backend
npm install
node src/local-server.js

# Terminal 2: Frontend (React dev server)
cd frontend
npm install
npm start
```

### Testing the API

```bash
# Test local backend
curl "http://localhost:3001/api/greeting?lang=en"
curl "http://localhost:3001/api/greeting?lang=es"

# All 7 supported language codes: en, es, fr, de, ja, zh, vi
```

### Building for Deployment

```bash
# Build React app for production
cd frontend
npm run build  # Creates frontend/build/ directory

# Backend is deployed as Lambda function
cd backend
npm install  # Install dependencies (uploaded with Lambda)
```

### AWS Deployment

```bash
# Option 1: AWS SAM (recommended)
./scripts/deploy-sam.sh

# Option 2: AWS CDK
./scripts/deploy-cdk.sh

# After either option, seed the database:
cd backend
npm install
TABLE_NAME=HelloSaaSGreetings node src/seed-data.js
```

### Deploy Frontend to S3

```bash
./scripts/deploy-frontend.sh my-unique-bucket-name
```

## Project Structure

**Key directories and their purposes:**

```
frontend/
├── src/App.js              # Main React component (language selector, API calls)
├── src/App.css             # Styling (purple gradient theme)
├── src/serviceWorker.js    # PWA offline support
└── public/manifest.json    # PWA configuration

backend/
├── src/index.js            # Lambda handler (queries DynamoDB)
├── src/local-server.js     # Express dev server with mock data
└── src/seed-data.js        # Populates DynamoDB with greetings

infrastructure/
├── template.yaml           # AWS SAM template (Lambda, API Gateway, DynamoDB)
└── cdk-app.js             # AWS CDK equivalent

scripts/
├── dev-local.sh           # Start local dev servers
├── deploy-sam.sh          # Deploy infrastructure with SAM
├── deploy-cdk.sh          # Deploy infrastructure with CDK
├── deploy-frontend.sh     # Upload React build to S3
└── codespace-deploy.sh    # Interactive deployment (works from iPhone)
```

## Architecture & Data Flow

**Request Flow:**
1. User selects language in React app (frontend/src/App.js)
2. Frontend sends: `GET /api/greeting?lang={code}`
3. API Gateway routes to Lambda function
4. Lambda queries DynamoDB table `HelloSaaSGreetings` with `languageCode` as key
5. Returns JSON: `{message, languageCode, languageName}`

**Database Schema (DynamoDB):**
```
Table: HelloSaaSGreetings
Partition Key: languageCode (String)
Attributes:
  - languageName (String)
  - greeting (String)
```

**Supported Languages:**
- `en` → "Hello SaaS!" (English)
- `es` → "¡Hola SaaS!" (Spanish)
- `fr` → "Bonjour SaaS!" (French)
- `de` → "Hallo SaaS!" (German)
- `ja` → "こんにちは SaaS!" (Japanese)
- `zh` → "你好 SaaS!" (Chinese)
- `vi` → "Xin chào SaaS!" (Vietnamese)

## Adding Languages

To add a new language (e.g., Italian):

1. **frontend/src/App.js** - Add to languages array:
   ```javascript
   { code: 'it', name: 'Italian' }
   ```

2. **backend/src/local-server.js** - Add to mockData:
   ```javascript
   it: { languageCode: 'it', languageName: 'Italian', greeting: 'Ciao SaaS!' }
   ```

3. **backend/src/seed-data.js** - Add to greetings array:
   ```javascript
   { languageCode: 'it', languageName: 'Italian', greeting: 'Ciao SaaS!' }
   ```

After deployment to AWS, run seed-data.js again to add it to DynamoDB.

## Configuration

**Frontend API URL** (frontend/.env):
```
REACT_APP_API_URL=http://localhost:3001          # Local development
REACT_APP_API_URL=https://YOUR_API_ID.execute-api.REGION.amazonaws.com/prod  # AWS
```

**Backend Environment** (Lambda):
```
TABLE_NAME=HelloSaaSGreetings
```

## Important Implementation Details

### Frontend (React PWA)
- **Language selector**: Maps language codes to display names, stored in state
- **API integration**: Uses `fetch()` with error handling; defaults to localhost:3001
- **Service worker**: Registered in index.js for offline caching
- **Styling**: CSS gradient (purple theme), fully responsive
- **PWA features**: manifest.json enables home screen installation on iOS/Android

### Backend (Lambda)
- **Query parameters**: Extracts `lang` from query string, defaults to 'en'
- **DynamoDB query**: Uses GetCommand with `languageCode` as key
- **CORS**: Enabled for all origins (header: `Access-Control-Allow-Origin: *`)
- **Error handling**: Returns 404 for missing languages, 500 for server errors
- **Local dev**: Express server provides mock data without AWS credentials

### Infrastructure
- **SAM template**: Defines Lambda (256MB, 30s timeout), API Gateway (GET /api/greeting), DynamoDB (on-demand billing)
- **CDK app**: Type-safe equivalent with same configuration
- **Deployment output**: Returns API Gateway URL for frontend configuration

## Common Patterns

**Backend response format:**
All endpoints return JSON with `message`, `languageCode`, and `languageName` fields.

**Error handling:**
Frontend catches `fetch()` errors and displays generic message. Backend returns HTTP status codes (404 for missing language, 500 for server error).

**Local testing:**
Mock data in local-server.js matches DynamoDB schema exactly for easy testing before AWS deployment.

## Deployment Notes

- **Database seeding is manual**: After infrastructure deployment, must run `seed-data.js` separately
- **Frontend needs API URL**: React app requires `REACT_APP_API_URL` env var set to deployed API Gateway URL
- **Cold starts**: Lambda cold starts are <1s; acceptable for this low-traffic app
- **Costs**: Typically $0-5/month within AWS free tier; scales automatically with usage

## Related Documentation

- **README.md** - User-facing documentation and quick start
- **ARCHITECTURE.md** - Technical deep-dive with system diagrams
- **DEPLOY_FROM_IPHONE.md** - Guide for deploying directly from iPhone using Codespaces
- **PROJECT_CONTEXT.md** - Detailed project context (for reference)
