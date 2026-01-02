"""
Product API - 제품 CRUD
개별 실행: python product.py
"""

from fastapi import APIRouter, Form, UploadFile, File, Response
from pydantic import BaseModel
from typing import Optional
from app.database.connection import connect_db
from pathlib import Path
import os
import httpx

router = APIRouter()

# ============================================
# PHP 웹서버 설정
# ============================================
# 환경 변수에서 경로를 읽어오고, 없으면 기본값 사용
# 환경 변수 설정 예시:
#   export PHP_MODEL_DIR="/var/www/html/model"
#   export PHP_WEB_SERVER_URL="https://yourdomain.com"
#   export PHP_MODEL_FILE="model.php"

# PHP 웹서버 디렉토리 경로 설정
# 확인된 DOCUMENT_ROOT: /share/Web (phpinfo.php에서 확인)
# - model 디렉토리: /share/Web/model (GLB 파일용)
# - images 디렉토리: /share/Web/images (제품 이미지용)

# GLB 모델 파일 디렉토리
PHP_MODEL_DIR_STR = os.getenv("PHP_MODEL_DIR", "/share/Web/model")
PHP_MODEL_DIR = Path(PHP_MODEL_DIR_STR)

# 제품 이미지 디렉토리
PHP_IMAGES_DIR_STR = os.getenv("PHP_IMAGES_DIR", "/share/Web/images")
PHP_IMAGES_DIR = Path(PHP_IMAGES_DIR_STR)

# PHP 웹서버 Base URL (파일 접근용)
# 확인된 URL: https://cheng80.myqnapcloud.com
PHP_WEB_SERVER_URL = os.getenv("PHP_WEB_SERVER_URL", "https://cheng80.myqnapcloud.com")

# PHP 파일명 (GLB 파일 제공용)
PHP_MODEL_FILE = os.getenv("PHP_MODEL_FILE", "model.php")

# PHP 업로드 스크립트 URL
PHP_UPLOAD_IMAGE_SCRIPT = os.getenv("PHP_UPLOAD_IMAGE_SCRIPT", f"{PHP_WEB_SERVER_URL}/upload_image.php")
PHP_UPLOAD_MODEL_SCRIPT = os.getenv("PHP_UPLOAD_MODEL_SCRIPT", f"{PHP_WEB_SERVER_URL}/upload_model.php")

# 경로가 설정되지 않았을 때 경고 출력 (기본값이 설정되어 있으므로 경고 불필요)
# 필요시 환경 변수로 오버라이드 가능:
# export PHP_MODEL_DIR="/share/Web/model"

# PHP_WEB_SERVER_URL은 기본값으로 설정되어 있으므로 경고 불필요


# ============================================
# 모델 정의
# ============================================
class Product(BaseModel):
    p_seq: Optional[int] = None
    kc_seq: int
    cc_seq: int
    sc_seq: int
    gc_seq: int
    m_seq: int
    p_name: Optional[str] = None
    p_price: int = 0
    p_stock: int = 0
    p_image: Optional[str] = None
    p_description: Optional[str] = None
    created_at: Optional[str] = None


# ============================================
# 전체 GROUP BY 제품 조회
# ============================================
@router.get("/group_by_name")
async def select_products_by_name():
    conn = connect_db()
    curs = conn.cursor()
    
    # original soruce
    # curs.execute("""
    #     SELECT p_seq, kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description, created_at 
    #     FROM product 
    #     ORDER BY p_seq
    # """)
    # rows = curs.fetchall()
    #      ,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
    curs.execute("""
                 
        select p.p_name, p.cc_seq, p.m_seq, cc.cc_name, ma.m_name,p.p_image
                
        from product p 
        inner join color_category cc on p.cc_seq=cc.cc_seq
        inner join gender_category gc on p.gc_seq=gc.gc_seq
        inner join size_category sc on p.sc_seq=sc.sc_seq
        inner join maker ma on p.m_seq=ma.m_seq
        group by p.p_name,p.cc_seq,p.m_seq,p.p_image                
    """)
    
    rows = curs.fetchall()

  
    result = [{
        'p_seq': -1,
        'kc_seq': -1,
        'cc_seq': row[1],
        'sc_seq': -1,
        'gc_seq': -1,
        'm_seq': row[2],
        'p_name': row[0],
        'p_price': -1,
        'p_stock': -1,
        'p_image': row[5],
        'p_description': '',
        'created_at': None,
        'p_color': row[3],
        'p_size': '',
        'p_gender': '',
        'p_maker': row[4],
    } for row in rows]
    return {"results": result}




