from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()

# 작성자: 임소연
# 작성일자: 2026-01-02

# ============================================
# 관리자 페이지 - Pickup 전체 목록 조회
# ============================================
@router.get("/all")
async def get_pickup_all(search: Optional[str] = None):
    """
    Pickup의 전체 상세 정보
    JOIN: Pickup + PurchaseItem + User + Product + Branch + 모든 카테고리 + Maker (10테이블)
    용도: 관리자 수령 화면
    """
    conn = connect_db()
    curs = conn.cursor()
    
    where_sql = ''
    params = []

    if search:
        if search.isdigit():
            where_sql = 'WHERE pic.pic_seq = %s'
            params.append(int(search))
        else:
            where_sql = 'WHERE u.u_name LIKE %s'
            params.append(f"%{search}%")

    try:
        sql = f"""
        SELECT 
            pic.pic_seq,
            pic.created_at,
            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            pi.b_date,
            pi.b_status,
            u.u_seq,
            u.u_name,
            u.u_phone,
            p.p_seq,
            p.p_name,
            p.p_price,
            p.p_image,
            kc.kc_name,
            cc.cc_name,
            sc.sc_name,
            gc.gc_name,
            m.m_name,
            br.br_seq,
            br.br_name,
            br.br_address,
            br.br_phone
        FROM pickup pic
        JOIN purchase_item pi ON pic.b_seq = pi.b_seq
        JOIN user u ON pi.u_seq = u.u_seq
        JOIN product p ON pi.p_seq = p.p_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        {where_sql}
        ORDER BY pic_seq DESC
        """
        curs.execute(sql, params)
        rows = curs.fetchall()

        result = [
        {
            'pic_seq': row[0],
            'created_at': row[1].isoformat() if row[1] else None,
            'b_seq': row[2],
            'b_price': row[3],
            'b_quantity': row[4],
            'b_date': row[5].isoformat() if row[5] else None,
            'b_status': row[6],
            'u_seq': row[7],
            'u_name': row[8],
            'u_phone': row[9],
            'p_seq': row[10],
            'p_name': row[11],
            'p_price': row[12],
            'p_image': row[13],
            'kind_name': row[14],
            'color_name': row[15],
            'size_name': row[16],
            'gender_name': row[17],
            'maker_name': row[18],
            'br_seq': row[19],
            'br_name': row[20],
            'br_address': row[21],
            'br_phone': row[22]
        } for row in rows]
        
        return {"result": result}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()

# ============================================
# ID로 수령 내역 조회
# ============================================
@router.get("/{pickup_seq}/full_detail")
async def get_pickup_all(pickup_seq: int):
    """
    Pickup의 전체 상세 정보
    JOIN: Pickup + PurchaseItem + User + Product + Branch + 모든 카테고리 + Maker (10테이블)
    용도: 관리자 수령 화면
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        sql = """
        SELECT 
            pic.pic_seq,
            pic.created_at,
            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            pi.b_date,
            pi.b_status,
            u.u_seq,
            u.u_name,
            u.u_phone,
            p.p_seq,
            p.p_name,
            p.p_price,
            p.p_image,
            kc.kc_name,
            cc.cc_name,
            sc.sc_name,
            gc.gc_name,
            m.m_name,
            br.br_seq,
            br.br_name,
            br.br_address,
            br.br_phone
        FROM pickup pic
        JOIN purchase_item pi ON pic.b_seq = pi.b_seq
        JOIN user u ON pi.u_seq = u.u_seq
        JOIN product p ON pi.p_seq = p.p_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        WHERE pic.pic_seq = %s
        """
        curs.execute(sql, (pickup_seq))
        row = curs.fetchone()
        
        if row is None:
            return {"result": "Error", "message": "PurchaseItem not found"}

        result = {
            'pic_seq': row[0],
            'created_at': row[1].isoformat() if row[1] else None,
            'b_seq': row[2],
            'b_price': row[3],
            'b_quantity': row[4],
            'b_date': row[5].isoformat() if row[5] else None,
            'b_status': row[6],
            'u_seq': row[7],
            'u_name': row[8],
            'u_phone': row[9],
            'p_seq': row[10],
            'p_name': row[11],
            'p_price': row[12],
            'p_image': row[13],
            'kind_name': row[14],
            'color_name': row[15],
            'size_name': row[16],
            'gender_name': row[17],
            'maker_name': row[18],
            'br_seq': row[19],
            'br_name': row[20],
            'br_address': row[21],
            'br_phone': row[22]
        }
        
        return {"result": result}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()


