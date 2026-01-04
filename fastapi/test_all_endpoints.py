#!/usr/bin/env python3
"""
남은 모든 API 엔드포인트 테스트 스크립트

사용 방법:
    python test_all_endpoints.py [--base-url BASE_URL] [--verbose]

옵션:
    --base-url: API 서버 기본 URL (기본값: http://127.0.0.1:8000)
    --verbose: 상세한 출력 표시
    --skip-unused: 미사용 엔드포인트 건너뛰기
"""

import requests
import sys
import argparse
from typing import Dict, List, Tuple
from datetime import datetime

# 테스트 결과 저장
test_results: Dict[str, List[Tuple[str, bool, str]]] = {
    "passed": [],
    "failed": [],
    "skipped": []
}

def print_header(text: str):
    """헤더 출력"""
    print("\n" + "=" * 80)
    print(f"  {text}")
    print("=" * 80)

def print_section(text: str):
    """섹션 출력"""
    print(f"\n{'─' * 80}")
    print(f"  {text}")
    print("─" * 80)

def test_endpoint(
    method: str,
    url: str,
    description: str,
    params: dict = None,
    data: dict = None,
    files: dict = None,
    expected_status: int = 200,
    skip: bool = False
) -> Tuple[bool, str]:
    """
    엔드포인트 테스트
    
    Returns:
        (성공 여부, 메시지)
    """
    if skip:
        return (None, "건너뜀")
    
    try:
        if method == "GET":
            response = requests.get(url, params=params, timeout=5)
        elif method == "POST":
            if files:
                response = requests.post(url, data=data, files=files, timeout=10)
            else:
                response = requests.post(url, data=data, timeout=5)
        elif method == "DELETE":
            response = requests.delete(url, timeout=5)
        else:
            return (False, f"지원하지 않는 메서드: {method}")
        
        if response.status_code == expected_status:
            return (True, f"✅ 성공 (상태 코드: {response.status_code})")
        else:
            return (False, f"❌ 실패 (예상: {expected_status}, 실제: {response.status_code}) - {response.text[:100]}")
    
    except requests.exceptions.ConnectionError:
        return (False, "❌ 서버 연결 실패 (서버가 실행 중인지 확인하세요)")
    except requests.exceptions.Timeout:
        return (False, "❌ 타임아웃")
    except Exception as e:
        return (False, f"❌ 오류: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description="API 엔드포인트 테스트")
    parser.add_argument("--base-url", default="http://127.0.0.1:8000", help="API 서버 기본 URL")
    parser.add_argument("--verbose", action="store_true", help="상세한 출력 표시")
    parser.add_argument("--skip-unused", action="store_true", help="미사용 엔드포인트 건너뛰기")
    args = parser.parse_args()
    
    base_url = args.base_url.rstrip("/")
    
    print_header("API 엔드포인트 종합 테스트")
    print(f"서버 URL: {base_url}")
    print(f"테스트 시작 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 헬스 체크
    print_section("헬스 체크")
    health_result, health_msg = test_endpoint("GET", f"{base_url}/health", "헬스 체크")
    print(f"  GET /health: {health_msg}")
    if not health_result:
        print("\n❌ 서버가 실행 중이지 않습니다. 서버를 먼저 시작하세요:")
        print("   cd fastapi && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload")
        sys.exit(1)
    
    # 테스트 데이터 (DB에서 조회하거나 기본값 사용)
    # 더미 데이터가 있다면 DB에서 조회, 없으면 기본값 사용
    test_user_seq = 1
    test_staff_seq = 1
    test_branch_seq = 1
    test_product_seq = 1
    test_maker_seq = 1
    
    # DB에서 실제 데이터 조회 시도
    try:
        from app.database.connection import connect_db
        conn = connect_db()
        curs = conn.cursor()
        
        # 사용자 조회
        curs.execute("SELECT u_seq FROM user WHERE u_quit_date IS NULL ORDER BY u_seq LIMIT 1")
        user_result = curs.fetchone()
        if user_result:
            test_user_seq = user_result[0]
        
        # 제품 조회
        curs.execute("SELECT p_seq FROM product ORDER BY p_seq LIMIT 1")
        product_result = curs.fetchone()
        if product_result:
            test_product_seq = product_result[0]
        
        # 구매 내역 조회 (Admin API 테스트용)
        curs.execute("SELECT b_seq FROM purchase_item ORDER BY b_seq LIMIT 1")
        purchase_item_result = curs.fetchone()
        test_purchase_item_seq = purchase_item_result[0] if purchase_item_result else None
        
        # 반품 조회 (Refund Join API 테스트용)
        curs.execute("SELECT ref_seq FROM refund ORDER BY ref_seq LIMIT 1")
        refund_result = curs.fetchone()
        test_refund_seq = refund_result[0] if refund_result else None
        
        # 수령 조회 (Pickup Admin API 테스트용)
        curs.execute("SELECT pic_seq FROM pickup ORDER BY pic_seq LIMIT 1")
        pickup_result = curs.fetchone()
        test_pickup_seq = pickup_result[0] if pickup_result else None
        
        conn.close()
        
        if args.verbose:
            print(f"   📋 DB에서 조회한 테스트 데이터:")
            print(f"      - user_seq: {test_user_seq}")
            print(f"      - product_seq: {test_product_seq}")
            if test_purchase_item_seq:
                print(f"      - purchase_item_seq: {test_purchase_item_seq}")
            if test_refund_seq:
                print(f"      - refund_seq: {test_refund_seq}")
            if test_pickup_seq:
                print(f"      - pickup_seq: {test_pickup_seq}")
    except Exception as e:
        if args.verbose:
            print(f"   ⚠️  DB 조회 실패, 기본값 사용: {e}")
        test_purchase_item_seq = None
        test_refund_seq = None
        test_pickup_seq = None
    
    # ============================================
    # 기본 CRUD API 테스트
    # ============================================
    print_section("1. 기본 CRUD API")
    
    # Branches API
    print("\n  📍 Branches API")
    result, msg = test_endpoint("GET", f"{base_url}/api/branches", "전체 지점 조회")
    print(f"    GET /api/branches: {msg}")
    if result: test_results["passed"].append(("GET /api/branches", True, msg))
    else: test_results["failed"].append(("GET /api/branches", False, msg))
    
    if not args.skip_unused:
        result, msg = test_endpoint("GET", f"{base_url}/api/branches/{test_branch_seq}", "특정 지점 조회", skip=True)
        print(f"    GET /api/branches/{{branch_seq}}: {msg} (미사용)")
        test_results["skipped"].append(("GET /api/branches/{branch_seq}", None, "미사용"))
    
    # Users API
    print("\n  👤 Users API")
    result, msg = test_endpoint("GET", f"{base_url}/api/users", "전체 고객 조회")
    print(f"    GET /api/users: {msg}")
    if result: test_results["passed"].append(("GET /api/users", True, msg))
    else: test_results["failed"].append(("GET /api/users", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/users/{test_user_seq}", "특정 고객 조회")
    print(f"    GET /api/users/{{user_seq}}: {msg}")
    if result: test_results["passed"].append(("GET /api/users/{user_seq}", True, msg))
    else: test_results["failed"].append(("GET /api/users/{user_seq}", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/users/{test_user_seq}/profile_image", "프로필 이미지 조회")
    print(f"    GET /api/users/{{user_seq}}/profile_image: {msg}")
    if result: test_results["passed"].append(("GET /api/users/{user_seq}/profile_image", True, msg))
    else: test_results["failed"].append(("GET /api/users/{user_seq}/profile_image", False, msg))
    
    # User Auth Identities API
    print("\n  🔐 User Auth Identities API")
    result, msg = test_endpoint("GET", f"{base_url}/api/user_auth_identities/user/{test_user_seq}", "사용자별 인증 정보 조회")
    print(f"    GET /api/user_auth_identities/user/{{user_seq}}: {msg}")
    if result: test_results["passed"].append(("GET /api/user_auth_identities/user/{user_seq}", True, msg))
    else: test_results["failed"].append(("GET /api/user_auth_identities/user/{user_seq}", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/user_auth_identities/provider/local", "제공자별 인증 정보 조회")
    print(f"    GET /api/user_auth_identities/provider/{{provider}}: {msg}")
    if result: test_results["passed"].append(("GET /api/user_auth_identities/provider/{provider}", True, msg))
    else: test_results["failed"].append(("GET /api/user_auth_identities/provider/{provider}", False, msg))
    
    # Staff API
    print("\n  👔 Staff API")
    result, msg = test_endpoint("GET", f"{base_url}/api/staff/by_id/admin", "직원 ID로 조회")
    print(f"    GET /api/staff/by_id/{{staff_id}}: {msg}")
    if result: test_results["passed"].append(("GET /api/staff/by_id/{staff_id}", True, msg))
    else: test_results["failed"].append(("GET /api/staff/by_id/{staff_id}", False, msg))
    
    # Makers API
    print("\n  🏭 Makers API")
    result, msg = test_endpoint("GET", f"{base_url}/api/makers", "전체 제조사 조회")
    print(f"    GET /api/makers: {msg}")
    if result: test_results["passed"].append(("GET /api/makers", True, msg))
    else: test_results["failed"].append(("GET /api/makers", False, msg))
    
    # Categories API
    print("\n  📂 Categories API")
    for category in ["kind_categories", "color_categories", "size_categories", "gender_categories", "refund_reason_categories"]:
        result, msg = test_endpoint("GET", f"{base_url}/api/{category}", f"{category} 조회")
        print(f"    GET /api/{category}: {msg}")
        if result: test_results["passed"].append((f"GET /api/{category}", True, msg))
        else: test_results["failed"].append((f"GET /api/{category}", False, msg))
    
    # Products API
    print("\n  👟 Products API")
    result, msg = test_endpoint("GET", f"{base_url}/api/products/id/{test_product_seq}", "제품 ID로 조회")
    print(f"    GET /api/products/id/{{product_seq}}: {msg}")
    if result: test_results["passed"].append(("GET /api/products/id/{product_seq}", True, msg))
    else: test_results["failed"].append(("GET /api/products/id/{product_seq}", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/products/group_by_name", "제품명 그룹화 조회")
    print(f"    GET /api/products/group_by_name: {msg}")
    if result: test_results["passed"].append(("GET /api/products/group_by_name", True, msg))
    else: test_results["failed"].append(("GET /api/products/group_by_name", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/products/getBySeqs", "시퀀스로 제품 조회", params={"m_seq": test_maker_seq})
    print(f"    GET /api/products/getBySeqs: {msg}")
    if result: test_results["passed"].append(("GET /api/products/getBySeqs", True, msg))
    else: test_results["failed"].append(("GET /api/products/getBySeqs", False, msg))
    
    # Purchase Items API
    print("\n  🛒 Purchase Items API")
    result, msg = test_endpoint("GET", f"{base_url}/api/purchase_items/by_user/{test_user_seq}", "사용자별 구매 내역 조회")
    print(f"    GET /api/purchase_items/by_user/{{user_seq}}: {msg}")
    if result: test_results["passed"].append(("GET /api/purchase_items/by_user/{user_seq}", True, msg))
    else: test_results["failed"].append(("GET /api/purchase_items/by_user/{user_seq}", False, msg))
    
    # Pickups API
    print("\n  📦 Pickups API")
    # Note: /api/pickups/by_user/{user_seq} 엔드포인트는 존재하지 않음
    # Plus API (/api/pickups/by_user/{user_seq}/all)만 존재하며 아래에서 테스트됨
    
    # Refunds API
    print("\n  🔄 Refunds API")
    result, msg = test_endpoint("GET", f"{base_url}/api/refunds/by_user/{test_user_seq}", "사용자별 반품 내역 조회")
    print(f"    GET /api/refunds/by_user/{{user_seq}}: {msg}")
    if result: test_results["passed"].append(("GET /api/refunds/by_user/{user_seq}", True, msg))
    else: test_results["failed"].append(("GET /api/refunds/by_user/{user_seq}", False, msg))
    
    # ============================================
    # JOIN API 테스트
    # ============================================
    print_section("2. JOIN API")
    
    # Product Join API
    print("\n  🔗 Product Join API")
    result, msg = test_endpoint("GET", f"{base_url}/api/products/with_categories", "제품 목록 + 카테고리 조회")
    print(f"    GET /api/products/with_categories: {msg}")
    if result: test_results["passed"].append(("GET /api/products/with_categories", True, msg))
    else: test_results["failed"].append(("GET /api/products/with_categories", False, msg))
    
    # Refund Join API
    print("\n  🔗 Refund Join API")
    if test_refund_seq:
        # 실제 경로: prefix /api/refunds + 라우터 경로 /refunds/{refund_seq}/with_details = /api/refunds/refunds/{refund_seq}/with_details
        result, msg = test_endpoint("GET", f"{base_url}/api/refunds/refunds/{test_refund_seq}/with_details", "반품 상세 정보 조회")
        print(f"    GET /api/refunds/refunds/{{refund_seq}}/with_details: {msg}")
        if result: test_results["passed"].append(("GET /api/refunds/refunds/{refund_seq}/with_details", True, msg))
        else: test_results["failed"].append(("GET /api/refunds/refunds/{refund_seq}/with_details", False, msg))
        
        result, msg = test_endpoint("GET", f"{base_url}/api/refunds/refunds/{test_refund_seq}/full_detail", "반품 전체 상세 정보 조회")
        print(f"    GET /api/refunds/refunds/{{refund_seq}}/full_detail: {msg}")
        if result: test_results["passed"].append(("GET /api/refunds/refunds/{refund_seq}/full_detail", True, msg))
        else: test_results["failed"].append(("GET /api/refunds/refunds/{refund_seq}/full_detail", False, msg))
    else:
        result, msg = test_endpoint("GET", f"{base_url}/api/refunds/refunds/1/with_details", "반품 상세 정보 조회", skip=True)
        print(f"    GET /api/refunds/refunds/{{refund_seq}}/with_details: {msg} (테스트 데이터 없음)")
        test_results["skipped"].append(("GET /api/refunds/refunds/{refund_seq}/with_details", None, "테스트 데이터 없음"))
    
    # ============================================
    # Plus API 테스트
    # ============================================
    print_section("3. Plus API (고객용)")
    
    result, msg = test_endpoint("GET", f"{base_url}/api/purchase_items/by_user/{test_user_seq}/user_bundle", "고객별 주문 그룹화 조회")
    print(f"    GET /api/purchase_items/by_user/{{user_seq}}/user_bundle: {msg}")
    if result: test_results["passed"].append(("GET /api/purchase_items/by_user/{user_seq}/user_bundle", True, msg))
    else: test_results["failed"].append(("GET /api/purchase_items/by_user/{user_seq}/user_bundle", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/pickups/by_user/{test_user_seq}/all", "고객별 수령 내역 조회")
    print(f"    GET /api/pickups/by_user/{{user_seq}}/all: {msg}")
    if result: test_results["passed"].append(("GET /api/pickups/by_user/{user_seq}/all", True, msg))
    else: test_results["failed"].append(("GET /api/pickups/by_user/{user_seq}/all", False, msg))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/refunds/refund/by_user/{test_user_seq}/all", "고객별 반품 내역 조회")
    print(f"    GET /api/refunds/refund/by_user/{{user_seq}}/all: {msg}")
    if result: test_results["passed"].append(("GET /api/refunds/refund/by_user/{user_seq}/all", True, msg))
    else: test_results["failed"].append(("GET /api/refunds/refund/by_user/{user_seq}/all", False, msg))
    
    # ============================================
    # Admin API 테스트
    # ============================================
    print_section("4. Admin API (관리자용)")
    
    result, msg = test_endpoint("GET", f"{base_url}/api/purchase_items/admin/all", "관리자용 전체 구매 내역 조회")
    print(f"    GET /api/purchase_items/admin/all: {msg}")
    if result: test_results["passed"].append(("GET /api/purchase_items/admin/all", True, msg))
    else: test_results["failed"].append(("GET /api/purchase_items/admin/all", False, msg))
    
    purchase_item_seq = 1  # 실제 테스트 시 DB에서 조회
    if test_purchase_item_seq:
        result, msg = test_endpoint("GET", f"{base_url}/api/purchase_items/admin/{test_purchase_item_seq}/full_detail", "관리자용 구매 내역 상세 조회")
        print(f"    GET /api/purchase_items/admin/{{purchase_item_seq}}/full_detail: {msg}")
        if result: test_results["passed"].append(("GET /api/purchase_items/admin/{purchase_item_seq}/full_detail", True, msg))
        else: test_results["failed"].append(("GET /api/purchase_items/admin/{purchase_item_seq}/full_detail", False, msg))
    else:
        result, msg = test_endpoint("GET", f"{base_url}/api/purchase_items/admin/1/full_detail", "관리자용 구매 내역 상세 조회", skip=True)
        print(f"    GET /api/purchase_items/admin/{{purchase_item_seq}}/full_detail: {msg} (테스트 데이터 없음)")
        test_results["skipped"].append(("GET /api/purchase_items/admin/{purchase_item_seq}/full_detail", None, "테스트 데이터 없음"))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/pickups/admin/all", "관리자용 전체 수령 내역 조회")
    print(f"    GET /api/pickups/admin/all: {msg}")
    if result: test_results["passed"].append(("GET /api/pickups/admin/all", True, msg))
    else: test_results["failed"].append(("GET /api/pickups/admin/all", False, msg))
    
    if test_pickup_seq:
        result, msg = test_endpoint("GET", f"{base_url}/api/pickups/admin/{test_pickup_seq}/full_detail", "관리자용 수령 내역 상세 조회")
        print(f"    GET /api/pickups/admin/{{pickup_seq}}/full_detail: {msg}")
        if result: test_results["passed"].append(("GET /api/pickups/admin/{pickup_seq}/full_detail", True, msg))
        else: test_results["failed"].append(("GET /api/pickups/admin/{pickup_seq}/full_detail", False, msg))
    else:
        result, msg = test_endpoint("GET", f"{base_url}/api/pickups/admin/1/full_detail", "관리자용 수령 내역 상세 조회", skip=True)
        print(f"    GET /api/pickups/admin/{{pickup_seq}}/full_detail: {msg} (테스트 데이터 없음)")
        test_results["skipped"].append(("GET /api/pickups/admin/{pickup_seq}/full_detail", None, "테스트 데이터 없음"))
    
    result, msg = test_endpoint("GET", f"{base_url}/api/refunds/admin/all", "관리자용 전체 반품 내역 조회")
    print(f"    GET /api/refunds/admin/all: {msg}")
    if result: test_results["passed"].append(("GET /api/refunds/admin/all", True, msg))
    else: test_results["failed"].append(("GET /api/refunds/admin/all", False, msg))
    
    if test_refund_seq:
        result, msg = test_endpoint("GET", f"{base_url}/api/refunds/admin/{test_refund_seq}/full_detail", "관리자용 반품 내역 상세 조회")
        print(f"    GET /api/refunds/admin/{{refund_seq}}/full_detail: {msg}")
        if result: test_results["passed"].append(("GET /api/refunds/admin/{refund_seq}/full_detail", True, msg))
        else: test_results["failed"].append(("GET /api/refunds/admin/{refund_seq}/full_detail", False, msg))
    else:
        result, msg = test_endpoint("GET", f"{base_url}/api/refunds/admin/1/full_detail", "관리자용 반품 내역 상세 조회", skip=True)
        print(f"    GET /api/refunds/admin/{{refund_seq}}/full_detail: {msg} (테스트 데이터 없음)")
        test_results["skipped"].append(("GET /api/refunds/admin/{refund_seq}/full_detail", None, "테스트 데이터 없음"))
    
    # ============================================
    # 기타 API 테스트
    # ============================================
    print_section("5. 기타 API")
    
    result, msg = test_endpoint("GET", f"{base_url}/api/chatting/by_user_seq", "채팅 세션 조회", params={"u_seq": test_user_seq, "is_closed": False})
    print(f"    GET /api/chatting/by_user_seq: {msg}")
    if result: test_results["passed"].append(("GET /api/chatting/by_user_seq", True, msg))
    else: test_results["failed"].append(("GET /api/chatting/by_user_seq", False, msg))
    
    # ============================================
    # 결과 요약
    # ============================================
    print_header("테스트 결과 요약")
    
    total_tests = len(test_results["passed"]) + len(test_results["failed"]) + len(test_results["skipped"])
    passed_count = len(test_results["passed"])
    failed_count = len(test_results["failed"])
    skipped_count = len(test_results["skipped"])
    
    print(f"\n총 테스트: {total_tests}개")
    print(f"  ✅ 성공: {passed_count}개")
    print(f"  ❌ 실패: {failed_count}개")
    print(f"  ⏭️  건너뜀: {skipped_count}개")
    
    if failed_count > 0:
        print("\n❌ 실패한 테스트:")
        for endpoint, _, msg in test_results["failed"]:
            print(f"  - {endpoint}: {msg}")
    
    if args.verbose and skipped_count > 0:
        print("\n⏭️  건너뛴 테스트:")
        for endpoint, _, reason in test_results["skipped"]:
            print(f"  - {endpoint}: {reason}")
    
    print(f"\n테스트 완료 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 종료 코드
    sys.exit(0 if failed_count == 0 else 1)

if __name__ == "__main__":
    main()

