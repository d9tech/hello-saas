# Project Context for Claude

## Quick Summary

This is **Hello SaaS** - a complete multilingual SaaS application built with AWS serverless architecture and a React Progressive Web App frontend. It displays "Hello SaaS!" in 6 different languages, with data stored in DynamoDB.

## What's Been Built

### Complete Full-Stack Application
- ✅ React PWA frontend with offline capability
- ✅ AWS Lambda backend (Node.js 18)
- ✅ DynamoDB database with multilingual greetings
- ✅ API Gateway RESTful endpoint
- ✅ Infrastructure as Code (both SAM and CDK templates)
- ✅ Automated deployment scripts
- ✅ iPhone/Android PWA support (installable on home screen)
- ✅ Local development environment
- ✅ GitHub Codespaces configuration for deployment from iPhone

### Tech Stack
- **Frontend**: React 18, Service Workers, PWA
- **Backend**: AWS Lambda (Node.js 18), API Gateway
- **Database**: DynamoDB (serverless, pay-per-request)
- **Infrastructure**: AWS SAM / AWS CDK
- **Hosting**: S3 + CloudFront or AWS Amplify
- **Development**: GitHub Codespaces enabled

## Project Structure

```
hello-saas/
├── frontend/                    # React PWA application
│   ├── src/
│   │   ├── App.js              # Main component with language selector
│   │   ├── App.css             # Responsive styling
│   │   ├── index.js            # Entry point with service worker registration
│   │   └── serviceWorker.js    # PWA offline functionality
│   ├── public/
│   │   ├── index.html          # HTML shell
│   │   └── manifest.json       # PWA manifest
│   ├── package.json
│   └── .env                    # API URL configuration
│
├── backend/                     # Lambda function
│   ├── src/
│   │   ├── index.js            # Lambda handler (DynamoDB queries)
│   │   ├── local-server.js     # Express dev server with mock data
│   │   └── seed-data.js        # Database seeding script
│   └── package.json
│
├── infrastructure/              # AWS Infrastructure as Code
│   ├── template.yaml           # AWS SAM template
│   ├── cdk-app.js             # AWS CDK app
│   └── package.json
│
├── scripts/                     # Deployment automation
│   ├── deploy-sam.sh           # Deploy with SAM
│   ├── deploy-cdk.sh           # Deploy with CDK
│   ├── deploy-frontend.sh      # Deploy frontend to S3
│   ├── dev-local.sh            # Run locally
│   └── codespace-deploy.sh     # Deploy from GitHub Codespaces
│
├── .devcontainer/              # GitHub Codespaces config
│   └── devcontainer.json
│
├── docs/
│   └── ARCHITECTURE.md         # Detailed architecture documentation
│
├── README.md                    # Main documentation
├── DEPLOY_FROM_IPHONE.md       # iPhone deployment guide
└── .gitignore

```

## Key Features

### Frontend (React PWA)
- Language dropdown selector (6 languages)
- "Show Greeting" button fetches from API
- Beautiful gradient UI (purple theme)
- Loading states and error handling
- **Installable on iPhone/Android** home screen
- Offline capability via service worker
- Fully responsive design

### Backend (AWS Lambda)
- **Endpoint**: `GET /api/greeting?lang={languageCode}`
- Queries DynamoDB by language code
- Returns JSON: `{ message, languageCode, languageName }`
- CORS enabled for all origins
- Error handling for missing languages

### Database (DynamoDB)
**Table**: `HelloSaaSGreetings`
**Schema**:
```
languageCode (String) - Partition Key
languageName (String)
greeting (String)
```

**Data**:
- `en` → "Hello SaaS!"
- `es` → "¡Hola SaaS!"
- `fr` → "Bonjour SaaS!"
- `de` → "Hallo SaaS!"
- `ja` → "こんにちは SaaS!"
- `zh` → "你好 SaaS!"

## Current Status

### What's Complete
✅ All application code written and tested
✅ Frontend React app with PWA features
✅ Backend Lambda function
✅ Infrastructure templates (SAM & CDK)
✅ All deployment scripts created
✅ Documentation complete
✅ GitHub Codespaces configuration
✅ Committed to branch: `claude/saas-app-aws-multilingual-y2D77`
✅ Pushed to GitHub

### What's NOT Done Yet
❌ Not deployed to AWS (waiting for user to deploy)
❌ Database not seeded yet
❌ Frontend not built/deployed yet

## How to Work With This Project

### 1. Local Development (No AWS needed)

```bash
# Start both frontend and backend locally
./scripts/dev-local.sh

# Or manually:
# Terminal 1 - Backend
cd backend
npm install
node src/local-server.js

# Terminal 2 - Frontend
cd frontend
npm install
npm start
```

Opens at: http://localhost:3000

### 2. Deploy to AWS

