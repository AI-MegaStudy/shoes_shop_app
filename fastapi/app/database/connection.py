"""
데이터베이스 연결 설정
소셜 로그인 지원 버전 (shoes_shop_db_2)
"""

import pymysql


DB_CONFIG = {
    'host': 'cheng80.myqnapcloud.com',
    'user': 'team0101',
    'password': 'qwer1234',
    'database': 'shoes_shop_db_2',  # 소셜 로그인 지원 데이터베이스
    'charset': 'utf8mb4',
    'port': 13306
}


def connect_db():
    """
    데이터베이스 연결
    
    Returns:
        pymysql.Connection: 데이터베이스 연결 객체
    """
    conn = pymysql.connect(**DB_CONFIG)
    return conn

