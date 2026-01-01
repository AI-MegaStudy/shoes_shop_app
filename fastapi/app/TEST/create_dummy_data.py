"""
새로운 ERD 구조에 맞는 더미 데이터 생성 스크립트

사용법:
    python create_dummy_data.py

생성 순서:
    1. branch (지점)
    2. maker (제조사)
    3. 카테고리들 (kind, color, size, gender)
    4. user (고객)
    5. staff (직원)
    6. product (제품)
    7. purchase_item (구매 내역)
    8. pickup (수령)
    9. refund (반품)
    10. receive (입고)
    11. request (발주)
"""

import pymysql
import random
from datetime import datetime, timedelta
import io

# 데이터베이스 연결 설정 (소셜 로그인 지원 버전)
DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'shoes_shop_db',  # 소셜 로그인 지원 데이터베이스
    'charset': 'utf8mb4',
    'port': 13306
}


def connect_db():
    return pymysql.connect(**DB_CONFIG)


def create_dummy_image():
    """더미 이미지 바이너리 생성 (1x1 PNG)"""
    return b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\xe2\xd9\xa4\xb5\x00\x00\x00\x00IEND\xaeB`\x82'


def create_branches(conn):
    """지점 데이터 생성 (중복 방지)"""
    print("📍 지점 데이터 생성 중...")
    curs = conn.cursor()
    
    branches = [
        ('강남점', '02-1234-5678', '서울시 강남구 테헤란로 123', 37.5010, 127.0260),
        ('홍대점', '02-2345-6789', '서울시 마포구 홍익로 456', 37.5563, 126.9236),
        ('잠실점', '02-3456-7890', '서울시 송파구 올림픽로 789', 37.5133, 127.1028),
        ('부산점', '051-1111-2222', '부산시 해운대구 해운대해변로 321', 35.1631, 129.1636),
        ('대구점', '053-3333-4444', '대구시 중구 동성로 654', 35.8714, 128.6014),
    ]
    
    branch_ids = []
    for branch in branches:
        br_name = branch[0]
        # 중복 확인
        curs.execute("SELECT br_seq FROM branch WHERE br_name = %s", (br_name,))
        existing = curs.fetchone()
        
        if existing:
            branch_ids.append(existing[0])
        else:
            sql = """
                INSERT INTO branch (br_name, br_phone, br_address, br_lat, br_lng)
                VALUES (%s, %s, %s, %s, %s)
            """
            curs.execute(sql, branch)
            branch_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(branch_ids)}개 지점 생성 완료")
    return branch_ids


def create_makers(conn):
    """제조사 데이터 생성 (중복 방지)"""
    print("🏭 제조사 데이터 생성 중...")
    curs = conn.cursor()
    
    makers = [
        ('나이키', '02-1111-1111', '서울시 강남구 테헤란로 100'),
        ('아디다스', '02-2222-2222', '서울시 서초구 서초대로 200'),
        ('뉴발란스', '02-3333-3333', '서울시 송파구 올림픽로 300'),
        ('컨버스', '02-4444-4444', '서울시 마포구 홍익로 400'),
        ('반스', '02-5555-5555', '서울시 강동구 천호대로 500'),
    ]
    
    maker_ids = []
    for maker in makers:
        m_name = maker[0]
        # 중복 확인
        curs.execute("SELECT m_seq FROM maker WHERE m_name = %s", (m_name,))
        existing = curs.fetchone()
        
        if existing:
            maker_ids.append(existing[0])
        else:
            sql = "INSERT INTO maker (m_name, m_phone, m_address) VALUES (%s, %s, %s)"
            curs.execute(sql, maker)
            maker_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(maker_ids)}개 제조사 생성 완료")
    return maker_ids


def create_categories(conn):
    """카테고리 데이터 생성"""
    print("📂 카테고리 데이터 생성 중...")
    curs = conn.cursor()
    
    # 종류 카테고리 (중복 방지)
    kind_categories = ['러닝화', '스니커즈', '부츠', '로퍼', '샌들']
    kind_ids = []
    for kc_name in kind_categories:
        curs.execute("SELECT kc_seq FROM kind_category WHERE kc_name = %s", (kc_name,))
        existing = curs.fetchone()
        if existing:
            kind_ids.append(existing[0])
        else:
            sql = "INSERT INTO kind_category (kc_name) VALUES (%s)"
            curs.execute(sql, (kc_name,))
            kind_ids.append(curs.lastrowid)
    
    # 색상 카테고리 (중복 방지)
    color_categories = ['블랙', '화이트', '그레이', '레드', '블루', '그린', '옐로우']
    color_ids = []
    for cc_name in color_categories:
        curs.execute("SELECT cc_seq FROM color_category WHERE cc_name = %s", (cc_name,))
        existing = curs.fetchone()
        if existing:
            color_ids.append(existing[0])
        else:
            sql = "INSERT INTO color_category (cc_name) VALUES (%s)"
            curs.execute(sql, (cc_name,))
            color_ids.append(curs.lastrowid)
    
    # 사이즈 카테고리 (중복 방지)
    size_categories = ['220', '230', '240', '250', '260', '270', '280', '290']
    size_ids = []
    for sc_name in size_categories:
        curs.execute("SELECT sc_seq FROM size_category WHERE sc_name = %s", (sc_name,))
        existing = curs.fetchone()
        if existing:
            size_ids.append(existing[0])
        else:
            sql = "INSERT INTO size_category (sc_name) VALUES (%s)"
            curs.execute(sql, (sc_name,))
            size_ids.append(curs.lastrowid)
    
    # 성별 카테고리 (중복 방지)
    gender_categories = ['남성', '여성', '공용']
    gender_ids = []
    for gc_name in gender_categories:
        curs.execute("SELECT gc_seq FROM gender_category WHERE gc_name = %s", (gc_name,))
        existing = curs.fetchone()
        if existing:
            gender_ids.append(existing[0])
        else:
            sql = "INSERT INTO gender_category (gc_name) VALUES (%s)"
            curs.execute(sql, (gc_name,))
            gender_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ 종류 {len(kind_ids)}개, 색상 {len(color_ids)}개, 사이즈 {len(size_ids)}개, 성별 {len(gender_ids)}개 생성 완료")
    return kind_ids, color_ids, size_ids, gender_ids


def create_users(conn):
    """고객 데이터 생성 (소셜 로그인 구조 - 중복 방지)
    
    생성되는 회원 유형:
    - 일반 회원: 최근 접속 (1-30일 전)
    - 휴면 회원: 6개월 이상 미접속 (200일 전)
    - 탈퇴 회원: u_quit_date가 설정된 회원
    
    주의사항:
    - 실제 회원가입 API는 user 생성(/api/users)과 user_auth_identities 생성(/api/user_auth_identities)을 
      별도로 호출하지만, 더미 데이터 생성은 성능상의 이유로 하나의 트랜잭션에서 함께 생성합니다.
    - 로컬 로그인: provider_subject에 이메일을 저장 (email_at_provider는 사용하지 않음)
    """
    print("👤 고객 데이터 생성 중...")
    curs = conn.cursor()
    
    now = datetime.now()
    dormant_days = 200  # 6개월 이상 (180일보다 조금 더 많게 설정)
    
    # 사용자 데이터 구조: (u_email, u_name, u_phone, u_address, u_quit_date, last_login_days_ago)
    # u_quit_date: None이면 탈퇴하지 않은 회원, datetime이면 탈퇴 회원
    # last_login_days_ago: None이면 신규 회원, int이면 며칠 전 로그인했는지
    users = [
        # 일반 회원들 (최근 접속)
        ('user001@example.com', '홍길동', '010-1111-1111', '서울시 강남구 테헤란로 123', None, 5),
        ('user002@example.com', '김철수', '010-2222-2222', '서울시 마포구 홍익로 456', None, 15),
        ('user003@example.com', '이영희', '010-3333-3333', '서울시 송파구 올림픽로 789', None, 30),
        ('user004@example.com', '박민수', '010-4444-4444', '부산시 해운대구 해운대해변로 321', None, 10),
        ('user005@example.com', '최지영', '010-5555-5555', '대구시 중구 동성로 654', None, 1),
        # 휴면 회원 (6개월 이상 미접속)
        ('dormant001@example.com', '휴면회원1', '010-6666-6666', '서울시 강남구 테헤란로 100', None, dormant_days),
        ('dormant002@example.com', '휴면회원2', '010-7777-7777', '서울시 마포구 홍익로 200', None, dormant_days + 10),
        # 탈퇴 회원
        ('quit001@example.com', '탈퇴회원1', '010-8888-8888', '서울시 송파구 올림픽로 300', now - timedelta(days=30), 60),
        ('quit002@example.com', '탈퇴회원2', '010-9999-9999', '부산시 해운대구 해운대해변로 400', now - timedelta(days=90), 120),
    ]
    
    # 로컬 로그인 비밀번호 (user_auth_identities에 저장) - 통일된 비밀번호
    passwords = ['qwer1234'] * len(users)
    
    user_ids = []
    dummy_image = create_dummy_image()
    
    for i, user in enumerate(users):
        u_email = user[0]
        u_phone = user[2]
        u_quit_date = user[4]
        last_login_days_ago = user[5]
        
        # 중복 확인 (u_email 또는 u_phone)
        curs.execute("SELECT u_seq FROM user WHERE u_email = %s OR u_phone = %s", (u_email, u_phone))
        existing = curs.fetchone()
        
        if existing:
            # 기존 회원: 데이터 업데이트만 수행
            u_seq = existing[0]
            user_ids.append(u_seq)
            
            # user 테이블: u_quit_date 업데이트
            if u_quit_date is not None:
                curs.execute("UPDATE user SET u_quit_date = %s WHERE u_seq = %s", (u_quit_date, u_seq))
            
            # user_auth_identities 테이블: last_login_at 업데이트
            if last_login_days_ago is not None:
                last_login_at = now - timedelta(days=last_login_days_ago)
                curs.execute("""
                    UPDATE user_auth_identities 
                    SET last_login_at = %s 
                    WHERE u_seq = %s AND provider = 'local'
                """, (last_login_at, u_seq))
        else:
            # 신규 회원 생성
            # 1단계: user 테이블에 사용자 정보 저장
            sql = """
                INSERT INTO user (u_email, u_name, u_phone, u_address, u_image, u_quit_date)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            curs.execute(sql, (user[0], user[1], user[2], user[3], dummy_image, u_quit_date))
            u_seq = curs.lastrowid
            user_ids.append(u_seq)
            
            # 2단계: user_auth_identities 테이블에 로컬 로그인 정보 저장
            # 참고: 실제 회원가입 API는 별도의 API 호출(/api/user_auth_identities)로 생성하지만,
            #       더미 데이터는 성능상의 이유로 같은 트랜잭션에서 함께 생성
            last_login_at = None
            if last_login_days_ago is not None:
                last_login_at = now - timedelta(days=last_login_days_ago)
            
            # 로컬 로그인: provider_subject에 이메일 저장 (email_at_provider는 사용하지 않음)
            auth_sql = """
                INSERT INTO user_auth_identities 
                (u_seq, provider, provider_subject, password, last_login_at)
                VALUES (%s, %s, %s, %s, %s)
            """
            curs.execute(auth_sql, (u_seq, 'local', u_email, passwords[i], last_login_at))
    
    conn.commit()
    
    # 생성된 회원 유형별 카운트
    normal_count = sum(1 for u in users if u[4] is None and (u[5] is None or u[5] < 180))
    dormant_count = sum(1 for u in users if u[4] is None and u[5] is not None and u[5] >= 180)
    quit_count = sum(1 for u in users if u[4] is not None)
    
    print(f"   ✅ {len(user_ids)}개 고객 생성 완료")
    print(f"      - 일반 회원: {normal_count}개")
    print(f"      - 휴면 회원 (6개월 이상 미접속): {dormant_count}개")
    print(f"      - 탈퇴 회원: {quit_count}개")
    return user_ids


def create_staffs(conn, branch_ids):
    """직원 데이터 생성 (중복 방지, 상급자 관계 설정)"""
    print("👔 직원 데이터 생성 중...")
    curs = conn.cursor()
    
    # 직원 데이터: (s_id, password, name, phone, rank, supervisor_s_id)
    # supervisor_s_id가 None이면 최상급자(점장)
    staffs = [
        ('staff001', 'pass1234', '김점장', '010-1001-1001', '점장', None),  # 강남점 점장 (최상급자)
        ('staff002', 'pass1234', '이부점장', '010-1002-1002', '부점장', 'staff001'),  # 강남점 부점장 (staff001의 하급자)
        ('staff003', 'pass1234', '박점장', '010-2001-2001', '점장', None),  # 홍대점 점장 (최상급자)
        ('staff004', 'pass1234', '최사원', '010-2002-2002', '사원', 'staff003'),  # 홍대점 사원 (staff003의 하급자)
        ('staff005', 'pass1234', '정점장', '010-3001-3001', '점장', None),  # 잠실점 점장 (최상급자)
    ]
    
    staff_ids = []
    staff_id_to_seq = {}  # s_id -> s_seq 매핑
    dummy_image = create_dummy_image()
    
    for i, staff in enumerate(staffs):
        s_id = staff[0]
        s_phone = staff[3]
        supervisor_s_id = staff[5]  # 상급자의 s_id
        
        # 중복 확인 (s_id 또는 s_phone)
        curs.execute("SELECT s_seq FROM staff WHERE s_id = %s OR s_phone = %s", (s_id, s_phone))
        existing = curs.fetchone()
        
        if existing:
            existing_seq = existing[0]
            staff_ids.append(existing_seq)
            staff_id_to_seq[s_id] = existing_seq
        else:
            br_seq = branch_ids[i % len(branch_ids)]
            
            # 상급자의 s_seq 찾기
            s_superseq = None
            if supervisor_s_id:
                # 상급자가 이미 생성되었는지 확인
                if supervisor_s_id in staff_id_to_seq:
                    s_superseq = staff_id_to_seq[supervisor_s_id]
                else:
                    # 데이터베이스에서 상급자 찾기
                    curs.execute("SELECT s_seq FROM staff WHERE s_id = %s", (supervisor_s_id,))
                    supervisor = curs.fetchone()
                    if supervisor:
                        s_superseq = supervisor[0]
                    else:
                        print(f"   ⚠️  상급자 {supervisor_s_id}를 찾을 수 없습니다. s_superseq를 NULL로 설정합니다.")
            
            sql = """
                INSERT INTO staff (s_id, br_seq, s_password, s_name, s_phone, s_rank, s_superseq, s_image)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            curs.execute(sql, (staff[0], br_seq, staff[1], staff[2], staff[3], staff[4], s_superseq, dummy_image))
            inserted_seq = curs.lastrowid
            staff_ids.append(inserted_seq)
            staff_id_to_seq[s_id] = inserted_seq
    
    conn.commit()
    print(f"   ✅ {len(staff_ids)}개 직원 생성 완료")
    
    # 상급자 관계 확인 출력
    print("   📋 상급자 관계:")
    for staff in staffs:
        s_id = staff[0]
        supervisor_s_id = staff[5]
        if supervisor_s_id:
            print(f"      - {staff[2]} ({s_id}) → 상급자: {supervisor_s_id}")
        else:
            print(f"      - {staff[2]} ({s_id}) → 최상급자 (점장)")
    
    return staff_ids


def create_products(conn, kind_ids, color_ids, size_ids, gender_ids, maker_ids):
    """제품 데이터 생성 (이전 SQLite 프로젝트의 더미 데이터 기반)"""
    print("👟 제품 데이터 생성 중...")
    curs = conn.cursor()
    
    # 카테고리 이름 매핑 (이전 SQLite 이름 → MySQL 이름)
    # 카테고리 ID 매핑을 위한 딕셔너리 생성
    color_name_to_id = {}
    curs.execute("SELECT cc_seq, cc_name FROM color_category")
    for row in curs.fetchall():
        color_name_to_id[row[1]] = row[0]
    
    kind_name_to_id = {}
    curs.execute("SELECT kc_seq, kc_name FROM kind_category")
    for row in curs.fetchall():
        kind_name_to_id[row[1]] = row[0]
    
    gender_name_to_id = {}
    curs.execute("SELECT gc_seq, gc_name FROM gender_category")
    for row in curs.fetchall():
        gender_name_to_id[row[1]] = row[0]
    
    size_name_to_id = {}
    curs.execute("SELECT sc_seq, sc_name FROM size_category")
    for row in curs.fetchall():
        size_name_to_id[row[1]] = row[0]
    
    maker_name_to_id = {}
    curs.execute("SELECT m_seq, m_name FROM maker")
    for row in curs.fetchall():
        maker_name_to_id[row[1]] = row[0]
    
    # 이전 SQLite 프로젝트의 제품 기본 정보
    product_bases = [
        # 0: U740WN2 - Black
        {'pName': 'U740WN2', 'pDescription': '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'pColor': 'Black', 'pGender': 'Unisex', 'pCategory': 'Running', 'mfid': 1, 'image': 'images/Newbalnce_U740WN2_Black_01.png'},
        # 1: U740WN2 - Gray
        {'pName': 'U740WN2', 'pDescription': '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'pColor': 'Gray', 'pGender': 'Unisex', 'pCategory': 'Running', 'mfid': 1, 'image': 'images/Newbalnce_U740WN2_Gray_01.png'},
        # 2: U740WN2 - White
        {'pName': 'U740WN2', 'pDescription': '2000년대 러닝화 스타일을 기반으로한 오픈형 니트 메쉬 어퍼는 물론 세분화된 ABZORB 미드솔 그리고 날렵한 실루엣으로 투톤 커러 메쉬와 각진 오버레이로 독특한 시각적 정체성 강조 및 현대적인 컬러웨이들을 담았으며, 기존 팬들과 새로운 세대에게 사랑받는 신발로 새롭게 출시됩니다.', 'pColor': 'White', 'pGender': 'Unisex', 'pCategory': 'Running', 'mfid': 1, 'image': 'images/Newbalnce_U740WN2_White_01.png'},
        # 3: 나이키 샥스 TL - Black
        {'pName': '나이키 샥스 TL', 'pDescription': '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'pColor': 'Black', 'pGender': 'Female', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Shox_TL_Black_01.png'},
        # 4: 나이키 샥스 TL - Gray
        {'pName': '나이키 샥스 TL', 'pDescription': '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'pColor': 'Gray', 'pGender': 'Female', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Shox_TL_Gray_01.png'},
        # 5: 나이키 샥스 TL - White
        {'pName': '나이키 샥스 TL', 'pDescription': '나이키 샥스 TL은 한 단계 진화된 역학적 쿠셔닝을 선사합니다. 2003년의 아이콘을 재해석한 버전으로, 통기성이 우수한 갑피의 메쉬와 전체적으로 적용된 나이키 샥스 기술이 최고의 충격 흡수 기능과 과감한 스트리트 룩을 제공합니다.', 'pColor': 'White', 'pGender': 'Female', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Shox_TL_White_01.png'},
        # 6: 나이키 에어포스 1 - Black
        {'pName': '나이키 에어포스 1', 'pDescription': '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.', 'pColor': 'Black', 'pGender': 'Female', 'pCategory': 'Sneakers', 'mfid': 0, 'image': 'images/Nike_Air_1_Black_01.png'},
        # 7: 나이키 에어포스 1 - Gray
        {'pName': '나이키 에어포스 1', 'pDescription': '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.', 'pColor': 'Gray', 'pGender': 'Female', 'pCategory': 'Sneakers', 'mfid': 0, 'image': 'images/Nike_Air_1_Gray_01.png'},
        # 8: 나이키 에어포스 1 - White
        {'pName': '나이키 에어포스 1', 'pDescription': '편안하고 내구성이 뛰어나며 유행을 타지 않는 고급스러운 스니커즈로, 프리미엄 가죽과 적절하게 배치된 미니 스우시가 클래식 아이템에 세련된 감각을 더해줍니다. 물론 1980년대를 떠올리게 하는 구조와 나이키 에어 쿠셔닝 등 모두가 사랑하는 전설적인 AF1의 룩과 감성은 고스란히 재현했습니다.', 'pColor': 'White', 'pGender': 'Female', 'pCategory': 'Sneakers', 'mfid': 0, 'image': 'images/Nike_Air_1_White_01.png'},
        # 9: 나이키 페가수스 플러스 - Black
        {'pName': '나이키 페가수스 플러스', 'pDescription': '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.', 'pColor': 'Black', 'pGender': 'Male', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Pegasus_Black_01.png'},
        # 10: 나이키 페가수스 플러스 - Gray
        {'pName': '나이키 페가수스 플러스', 'pDescription': '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.', 'pColor': 'Gray', 'pGender': 'Male', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Pegasus_Gray_01.png'},
        # 11: 나이키 페가수스 플러스 - White
        {'pName': '나이키 페가수스 플러스', 'pDescription': '페가수스 플러스로 차원이 다른 반응성과 쿠셔닝을 느껴보세요. 전체적으로 적용된 초경량 줌X 폼이 일상의 러닝에 높은 에너지 반환력을 제공하기 때문에 활력 있게 달릴 수 있습니다. 그리고 신축성 좋은 플라이니트 갑피가 발을 꼭 맞게 감싸 매끄러운 핏을 선사합니다.', 'pColor': 'White', 'pGender': 'Male', 'pCategory': 'Running', 'mfid': 0, 'image': 'images/Nike_Pegasus_White_01.png'},
    ]
    
    # 제품 설정 (사이즈별 가격 정보)
    product_configs = {
        0: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [100000, 110000, 120000, 130000, 140000, 150000, 160000], 'quantity': 30},
        1: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [100500, 101500, 102500, 103500, 104500, 105500, 106500], 'quantity': 30},
        2: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [102000, 102100, 102200, 102300, 102400, 102500, 102600], 'quantity': 30},
        3: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [180000, 181000, 182000, 183000, 184000, 185000, 186000], 'quantity': 30},
        4: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [118000, 123000, 128000, 133000, 138000, 143000, 148000], 'quantity': 30},
        5: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [98000, 99500, 101000, 102500, 104000, 105500, 107000], 'quantity': 30},
        6: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [102000, 103000, 104000, 105000, 106000, 107000, 108000], 'quantity': 30},
        7: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [175000, 178000, 181000, 184000, 187000, 190000, 193000], 'quantity': 30},
        8: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [135000, 140000, 145000, 150000, 155000, 160000, 165000], 'quantity': 30},
        9: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [112000, 115000, 118000, 121000, 124000, 127000, 130000], 'quantity': 30},
        10: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [92000, 94000, 96000, 98000, 100000, 102000, 104000], 'quantity': 30},
        11: {'sizes': [220, 230, 240, 250, 260, 270, 280], 'basePrices': [198000, 202000, 206000, 210000, 214000, 218000, 222000], 'quantity': 30},
    }
    
    # 이름 매핑 (이전 SQLite → MySQL)
    color_mapping = {'Black': '블랙', 'Gray': '그레이', 'White': '화이트'}
    kind_mapping = {'Running': '러닝화', 'Sneakers': '스니커즈'}
    gender_mapping = {'Male': '남성', 'Female': '여성', 'Unisex': '공용'}
    maker_mapping = {0: '나이키', 1: '뉴발란스'}  # mfid → maker 이름
    
    product_ids = []
    created_combinations = set()  # (cc_seq, sc_seq, m_seq) 조합 중복 방지
    
    # 기존 제품 조합 조회
    curs.execute("SELECT cc_seq, sc_seq, m_seq FROM product")
    existing_combinations = set(curs.fetchall())
    created_combinations.update(existing_combinations)
    
    # 제조사 이름으로 ID 찾기 (mfid → maker ID)
    # mfid 0 = Nike → '나이키', mfid 1 = NewBalance → '뉴발란스'
    maker_id_by_name = {}
    for mfid, maker_name in maker_mapping.items():
        if maker_name in maker_name_to_id:
            maker_id_by_name[mfid] = maker_name_to_id[maker_name]
        else:
            print(f"   ⚠️  제조사 '{maker_name}'를 찾을 수 없습니다.")
    
    # 각 제품 기본 정보에 대해 사이즈별로 제품 생성
    for base_idx, product_base in enumerate(product_bases):
        # 카테고리 ID 찾기
        color_name_en = product_base['pColor']
        color_name_ko = color_mapping.get(color_name_en, color_name_en)
        cc_seq = color_name_to_id.get(color_name_ko)
        
        kind_name_en = product_base['pCategory']
        kind_name_ko = kind_mapping.get(kind_name_en, kind_name_en)
        kc_seq = kind_name_to_id.get(kind_name_ko)
        
        gender_name_en = product_base['pGender']
        gender_name_ko = gender_mapping.get(gender_name_en, gender_name_en)
        gc_seq = gender_name_to_id.get(gender_name_ko)
        
        mfid = product_base['mfid']
        m_seq = maker_id_by_name.get(mfid)
        
        if not all([cc_seq, kc_seq, gc_seq, m_seq]):
            print(f"   ⚠️  제품 {base_idx} ({product_base['pName']}) 생성 실패: 카테고리 또는 제조사를 찾을 수 없습니다.")
            continue
        
        # 사이즈별로 제품 생성
        config = product_configs[base_idx]
        for size_idx, size_num in enumerate(config['sizes']):
            size_str = str(size_num)
            sc_seq = size_name_to_id.get(size_str)
            
            if not sc_seq:
                print(f"   ⚠️  사이즈 {size_str}를 찾을 수 없습니다. 건너뜁니다.")
                continue
            
            # UNIQUE 제약조건 체크: (cc_seq, sc_seq, m_seq)
            combination = (cc_seq, sc_seq, m_seq)
            
            # 데이터베이스에서 기존 제품 확인
            curs.execute("""
                SELECT p_seq FROM product 
                WHERE cc_seq = %s AND sc_seq = %s AND m_seq = %s
            """, combination)
            existing = curs.fetchone()
            
            if existing:
                product_ids.append(existing[0])
            else:
                # 새 제품 생성
                p_name = product_base['pName']
                p_description = product_base['pDescription']
                p_price = config['basePrices'][size_idx]
                p_stock = config['quantity']
                p_image = product_base['image']
                
                sql = """
                    INSERT INTO product (kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                curs.execute(sql, (kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description))
                product_ids.append(curs.lastrowid)
                created_combinations.add(combination)
    
    conn.commit()
    print(f"   ✅ {len(product_ids)}개 제품 생성 완료")
    return product_ids


def create_purchase_items(conn, branch_ids, user_ids, product_ids):
    """구매 내역 데이터 생성 (분 단위 그룹화)"""
    print("🛒 구매 내역 데이터 생성 중...")
    curs = conn.cursor()
    
    purchase_item_ids = []
    base_date = datetime.now() - timedelta(days=30)
    
    # 10개의 주문 그룹 생성 (각 그룹당 1-3개 항목)
    for order_num in range(10):
        # 각 주문은 다른 분에 생성 (분 단위 그룹핑을 위해)
        # 날짜는 랜덤하게 선택하되, 시간은 분 단위로 구분
        order_day = base_date + timedelta(days=random.randint(0, 29))
        order_hour = random.randint(9, 20)  # 9시~20시
        order_minute = random.randint(0, 59)  # 0~59분
        # 초는 0~59초 중 랜덤 (같은 분이면 같은 주문으로 묶임)
        order_second = random.randint(0, 59)
        
        # 같은 주문 그룹의 모든 항목은 같은 분에 주문 (초는 다를 수 있음)
        order_datetime = order_day.replace(hour=order_hour, minute=order_minute, second=order_second, microsecond=0)
        
        u_seq = random.choice(user_ids)
        br_seq = random.choice(branch_ids)
        b_status = random.choice(['주문완료', '배송중', '배송완료', '수령완료', None])
        
        # 각 주문당 1-3개 항목 (같은 분, 사용자, 지점)
        item_count = random.randint(1, 3)
        for item_num in range(item_count):
            p_seq = random.choice(product_ids)
            b_price = random.randint(50000, 200000)
            b_quantity = random.randint(1, 3)
            
            # 같은 주문 그룹의 항목들은 같은 분에 주문 (초만 약간 다름)
            # 같은 분 내에서 0~59초 사이의 랜덤한 시간 사용
            item_second = random.randint(0, 59)
            item_datetime = order_datetime.replace(second=item_second)
            
            sql = """
                INSERT INTO purchase_item (br_seq, u_seq, p_seq, b_price, b_quantity, b_date, b_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            curs.execute(sql, (br_seq, u_seq, p_seq, b_price, b_quantity, item_datetime, b_status))
            purchase_item_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(purchase_item_ids)}개 구매 내역 생성 완료 (10개 주문 그룹, 분 단위 그룹화)")
    return purchase_item_ids


def create_pickups(conn, purchase_item_ids):
    """수령 데이터 생성"""
    print("📦 수령 데이터 생성 중...")
    curs = conn.cursor()
    
    pickup_ids = []
    # 일부 구매 내역만 수령 처리
    picked_items = random.sample(purchase_item_ids, min(15, len(purchase_item_ids)))
    
    for b_seq in picked_items:
        # purchase_item에서 u_seq 조회
        curs.execute("SELECT u_seq FROM purchase_item WHERE b_seq = %s", (b_seq,))
        result = curs.fetchone()
        if result:
            u_seq = result[0]
            created_at = datetime.now() - timedelta(days=random.randint(0, 20))
            sql = "INSERT INTO pickup (b_seq, u_seq, created_at) VALUES (%s, %s, %s)"
            curs.execute(sql, (b_seq, u_seq, created_at))
            pickup_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(pickup_ids)}개 수령 기록 생성 완료")
    return pickup_ids


def create_refunds(conn, user_ids, staff_ids, pickup_ids):
    """반품 데이터 생성"""
    print("↩️ 반품 데이터 생성 중...")
    curs = conn.cursor()
    
    refund_ids = []
    # 일부 수령만 반품 처리
    refunded_pickups = random.sample(pickup_ids, min(5, len(pickup_ids)))
    
    reasons = ['사이즈 불일치', '색상 불일치', '제품 불량', '단순 변심', '배송 지연']
    
    for pic_seq in refunded_pickups:
        # 해당 pickup의 user 찾기 (pickup 테이블의 u_seq 사용)
        curs.execute("SELECT p.u_seq FROM pickup p WHERE p.pic_seq = %s", (pic_seq,))
        result = curs.fetchone()
        u_seq = result[0] if result else random.choice(user_ids)
        
        s_seq = random.choice(staff_ids)
        ref_date = datetime.now() - timedelta(days=random.randint(0, 10))
        ref_reason = random.choice(reasons)
        
        sql = """
            INSERT INTO refund (ref_date, ref_reason, u_seq, s_seq, pic_seq)
            VALUES (%s, %s, %s, %s, %s)
        """
        curs.execute(sql, (ref_date, ref_reason, u_seq, s_seq, pic_seq))
        refund_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(refund_ids)}개 반품 기록 생성 완료")
    return refund_ids


def create_receives(conn, staff_ids, product_ids, maker_ids):
    """입고 데이터 생성"""
    print("📥 입고 데이터 생성 중...")
    curs = conn.cursor()
    
    receive_ids = []
    base_date = datetime.now() - timedelta(days=60)
    
    for i in range(20):
        s_seq = random.choice(staff_ids)
        p_seq = random.choice(product_ids)
        # 제품의 제조사 찾기
        curs.execute("SELECT m_seq FROM product WHERE p_seq = %s", (p_seq,))
        result = curs.fetchone()
        m_seq = result[0] if result else random.choice(maker_ids)
        
        rec_quantity = random.randint(10, 100)
        rec_date = base_date + timedelta(days=random.randint(0, 59))
        
        sql = """
            INSERT INTO receive (rec_quantity, rec_date, s_seq, p_seq, m_seq)
            VALUES (%s, %s, %s, %s, %s)
        """
        curs.execute(sql, (rec_quantity, rec_date, s_seq, p_seq, m_seq))
        receive_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(receive_ids)}개 입고 기록 생성 완료")
    return receive_ids


def create_requests(conn, staff_ids, product_ids, maker_ids):
    """발주 데이터 생성"""
    print("📋 발주 데이터 생성 중...")
    curs = conn.cursor()
    
    request_ids = []
    base_date = datetime.now() - timedelta(days=30)
    
    contents = [
        '재고 부족으로 인한 발주 요청',
        '신제품 입고 요청',
        '인기 상품 추가 발주',
        '계절 상품 발주',
        '프로모션 상품 발주'
    ]
    
    for i in range(15):
        s_seq = random.choice(staff_ids)
        p_seq = random.choice(product_ids)
        # 제품의 제조사 찾기
        curs.execute("SELECT m_seq FROM product WHERE p_seq = %s", (p_seq,))
        result = curs.fetchone()
        m_seq = result[0] if result else random.choice(maker_ids)
        
        req_quantity = random.randint(20, 200)
        req_date = base_date + timedelta(days=random.randint(0, 29))
        req_content = random.choice(contents)
        
        # 일부는 결재 완료
        req_manappdate = None
        req_dirappdate = None
        if random.random() > 0.5:
            req_manappdate = req_date + timedelta(days=random.randint(1, 5))
            if random.random() > 0.3:
                req_dirappdate = req_manappdate + timedelta(days=random.randint(1, 3))
        
        s_superseq = staff_ids[0] if len(staff_ids) > 0 else None
        
        sql = """
            INSERT INTO request (req_date, req_content, req_quantity, req_manappdate, req_dirappdate, s_seq, p_seq, m_seq, s_superseq)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (req_date, req_content, req_quantity, req_manappdate, req_dirappdate, s_seq, p_seq, m_seq, s_superseq))
        request_ids.append(curs.lastrowid)
    
    conn.commit()
    print(f"   ✅ {len(request_ids)}개 발주 기록 생성 완료")
    return request_ids


def clear_product_data(conn):
    """제품 관련 데이터만 삭제 (외래 키 제약조건 고려)"""
    print("🗑️  제품 관련 데이터 삭제 중...")
    curs = conn.cursor()
    
    # 외래 키 체크 비활성화
    curs.execute("SET FOREIGN_KEY_CHECKS = 0")
    
    # 제품을 참조하는 테이블 먼저 삭제 (역순)
    product_dependent_tables = [
        'request',      # product 참조
        'receive',      # product 참조
        'pickup',       # purchase_item 참조
        'refund',       # pickup 참조
        'purchase_item', # product 참조
    ]
    
    for table in product_dependent_tables:
        try:
            curs.execute(f"DELETE FROM {table}")
            print(f"   ✅ {table} 데이터 삭제 완료")
        except Exception as e:
            print(f"   ⚠️  {table} 삭제 중 오류: {e}")
    
    # 제품 테이블 삭제
    try:
        curs.execute("DELETE FROM product")
        print(f"   ✅ product 데이터 삭제 완료")
    except Exception as e:
        print(f"   ⚠️  product 삭제 중 오류: {e}")
    
    # 외래 키 체크 재활성화
    curs.execute("SET FOREIGN_KEY_CHECKS = 1")
    conn.commit()
    print("   ✅ 제품 관련 데이터 삭제 완료\n")


def clear_all_data(conn):
    """모든 테이블 데이터 삭제 (외래 키 제약조건 고려)"""
    print("🗑️  기존 데이터 삭제 중...")
    curs = conn.cursor()
    
    # 외래 키 체크 비활성화
    curs.execute("SET FOREIGN_KEY_CHECKS = 0")
    
    # 역순으로 삭제 (외래 키 의존성 고려)
    tables = [
        'request', 'receive', 'refund', 'pickup', 'purchase_item',
        'product', 'user_auth_identities', 'staff', 'user', 'gender_category', 'size_category',
        'color_category', 'kind_category', 'maker', 'branch'
    ]
    
    for table in tables:
        try:
            curs.execute(f"DELETE FROM {table}")
            print(f"   ✅ {table} 데이터 삭제 완료")
        except Exception as e:
            print(f"   ⚠️  {table} 삭제 중 오류: {e}")
    
    # 외래 키 체크 재활성화
    curs.execute("SET FOREIGN_KEY_CHECKS = 1")
    conn.commit()
    print("   ✅ 모든 데이터 삭제 완료\n")


def main():
    print("=" * 60)
    print("🎯 새로운 ERD 구조 더미 데이터 생성 시작")
    print("=" * 60)
    
    conn = connect_db()
    
    try:
        # 기존 데이터 삭제
        clear_all_data(conn)
        
        # 데이터 생성 순서
        branch_ids = create_branches(conn)
        maker_ids = create_makers(conn)
        kind_ids, color_ids, size_ids, gender_ids = create_categories(conn)
        user_ids = create_users(conn)
        staff_ids = create_staffs(conn, branch_ids)
        product_ids = create_products(conn, kind_ids, color_ids, size_ids, gender_ids, maker_ids)
        purchase_item_ids = create_purchase_items(conn, branch_ids, user_ids, product_ids)
        pickup_ids = create_pickups(conn, purchase_item_ids)
        refund_ids = create_refunds(conn, user_ids, staff_ids, pickup_ids)
        receive_ids = create_receives(conn, staff_ids, product_ids, maker_ids)
        request_ids = create_requests(conn, staff_ids, product_ids, maker_ids)
        
        print("\n" + "=" * 60)
        print("✅ 모든 더미 데이터 생성 완료!")
        print("=" * 60)
        print(f"📊 생성된 데이터 요약:")
        print(f"   - 지점: {len(branch_ids)}개")
        print(f"   - 제조사: {len(maker_ids)}개")
        print(f"   - 카테고리: 종류 {len(kind_ids)}개, 색상 {len(color_ids)}개, 사이즈 {len(size_ids)}개, 성별 {len(gender_ids)}개")
        print(f"   - 고객: {len(user_ids)}개")
        print(f"   - 직원: {len(staff_ids)}개")
        print(f"   - 제품: {len(product_ids)}개")
        print(f"   - 구매 내역: {len(purchase_item_ids)}개")
        print(f"   - 수령: {len(pickup_ids)}개")
        print(f"   - 반품: {len(refund_ids)}개")
        print(f"   - 입고: {len(receive_ids)}개")
        print(f"   - 발주: {len(request_ids)}개")
        
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        conn.rollback()
    finally:
        conn.close()


def update_products_only():
    """제품 데이터만 갱신 (기존 제품 관련 데이터 삭제 후 재생성)"""
    print("=" * 60)
    print("🔄 제품 데이터만 갱신 시작")
    print("=" * 60)
    
    conn = connect_db()
    
    try:
        # 제품 관련 데이터 삭제
        clear_product_data(conn)
        
        # 카테고리와 제조사는 기존 데이터 사용 (재생성하지 않음)
        # 카테고리 ID 조회
        curs = conn.cursor()
        curs.execute("SELECT kc_seq FROM kind_category")
        kind_ids = [row[0] for row in curs.fetchall()]
        
        curs.execute("SELECT cc_seq FROM color_category")
        color_ids = [row[0] for row in curs.fetchall()]
        
        curs.execute("SELECT sc_seq FROM size_category")
        size_ids = [row[0] for row in curs.fetchall()]
        
        curs.execute("SELECT gc_seq FROM gender_category")
        gender_ids = [row[0] for row in curs.fetchall()]
        
        curs.execute("SELECT m_seq FROM maker")
        maker_ids = [row[0] for row in curs.fetchall()]
        
        print(f"   📋 기존 카테고리 사용: 종류 {len(kind_ids)}개, 색상 {len(color_ids)}개, 사이즈 {len(size_ids)}개, 성별 {len(gender_ids)}개")
        print(f"   📋 기존 제조사 사용: {len(maker_ids)}개")
        
        # 제품만 재생성
        product_ids = create_products(conn, kind_ids, color_ids, size_ids, gender_ids, maker_ids)
        
        print("\n" + "=" * 60)
        print("✅ 제품 데이터 갱신 완료!")
        print("=" * 60)
        print(f"📊 생성된 제품: {len(product_ids)}개")
        
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        conn.rollback()
    finally:
        conn.close()


if __name__ == "__main__":
    import sys
    
    # 명령줄 인자로 제품만 갱신할지 결정
    if len(sys.argv) > 1 and sys.argv[1] == '--products-only':
        update_products_only()
    else:
        main()

