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
async def select_chatting(u_seq: int, is_closed: bool):
    """
    고객별 채팅 세션 조회
    - is_closed=False: 열린 채팅방을 찾고, 없으면 닫힌 채팅방을 다시 열어서 반환
    - is_closed=True: 닫힌 채팅방만 조회
    """
    conn = connect_db()
    curs = conn.cursor()
    
    if is_closed == False:
        # 열린 채팅방 먼저 찾기
        curs.execute("""
            SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
            , u.u_name, s.s_name
            FROM chatting c
            INNER JOIN user u on u.u_seq=c.u_seq
            LEFT JOIN staff s on c.s_seq=s.s_seq
            WHERE c.u_seq=%s AND c.is_closed=0
            ORDER BY c.created_at DESC
            LIMIT 1
        """, (u_seq,))
        row = curs.fetchone()
        
        # 열린 채팅방이 없으면 닫힌 채팅방 찾기
        if row is None:
            curs.execute("""
                SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
                , u.u_name, s.s_name
                FROM chatting c
                INNER JOIN user u on u.u_seq=c.u_seq
                LEFT JOIN staff s on c.s_seq=s.s_seq
                WHERE c.u_seq=%s AND c.is_closed=1
                ORDER BY c.created_at DESC
                LIMIT 1
            """, (u_seq,))
            row = curs.fetchone()
            
            # 닫힌 채팅방을 찾으면 다시 열기
            if row is not None:
                chatting_seq = row[0]
                curs.execute("""
                    UPDATE chatting SET is_closed=0 WHERE chatting_seq=%s
                """, (chatting_seq,))
                conn.commit()
                # 업데이트 후 다시 조회
                curs.execute("""
                    SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
                    , u.u_name, s.s_name
                    FROM chatting c
                    INNER JOIN user u on u.u_seq=c.u_seq
                    LEFT JOIN staff s on c.s_seq=s.s_seq
                    WHERE c.chatting_seq=%s
                """, (chatting_seq,))
                row = curs.fetchone()
    else:
        # 닫힌 채팅방만 조회
        curs.execute("""
            SELECT c.chatting_seq, c.u_seq, c.fb_doc_id, c.s_seq, c.created_at, c.is_closed
            , u.u_name, s.s_name
            FROM chatting c
            INNER JOIN user u on u.u_seq=c.u_seq
            LEFT JOIN staff s on c.s_seq=s.s_seq
            WHERE c.u_seq=%s AND c.is_closed=1
            ORDER BY c.created_at DESC
            LIMIT 1
        """, (u_seq,))
        row = curs.fetchone()
    
    conn.close()
    
    if row is None:
        return {"result": "Error", "message": "Chatting not found"}
    
    result = {
        'chatting_seq': row[0],
        'u_seq': row[1],
        'fb_doc_id': row[2],
        's_seq': row[3],
        'created_at': row[4],
        'is_closed': row[5],
        'u_name': row[6],
        's_name': row[7]
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

