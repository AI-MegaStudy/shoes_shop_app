"""
Product 복합 쿼리 API
- Product 중심의 JOIN 쿼리들
- Product + 모든 카테고리 (kind, color, size, gender) + Maker

개별 실행: python product_join.py
"""

from fastapi import APIRouter, Query
from typing import Optional
from app.database.connection import connect_db

router = APIRouter()


# ============================================
# Product 목록 + 모든 카테고리 + Maker
# ============================================
@router.get("/with_categories")
async def get_products_with_categories(
    maker_seq: Optional[int] = Query(None, description="제조사 ID (없으면 전체)"),
    kind_seq: Optional[int] = Query(None, description="종류 카테고리 ID"),
    color_seq: Optional[int] = Query(None, description="색상 카테고리 ID"),
    size_seq: Optional[int] = Query(None, description="사이즈 카테고리 ID"),
    gender_seq: Optional[int] = Query(None, description="성별 카테고리 ID")
):
    """
    Product 목록 + 모든 카테고리 + Maker 정보
    JOIN: Product + 모든 카테고리 + Maker
    용도: 제품 목록 화면 (필터링 가능)
    """
    conn = connect_db()
    curs = conn.cursor()
    
    try:
        # 동적 WHERE 절 구성
        conditions = []
        params = []
        
        if maker_seq:
            conditions.append("p.m_seq = %s")
            params.append(maker_seq)
        if kind_seq:
            conditions.append("p.kc_seq = %s")
            params.append(kind_seq)
        if color_seq:
            conditions.append("p.cc_seq = %s")
            params.append(color_seq)
        if size_seq:
            conditions.append("p.sc_seq = %s")
            params.append(size_seq)
        if gender_seq:
            conditions.append("p.gc_seq = %s")
            params.append(gender_seq)
        
        where_clause = "WHERE " + " AND ".join(conditions) if conditions else ""
        
        sql = f"""
        SELECT 
            p.p_seq,
            p.p_name,
            p.p_price,
            p.p_stock,
            p.p_image,
            kc.kc_name,
            cc.cc_name,
            sc.sc_name,
            gc.gc_name,
            m.m_name
        FROM product p
        JOIN kind_category kc ON p.kc_seq = kc.kc_seq
        JOIN color_category cc ON p.cc_seq = cc.cc_seq
        JOIN size_category sc ON p.sc_seq = sc.sc_seq
        JOIN gender_category gc ON p.gc_seq = gc.gc_seq
        JOIN maker m ON p.m_seq = m.m_seq
        {where_clause}
        ORDER BY p.p_seq DESC
        """
        
        curs.execute(sql, tuple(params))
        rows = curs.fetchall()
        
        result = [{
            'p_seq': row[0],
            'p_name': row[1],
            'p_price': row[2],
            'p_stock': row[3],
            'p_image': row[4],
            'kind_name': row[5],
            'color_name': row[6],
            'size_name': row[7],
            'gender_name': row[8],
            'maker_name': row[9]
        } for row in rows]
        
        return {"results": result}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}
    finally:
        conn.close()


# ============================================
# 개별 실행용 (테스트)


# ============================================
# 변경 이력
# ============================================
# 2026-01-01: 
#   - 라우터 경로 수정: prefix(/api/products)를 고려하여 /products/...를 제거
#     - /products/{product_seq}/full_detail → /{product_seq}/full_detail
#     - /products/with_categories → /with_categories
#     - /products/by_maker/{maker_seq}/with_categories → /by_maker/{maker_seq}/with_categories
#     - /products/by_category → /by_category