"""
인증 API
- 소셜 로그인 후 사용자 생성/조회
- 로컬 회원가입 (단일 트랜잭션)
"""

from fastapi import APIRouter, Form, UploadFile, File
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.database.connection import connect_db

router = APIRouter()


# ============================================
# 모델 정의
# ============================================
class SocialLoginRequest(BaseModel):
    provider: str  # 'google', 'kakao'
    provider_subject: str  # 구글 sub, 카카오 id
    email: Optional[str] = None
    name: Optional[str] = None
    provider_issuer: Optional[str] = None


# ============================================
# 소셜 로그인
# ============================================
@router.post("/auth/social/login")
async def social_login(
    provider: str = Form(...),
    provider_subject: str = Form(...),
    email: Optional[str] = Form(None),
    name: Optional[str] = Form(None),
    provider_issuer: Optional[str] = Form(None)
):
    """
    소셜 로그인 후 사용자 생성 또는 조회
    - 기존 사용자면 조회하여 반환
    - 신규 사용자면 기본 정보 저장 (u_email, u_name)
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 1. user_auth_identities에서 기존 사용자 확인 (auth_seq도 함께 조회)
        curs.execute("""
            SELECT auth_seq, u_seq
            FROM user_auth_identities 
            WHERE provider = %s AND provider_subject = %s
        """, (provider, provider_subject))
        existing_auth = curs.fetchone()
        
        if existing_auth:
            # 기존 사용자: user 정보 조회
            auth_seq = existing_auth[0]
            user_seq = existing_auth[1]
            curs.execute("""
                SELECT u_seq, u_name, u_email, u_phone, u_address, u_quit_date, created_at
                FROM user 
                WHERE u_seq = %s
            """, (user_seq,))
            user_row = curs.fetchone()
            
            # last_login_at 조회
            curs.execute("""
                SELECT last_login_at
                FROM user_auth_identities
                WHERE auth_seq = %s
            """, (auth_seq,))
            last_login_row = curs.fetchone()
            last_login_at = None
            if last_login_row and last_login_row[0]:
                if hasattr(last_login_row[0], 'isoformat'):
                    last_login_at = last_login_row[0].isoformat()
                else:
                    last_login_at = str(last_login_row[0])
            
            if user_row:
                return {
                    "result": {
                        "u_seq": user_row[0],
                        "u_name": user_row[1],
                        "u_email": user_row[2],
                        "u_phone": user_row[3],
                        "u_address": user_row[4],
                        "u_quit_date": user_row[5].isoformat() if user_row[5] else None,
                        "created_at": user_row[6].isoformat() if user_row[6] else None,
                        "auth_seq": auth_seq,
                        "provider": provider,
                        "provider_subject": provider_subject,
                        "last_login_at": last_login_at
                    },
                    "message": "기존 사용자 로그인 성공"
                }
        
        # 2. 신규 사용자: user 테이블에 기본 정보만 저장
        curs.execute("""
            INSERT INTO user (u_email, u_name, u_phone, u_address)
            VALUES (%s, %s, NULL, NULL)
        """, (email, name))
        user_seq = curs.lastrowid
        
        # 3. user_auth_identities에 소셜 로그인 정보 저장
        curs.execute("""
            INSERT INTO user_auth_identities 
            (u_seq, provider, provider_subject, provider_issuer, email_at_provider)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_seq, provider, provider_subject, provider_issuer, email))
        auth_seq = curs.lastrowid
        
        conn.commit()
        
        return {
            "result": {
                "u_seq": user_seq,
                "u_name": name,
                "u_email": email,
                "u_phone": None,
                "u_address": None,
                "u_quit_date": None,
                "created_at": datetime.now().isoformat(),
                "auth_seq": auth_seq,
                "provider": provider,
                "provider_subject": provider_subject,
                "last_login_at": None
            },
            "message": "소셜 로그인 성공"
        }
        
    except Exception as e:
        conn.rollback()
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()


# ============================================
# 로컬 회원가입
# ============================================
@router.post("/auth/local/signup")
async def local_signup(
    u_email: str = Form(...),
    password: str = Form(...),
    u_name: Optional[str] = Form(None),
    u_phone: Optional[str] = Form(None),
    u_address: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    """
    로컬 회원가입 (단일 트랜잭션)
    - user 테이블과 user_auth_identities 테이블을 하나의 트랜잭션에서 함께 생성
    - 원자성 보장: 둘 다 성공하거나 둘 다 실패
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 1. 이메일 중복 확인
        curs.execute("""
            SELECT u_seq FROM user WHERE u_email = %s
        """, (u_email,))
        existing_user = curs.fetchone()
        
        if existing_user:
            return {
                "result": "Error",
                "errorMsg": "이미 사용 중인 이메일입니다."
            }
        
        # 2. provider_subject 중복 확인 (로컬 로그인의 경우 이메일 = provider_subject)
        curs.execute("""
            SELECT auth_seq FROM user_auth_identities 
            WHERE provider = 'local' AND provider_subject = %s
        """, (u_email,))
        existing_auth = curs.fetchone()
        
        if existing_auth:
            return {
                "result": "Error",
                "errorMsg": "이미 사용 중인 이메일입니다."
            }
        
        # 3. 파일 읽기
        image_data = await file.read()
        
        # 4. user 테이블에 사용자 정보 저장
        curs.execute("""
            INSERT INTO user (u_email, u_name, u_phone, u_address, u_image) 
            VALUES (%s, %s, %s, %s, %s)
        """, (u_email, u_name, u_phone, u_address, image_data))
        user_seq = curs.lastrowid
        
        # 5. user_auth_identities에 로컬 로그인 정보 저장
        # TODO: 향후 비밀번호 해시화 필요 (bcrypt 등)
        curs.execute("""
            INSERT INTO user_auth_identities 
            (u_seq, provider, provider_subject, password) 
            VALUES (%s, %s, %s, %s)
        """, (user_seq, 'local', u_email, password))
        auth_seq = curs.lastrowid
        
        # 6. 트랜잭션 커밋 (하나의 트랜잭션으로 두 테이블 모두 처리)
        conn.commit()
        
        return {
            "result": {
                "u_seq": user_seq,
                "u_name": u_name,
                "u_email": u_email,
                "u_phone": u_phone,
                "u_address": u_address,
                "u_quit_date": None,
                "created_at": datetime.now().isoformat(),
                "auth_seq": auth_seq,
                "provider": "local",
                "provider_subject": u_email,
                "last_login_at": None
            },
            "message": "회원가입 성공"
        }
        
    except Exception as e:
        conn.rollback()
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {
            "result": "Error",
            "errorMsg": error_msg,
            "traceback": traceback.format_exc()
        }
    finally:
        conn.close()

