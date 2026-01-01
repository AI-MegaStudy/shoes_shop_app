"""
소셜 로그인 API
- 소셜 로그인 후 사용자 생성/조회
"""

from fastapi import APIRouter, Form
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

