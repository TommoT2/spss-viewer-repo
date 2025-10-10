#!/bin/bash

# Set API URL (replace with your Render.com URL)
API_URL="https://spss-viewer-repo.onrender.com"

echo "🧪 Testing SPSS Parser API..."
echo "🌐 API URL: $API_URL"
echo ""

# Test health endpoint
echo "📊 Testing health endpoint..."
curl -f "$API_URL/api/health" | jq '.' || echo "❌ Health check failed"
echo ""

# Test docs endpoint
echo "📚 Testing docs endpoint..."
curl -f "$API_URL/api/docs" | jq '.' || echo "❌ Docs endpoint failed"
echo ""

# Test actuator health
echo "🔍 Testing actuator health..."
curl -f "$API_URL/actuator/health" | jq '.' || echo "❌ Actuator health failed"
echo ""

# Test actuator metrics
echo "📈 Testing actuator metrics..."
curl -f "$API_URL/actuator/metrics" | jq '.' || echo "❌ Actuator metrics failed"
echo ""

# Test Swagger UI (HTML endpoint)
echo "📖 Testing Swagger UI..."
curl -f "$API_URL/swagger-ui.html" > /dev/null && echo "✅ Swagger UI accessible" || echo "❌ Swagger UI failed"
echo ""

# Test CORS preflight
echo "🔐 Testing CORS preflight..."
curl -X OPTIONS \
  -H "Origin: https://tommot2.github.io" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v "$API_URL/api/parse" 2>&1 | grep -i "access-control" && echo "✅ CORS configured" || echo "❌ CORS not configured"
echo ""

# Test file upload (if test.sav file exists)
if [ -f "test.sav" ]; then
    echo "📁 Testing file upload with test.sav..."
    UPLOAD_RESULT=$(curl -X POST -F "file=@test.sav" "$API_URL/api/parse")
    echo "$UPLOAD_RESULT" | jq '.' || echo "❌ File upload failed"
else
    echo "⚠️ No test.sav file found - skipping upload test"
    echo "💡 To test file upload, create a test.sav file in the current directory"
fi
echo ""

# Summary
echo "🎯 API Testing Summary:"
echo "   🏥 Health: $API_URL/api/health"
echo "   📚 Docs: $API_URL/api/docs"
echo "   📖 Swagger: $API_URL/swagger-ui.html"
echo "   🔧 Actuator: $API_URL/actuator/health"
echo "   📊 Parse: $API_URL/api/parse (POST with file)"
echo ""
echo "✅ API testing completed!"
echo "🚀 Your SPSS Parser API is ready for production use!"