# ============================================
# 전체 제품 조회
# ============================================
@router.get("")
async def select_products():
    conn = connect_db()
    curs = conn.cursor()
    
    # original soruce
    # curs.execute("""
    #     SELECT p_seq, kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description, created_at 
    #     FROM product 
    #     ORDER BY p_seq
    # """)
    # rows = curs.fetchall()

    curs.execute("""
        select
            p.p_seq, p.kc_seq, p.cc_seq, p.sc_seq, p.gc_seq, p.m_seq, p.p_name, p.p_price, p.p_stock, p.p_image, p.p_description, p.created_at  
            ,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
        from product p 
        inner join color_category cc on p.cc_seq=cc.cc_seq
        inner join gender_category gc on p.gc_seq=gc.gc_seq
        inner join size_category sc on p.sc_seq=sc.sc_seq
        inner join maker ma on p.m_seq=ma.m_seq                
    """)
    
    rows = curs.fetchall()

  
    result = [{
        'p_seq': row[0],
        'kc_seq': row[1],
        'cc_seq': row[2],
        'sc_seq': row[3],
        'gc_seq': row[4],
        'm_seq': row[5],
        'p_name': row[6],
        'p_price': row[7],
        'p_stock': row[8],
        'p_image': row[9],
        'p_description': row[10],
        'created_at': row[11].isoformat() if row[11] else None,
        'p_color': row[12],
        'p_size': row[13],
        'p_gender': row[14],
        'p_maker': row[15],
    } for row in rows]
    return {"results": result}


# ============================================
# ID로 제품 조회
# ============================================
@router.get("/id/{product_seq}")
async def select_product(product_seq: int):
    conn = connect_db()
    curs = conn.cursor()

    # original source 
    # curs.execute("""
    #     SELECT p_seq, kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description, created_at 
    #     FROM product 
    #     WHERE p_seq = %s
    # """, (product_seq,))

    curs.execute("""
        select
            p.p_seq, p.kc_seq, p.cc_seq, p.sc_seq, p.gc_seq, p.m_seq, p.p_name, p.p_price, p.p_stock, p.p_image, p.p_description, p.created_at  
            ,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
        from product p 
        inner join color_category cc on p.cc_seq=cc.cc_seq
        inner join gender_category gc on p.gc_seq=gc.gc_seq
        inner join size_category sc on p.sc_seq=sc.sc_seq
        inner join maker ma on p.m_seq=ma.m_seq
        WHERE p.p_seq = %s
        ORDER BY p.p_seq
    """,(product_seq,))

    row = curs.fetchone()
    conn.close()
    if row is None:
        return {"result": "Error", "message": "Product not found"}
    result = {
        'p_seq': row[0],
        'kc_seq': row[1],
        'cc_seq': row[2],
        'sc_seq': row[3],
        'gc_seq': row[4],
        'm_seq': row[5],
        'p_name': row[6],
        'p_price': row[7],
        'p_stock': row[8],
        'p_image': row[9],
        'p_description': row[10],
        'created_at': row[11].isoformat() if row[11] else None,
        'p_color': row[12],
        'p_size': row[13],
        'p_gender': row[14],
        'p_maker': row[15]
    }
    return {"result": result}


# ============================================
# 제조사별 제품 조회
# ============================================
@router.get("/by_maker/{maker_seq}")
async def select_products_by_maker(maker_seq: int):
    conn = connect_db()
    curs = conn.cursor()
    curs.execute("""
        SELECT p_seq, kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description, created_at 
        FROM product 
        WHERE m_seq = %s
        ORDER BY p_seq
    """, (maker_seq,))
    rows = curs.fetchall()
    conn.close()
    result = [{
        'p_seq': row[0],
        'kc_seq': row[1],
        'cc_seq': row[2],
        'sc_seq': row[3],
        'gc_seq': row[4],
        'm_seq': row[5],
        'p_name': row[6],
        'p_price': row[7],
        'p_stock': row[8],
        'p_image': row[9],
        'p_description': row[10],
        'created_at': row[11].isoformat() if row[11] else None
    } for row in rows]
    return {"results": result}


