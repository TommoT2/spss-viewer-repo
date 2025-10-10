#!/bin/bash

# SPSS Parser - Complete System Test
# Tests both frontend (GitHub Pages) and API (Render.com)

# Configuration
FRONTEND_URL="https://TommoT2.github.io/spss-viewer-repo"
API_URL="https://spss-parser-api.onrender.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -e "${BLUE}Testing:${NC} $description"
    echo -e "${YELLOW}URL:${NC} $url"
    
    # Use timeout and follow redirects
    response=$(curl -s -w "\n%{http_code}\n%{time_total}" --max-time 30 -L "$url" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ NETWORK ERROR${NC} - Could not connect"
        FAILED=$((FAILED + 1))
        echo "---"
        return 1
    fi
    
    status_code=$(echo "$response" | tail -n2 | head -n1)
    time_total=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -2)
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ SUCCESS${NC} - Status: $status_code (${time_total}s)"
        PASSED=$((PASSED + 1))
        
        # Try to format JSON if it's JSON
        if [[ $body == {* ]]; then
            echo "$body" | jq '.' 2>/dev/null || echo "$body"
        else
            echo "Response received ($(echo "$body" | wc -c) bytes)"
        fi
    else
        echo -e "${RED}❌ FAILED${NC} - Expected: $expected_status, Got: $status_code"
        FAILED=$((FAILED + 1))
        echo "Response: $body"
    fi
    echo "---"
}

# Function to test CORS
test_cors() {
    local url=$1
    local origin=$2
    
    echo -e "${BLUE}Testing:${NC} CORS preflight for $origin"
    echo -e "${YELLOW}URL:${NC} $url"
    
    response=$(curl -s -I \
        -H "Origin: $origin" \
        -H "Access-Control-Request-Method: POST" \
        -H "Access-Control-Request-Headers: Content-Type" \
        -X OPTIONS \
        "$url" 2>/dev/null)
    
    if echo "$response" | grep -i "access-control-allow-origin" > /dev/null; then
        echo -e "${GREEN}✅ CORS CONFIGURED${NC}"
        PASSED=$((PASSED + 1))
        echo "$response" | grep -i "access-control"
    else
        echo -e "${RED}❌ CORS NOT CONFIGURED${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo "---"
}

echo -e "${PURPLE}🧪 SPSS Parser - Complete System Testing${NC}"
echo "============================================="
echo -e "Frontend: ${FRONTEND_URL}"
echo -e "API: ${API_URL}"
echo -e "Date: $(date)"
echo ""

# Phase 1: Frontend Testing
echo -e "${PURPLE}📱 Phase 1: Frontend Testing${NC}"
echo "=============================="

test_endpoint "$FRONTEND_URL" "Frontend Homepage"
test_endpoint "$FRONTEND_URL/style.css" "CSS Stylesheet"
test_endpoint "$FRONTEND_URL/script.js" "JavaScript File"

echo ""

# Phase 2: API Health Testing
echo -e "${PURPLE}🏥 Phase 2: API Health Testing${NC}"
echo "=============================="

test_endpoint "$API_URL/api/health" "Basic API Health"
test_endpoint "$API_URL/actuator/health" "Detailed Health Check"
test_endpoint "$API_URL/api/docs" "API Documentation"

echo ""

# Phase 3: API Endpoints Testing
echo -e "${PURPLE}🔗 Phase 3: API Endpoints Testing${NC}"
echo "================================"

test_endpoint "$API_URL/actuator/metrics" "Application Metrics"
test_endpoint "$API_URL/actuator/info" "Application Info"
test_endpoint "$API_URL/swagger-ui.html" "Swagger UI" 200
test_endpoint "$API_URL/api-docs" "OpenAPI Docs" 200

echo ""

# Phase 4: Error Handling Testing
echo -e "${PURPLE}❌ Phase 4: Error Handling Testing${NC}"
echo "================================="

test_endpoint "$API_URL/api/nonexistent" "Invalid API Endpoint" 404
test_endpoint "$API_URL/api/parse" "Parse Endpoint (GET - should fail)" 405

echo ""

# Phase 5: CORS Testing
echo -e "${PURPLE}🔐 Phase 5: CORS Testing${NC}"
echo "========================"

test_cors "$API_URL/api/parse" "$FRONTEND_URL"
test_cors "$API_URL/api/parse" "https://example.com"

echo ""

# Phase 6: Performance Testing
echo -e "${PURPLE}⚡ Phase 6: Performance Testing${NC}"
echo "=============================="

echo -e "${BLUE}Testing:${NC} API Response Time"
api_time=$(curl -s -w "%{time_total}" -o /dev/null "$API_URL/api/health")
if (( $(echo "$api_time < 2.0" | bc -l) )); then
    echo -e "${GREEN}✅ FAST RESPONSE${NC} - ${api_time}s"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  SLOW RESPONSE${NC} - ${api_time}s (>2s)"
    FAILED=$((FAILED + 1))
fi
echo "---"

echo -e "${BLUE}Testing:${NC} Frontend Load Time"
frontend_time=$(curl -s -w "%{time_total}" -o /dev/null "$FRONTEND_URL")
if (( $(echo "$frontend_time < 3.0" | bc -l) )); then
    echo -e "${GREEN}✅ FAST LOAD${NC} - ${frontend_time}s"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠️  SLOW LOAD${NC} - ${frontend_time}s (>3s)"
    FAILED=$((FAILED + 1))
fi
echo "---"

echo ""

# Final Summary
echo -e "${PURPLE}📊 Test Results Summary${NC}"
echo "========================"
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo -e "Total Tests: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Your SPSS Parser is ready for production! 🚀${NC}"
    echo ""
    echo -e "${BLUE}🔗 Quick Links:${NC}"
    echo -e "   Frontend: $FRONTEND_URL"
    echo -e "   API Health: $API_URL/api/health"
    echo -e "   API Docs: $API_URL/swagger-ui.html"
    echo -e "   File Upload: Use the frontend to upload .sav files"
    exit 0
else
    echo ""
    echo -e "${RED}⚠️  Some tests failed. Please check the issues above.${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "   - Check Render.com deployment status"
    echo "   - Verify GitHub Pages is enabled"
    echo "   - Wait a few minutes for services to fully start"
    echo "   - Check service logs for errors"
    exit 1
fi