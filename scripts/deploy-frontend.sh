#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./deploy-frontend.sh <s3-bucket-name>"
  exit 1
fi

BUCKET_NAME=$1

echo "🚀 Deploying Frontend to S3..."

cd frontend

if [ ! -f ".env" ]; then
  echo "⚠️  Warning: .env file not found. Make sure REACT_APP_API_URL is set."
fi

echo "📦 Installing dependencies..."
npm install

echo "🏗️  Building React app..."
npm run build

echo "☁️  Uploading to S3 bucket: $BUCKET_NAME..."
aws s3 sync build/ s3://$BUCKET_NAME --delete

echo "🌐 Configuring S3 bucket for static website hosting..."
aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document index.html

echo "✅ Frontend deployed successfully!"
echo ""
echo "Your app is available at:"
echo "http://$BUCKET_NAME.s3-website-$(aws configure get region).amazonaws.com"
echo ""
echo "Note: Make sure your S3 bucket has public read access configured."
