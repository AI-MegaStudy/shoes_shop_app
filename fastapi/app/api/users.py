"""
User API - 고객 계정 CRUD (Form 방식)
소셜 로그인 지원 버전

변경사항:
- u_id, u_password 제거
- u_email 추가 (필수, UNIQUE)
- u_phone nullable로 변경
"""

from fastapi import APIRouter, Form, UploadFile, File, Response
from pydantic import BaseModel
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()


# ============================================
# 모델 정의
# ============================================
class User(BaseModel):
    u_seq: Optional[int] = None
    u_email: str
    u_name: str
    u_phone: Optional[str] = None
    u_address: Optional[str] = None
    created_at: Optional[str] = None
    u_quit_date: Optional[str] = None


# ============================================
# 전체 고객 조회 (이미지 제외)
# ============================================
@router.get("")
async def select_users():
    """전체 고객 목록을 조회합니다 (이미지 제외)."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT u_seq, u_email, u_name, u_phone, u_address, created_at, u_quit_date 
            FROM user 
            ORDER BY u_seq
        """)
        rows = curs.fetchall()
        conn.close()
        result = []
        for row in rows:
            try:
                created_at = None
                u_quit_date = None
                if row[5]:
                    if hasattr(row[5], 'isoformat'):
                        created_at = row[5].isoformat()
                    else:
                        created_at = str(row[5])
                if row[6]:
                    if hasattr(row[6], 'isoformat'):
                        u_quit_date = row[6].isoformat()
                    else:
                        u_quit_date = str(row[6])
                
                result.append({
                    'u_seq': row[0],
                    'u_email': row[1],
                    'u_name': row[2],
                    'u_phone': row[3],
                    'u_address': row[4],
                    'created_at': created_at,
                    'u_quit_date': u_quit_date
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
# ID로 고객 조회 (이미지 제외)
# ============================================
@router.get("/{user_seq}")
async def select_user(user_seq: int):
    """특정 고객을 ID로 조회합니다 (이미지 제외)."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("""
            SELECT u_seq, u_email, u_name, u_phone, u_address, created_at, u_quit_date 
            FROM user 
            WHERE u_seq = %s
        """, (user_seq,))
        row = curs.fetchone()
        conn.close()
        if row is None:
            return {"result": "Error", "message": "User not found"}
        
        created_at = None
        u_quit_date = None
        if row[5]:
            if hasattr(row[5], 'isoformat'):
                created_at = row[5].isoformat()
            else:
                created_at = str(row[5])
        if row[6]:
            if hasattr(row[6], 'isoformat'):
                u_quit_date = row[6].isoformat()
            else:
                u_quit_date = str(row[6])
        
        result = {
            'u_seq': row[0],
            'u_email': row[1],
            'u_name': row[2],
            'u_phone': row[3],
            'u_address': row[4],
            'created_at': created_at,
            'u_quit_date': u_quit_date
        }
        return {"result": result}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 고객 추가 (이미지 포함 필수 - Form + UploadFile)
# ============================================
@router.post("")
async def insert_user(
    u_email: str = Form(...),
    u_name: str = Form(...),
    u_phone: Optional[str] = Form(None),
    u_address: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    """새로운 고객을 추가합니다 (이미지 포함 필수)."""
    try:
        # 파일 읽기
        image_data = await file.read()
        
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            INSERT INTO user (u_email, u_name, u_phone, u_address, u_image) 
            VALUES (%s, %s, %s, %s, %s)
        """
        curs.execute(sql, (u_email, u_name, u_phone, u_address, image_data))
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        return {"result": "OK", "u_seq": inserted_id}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 고객 수정 (이미지 제외 - Form)
# ============================================
@router.post("/{user_seq}")
async def update_user(
    user_seq: int,
    u_email: str = Form(...),
    u_name: str = Form(...),
    u_phone: Optional[str] = Form(None),
    u_address: Optional[str] = Form(None),
):
    """기존 고객 정보를 수정합니다 (이미지 제외)."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            UPDATE user 
            SET u_email=%s, u_name=%s, u_phone=%s, u_address=%s 
            WHERE u_seq=%s
        """
        curs.execute(sql, (u_email, u_name, u_phone, u_address, user_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 고객 수정 (이미지 포함 - Form + UploadFile)
# ============================================
@router.post("/{user_seq}/with_image")
async def update_user_with_image(
    user_seq: int,
    u_email: str = Form(...),
    u_name: str = Form(...),
    u_phone: Optional[str] = Form(None),
    u_address: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    """기존 고객 정보를 수정합니다 (이미지 포함)."""
    try:
        # 파일 읽기
        image_data = await file.read()
        
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            UPDATE user 
            SET u_email=%s, u_name=%s, u_phone=%s, u_address=%s, u_image=%s 
            WHERE u_seq=%s
        """
        curs.execute(sql, (u_email, u_name, u_phone, u_address, image_data, user_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 프로필 이미지 조회 (Response - 바이너리 직접 반환)
# ============================================
@router.get("/{user_seq}/profile_image")
async def view_user_profile_image(user_seq: int):
    """고객의 프로필 이미지를 조회합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("SELECT u_image FROM user WHERE u_seq = %s", (user_seq,))
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "User not found"}
        
        if row[0] is None:
            return {"result": "Error", "message": "No profile image"}
        
        # Response 객체로 바이너리 직접 반환
        return Response(
            content=row[0],
            media_type="image/jpeg",
            headers={"Cache-Control": "no-cache, no-store, must-revalidate"}
        )
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 프로필 이미지 삭제
# ============================================
@router.delete("/{user_seq}/profile_image")
async def delete_user_profile_image(user_seq: int):
    """고객의 프로필 이미지를 삭제합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE user SET u_image=NULL WHERE u_seq=%s"
        curs.execute(sql, (user_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 고객 삭제
# ============================================
@router.delete("/{user_seq}")
async def delete_user(user_seq: int):
    """고객을 삭제합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "DELETE FROM user WHERE u_seq=%s"
        curs.execute(sql, (user_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}