# GT: 추가함
# ============================================
# Search (Read All)
# ============================================
@router.get("/search")
async def select_search(
  maker: Optional[str]=None,
  kwds: Optional[str]=None,
  color: Optional[str]=None,
  size: Optional[str]=None,
  isOneKwds: Optional[bool]=False
):
  
  #### 쿼리 조건문 만들기
  data = []
  qry_condition = 'where 1=1 and '
  if maker is not None:
    qry_condition += 'ma.m_name=%s and '
    data.append(maker)
  kwds_condition = ''
  if kwds is not None:
    if isOneKwds :
        kwds_condition += 'p.p_name =%s or '
        data.append(kwds)
    else :
        for kwd in kwds.split(' '):
            kwds_condition += 'p.p_name like %s or '
            data.append(f"%{kwd}%")
  if kwds_condition != '':
    qry_condition += f'({kwds_condition[0:len(kwds_condition)-3]}) and '
  if color is not None:
    qry_condition += 'cc.cc_name=%s and '
    data.append(color)
  if size is not None:
    qry_condition += 'p.size=%s and '
    data.append(size)

  qry_condition = qry_condition[0:len(qry_condition)-4]
  #### END OF 쿼리 조건문 만들기

  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
          select 
            p.p_seq, p.kc_seq, p.cc_seq, p.sc_seq, p.gc_seq, p.m_seq, p.p_name, p.p_price, p.p_stock, p.p_image, p.p_description, p.created_at      
            ,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
          from product p 
          inner join color_category cc on p.cc_seq=cc.cc_seq
          inner join gender_category gc on p.gc_seq=gc.gc_seq
          inner join size_category sc on p.sc_seq=sc.sc_seq
          inner join maker ma on p.m_seq=ma.m_seq 
          """ + qry_condition
          ,data
    )


    rows = curs.fetchall()
    print(rows)
    results = [{
        "p_seq": row[0],
        "kc_seq": row[1],
        "cc_seq": row[2],
        "sc_seq": row[3],
        "gc_seq": row[4],
        "m_seq": row[5],
        "p_name": row[6],
        "p_price": row[7],
        "p_stock": row[8],
        "p_image": row[9],
        "p_description" : row[10],
        'created_at': row[11].isoformat() if row[11] else None,
        "p_color": row[12],
        "p_size": row[13],
        "p_gender": row[14],
        "p_maker": row[15]
    } for row in rows]
   
  
    return {"results": results}
  except Exception as error:
    print(error)
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()


# GT: 추가함
# ============================================
# Search (Read All)
# ============================================
@router.get("/getBySeqs")
async def select_search(
  m_seq: Optional[int]=None,
  p_name: Optional[str]=None,
  cc_seq: Optional[int]=None,
  gc_seq: Optional[int]=None,
  sc_seq: Optional[int]=None

):
  
  #### 쿼리 조건문 만들기
  data = []
  qry_condition = 'where 1=1 and '
  if m_seq is not None:
    qry_condition += 'p.m_seq=%s and '
    data.append(m_seq)
  kwds_condition = ''
  if p_name is not None:

    kwds_condition += 'p.p_name =%s or '
    data.append(p_name)

  if kwds_condition != '':
    qry_condition += f'({kwds_condition[0:len(kwds_condition)-3]}) and '
  if cc_seq is not None:
    qry_condition += 'p.cc_seq=%s and '
    data.append(cc_seq)
  if sc_seq is not None:
    qry_condition += 'p.sc_seq=%s and '
    data.append(sc_seq)
  if gc_seq is not None:
    qry_condition += 'p.gc_seq=%s and '
    data.append(gc_seq)

  qry_condition = qry_condition[0:len(qry_condition)-4]
  #### END OF 쿼리 조건문 만들기

  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
          select 
            p.p_seq, p.kc_seq, p.cc_seq, p.sc_seq, p.gc_seq, p.m_seq, p.p_name, p.p_price, p.p_stock, p.p_image, p.p_description, p.created_at      
            ,cc.cc_name as p_color,sc.sc_name as p_size,gc.gc_name as p_gender, ma.m_name
          from product p 
          inner join color_category cc on p.cc_seq=cc.cc_seq
          inner join gender_category gc on p.gc_seq=gc.gc_seq
          inner join size_category sc on p.sc_seq=sc.sc_seq
          inner join maker ma on p.m_seq=ma.m_seq 
          """ + qry_condition
          ,data
    )


    rows = curs.fetchall()

    results = [{
        "p_seq": row[0],
        "kc_seq": row[1],
        "cc_seq": row[2],
        "sc_seq": row[3],
        "gc_seq": row[4],
        "m_seq": row[5],
        "p_name": row[6],
        "p_price": row[7],
        "p_stock": row[8],
        "p_image": row[9],
        "p_description" : row[10],
        'created_at': row[11].isoformat() if row[11] else None,
        "p_color": row[12],
        "p_size": row[13],
        "p_gender": row[14],
        "p_maker": row[15]
    } for row in rows]
   
  
    return {"results": results}
  except Exception as error:
    print(error)
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()



