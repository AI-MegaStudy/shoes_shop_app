from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()

# 작성자: 유다원
# 작성일자: 2026.01.01

# ============================================
# 고객별 PurchaseItem 목록 + 상세 정보 (주문 일자 분 단위로 그룹화)
# ============================================
@router.get("/purchase_items/by_user/{user_seq}/user_bundle")
async def get_purchase_items_by_user_with_details(user_seq: int):
    
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        sql = """
        SELECT 
            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            DATE_FORMAT(pi.b_date, '%%Y-%%m-%%d %%H:%%i'),
            pi.b_status,

            u.u_seq,
            u.u_email,
            u.u_name,
            u.u_phone,

            p.p_seq,
            p.p_name,
            p.p_price,
            p.p_stock,
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

        FROM purchase_item pi

        JOIN product p ON pi.p_seq = p.p_seq
        JOIN user u ON pi.u_seq = u.u_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq

        WHERE pi.u_seq = %s

        ORDER BY pi.b_date DESC, pi.b_seq DESC
        """
        curs.execute(sql, (user_seq,))
        rows = curs.fetchall()
        
        result = [
            {
            'b_seq': row[0],
            'b_price': row[1],
            'b_quantity': row[2],
            'b_date': row[3],
            'b_status': row[4],

            'u_seq': row[5],
            'u_email': row[6],
            'u_name': row[7],
            'u_phone': row[8],

            'p_seq': row[9],
            'p_name': row[10],
            'p_price': row[11],
            'p_stock': row[12],
            'p_image': row[13],
            
            'kc_name': row[14],
            'cc_name': row[15],
            'sc_name': row[16],
            'gc_name': row[17],
            'm_name': row[18],

            'br_seq': row[19],
            'br_name': row[20],
            'br_address': row[21],
            'br_phone': row[22]
        } for row in rows]
        
        return {"results": result}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()