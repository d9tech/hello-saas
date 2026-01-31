# Hello SaaS - Multilingual Greeting Application

A serverless SaaS application built on AWS that displays multilingual greetings. Works seamlessly on web browsers, iPhone, and Android devices as a Progressive Web App (PWA).

## 📱 Quick Start

**Deploying from your iPhone?** → **[Click here for iPhone deployment guide](./DEPLOY_FROM_IPHONE.md)**

**Have a computer?** → Continue reading below for full deployment options

## Features

- **Multilingual Support**: Supports English, Spanish, French, German, Japanese, Chinese, Vietnamese, and Russian
- **Progressive Web App**: Installable on iPhone and Android home screens
- **Serverless Architecture**: Built with AWS Lambda, API Gateway, and DynamoDB
- **Responsive Design**: Beautiful UI that works on all devices
- **Offline Capable**: Service worker enables offline functionality

## Architecture

### Frontend
- **React 18** - Modern UI framework
- **Progressive Web App** - Installable on mobile devices
- **Responsive Design** - Works on all screen sizes

### Backend
- **AWS Lambda** - Serverless compute
- **API Gateway** - RESTful API endpoint
- **DynamoDB** - NoSQL database for greetings

### Infrastructure
- **AWS SAM** or **AWS CDK** - Infrastructure as Code
- **S3 + CloudFront** or **Amplify** - Frontend hosting

## Project Structure

```
hello-saas/
├── frontend/              # React PWA application
│   ├── public/           # Static assets
│   ├── src/              # React components
│   └── package.json
├── backend/              # Lambda function code
│   └── src/
│       ├── index.js      # Lambda handler
│       ├── local-server.js  # Local development server
│       └── seed-data.js  # Database seeding script
├── infrastructure/       # AWS infrastructure templates
│   ├── template.yaml     # AWS SAM template
│   └── cdk-app.js       # AWS CDK app
└── scripts/             # Deployment scripts
```

## Prerequisites

- **Node.js 18+** and npm
- **AWS CLI** configured with credentials
- **AWS SAM CLI** (for SAM deployment) or **AWS CDK** (for CDK deployment)
- An AWS account

## Local Development

