"""
상세 값 검수 스크립트
레코드 수뿐만 아니라 컬럼 값의 변경도 감지

기대값 = 더미 데이터 생성 스크립트에 정의된 값
- 레코드 수
- 각 레코드의 컬럼 값
"""

import pymysql
from datetime import datetime, timedelta

DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'shoes_shop_db',
    'charset': 'utf8mb4',
    'port': 13306
}

def connect_db():
    return pymysql.connect(**DB_CONFIG)

def audit_staffs_detailed(conn):
    """직원 데이터 상세 검수 (컬럼 값 포함)"""
    print("\n" + "=" * 60)
    print("👔 직원 데이터 상세 검수")
    print("=" * 60)
    curs = conn.cursor()
    
    # 기대값: 더미 데이터 스크립트에 정의된 값
    expected_staffs = {
        'staff001': {'s_name': '김점장', 's_rank': '점장', 's_phone': '010-1001-1001', 's_superseq': None},
        'staff002': {'s_name': '이부점장', 's_rank': '부점장', 's_phone': '010-1002-1002', 's_superseq': 'staff001'},
        'staff003': {'s_name': '박점장', 's_rank': '점장', 's_phone': '010-2001-2001', 's_superseq': None},
        'staff004': {'s_name': '최사원', 's_rank': '사원', 's_phone': '010-2002-2002', 's_superseq': 'staff003'},
        'staff005': {'s_name': '정점장', 's_rank': '점장', 's_phone': '010-3001-3001', 's_superseq': None},
    }
    
    curs.execute("SELECT s_seq, s_id, s_name, s_rank, s_phone, s_superseq FROM staff ORDER BY s_seq")
    actual_staffs = curs.fetchall()
    
    # s_superseq를 s_id로 변환하기 위한 매핑
    curs.execute("SELECT s_seq, s_id FROM staff")
    seq_to_id = {row[0]: row[1] for row in curs.fetchall()}
    
    print(f"기대 직원 수: {len(expected_staffs)}명")
    print(f"실제 직원 수: {len(actual_staffs)}명\n")
    
    issues = []
    
    for row in actual_staffs:
        s_seq, s_id, s_name, s_rank, s_phone, s_superseq = row
        s_superseq_id = seq_to_id.get(s_superseq) if s_superseq else None
        
        if s_id in expected_staffs:
            expected = expected_staffs[s_id]
            changes = []
            
            if s_name != expected['s_name']:
                changes.append(f"이름: '{expected['s_name']}' → '{s_name}'")
            if s_rank != expected['s_rank']:
                changes.append(f"직급: '{expected['s_rank']}' → '{s_rank}'")
            if s_phone != expected['s_phone']:
                changes.append(f"전화번호: '{expected['s_phone']}' → '{s_phone}'")
            if s_superseq_id != expected['s_superseq']:
                changes.append(f"상급자: '{expected['s_superseq']}' → '{s_superseq_id}'")
            
            if changes:
                issues.append(f"  ⚠️  {s_id} ({s_name}): {', '.join(changes)}")
            else:
                print(f"  ✅ {s_id} ({s_name}): 모든 값 일치")
        else:
            issues.append(f"  ℹ️  {s_id} ({s_name}): 기대값 목록에 없는 직원")
    
    if issues:
        print("\n변경된 값:")
        for issue in issues:
            print(issue)
    else:
        print("\n✅ 모든 직원의 컬럼 값이 기대값과 일치합니다.")
    
    return len(issues) == 0

