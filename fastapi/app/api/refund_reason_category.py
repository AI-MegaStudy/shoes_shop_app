"""
RefundReasonCategory API - 반품 사유 카테고리 CRUD
개별 실행: python refund_reason_category.py
"""

from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
from app_new_form.database.connection import connect_db

router = APIRouter()


# ============================================
# 모델 정의
# ============================================
class RefundReasonCategory(BaseModel):
    ref_re_seq: Optional[int] = None
    ref_re_name: str


# ============================================
# 전체 반품 사유 카테고리 조회
# ============================================
@router.get("")
async def select_refund_reason_categories():
    """전체 반품 사유 카테고리 목록을 조회합니다."""
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT ref_re_seq, ref_re_name 
        FROM refund_reason_category 
        ORDER BY ref_re_seq
    """)
    rows = curs.fetchall()
    conn.close()
    result = [{
        'ref_re_seq': row[0],
        'ref_re_name': row[1]
    } for row in rows]
    return {"results": result}


# ============================================
# ID로 반품 사유 카테고리 조회
# ============================================
@router.get("/{refund_reason_category_seq}")
async def select_refund_reason_category(refund_reason_category_seq: int):
    """특정 반품 사유 카테고리를 ID로 조회합니다."""
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT ref_re_seq, ref_re_name 
        FROM refund_reason_category 
        WHERE ref_re_seq = %s
    """, (refund_reason_category_seq,))
    row = curs.fetchone()
    conn.close()
    if row is None:
        return {"result": "Error", "message": "RefundReasonCategory not found"}
    result = {
        'ref_re_seq': row[0],
        'ref_re_name': row[1]
    }
    return {"result": result}


# ============================================
# 반품 사유 카테고리 추가
# ============================================
@router.post("")
async def insert_refund_reason_category(
    ref_re_name: str = Form(...),
):
    """새로운 반품 사유 카테고리를 추가합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "INSERT INTO refund_reason_category (ref_re_name) VALUES (%s)"
        curs.execute(sql, (ref_re_name,))
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        return {"result": "OK", "ref_re_seq": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 반품 사유 카테고리 수정
# ============================================
@router.post("/{id}")
async def update_refund_reason_category(
    ref_re_seq: int = Form(...),
    ref_re_name: str = Form(...),
):
    """기존 반품 사유 카테고리 정보를 수정합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE refund_reason_category SET ref_re_name=%s WHERE ref_re_seq=%s"
        curs.execute(sql, (ref_re_name, ref_re_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 반품 사유 카테고리 삭제
# ============================================
@router.delete("/{refund_reason_category_seq}")
async def delete_refund_reason_category(refund_reason_category_seq: int):
    """반품 사유 카테고리를 삭제합니다."""
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "DELETE FROM refund_reason_category WHERE ref_re_seq=%s"
        curs.execute(sql, (refund_reason_category_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