# GT: 추가함
# ============================================
# Search (Read All)
# ============================================
@router.get("/searchByMain")
async def select_search_by_main(
  maker: Optional[str]=None,
  kwds: Optional[str]=None,
  color: Optional[str]=None
):
  
  #### 쿼리 조건문 만들기
  data = []
  qry_condition = 'where 1=1 and '
  if maker is not None:
    qry_condition += 'ma.m_name=%s and '
    data.append(maker)
  kwds_condition = ''
  if kwds is not None:
    for kwd in kwds.split(' '):
      kwds_condition += 'p.p_name like %s or '
      data.append(f"%{kwd}%")

  if kwds_condition != '':
    qry_condition += f'({kwds_condition[0:len(kwds_condition)-3]}) and '
  if color is not None:
    qry_condition += 'cc.cc_name=%s and '
    data.append(color)
  qry_condition = qry_condition[0:len(qry_condition)-4]
  #### END OF 쿼리 조건문 만들기

  conn = connect_db()
  try:
    curs = conn.cursor()
    curs.execute("""
             select p.p_name, p.cc_seq, p.m_seq, cc.cc_name, ma.m_name,p.p_image
                
            from product p 
            inner join color_category cc on p.cc_seq=cc.cc_seq
            inner join gender_category gc on p.gc_seq=gc.gc_seq
            inner join size_category sc on p.sc_seq=sc.sc_seq
            inner join maker ma on p.m_seq=ma.m_seq
            
          """ + qry_condition + " group by p.p_name,p.cc_seq,p.m_seq,p.p_image"
          ,data
    )
         
    rows = curs.fetchall()
    print(rows)
    # results = [{
    #     "p_seq": row[0],
    #     "kc_seq": row[1],
    #     "cc_seq": row[2],
    #     "sc_seq": row[3],
    #     "gc_seq": row[4],
    #     "m_seq": row[5],
    #     "p_name": row[6],
    #     "p_price": row[7],
    #     "p_stock": row[8],
    #     "p_image": row[9],
    #     "p_description" : row[10],
    #     'created_at': row[11].isoformat() if row[11] else None,
    #     "p_color": row[12],
    #     "p_size": row[13],
    #     "p_gender": row[14],
    #     "p_maker": row[15]
    # } for row in rows]
    results = [{
        'p_seq': -1,
        'kc_seq': -1,
        'cc_seq': row[1],
        'sc_seq': -1,
        'gc_seq': -1,
        'm_seq': row[2],
        'p_name': row[0],
        'p_price': -1,
        'p_stock': -1,
        'p_image': row[5],
        'p_description': '',
        'created_at': None,
        'p_color': row[3],
        'p_size': '',
        'p_gender': '',
        'p_maker': row[4],
    } for row in rows]
    return {"results": results}
  except Exception as error:
    print(error)
    return {"result": "Error", "errorMsg": str(error)}
  finally:
     conn.close()



# ============================================
# 제품 추가
# ============================================
@router.post("")
async def insert_product(
    kc_seq: int = Form(...),
    cc_seq: int = Form(...),
    sc_seq: int = Form(...),
    gc_seq: int = Form(...),
    m_seq: int = Form(...),
    p_name: Optional[str] = Form(None),
    p_price: int = Form(0),
    p_stock: int = Form(0),
    p_image: Optional[str] = Form(None),
    p_description: Optional[str] = Form(None),
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            INSERT INTO product (kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description))
        conn.commit()
        inserted_id = curs.lastrowid
        conn.close()
        return {"result": "OK", "p_seq": inserted_id}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제품 수정