### Quick Start

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd hello-saas
   ```

2. **Run both frontend and backend locally**:
   ```bash
   ./scripts/dev-local.sh
   ```

   This starts:
   - Frontend at http://localhost:3000
   - Backend at http://localhost:3001

### Manual Setup

**Backend**:
```bash
cd backend
npm install
node src/local-server.js
```

**Frontend** (in a new terminal):
```bash
cd frontend
npm install
npm start
```

The app will open at http://localhost:3000

## AWS Deployment

### Option 1: Deploy with AWS SAM

1. **Deploy infrastructure and backend**:
   ```bash
   ./scripts/deploy-sam.sh
   ```

2. **Seed the database**:
   ```bash
   cd backend
   npm install
   TABLE_NAME=HelloSaaSGreetings node src/seed-data.js
   ```

3. **Update frontend configuration**:
   - Copy the API URL from the deployment output
   - Update `frontend/.env`:
     ```
     REACT_APP_API_URL=https://YOUR_API_ID.execute-api.REGION.amazonaws.com/prod
     ```

4. **Deploy frontend**:
   ```bash
   ./scripts/deploy-frontend.sh your-bucket-name
   ```

### Option 2: Deploy with AWS CDK

1. **Deploy infrastructure and backend**:
   ```bash
   ./scripts/deploy-cdk.sh
   ```

2. **Seed the database** (same as SAM):
   ```bash
   cd backend
   npm install
   TABLE_NAME=HelloSaaSGreetings node src/seed-data.js
   ```

3. **Deploy frontend** (same as SAM):
   - Update `frontend/.env` with your API URL
   - Run `./scripts/deploy-frontend.sh your-bucket-name`

### Frontend Deployment Options

#### Option A: S3 + CloudFront (Manual)

1. **Create S3 bucket**:
   ```bash
   aws s3 mb s3://your-unique-bucket-name
   aws s3 website s3://your-unique-bucket-name --index-document index.html
   ```

2. **Deploy**:
   ```bash
   ./scripts/deploy-frontend.sh your-unique-bucket-name
   ```

3. **(Optional) Add CloudFront** for HTTPS and better performance

#### Option B: AWS Amplify (Recommended for Production)

1. **Install Amplify CLI**:
   ```bash
   npm install -g @aws-amplify/cli
   amplify configure
   ```

2. **Initialize and deploy**:
   ```bash
   cd frontend
   amplify init
   amplify add hosting
   amplify publish
   ```

## Mobile Installation

### iPhone
1. Open the app URL in Safari
2. Tap the Share button (square with arrow)
3. Scroll down and tap "Add to Home Screen"
4. Tap "Add" in the top right

### Android
1. Open the app URL in Chrome
2. Tap the three-dot menu
3. Tap "Add to Home Screen" or "Install App"
4. Tap "Add"

## Database Schema

**DynamoDB Table**: `HelloSaaSGreetings`

```json
{
  "languageCode": "en",      // Partition Key
  "languageName": "English",
  "greeting": "Hello SaaS!"
}
```

**Supported Languages**:
- `en` - English: "Hello SaaS!"
- `es` - Spanish: "¡Hola SaaS!"
- `fr` - French: "Bonjour SaaS!"
- `de` - German: "Hallo SaaS!"
- `ja` - Japanese: "こんにちは SaaS!"
- `zh` - Chinese: "你好 SaaS!"
- `vi` - Vietnamese: "Xin chào SaaS!"
- `ru` - Russian: "Привет SaaS!"

## API Endpoints

**GET** `/api/greeting?lang={languageCode}`

**Request**:
```bash
curl "https://your-api-url.com/api/greeting?lang=en"
```

**Response**:
```json
{
  "message": "Hello SaaS!",
  "languageCode": "en",
  "languageName": "English"
}
```

## Cost Estimation

This application uses serverless architecture, so costs scale with usage:

- **DynamoDB**: Free tier includes 25 GB storage and 25 read/write capacity units
- **Lambda**: Free tier includes 1M requests and 400,000 GB-seconds per month
- **API Gateway**: Free tier includes 1M API calls per month (first 12 months)
- **S3**: Minimal storage costs (usually < $1/month for static site)

**Estimated monthly cost**: $0-5 for low-medium traffic (within free tier)

## Customization

### Adding New Languages

1. **Add to frontend** (`frontend/src/App.js`):
   ```javascript
   { code: 'it', name: 'Italian' }
   ```

2. **Add to database** (create a script or use AWS Console):
   ```javascript
   {
     languageCode: 'it',
     languageName: 'Italian',
     greeting: 'Ciao SaaS!'
   }
   ```

### Styling

Modify `frontend/src/App.css` to customize colors, fonts, and layout.

## Troubleshooting

### CORS Errors
- Ensure API Gateway has CORS enabled
- Check that `Access-Control-Allow-Origin` is set to `*` or your domain

### Database Empty
- Run the seed script: `node backend/src/seed-data.js`
- Verify table name matches in all configurations

### Build Failures
- Clear node_modules: `rm -rf node_modules && npm install`
- Check Node version: `node --version` (should be 18+)

## Security Considerations

For production deployments:

1. **API Authentication**: Add API Gateway authentication (Cognito, Lambda authorizers)
2. **CORS**: Restrict origins to your domain only
3. **HTTPS**: Use CloudFront or Amplify for HTTPS
4. **Rate Limiting**: Add API Gateway throttling
5. **Environment Variables**: Never commit `.env` files with secrets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - feel free to use this project for learning or commercial purposes.

## Support

For issues or questions, please open an issue on GitHub.

---

Built with ❤️ using React, AWS Lambda, and DynamoDB
