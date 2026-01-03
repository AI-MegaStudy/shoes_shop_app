# Purchase Item API 체크리스트

**작성일**: 2026-01-01  
**작성자**: 김택권  
**파일**: `fastapi/app/api/purchase_item.py`  
**경로**: `/api/purchase_items`

---

## 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | |
| 작성일 | |
| 완료일 | |

---

## 컬럼 설명

| 컬럼명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `b_seq` | INT | ✅ | 구매 고유 ID(PK), AUTO_INCREMENT |
| `br_seq` | INT | ✅ | 수령 지점 ID(FK) → branch.br_seq |
| `u_seq` | INT | ✅ | 구매 고객 ID(FK) → user.u_seq |
| `p_seq` | INT | ✅ | 구매 제품 ID(FK) → product.p_seq |
| `b_price` | INT | | 구매 당시 가격 (DEFAULT 0) |
| `b_quantity` | INT | | 구매 수량 (DEFAULT 1) |
| `b_date` | DATETIME | ✅ | 구매 일시 |
| `b_tnum` | VARCHAR(100) | | 결제 트랜잭션 번호 |
| `b_status` | VARCHAR(50) | | 상품주문상태 (주문완료, 배송중, 배송완료, 수령완료, NULL) |

**참고**: 
- 주문 그룹화: `b_date` 기준으로 분 단위(YYYY-MM-DD HH:MM)로 그룹화
- 같은 분, 같은 고객, 같은 지점의 구매는 하나의 주문으로 처리

---

## API 목록

| API | 엔드포인트 | 완료 |
|-----|-----------|------|
| Read (전체) | `GET /api/purchase_items` | [ ] |
| Read (단일) | `GET /api/purchase_items/{purchase_item_seq}` | [ ] |
| Read (고객별) | `GET /api/purchase_items/by_user/{user_seq}` | [ ] |
| Read (분 단위 그룹화) | `GET /api/purchase_items/by_datetime` | [ ] |
| Create | `POST /api/purchase_items` | [ ] |
| Update | `POST /api/purchase_items/{id}` | [ ] |
| Delete | `DELETE /api/purchase_items/{purchase_item_seq}` | [ ] |

---

## 수정 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2026-01-01 | 김택권 | 체크리스트 최초 작성 |

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-01-01  
**최종 수정자**: 김택권

