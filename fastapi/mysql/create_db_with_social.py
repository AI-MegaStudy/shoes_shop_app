"""
shoes_shop_db 데이터베이스 생성 스크립트 (소셜 로그인 지원)
"""

import pymysql
import os

# 데이터베이스 연결 설정
DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',
    'charset': 'utf8mb4',
    'port': 13306
}

# SQL 파일 경로
SQL_FILE = os.path.join(os.path.dirname(__file__), 'shoes_shop_db_mysql_init_with_social.sql')

def create_database():
    """데이터베이스 생성 및 스키마 적용"""
    try:
        # 데이터베이스 연결 (데이터베이스 이름 없이)
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("데이터베이스 서버에 연결되었습니다.")
        
        # SQL 파일 읽기
        with open(SQL_FILE, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        print(f"SQL 파일을 읽었습니다: {SQL_FILE}")
        
        # SQL 문을 세미콜론으로 분리하여 실행
        # 주석과 빈 줄 제거
        sql_statements = []
        current_statement = ""
        
        for line in sql_content.split('\n'):
            # 주석 제거 (-- 로 시작하는 줄)
            if line.strip().startswith('--'):
                continue
            
            # 빈 줄 건너뛰기
            if not line.strip():
                continue
            
            current_statement += line + '\n'
            
            # 세미콜론으로 끝나는 경우 문장 완성
            if ';' in line:
                sql_statements.append(current_statement.strip())
                current_statement = ""
        
        # 남은 문장이 있으면 추가
        if current_statement.strip():
            sql_statements.append(current_statement.strip())
        
        print(f"총 {len(sql_statements)}개의 SQL 문을 실행합니다...")
        
        # 각 SQL 문 실행
        for i, sql in enumerate(sql_statements, 1):
            if sql.strip():
                try:
                    cursor.execute(sql)
                    conn.commit()
                    print(f"[{i}/{len(sql_statements)}] SQL 문 실행 완료")
                except Exception as e:
                    print(f"[{i}/{len(sql_statements)}] SQL 문 실행 중 오류 발생: {str(e)}")
                    print(f"SQL: {sql[:100]}...")
                    raise
        
        print("\n✅ 데이터베이스 생성 및 스키마 적용이 완료되었습니다!")
        print("데이터베이스 이름: shoes_shop_db")
        
        # 테이블 목록 확인
        cursor.execute("USE shoes_shop_db")
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        print(f"\n생성된 테이블 목록 ({len(tables)}개):")
        for table in tables:
            print(f"  - {table[0]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ 오류 발생: {str(e)}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == "__main__":
    create_database()

