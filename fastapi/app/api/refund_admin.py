from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()

# 작성자: 임소연
# 작성일자: 2026-01-02

# ============================================
# 관리자 페이지 - Refund 전체 목록 조회
# ============================================
@router.get("/all")
async def get_refund_all(search: Optional[str] = None):
    conn = connect_db()
    curs = conn.cursor()

    where_sql = ''
    params = []

    if search:
        if search.isdigit():
            where_sql = 'WHERE ref.ref_seq = %s'
            params.append(int(search))
        else:
            where_sql = 'WHERE u.u_name LIKE %s'
            params.append(f"%{search}%")

    
    try:
        sql = f"""
        SELECT 
            ref.ref_seq,
            ref.ref_date,
            ref.ref_reason,
            u.u_seq,
            u.u_name,
            u.u_phone,
            u.u_email,
            s.s_seq,
            s.s_rank,
            s.s_phone,
            pic.pic_seq,
            pic.created_at,
            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            pi.b_date,
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
            br.br_address
        FROM refund ref
        JOIN user u ON ref.u_seq = u.u_seq
        JOIN staff s ON ref.s_seq = s.s_seq
        JOIN pickup pic ON ref.pic_seq = pic.pic_seq
        JOIN purchase_item pi ON pic.b_seq = pi.b_seq
        JOIN product p ON pi.p_seq = p.p_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        {where_sql}
        """
        curs.execute(sql, params)
        rows = curs.fetchall()
        
        # fetchall()은 결과가 없을 때 빈 리스트 []를 반환하므로 None 체크는 불필요
        result = [
        {
            'ref_seq': row[0],
            'ref_date': row[1].isoformat() if row[1] else None,
            'ref_reason': row[2],
            'u_seq': row[3],
            'u_name': row[4],
            'u_phone': row[5],
            'u_email': row[6],  # row[5] 중복 수정
            's_seq': row[7],
            's_rank': row[8],
            's_phone': row[9],
            'pic_seq': row[10],
            'created_at': row[11].isoformat() if row[11] else None,
            'b_seq': row[12],
            'b_price': row[13],
            'b_quantity': row[14],
            'b_date': row[15].isoformat() if row[15] else None,
            'p_seq': row[16],
            'p_name': row[17],
            'p_price': row[18],
            'p_image': row[19],
            'kind_name': row[20],
            'color_name': row[21],
            'size_name': row[22],
            'gender_name': row[23],
            'maker_name': row[24],
            'br_seq': row[25],
            'br_name': row[26],
            'br_address': row[27]
        } for row in rows]
        
        return {"results": result}
    except Exception as e:
        # 에러 발생 시 results를 빈 리스트로 반환 (문자열 "Error"가 아닌)
        print(f"Error in get_refund_all: {e}")
        return {"results": [], "result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()


# ============================================
# 관리자 페이지 - Refund 상세 정보 조회
# ============================================
@router.get("/{ref_seq}/full_detail")
async def get_refund_all(ref_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        sql = """
        SELECT 
            ref.ref_seq,
            ref.ref_date,
            ref.ref_reason,
            u.u_seq,
            u.u_name,
            u.u_phone,
            u.u_email,
            s.s_seq,
            s.s_rank,
            s.s_phone,
            pic.pic_seq,
            pic.created_at,
            pi.b_seq,
            pi.b_price,
            pi.b_quantity,
            pi.b_date,
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
            br.br_address
        FROM refund ref
        JOIN user u ON ref.u_seq = u.u_seq
        JOIN staff s ON ref.s_seq = s.s_seq
        JOIN pickup pic ON ref.pic_seq = pic.pic_seq
        JOIN purchase_item pi ON pic.b_seq = pi.b_seq
        JOIN product p ON pi.p_seq = p.p_seq
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq
        JOIN branch br ON pi.br_seq = br.br_seq
        WHERE ref.ref_seq = %s

        """
        curs.execute(sql, (ref_seq))
        row = curs.fetchone()
        
        if row is None:
            return {"results": "Error", "message": "Refund not found"}
        
        result = {
            'ref_seq': row[0],
            'ref_date': row[1].isoformat() if row[1] else None,
            'ref_reason': row[2],
            'u_seq': row[3],
            'u_name': row[4],
            'u_phone': row[5],
            'u_email': row[6],
            's_seq': row[7],
            's_rank': row[8],
            's_phone': row[9],
            'pic_seq': row[10],
            'created_at': row[11].isoformat() if row[11] else None,
            'b_seq': row[12],
            'b_price': row[13],
            'b_quantity': row[14],
            'b_date': row[15].isoformat() if row[15] else None,
            'p_seq': row[16],
            'p_name': row[17],
            'p_price': row[18],
            'p_image': row[19],
            'kind_name': row[20],
            'color_name': row[21],
            'size_name': row[22],
            'gender_name': row[23],
            'maker_name': row[24],
            'br_seq': row[25],
            'br_name': row[26],
            'br_address': row[27]
        }
        
        return {"results": result}
    except Exception as e:
        return {"results": "Error", "errorMsg": str(e)}
    finally:
        conn.close()