# ============================================
@router.post("/{product_seq}")
async def update_product(
    product_seq: int,
    kc_seq: int = Form(...),
    cc_seq: int = Form(...),
    sc_seq: int = Form(...),
    gc_seq: int = Form(...),
    m_seq: int = Form(...),
    p_name: Optional[str] = Form(None),
    p_price: int = Form(0),
    p_stock: int = Form(0),
    p_image: Optional[str] = Form(None),
    p_description: Optional[str] = Form(None),
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = """
            UPDATE product 
            SET kc_seq=%s, cc_seq=%s, sc_seq=%s, gc_seq=%s, m_seq=%s, 
                p_name=%s, p_price=%s, p_stock=%s, p_image=%s, p_description=%s 
            WHERE p_seq=%s
        """
        curs.execute(sql, (kc_seq, cc_seq, sc_seq, gc_seq, m_seq, p_name, p_price, p_stock, p_image, p_description, product_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제품 재고 수정
# ============================================
@router.post("/{product_seq}/stock")
async def update_product_stock(
    product_seq: int,
    p_stock: int = Form(...),
):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "UPDATE product SET p_stock=%s WHERE p_seq=%s"
        curs.execute(sql, (p_stock, product_seq))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제품 삭제
# ============================================
@router.delete("/{product_seq}")
async def delete_product(product_seq: int):
    try:
        conn = connect_db()
        curs = conn.cursor()
        sql = "DELETE FROM product WHERE p_seq=%s"
        curs.execute(sql, (product_seq,))
        conn.commit()
        conn.close()
        return {"result": "OK"}
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제품 파일 업로드 (이미지 또는 GLB 파일)
# ============================================
@router.post("/{product_seq}/upload_file")
async def upload_product_file(
    product_seq: int,
    file_type: str = Form(...),  # 'image' 또는 'glb'
    model_name: Optional[str] = Form(None),  # GLB 파일일 때 모델명 (예: 'nike_v2k')
    file: UploadFile = File(...)
):
    """
    제품 파일을 PHP 웹서버를 통해 업로드합니다.
    FastAPI는 파일을 받아서 PHP 스크립트로 전달하고, PHP가 NAS 경로에 저장합니다.
    
    - file_type: 'image' 또는 'glb'
    - model_name: GLB 파일일 때 필수 (예: 'nike_v2k')
    - file: 업로드할 파일
    
    반환: 파일 경로 (PHP 웹서버 URL)
    """
    try:
        # 파일 타입 검증
        if file_type not in ['image', 'glb']:
            return {"result": "Error", "errorMsg": "file_type은 'image' 또는 'glb'만 가능합니다."}
        
        # GLB 파일일 때 model_name 필수
        if file_type == 'glb' and not model_name:
            return {"result": "Error", "errorMsg": "GLB 파일은 model_name이 필수입니다."}
        
        # 파일 확장자 검증
        file_ext = Path(file.filename).suffix.lower()
        if file_type == 'glb' and file_ext != '.glb':
            return {"result": "Error", "errorMsg": "GLB 파일만 업로드 가능합니다."}
        elif file_type == 'image' and file_ext not in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
            return {"result": "Error", "errorMsg": "지원하는 이미지 형식이 아닙니다."}
        
        # 파일 읽기
        file_content = await file.read()
        
        # 파일 타입에 따라 적절한 PHP 스크립트 선택
        if file_type == 'glb':
            php_upload_url = PHP_UPLOAD_MODEL_SCRIPT
            # GLB 파일: upload_model.php 사용
            files = {
                'file': (file.filename, file_content, file.content_type or 'model/gltf-binary')
            }
            data = {
                'product_seq': str(product_seq),
                'model_name': model_name
            }
        else:
            php_upload_url = PHP_UPLOAD_IMAGE_SCRIPT
            # 이미지 파일: upload_image.php 사용
            files = {
                'file': (file.filename, file_content, file.content_type or 'image/png')
            }
            data = {
                'product_seq': str(product_seq)
            }
        
        # PHP 스크립트로 파일 전달
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.post(php_upload_url, files=files, data=data)
                response.raise_for_status()
                php_result = response.json()
            except httpx.HTTPStatusError as e:
                return {
                    "result": "Error",
                    "errorMsg": f"PHP 업로드 스크립트 오류: HTTP {e.response.status_code} - {e.response.text}"
                }
            except httpx.RequestError as e:
                return {
                    "result": "Error",
                    "errorMsg": f"PHP 업로드 스크립트 연결 실패: {str(e)}"
                }
        
        # PHP 응답 확인
        if php_result.get('result') != 'OK':
            error_msg = php_result.get('errorMsg', '알 수 없는 오류')
            return {"result": "Error", "errorMsg": f"PHP 업로드 실패: {error_msg}"}
        
        # DB에 파일 경로 저장
        conn = connect_db()
        curs = conn.cursor()
        
        file_url = php_result.get('file_url')
        if not file_url:
            conn.close()
            return {"result": "Error", "errorMsg": "PHP 응답에 file_url이 없습니다."}
        
        # product 테이블의 p_image 필드 업데이트
        sql = "UPDATE product SET p_image=%s WHERE p_seq=%s"
        curs.execute(sql, (file_url, product_seq))
        conn.commit()
        conn.close()
        
        # PHP 응답 반환
        return {
            "result": "OK",
            "file_url": file_url,
            "file_name": php_result.get('file_name'),
            "file_type": file_type,
            "saved_path": php_result.get('saved_path'),
            "file_path": php_result.get('file_path')
        }
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}


# ============================================
# 제품 파일 정보 조회
# ============================================
@router.get("/{product_seq}/file_info")
async def get_product_file_info(product_seq: int):
    """
    제품의 파일 정보를 조회합니다 (DB에 저장된 경로 반환).
    """
    try:
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("SELECT p_image FROM product WHERE p_seq = %s", (product_seq,))
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "Product not found"}
        
        file_path = row[0] if row[0] else None
        
        if file_path is None:
            return {"result": "Error", "message": "No file uploaded"}
        
        return {
            "result": "OK",
            "file_url": file_path,
            "product_seq": product_seq
        }
    except Exception as e:
        return {"result": "Error", "errorMsg": str(e)}


# ============================================
# 제품 파일 직접 다운로드 (PHP 웹서버 파일 시스템에서 직접 읽어서 반환)
# ============================================
@router.get("/{product_seq}/file")
async def download_product_file(product_seq: int):
    """
    제품 파일을 직접 다운로드합니다 (PHP 웹서버 파일 시스템에서 파일을 읽어서 반환).
    GLB 파일은 PHP 파일을 통해 접근하는 것을 권장하지만, 이 엔드포인트로도 다운로드 가능합니다.
    """
    try:
        # DB에서 파일 경로 조회
        conn = connect_db()
        curs = conn.cursor()
        curs.execute("SELECT p_image FROM product WHERE p_seq = %s", (product_seq,))
        row = curs.fetchone()
        conn.close()
        
        if row is None:
            return {"result": "Error", "message": "Product not found"}
        
        file_url = row[0] if row[0] else None
        
        if file_url is None:
            return {"result": "Error", "message": "No file uploaded"}
        
        # PHP 웹서버 URL에서 실제 파일명 추출
        # 예: "https://cheng80.myqnapcloud.com/model.php?name=nike_v2k" -> "nike_v2k.glb"
        # 예: "https://cheng80.myqnapcloud.com/images/product_1_image.jpg" -> "product_1_image.jpg"
        
        file_name = None
        save_dir = None
        
        if "?name=" in file_url:
            # GLB 파일: URL에서 모델명 추출
            model_name = file_url.split("?name=")[1].split("&")[0]
            file_name = f"{model_name}.glb"
            save_dir = PHP_MODEL_DIR
        elif "/images/" in file_url:
            # 이미지 파일: images 디렉토리에서 파일명 추출
            file_name = file_url.split("/images/")[1].split("?")[0]
            save_dir = PHP_IMAGES_DIR
        elif "/model/" in file_url:
            # 예전 형식 호환: model 디렉토리에서 파일명 추출
            file_name = file_url.split("/model/")[1].split("?")[0]
            save_dir = PHP_MODEL_DIR
        else:
            # 파일명을 추출할 수 없는 경우
            return {"result": "Error", "message": "Cannot extract file name from URL"}
        
        # PHP 웹서버 디렉토리에서 파일 읽기
        file_path = save_dir / file_name
        
        if not file_path.exists():
            return {"result": "Error", "message": f"파일을 찾을 수 없습니다: {file_path}"}
        
        # 파일 읽기
        with open(file_path, "rb") as f:
            file_content = f.read()
        
        # MIME 타입 결정
        file_ext = Path(file_name).suffix.lower()
        if file_ext == '.glb':
            media_type = "model/gltf-binary"
        elif file_ext in ['.jpg', '.jpeg']:
            media_type = "image/jpeg"
        elif file_ext == '.png':
            media_type = "image/png"
        elif file_ext == '.gif':
            media_type = "image/gif"
        elif file_ext == '.webp':
            media_type = "image/webp"
        else:
            media_type = "application/octet-stream"
        
        # 파일 반환
        return Response(
            content=file_content,
            media_type=media_type,
            headers={
                "Content-Disposition": f'inline; filename="{file_name}"',
                "Cache-Control": "no-cache, no-store, must-revalidate"
            }
        )
    except Exception as e:
        import traceback
        error_msg = str(e)
        traceback.print_exc()
        return {"result": "Error", "errorMsg": error_msg, "traceback": traceback.format_exc()}

