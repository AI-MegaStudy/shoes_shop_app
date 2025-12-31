"""
UserAuthIdentities API - 사용자 로그인 수단별 인증 정보 CRUD
소셜 로그인 지원을 위한 인증 정보 관리
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
class UserAuthIdentity(BaseModel):
    auth_seq: Optional[int] = None
    u_seq: int
    provider: str  # 'local', 'google', 'kakao' 등
    provider_subject: str  # 제공자별 고유 식별자
    provider_issuer: Optional[str] = None
    email_at_provider: Optional[str] = None
    password: Optional[str] = None  # 로컬 로그인용 비밀번호
    created_at: Optional[str] = None
    last_login_at: Optional[str] = None


# ============================================
# 전체 인증 정보 조회
# ============================================
@router.get("")
async def select_user_auth_identities():
    """전체 사용자 인증 정보 목록을 조회합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT auth_seq, u_seq, provider, provider_subject, provider_issuer, 
                   email_at_provider, password, created_at, last_login_at 
            FROM user_auth_identities 
            ORDER BY auth_seq
        """)
        rows = curs.fetchall()
        conn.close()
        result = []
        for row in rows:
            try:
                created_at = None
                last_login_at = None
                if row[7]:
                    if hasattr(row[7], 'isoformat'):
                        created_at = row[7].isoformat()
                    else:
                        created_at = str(row[7])
                if row[8]:
                    if hasattr(row[8], 'isoformat'):
                        last_login_at = row[8].isoformat()
                    else:
                        last_login_at = str(row[8])
                
                result.append({
                    'auth_seq': row[0],
                    'u_seq': row[1],
                    'provider': row[2],
                    'provider_subject': row[3],
                    'provider_issuer': row[4],
                    'email_at_provider': row[5],
                    'password': row[6],  # 보안상 실제로는 반환하지 않는 것이 좋지만, 현재는 포함
                    'created_at': created_at,
                    'last_login_at': last_login_at
                })
            except Exception as e:
                print(f"Error processing row: {e}, row: {row}")
                continue
        return {"results": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# auth_seq로 인증 정보 조회
# ============================================
@router.get("/{auth_seq}")
async def select_user_auth_identity(auth_seq: int):
    """특정 인증 정보를 auth_seq로 조회합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT auth_seq, u_seq, provider, provider_subject, provider_issuer, 
                   email_at_provider, password, created_at, last_login_at 
            FROM user_auth_identities 
            WHERE auth_seq = %s
        """, (auth_seq,))
        row = curs.fetchone()
        conn.close()
        if row is None:
            return {"result": "Error", "message": "UserAuthIdentity not found"}
        
        created_at = None
        last_login_at = None
        if row[7]:
            if hasattr(row[7], 'isoformat'):
                created_at = row[7].isoformat()
            else:
                created_at = str(row[7])
        if row[8]:
            if hasattr(row[8], 'isoformat'):
                last_login_at = row[8].isoformat()
            else:
                last_login_at = str(row[8])
        
        result = {
            'auth_seq': row[0],
            'u_seq': row[1],
            'provider': row[2],
            'provider_subject': row[3],
            'provider_issuer': row[4],
            'email_at_provider': row[5],
            'password': row[6],
            'created_at': created_at,
            'last_login_at': last_login_at
        }
        return {"result": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 사용자별 인증 정보 조회
# ============================================
@router.get("/user/{user_seq}")
async def select_user_auth_identities_by_user(user_seq: int):
    """특정 사용자의 모든 인증 정보를 조회합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT auth_seq, u_seq, provider, provider_subject, provider_issuer, 
                   email_at_provider, password, created_at, last_login_at 
            FROM user_auth_identities 
            WHERE u_seq = %s
            ORDER BY created_at
        """, (user_seq,))
        rows = curs.fetchall()
        conn.close()
        result = []
        for row in rows:
            try:
                created_at = None
                last_login_at = None
                if row[7]:
                    if hasattr(row[7], 'isoformat'):
                        created_at = row[7].isoformat()
                    else:
                        created_at = str(row[7])
                if row[8]:
                    if hasattr(row[8], 'isoformat'):
                        last_login_at = row[8].isoformat()
                    else:
                        last_login_at = str(row[8])
                
                result.append({
                    'auth_seq': row[0],
                    'u_seq': row[1],
                    'provider': row[2],
                    'provider_subject': row[3],
                    'provider_issuer': row[4],
                    'email_at_provider': row[5],
                    'password': row[6],
                    'created_at': created_at,
                    'last_login_at': last_login_at
                })
            except Exception as e:
                print(f"Error processing row: {e}, row: {row}")
                continue
        return {"results": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 제공자별 인증 정보 조회
# ============================================
@router.get("/provider/{provider}")
async def select_user_auth_identities_by_provider(provider: str):
    """특정 제공자(provider)의 모든 인증 정보를 조회합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT auth_seq, u_seq, provider, provider_subject, provider_issuer, 
                   email_at_provider, password, created_at, last_login_at 
            FROM user_auth_identities 
            WHERE provider = %s
            ORDER BY created_at
        """, (provider,))
        rows = curs.fetchall()
        conn.close()
        result = []
        for row in rows:
            try:
                created_at = None
                last_login_at = None
                if row[7]:
                    if hasattr(row[7], 'isoformat'):
                        created_at = row[7].isoformat()
                    else:
                        created_at = str(row[7])
                if row[8]:
                    if hasattr(row[8], 'isoformat'):
                        last_login_at = row[8].isoformat()
                    else:
                        last_login_at = str(row[8])
                
                result.append({
                    'auth_seq': row[0],
                    'u_seq': row[1],
                    'provider': row[2],
                    'provider_subject': row[3],
                    'provider_issuer': row[4],
                    'email_at_provider': row[5],
                    'password': row[6],
                    'created_at': created_at,
                    'last_login_at': last_login_at
                })
            except Exception as e:
                print(f"Error processing row: {e}, row: {row}")
                continue
        return {"results": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 인증 정보 추가
# ============================================
@router.post("")
async def insert_user_auth_identity(
    u_seq: int = Form(...),
    provider: str = Form(...),
    provider_subject: str = Form(...),
    provider_issuer: Optional[str] = Form(None),
    email_at_provider: Optional[str] = Form(None),
    password: Optional[str] = Form(None),
):
    """새로운 사용자 인증 정보를 추가합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            INSERT INTO user_auth_identities 
            (u_seq, provider, provider_subject, provider_issuer, email_at_provider, password) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (u_seq, provider, provider_subject, provider_issuer, email_at_provider, password))
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        return {"result": "OK", "auth_seq": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 인증 정보 수정
# ============================================
@router.post("/{auth_seq}")
async def update_user_auth_identity(
    auth_seq: int,
    u_seq: int = Form(...),
    provider: str = Form(...),
    provider_subject: str = Form(...),
    provider_issuer: Optional[str] = Form(None),
    email_at_provider: Optional[str] = Form(None),
    password: Optional[str] = Form(None),
):
    """기존 인증 정보를 수정합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            UPDATE user_auth_identities 
            SET u_seq=%s, provider=%s, provider_subject=%s, provider_issuer=%s, 
                email_at_provider=%s, password=%s 
            WHERE auth_seq=%s
        """
        curs.execute(sql, (u_seq, provider, provider_subject, provider_issuer, email_at_provider, password, auth_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 마지막 로그인 시간 업데이트
# ============================================
@router.post("/{auth_seq}/update_login_time")
async def update_last_login_time(auth_seq: int):
    """인증 정보의 마지막 로그인 시간을 업데이트합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            UPDATE user_auth_identities 
            SET last_login_at = NOW() 
            WHERE auth_seq = %s
        """
        curs.execute(sql, (auth_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 인증 정보 삭제
# ============================================
@router.delete("/{auth_seq}")
async def delete_user_auth_identity(auth_seq: int):
    """인증 정보를 삭제합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "DELETE FROM user_auth_identities WHERE auth_seq=%s"
        curs.execute(sql, (auth_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}

