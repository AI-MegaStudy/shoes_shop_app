#!/bin/bash
# 간단한 파일 업로드 테스트 스크립트 (curl 사용)

# 설정
API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}"
PRODUCT_SEQ="${1:-1}"
IMAGE_PATH="${2:-}"

if [ -z "$IMAGE_PATH" ]; then
    echo "사용 방법: ./test_upload_simple.sh [product_seq] [image_path]"
    echo "예시: ./test_upload_simple.sh 1 /path/to/image.jpg"
    exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ 파일을 찾을 수 없습니다: $IMAGE_PATH"
    exit 1
fi

echo "📤 제품 이미지 업로드 테스트"
echo "   제품 번호: $PRODUCT_SEQ"
echo "   파일: $IMAGE_PATH"
echo "   API URL: $API_BASE_URL"
echo ""

# curl로 파일 업로드
response=$(curl -s -w "\n%{http_code}" -X POST \
    -F "file_type=image" \
    -F "file=@$IMAGE_PATH" \
    "$API_BASE_URL/api/products/$PRODUCT_SEQ/upload_file")

# HTTP 상태 코드와 본문 분리
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "📥 응답:"
echo "   HTTP 상태 코드: $http_code"
echo "   응답 본문:"
echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
echo ""

if [ "$http_code" = "200" ]; then
    echo "✅ 업로드 성공!"
    # file_url 추출 (간단한 방법)
    echo "$body" | grep -o '"file_url":"[^"]*"' | cut -d'"' -f4 | head -1
else
    echo "❌ 업로드 실패"
    exit 1
fi