def audit_users_detailed(conn):
    """고객 데이터 상세 검수 (컬럼 값 포함)"""
    print("\n" + "=" * 60)
    print("👤 고객 데이터 상세 검수")
    print("=" * 60)
    curs = conn.cursor()
    
    # 기대값: 더미 데이터 스크립트에 정의된 값
    expected_users = {
        'user001@example.com': {'u_name': '홍길동', 'u_phone': '010-1111-1111', 'u_address': '서울시 강남구 테헤란로 123', 'u_quit_date': None},
        'user002@example.com': {'u_name': '김철수', 'u_phone': '010-2222-2222', 'u_address': '서울시 마포구 홍익로 456', 'u_quit_date': None},
        'user003@example.com': {'u_name': '이영희', 'u_phone': '010-3333-3333', 'u_address': '서울시 송파구 올림픽로 789', 'u_quit_date': None},
        'user004@example.com': {'u_name': '박민수', 'u_phone': '010-4444-4444', 'u_address': '부산시 해운대구 해운대해변로 321', 'u_quit_date': None},
        'user005@example.com': {'u_name': '최지영', 'u_phone': '010-5555-5555', 'u_address': '대구시 중구 동성로 654', 'u_quit_date': None},
        'dormant001@example.com': {'u_name': '휴면회원1', 'u_phone': '010-6666-6666', 'u_address': '서울시 강남구 테헤란로 100', 'u_quit_date': None},
        'dormant002@example.com': {'u_name': '휴면회원2', 'u_phone': '010-7777-7777', 'u_address': '서울시 마포구 홍익로 200', 'u_quit_date': None},
        'quit001@example.com': {'u_name': '탈퇴회원1', 'u_phone': '010-8888-8888', 'u_address': '서울시 송파구 올림픽로 300', 'u_quit_date': '있음'},  # 탈퇴일은 날짜이므로 '있음'으로 체크
        'quit002@example.com': {'u_name': '탈퇴회원2', 'u_phone': '010-9999-9999', 'u_address': '부산시 해운대구 해운대해변로 400', 'u_quit_date': '있음'},
    }
    
    curs.execute("SELECT u_seq, u_email, u_name, u_phone, u_address, u_quit_date FROM user ORDER BY u_seq")
    actual_users = curs.fetchall()
    
    print(f"기대 고객 수: {len(expected_users)}명")
    print(f"실제 고객 수: {len(actual_users)}명\n")
    
    issues = []
    new_users = []
    
    for row in actual_users:
        u_seq, u_email, u_name, u_phone, u_address, u_quit_date = row
        u_quit_date_exists = u_quit_date is not None
        
        if u_email in expected_users:
            expected = expected_users[u_email]
            changes = []
            
            if u_name != expected['u_name']:
                changes.append(f"이름: '{expected['u_name']}' → '{u_name}'")
            if u_phone != expected['u_phone']:
                changes.append(f"전화번호: '{expected['u_phone']}' → '{u_phone}'")
            if u_address != expected['u_address']:
                changes.append(f"주소: '{expected['u_address']}' → '{u_address}'")
            
            # 탈퇴일 체크
            expected_quit = expected['u_quit_date'] == '있음'
            if u_quit_date_exists != expected_quit:
                if expected_quit:
                    changes.append(f"탈퇴일: 기대(있음) → 실제(없음)")
                else:
                    changes.append(f"탈퇴일: 기대(없음) → 실제(있음: {u_quit_date})")
            
            if changes:
                issues.append(f"  ⚠️  {u_email} ({u_name}): {', '.join(changes)}")
            else:
                print(f"  ✅ {u_email} ({u_name}): 모든 값 일치")
        else:
            new_users.append(f"  ℹ️  {u_email} ({u_name}): 기대값 목록에 없는 고객")
    
    if issues:
        print("\n변경된 값:")
        for issue in issues:
            print(issue)
    
    if new_users:
        print("\n추가된 고객:")
        for user in new_users:
            print(user)
    
    if not issues and not new_users:
        print("\n✅ 모든 고객의 컬럼 값이 기대값과 일치합니다.")
    
    return len(issues) == 0 and len(new_users) == 0

def audit_products_detailed(conn):
    """제품 데이터 상세 검수 (주요 컬럼 값 확인)"""
    print("\n" + "=" * 60)
    print("👟 제품 데이터 상세 검수")
    print("=" * 60)
    curs = conn.cursor()
    
    # 기대 제품명 목록
    expected_product_names = [
        'U740WN2',
        '나이키 샥스 TL',
        '나이키 에어포스 1',
        '나이키 페가수스 플러스'
    ]
    
    # 각 제품명별 기대 개수: 3개 색상 × 7개 사이즈 = 21개
    expected_count_per_name = 21
    
    curs.execute("""
        SELECT p_name, COUNT(*) as cnt, 
               MIN(p_price) as min_price, MAX(p_price) as max_price, AVG(p_price) as avg_price,
               MIN(p_stock) as min_stock, MAX(p_stock) as max_stock
        FROM product
        GROUP BY p_name
        ORDER BY p_name
    """)
    
    actual_products = curs.fetchall()
    
    print(f"기대 제품명 종류: {len(expected_product_names)}개")
    print(f"실제 제품명 종류: {len(actual_products)}개\n")
    
    issues = []
    
    actual_names = []
    for row in actual_products:
        p_name, cnt, min_price, max_price, avg_price, min_stock, max_stock = row
        actual_names.append(p_name)
        
        if p_name in expected_product_names:
            if cnt != expected_count_per_name:
                issues.append(f"  ⚠️  {p_name}: 기대 개수 {expected_count_per_name}개 → 실제 {cnt}개")
            else:
                print(f"  ✅ {p_name}: {cnt}개 (가격 범위: {int(min_price):,}원 ~ {int(max_price):,}원, 재고: {min_stock}~{max_stock}개)")
        else:
            issues.append(f"  ℹ️  {p_name}: 기대값 목록에 없는 제품 ({cnt}개)")
    
    missing_names = set(expected_product_names) - set(actual_names)
    if missing_names:
        for name in missing_names:
            issues.append(f"  ⚠️  {name}: 기대값 목록에 있지만 DB에 없음")
    
    if issues:
        print("\n문제점:")
        for issue in issues:
            print(issue)
    else:
        print("\n✅ 모든 제품의 컬럼 값이 기대값과 일치합니다.")
    
    return len(issues) == 0

def main():
    print("=" * 60)
    print("🔍 상세 값 검수 시작")
    print("=" * 60)
    print("📌 기대값 = 더미 데이터 생성 스크립트에 정의된 값")
    print("📌 레코드 수 + 각 컬럼 값 모두 비교")
    
    conn = connect_db()
    
    try:
        staff_ok = audit_staffs_detailed(conn)
        users_ok = audit_users_detailed(conn)
        products_ok = audit_products_detailed(conn)
        
        print("\n" + "=" * 60)
        print("📊 검수 요약")
        print("=" * 60)
        print(f"직원 데이터: {'✅ 일치' if staff_ok else '⚠️  불일치'}")
        print(f"고객 데이터: {'✅ 일치' if users_ok else '⚠️  불일치'}")
        print(f"제품 데이터: {'✅ 일치' if products_ok else '⚠️  불일치'}")
        
        if staff_ok and users_ok and products_ok:
            print("\n✅ 모든 데이터가 기대값과 일치합니다!")
        else:
            print("\n⚠️  일부 데이터가 기대값과 다릅니다. 위의 상세 내용을 확인해주세요.")
        
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()

