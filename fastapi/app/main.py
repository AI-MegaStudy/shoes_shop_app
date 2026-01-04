"""
FastAPI 메인 애플리케이션 - 새로운 ERD 구조
모든 모델의 CRUD API 제공 (Form 데이터 방식)
"""

from fastapi import FastAPI
from app.database.connection import connect_db

# 기본 라우터 import
from app.api import branch
from app.api import users
from app.api import user_auth_identities
from app.api import auth
from app.api import staff
from app.api import maker
from app.api import kind_category
from app.api import color_category
from app.api import size_category
from app.api import gender_category
from app.api import refund_reason_category
from app.api import product
from app.api import purchase_item
from app.api import pickup
from app.api import refund

# JOIN 라우터 import
from app.api import product_join
from app.api import refund_join

from app.api import purchase_item_plus
from app.api import pickup_plus
from app.api import refund_plus
from app.api import purchase_item_admin
from app.api import pickup_admin
from app.api import refund_admin

# GT ADDED
# Chatting router
from app.api import chatting

app = FastAPI(title="Shoes Store API - 새로운 ERD 구조")
ip_address = '0.0.0.0'  # 모든 인터페이스에서 접근 가능하도록 변경

# 기본 CRUD 라우터 등록
app.include_router(branch.router, prefix="/api/branches", tags=["branches"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(user_auth_identities.router, prefix="/api/user_auth_identities", tags=["user_auth_identities"])
app.include_router(auth.router, prefix="/api", tags=["auth"])
app.include_router(staff.router, prefix="/api/staff", tags=["staff"])
app.include_router(maker.router, prefix="/api/makers", tags=["makers"])
app.include_router(kind_category.router, prefix="/api/kind_categories", tags=["kind_categories"])
app.include_router(color_category.router, prefix="/api/color_categories", tags=["color_categories"])
app.include_router(size_category.router, prefix="/api/size_categories", tags=["size_categories"])
app.include_router(gender_category.router, prefix="/api/gender_categories", tags=["gender_categories"])
app.include_router(refund_reason_category.router, prefix="/api/refund_reason_categories", tags=["refund_reason_categories"])
# JOIN 라우터 등록 (더 구체적인 경로를 먼저 등록)
app.include_router(product_join.router, prefix="/api/products", tags=["products-join"])

app.include_router(product.router, prefix="/api/products", tags=["products"])
app.include_router(purchase_item.router, prefix="/api/purchase_items", tags=["purchase_items"])
app.include_router(pickup.router, prefix="/api/pickups", tags=["pickups"])
app.include_router(refund.router, prefix="/api/refunds", tags=["refunds"])
app.include_router(refund_join.router, prefix="/api/refunds", tags=["refunds-join"])

app.include_router(purchase_item_plus.router, prefix="/api/purchase_items", tags=["purchase_items-plus"])
app.include_router(pickup_plus.router, prefix="/api/pickups", tags=["pickups-plus"])
app.include_router(refund_plus.router, prefix="/api/refunds", tags=["refunds-plus"])
app.include_router(purchase_item_admin.router, prefix="/api/purchase_items/admin", tags=["purchase_items-admin"])
app.include_router(pickup_admin.router, prefix="/api/pickups/admin", tags=["pickups-admin"])
app.include_router(refund_admin.router, prefix="/api/refunds/admin", tags=["refunds-admin"])

# GT ADDED
app.include_router(chatting.router, prefix="/api/chatting", tags=["chatting"])

@app.get("/")
async def root():
    """루트 엔드포인트"""
    return {
        "message": "Shoes Store API - 새로운 ERD 구조",
        "status": "running",
        "endpoints": {
            "branches": "/api/branches",
            "users": "/api/users",
            "user_auth_identities": "/api/user_auth_identities",
            "staff": "/api/staff",
            "makers": "/api/makers",
            "kind_categories": "/api/kind_categories",
            "color_categories": "/api/color_categories",
            "size_categories": "/api/size_categories",
            "gender_categories": "/api/gender_categories",
            "refund_reason_categories": "/api/refund_reason_categories",
            "products": "/api/products",
            "purchase_items": "/api/purchase_items",
            "pickups": "/api/pickups",
            "refunds": "/api/refunds",
            "chatting": "/api/chatting" # GT ADDED
        },
        "join_endpoints": {
            "products_join": "/api/products/with_categories",
            "refunds_join": "/api/refunds/{id}/with_details, /api/refunds/{id}/full_detail"
        }
    }


@app.get("/health")
async def health_check():
    """헬스 체크"""
    try:
        conn = connect_db()
        conn.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=ip_address, port=8000)


# ============================================
# 변경 이력
# ============================================
# 2026-01-01: 김택권
#   - IP 주소를 0.0.0.0으로 변경하여 iOS 시뮬레이터 및 외부 접근 지원
#   - 라우터 등록 순서 변경: 더 구체적인 경로(product_join, purchase_item_join)를 일반 경로보다 먼저 등록
### 2026-01-03 유다원
# - **관리자 API (Admin API) 섹션 추가**:
#   - `GET /api/purchase_items/admin/all`: 관리자용 전체 구매 내역 조회 (검색 기능 포함)
#   - `GET /api/purchase_items/admin/{purchase_item_seq}/full_detail`: 관리자용 구매 내역 상세 조회
#   - `GET /api/pickups/admin/all`: 관리자용 전체 수령 내역 조회 (검색 기능 포함)
#   - `GET /api/pickups/admin/{pickup_seq}/full_detail`: 관리자용 수령 내역 상세 조회
#   - `GET /api/refunds/admin/all`: 관리자용 전체 반품 내역 조회 (검색 기능 포함)
#   - `GET /api/refunds/admin/{refund_seq}/full_detail`: 관리자용 반품 내역 상세 조회
# - **고객용 Plus API 섹션 추가**:
#   - `GET /api/purchase_items/by_user/{user_seq}/user_bundle`: 고객별 주문 그룹화 조회 (검색 및 정렬 기능 포함)
#   - `GET /api/pickups/by_user/{user_seq}/all`: 고객별 수령 내역 조회 (검색 및 정렬 기능 포함)
#   - `GET /api/refunds/refund/by_user/{user_seq}/all`: 고객별 반품 내역 조회 (검색 및 정렬 기능 포함)
# - **API 개요 업데이트**: 관리자 API 및 고객용 Plus API 추가 반영
# 2026-01-04: 이광태
#   신규 라우터 등록:
#   - chatting