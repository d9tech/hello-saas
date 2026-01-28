#!/bin/bash

echo "🚀 Starting Hello SaaS in local development mode..."

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

cd backend
echo "📦 Installing backend dependencies..."
npm install

echo "🖥️  Starting backend server on http://localhost:3001..."
node src/local-server.js &
BACKEND_PID=$!

cd ../frontend
echo "📦 Installing frontend dependencies..."
npm install

echo "🌐 Starting frontend server on http://localhost:3000..."
npm start &
FRONTEND_PID=$!

echo ""
echo "✅ Development servers started!"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:3001"
echo ""
echo "Press Ctrl+C to stop both servers"

wait
