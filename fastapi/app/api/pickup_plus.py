from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()

# 작성자: 유다원
# 작성일자: 2026.01.02

# ============================================
# 고객별 Pickup 목록 + 상세 정보
# ============================================

@router.get("/by_user/{user_seq}/all")
async def get_pickups_by_user_with_details(
    user_seq: int,
    keyword: Optional[str] = None,
    order: str = "최신순",
):

    conn = connect_db()
    curs = conn.cursor()

    where_sql = "WHERE pi.u_seq = %s AND pi.b_status = '2'"
    params = [user_seq]
    ORDER_MAP = {
        "최신순": "pic.created_at DESC, pic.pic_seq DESC",
        "오래된 순": "pic.created_at ASC, pi.b_seq DESC",
        "가격 높은순": "pi.b_price DESC, pi.b_seq DESC",
        "가격 낮은순": "pi.b_price ASC, pi.b_seq DESC",
    }

    # 검색어
    if keyword:
        where_sql += " AND (p.p_name LIKE %s OR m.m_name LIKE %s)"
        params.append(f"%{keyword}%")
        params.append(f"%{keyword}%")

    # 정렬
    order_sql = ORDER_MAP.get(order)

    try:
        sql = f"""
        SELECT
            pic.pic_seq,
            pic.created_at,

            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            DATE_FORMAT(pi.b_date, '%%Y-%%m-%%d %%H:%%i') AS b_date,
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

        FROM pickup pic
        JOIN purchase_item pi ON pic.b_seq = pi.b_seq
        JOIN product p ON pi.p_seq = p.p_seq
        JOIN user u ON pi.u_seq = u.u_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq

        {where_sql}

        ORDER BY {order_sql}
        """

        curs.execute(sql, params)
        rows = curs.fetchall()

        grouped = {}

        result = [{
            'pic_seq': row[0],
            'pic_created_at': row[1],

            'b_seq': row[2],
            'b_price': row[3],
            'b_quantity': row[4],
            'b_date': row[5],
            'b_status': row[6],

            'u_seq': row[7],
            'u_email': row[8],
            'u_name': row[9],
            'u_phone': row[10],

            'p_seq': row[11],
            'p_name': row[12],
            'p_price': row[13],
            'p_stock': row[14],
            'p_image': row[15],

            'kc_name': row[16],
            'cc_name': row[17],
            'sc_name': row[18],
            'gc_name': row[19],
            'm_name': row[20],

            'br_seq': row[21],
            'br_name': row[22],
            'br_address': row[23],
            'br_phone': row[24]
        } for row in rows ]

        return {"results": result}

    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()