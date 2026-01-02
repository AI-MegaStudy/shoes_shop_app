from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()

# 작성자: 유다원
# 작성일자: 2026.01.02

# ============================================
# 고객별 Pickup 목록 + 상세 정보
# ============================================

@router.get("/refund/by_user/{user_seq}/all")
async def get_refunds_by_user_with_details(
    user_seq: int,
    keyword: Optional[str] = None,
    order: str = "최신순",
):
    conn = connect_db()
    curs = conn.cursor()

    where_sql = "WHERE ref.u_seq = %s"
    params = [user_seq]

    ORDER_MAP = {
        "최신순": "ref.ref_date DESC, ref.ref_seq DESC",
        "오래된 순": "ref.ref_date ASC, ref.ref_seq DESC",
        "가격 높은순": "pi.b_price DESC, pi.b_seq DESC",
        "가격 낮은순": "pi.b_price ASC, pi.b_seq DESC",
    }

    if keyword:
        where_sql += " AND (p.p_name LIKE %s OR m.m_name LIKE %s)"
        params.append(f"%{keyword}%")
        params.append(f"%{keyword}%")

    order_sql = ORDER_MAP.get(order)

    try:
        sql = f"""
        SELECT
            ref.ref_seq,
            DATE_FORMAT(ref.ref_date, '%%Y-%%m-%%d %%H:%%i') AS ref_date,
            ref.ref_re_count,

            rrc.ref_re_seq,
            rrc.ref_re_name,

            u.u_seq,
            u.u_email,
            u.u_name,
            u.u_phone,

            s.s_seq,
            s.s_name,
            s.s_rank,
            s.s_phone,

            pic.pic_seq,
            DATE_FORMAT(pic.created_at, '%%Y-%%m-%%d %%H:%%i') AS pic_created_at,

            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            DATE_FORMAT(pi.b_date, '%%Y-%%m-%%d %%H:%%i') AS b_date,
            pi.b_status,

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

        FROM refund ref
        JOIN ref_reason_category rrc ON ref.ref_reason = rrc.ref_re_seq
        JOIN user u ON ref.u_seq = u.u_seq
        JOIN staff s ON ref.s_seq = s.s_seq
        JOIN pickup pic ON ref.pic_seq = pic.pic_seq
        JOIN purchase_item pi ON pic.pic_seq = pi.pic_seq
        JOIN product p ON pi.p_seq = p.p_seq
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

        result = [{
            'ref_seq': row[0],
            'ref_date': row[1],
            'ref_re_count': row[2],

            'ref_re_seq': row[3],
            'ref_re_name': row[4],

            'u_seq': row[5],
            'u_email': row[6],
            'u_name': row[7],
            'u_phone': row[8],

            's_seq': row[9],
            's_name': row[10],
            's_rank': row[11],
            's_phone': row[12],

            'pic_seq': row[13],
            'pic_created_at': row[14],

            'b_seq': row[15],
            'b_price': row[16],
            'b_quantity': row[17],
            'b_date': row[18],
            'b_status': row[19],

            'p_seq': row[20],
            'p_name': row[21],
            'p_price': row[22],
            'p_stock': row[23],
            'p_image': row[24],

            'kc_name': row[25],
            'cc_name': row[26],
            'sc_name': row[27],
            'gc_name': row[28],
            'm_name': row[29],

            'br_seq': row[30],
            'br_name': row[31],
            'br_address': row[32],
            'br_phone': row[33],
        } for row in rows]

        return {"results": result}

    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()