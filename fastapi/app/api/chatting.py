"""
Maker API - 제조사 CRUD
개별 실행: python maker.py
"""

from fastapi import APIRouter, Form
from pydantic import BaseModel
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()


# ============================================
# 모델 정의
# ============================================
class Chatting(BaseModel):
    chatting_seq: Optional[int] = None
    u_seq: int
    u_name: Optional[str] = None
    fb_doc_id: Optional[str] = None
    s_seq: Optional[int] = None
    s_name: Optional[str] = None
    created_at: str
    is_closed: bool


# ============================================
# 전체 제조사 조회
# ============================================
@router.get("")
async def select_chattings():
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
        , u.u_name, s.s_name
        FROM chatting c
        INNER JOIN user u on u.u_seq=c.u_seq
        INNER JOIN staff s on c.s_seq=s.s_seq
        ORDER BY c. created_at DESC
    """)
    rows = curs.fetchall()
    conn.close()
    result = [{
        'chatting_seq': row[0],
        'u_seq': row[1],
        'fb_doc_id': row[2],
        's_seq': row[3],
        'created_at': row[4],
        'is_closed': row[5],
        'u_name' : row[6],
        's_name' : row[7]
    } for row in rows]
    return {"results": result}



@router.get("/by_user_seq")
async def select_chatting(u_seq: int,is_closed:bool):
    print(u_seq)
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
        , u.u_name, s.s_name
        FROM chatting c
        INNER JOIN user u on u.u_seq=c.u_seq
        LEFT JOIN staff s on c.s_seq=s.s_seq
        WHERE c.u_seq=%s
    """,(u_seq,))
    row = curs.fetchone()
    conn.close()
    if row is None:
        return {"result": "Error", "message": "Maker not found"}
    result = {
        'chatting_seq': row[0],
        'u_seq': row[1],
        'fb_doc_id': row[2],
        's_seq': row[3],
        'created_at': row[4],
        'is_closed': row[5],
        'u_name' : row[6],
        's_name' : row[7]
    }
    return {"result": result}


# ============================================
# ID로 제조사 조회
# ============================================
@router.get("/{chatting_seq}")
async def select_chatting(chatting_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
        , u.u_name, s.s_name
        FROM chatting c
        INNER JOIN user u on u.u_seq=c.u_seq
        INNER JOIN staff s on c.s_seq=s.s_seq
        WHERE c.chatting_seq=%s
    """,(chatting_seq,))
    row = curs.fetchone()
    conn.close()
    if row is None:
        return {"result": "Error", "message": "Maker not found"}
    result = {
        'chatting_seq': row[0],
        'u_seq': row[1],
        'fb_doc_id': row[2],
        's_seq': row[3],
        'created_at': row[4],
        'is_closed': row[5],
        'u_name' : row[6],
        's_name' : row[7]
    }
    return {"result": result}



# ============================================
# 제조사 추가
# ============================================
@router.post("")
async def insert_chatting(

    u_seq: int = Form(...),
    fb_doc_id: Optional[str] = Form(None),
    s_seq: Optional[int] = Form(None),
    is_closed: Optional[bool] = Form(None)
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "INSERT INTO chatting (u_seq, fb_doc_id, s_seq,is_closed) VALUES (%s, %s, %s, %s)"
        curs.execute(sql, (u_seq, fb_doc_id, s_seq, is_closed))
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        return {"result": "OK", "chatting_seq": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제조사 수정
# ============================================
@router.post("/{id}")
async def update_chatting(
    chatting_seq: int = Form(...),
    u_seq: int = Form(...),
    fb_doc_id: Optional[str] = Form(None),
    s_seq: Optional[int] = Form(None),
    is_closed: Optional[bool] = Form(None)
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE chatting SET u_seq=%s, fb_doc_id=%s, s_seq=%s, is_closed=%s WHERE chatting_seq=%s"
        curs.execute(sql, (u_seq, fb_doc_id, s_seq, is_closed, chatting_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제조사 삭제
# ============================================
@router.delete("/{chatting_seq}")
async def delete_chatting(chatting_seq: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "DELETE FROM chatting WHERE chatting_seq=%s"
        curs.execute(sql, (chatting_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}

