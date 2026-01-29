#!/bin/bash
set -e

echo "🚀 Hello SaaS - GitHub Codespaces Deployment Script"
echo "=================================================="
echo ""

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
  echo "⚠️  AWS credentials not configured yet!"
  echo ""
  echo "Please configure AWS credentials by running:"
  echo "  aws configure"
  echo ""
  echo "You will need:"
  echo "  - AWS Access Key ID"
  echo "  - AWS Secret Access Key"
  echo "  - Default region (e.g., us-east-1)"
  echo "  - Output format (just press Enter for default)"
  echo ""
  read -p "Press Enter when you're ready to configure AWS credentials..."
  aws configure
  echo ""
fi

# Verify credentials
echo "✅ Checking AWS credentials..."
aws sts get-caller-identity
echo ""

# Install AWS SAM CLI
if ! command -v sam &> /dev/null; then
  echo "📦 Installing AWS SAM CLI..."
  pip install --user aws-sam-cli
  export PATH=$PATH:~/.local/bin
  echo ""
fi

echo "🎯 Deployment Options:"
echo "  1) Deploy Backend Only (Lambda + API Gateway + DynamoDB)"
echo "  2) Deploy Frontend Only (after backend is deployed)"
echo "  3) Deploy Both (Full Stack)"
echo "  4) Test Locally (No AWS deployment)"
echo ""
read -p "Choose an option (1-4): " choice

case $choice in
  1)
    echo ""
    echo "🏗️  Deploying Backend..."
    cd backend
    npm install
    cd ../infrastructure

    # Use SAM
    sam build
    sam deploy --guided

    echo ""
    echo "✅ Backend deployed!"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Copy the API URL from the output above"
    echo "  2. Run this script again and choose option 2 to deploy frontend"
    ;;

  2)
    echo ""
    read -p "Enter your API Gateway URL: " api_url

    echo "REACT_APP_API_URL=$api_url" > frontend/.env

    echo ""
    echo "🌱 Seeding database..."
    cd backend
    npm install
    node src/seed-data.js
    cd ..

    echo ""
    read -p "Enter your S3 bucket name for frontend hosting: " bucket_name

    # Create bucket if it doesn't exist
    if ! aws s3 ls "s3://$bucket_name" 2>/dev/null; then
      echo "📦 Creating S3 bucket..."
      aws s3 mb "s3://$bucket_name"

      # Configure bucket for static website hosting
      aws s3 website "s3://$bucket_name" --index-document index.html --error-document index.html

      # Set bucket policy for public access
      cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::$bucket_name/*"
  }]
}
EOF
      aws s3api put-bucket-policy --bucket "$bucket_name" --policy file:///tmp/bucket-policy.json
    fi

    echo "🏗️  Building and deploying frontend..."
    cd frontend
    npm install
    npm run build

    echo "☁️  Uploading to S3..."
    aws s3 sync build/ "s3://$bucket_name" --delete

    region=$(aws configure get region)
    echo ""
    echo "✅ Frontend deployed successfully!"
    echo ""
    echo "🌐 Your app is live at:"
    echo "   http://$bucket_name.s3-website-$region.amazonaws.com"
    echo ""
    echo "📱 Open this URL on your iPhone and add it to your home screen!"
    ;;

  3)
    echo ""
    echo "🏗️  Deploying Full Stack..."

    # Deploy backend
    cd backend
    npm install
    cd ../infrastructure

    echo "📝 SAM will ask you some questions. Use these recommended answers:"
    echo "  - Stack Name: hello-saas-stack"
    echo "  - AWS Region: us-east-1 (or your preferred region)"
    echo "  - Confirm changes before deploy: Y"
    echo "  - Allow SAM CLI IAM role creation: Y"
    echo "  - Save arguments to configuration file: Y"
    echo ""

    sam build
    sam deploy --guided

    # Get API URL from stack outputs
    echo ""
    echo "📊 Getting API URL from stack outputs..."
    api_url=$(aws cloudformation describe-stacks --stack-name hello-saas-stack --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' --output text 2>/dev/null || echo "")

    if [ -z "$api_url" ]; then
      echo "⚠️  Could not automatically retrieve API URL"
      read -p "Please enter the API URL from the output above: " api_url
    else
      echo "✅ Found API URL: $api_url"
    fi

    cd ..
    echo "REACT_APP_API_URL=$api_url" > frontend/.env

    # Seed database
    echo ""
    echo "🌱 Seeding database with multilingual greetings..."
    cd backend
    node src/seed-data.js
    cd ..

    # Deploy frontend
    echo ""
    read -p "Enter your S3 bucket name for frontend hosting (must be globally unique): " bucket_name

    # Create bucket
    region=$(aws configure get region)
    if ! aws s3 ls "s3://$bucket_name" 2>/dev/null; then
      echo "📦 Creating S3 bucket..."
      if [ "$region" = "us-east-1" ]; then
        aws s3 mb "s3://$bucket_name"
      else
        aws s3 mb "s3://$bucket_name" --region "$region"
      fi

      aws s3 website "s3://$bucket_name" --index-document index.html --error-document index.html

      cat > /tmp/bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::$bucket_name/*"
  }]
}
EOF
      aws s3api put-bucket-policy --bucket "$bucket_name" --policy file:///tmp/bucket-policy.json
    fi

    echo "🏗️  Building frontend..."
    cd frontend
    npm install
    npm run build

    echo "☁️  Uploading to S3..."
    aws s3 sync build/ "s3://$bucket_name" --delete

    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "✅ DEPLOYMENT COMPLETE!"
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "🌐 Your app is live at:"
    echo "   http://$bucket_name.s3-website-$region.amazonaws.com"
    echo ""
    echo "📱 iPhone Installation:"
    echo "   1. Open the URL above in Safari on your iPhone"
    echo "   2. Tap the Share button"
    echo "   3. Tap 'Add to Home Screen'"
    echo "   4. Tap 'Add'"
    echo ""
    echo "🎉 Your SaaS app is now live and installable!"
    echo "════════════════════════════════════════════════════════"
    ;;

  4)
    echo ""
    echo "🖥️  Starting local development servers..."
    echo ""
    echo "This will start:"
    echo "  - Backend on port 3001"
    echo "  - Frontend on port 3000"
    echo ""

    # Start backend
    cd backend
    npm install
    node src/local-server.js &
    BACKEND_PID=$!

    cd ../frontend
    npm install

    echo ""
    echo "✅ Backend started on http://localhost:3001"
    echo "🌐 Starting frontend on http://localhost:3000"
    echo ""
    echo "Your Codespace will forward these ports automatically."
    echo "Click the notification to open the app in your browser."
    echo ""

    npm start
    ;;

  *)
    echo "Invalid option!"
    exit 1
    ;;
esac
