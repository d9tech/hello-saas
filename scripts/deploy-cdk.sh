#!/bin/bash
set -e

echo "🚀 Deploying Hello SaaS with AWS CDK..."

cd backend
echo "📦 Installing backend dependencies..."
npm install
cd ..

cd infrastructure
echo "📦 Installing CDK dependencies..."
npm install

echo "🔧 Bootstrapping CDK (if needed)..."
npx cdk bootstrap

echo "🏗️  Synthesizing CDK stack..."
npx cdk synth

echo "🚀 Deploying to AWS..."
npx cdk deploy

echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Copy the API URL from the outputs above"
echo "2. Run: cd backend && node src/seed-data.js"
echo "3. Update frontend/.env with REACT_APP_API_URL=<your-api-url>"
echo "4. Deploy frontend to S3 or Amplify"