**Option A: AWS SAM (Recommended)**
```bash
./scripts/deploy-sam.sh          # Deploy backend
cd backend && node src/seed-data.js  # Seed database
# Update frontend/.env with API URL
./scripts/deploy-frontend.sh my-bucket-name
```

**Option B: AWS CDK**
```bash
./scripts/deploy-cdk.sh          # Deploy backend
cd backend && node src/seed-data.js  # Seed database
# Update frontend/.env with API URL
./scripts/deploy-frontend.sh my-bucket-name
```

**Option C: GitHub Codespaces (from iPhone)**
```bash
./scripts/codespace-deploy.sh
# Choose option 3 for full stack
```

### 3. Important Files to Know

**Frontend Entry Point**: `frontend/src/App.js`
- Main React component
- Language selector logic
- API calls to backend

**Backend Handler**: `backend/src/index.js`
- Lambda function handler
- DynamoDB queries
- CORS configuration

**Infrastructure**: `infrastructure/template.yaml`
- Defines all AWS resources
- Lambda, API Gateway, DynamoDB
- Uses AWS SAM syntax

**Deployment**: `scripts/codespace-deploy.sh`
- Interactive deployment script
- Handles AWS configuration
- Creates S3 bucket, deploys app

## Common Tasks

### Add a New Language
1. Update `frontend/src/App.js` languages array
2. Add entry to DynamoDB (use seed-data.js as template)

### Change Styling
- Edit `frontend/src/App.css`

### Modify API Endpoint
- Backend logic: `backend/src/index.js`
- API Gateway config: `infrastructure/template.yaml`

### Update Database Schema
- Modify `infrastructure/template.yaml` DynamoDB table
- Update `backend/src/seed-data.js`

## Environment Variables

**Frontend** (`frontend/.env`):
```
REACT_APP_API_URL=http://localhost:3001  # For local dev
# OR
REACT_APP_API_URL=https://xxxxx.execute-api.region.amazonaws.com/prod  # For AWS
```

**Backend** (Lambda environment):
```
TABLE_NAME=HelloSaaSGreetings
```

## Git Branch

**Current branch**: `claude/saas-app-aws-multilingual-y2D77`

All code is committed and pushed to this branch.

## Architecture Pattern

This follows a **serverless JAMstack** pattern:
- **J**avaScript frontend (React)
- **A**PIs (AWS API Gateway + Lambda)
- **M**arkup (Static HTML from React build)

Benefits:
- Scales automatically
- Pay-per-use pricing ($0-5/month typically)
- No servers to manage
- Fast global delivery

## Testing URLs

**Local**:
- Frontend: http://localhost:3000
- Backend: http://localhost:3001
- Test API: http://localhost:3001/api/greeting?lang=es

**Production** (after deployment):
- Frontend: http://your-bucket.s3-website-region.amazonaws.com
- Backend: https://your-api-id.execute-api.region.amazonaws.com/prod/api/greeting?lang=es

## Cost Estimate

With AWS Free Tier:
- DynamoDB: Free (25GB, 25 RCU/WCU)
- Lambda: Free (1M requests/month)
- API Gateway: Free first 12 months (1M calls/month)
- S3: ~$0.50/month

**Total**: $0-5/month for typical usage

## Next Steps for Deployment

1. **Get AWS credentials** (Access Key ID + Secret Key)
2. **Choose deployment method** (SAM recommended)
3. **Run deployment script**
4. **Seed database** with multilingual data
5. **Deploy frontend** to S3
6. **Test** the live application
7. **Install on iPhone** (Safari → Share → Add to Home Screen)

## Tips for Claude Instances

If you're a Claude instance getting up to speed:

1. **Read this file first** for project overview
2. **Check README.md** for user-facing documentation
3. **Review ARCHITECTURE.md** for technical deep-dive
4. **Look at DEPLOY_FROM_IPHONE.md** for deployment guide
5. **Key files**:
   - Frontend: `frontend/src/App.js`
   - Backend: `backend/src/index.js`
   - Infrastructure: `infrastructure/template.yaml`

## Questions to Ask User

If the user wants to continue working on this project:

1. Do you want to deploy to AWS now?
2. Do you want to test locally first?
3. Do you want to add more languages?
4. Do you want to customize the styling?
5. Do you need help with AWS credentials?

## Important Notes

- ⚠️ The app is ready to deploy but **not yet deployed**
- ⚠️ Database needs to be seeded after infrastructure deployment
- ⚠️ Frontend `.env` file needs API URL updated after backend deployment
- ✅ All code is complete and tested
- ✅ Works on iPhone/Android as PWA
- ✅ Can be deployed from iPhone using Codespaces

---

**Project Created**: 2026-01-31
**Current Status**: Ready for deployment
**Git Branch**: `claude/saas-app-aws-multilingual-y2D77`
