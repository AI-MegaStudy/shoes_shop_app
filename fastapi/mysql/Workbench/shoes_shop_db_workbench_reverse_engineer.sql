/* =========================================================
   MySQL Workbench Forward/Reverse Engineering Script
   Generated: 2026-01-04 (Asia/Seoul)
   Source: shoes_shop_db_mysql_init_with_social.sql + database_schema.dbml
   Notes:
   - Includes schema drop/create, tables, indexes, foreign keys.
   - Uses utf8mb4 + InnoDB.
   - Updated: chatting 테이블 추가 (2026-01-04)
   - Updated: user_auth_identities CASCADE 정책 주석 추가 (2026-01-04)
   - Updated: chatting 테이블은 외래 키 없이 논리적 참조만 사용 (2026-01-04)
========================================================= */

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP DATABASE IF EXISTS `shoes_shop_db`;
CREATE DATABASE `shoes_shop_db`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `shoes_shop_db`;

/* =========================================================
   BRANCH : 오프라인 지점 정보
========================================================= */
DROP TABLE IF EXISTS `branch`;
CREATE TABLE `branch` (
  br_seq     INT AUTO_INCREMENT PRIMARY KEY COMMENT '지점 고유 ID(PK)',
  br_phone   VARCHAR(30)  COMMENT '지점 전화번호',
  br_address VARCHAR(255) COMMENT '지점 주소',
  br_name    VARCHAR(100) NOT NULL COMMENT '지점명',
  br_lat     DECIMAL(10,7) COMMENT '지점 위도',
  br_lng     DECIMAL(10,7) COMMENT '지점 경도',
  
  UNIQUE INDEX idx_branch_name (br_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='오프라인 지점 정보';

/* =========================================================
   USER : 고객 계정 (소셜 로그인 지원)
========================================================= */
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  u_seq      INT AUTO_INCREMENT PRIMARY KEY COMMENT '고객 고유 ID(PK)',
  u_email    VARCHAR(255) NOT NULL COMMENT '고객 이메일 (로컬/소셜 모두 필수, UNIQUE)',
  u_name     VARCHAR(255) NULL COMMENT '고객 이름 (선택 사항)',
  u_phone    VARCHAR(30)  NULL COMMENT '고객 전화번호 (선택 사항)',
  u_image    MEDIUMBLOB   NULL COMMENT '고객 프로필 이미지',
  u_address  VARCHAR(255) COMMENT '고객 주소',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '고객 가입일자',
  u_quit_date DATETIME NULL COMMENT '고객 탈퇴일자',
  
  UNIQUE INDEX idx_user_email (u_email),
  UNIQUE INDEX idx_user_phone (u_phone),
  INDEX idx_user_created_at (created_at),
  INDEX idx_user_quit_date (u_quit_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='고객 계정 정보';

/* =========================================================
   USER_AUTH_IDENTITIES : 사용자 로그인 수단별 인증 정보
   
   외래 키 정책: ON DELETE CASCADE ON UPDATE CASCADE
   - CASCADE 사용 이유: user 삭제 시 인증 정보도 함께 삭제되어야 함 (종속적 데이터)
   - 인증 정보는 사용자와 함께 존재해야 하므로, 사용자가 없으면 인증 정보도 의미가 없음
   - 다른 테이블(purchase_item, pickup, refund 등)과 달리 CASCADE를 사용하는 이유:
     * 구매 내역, 수령, 반품 등은 사용자 삭제 후에도 기록으로 남아야 함 (비즈니스 데이터)
     * 인증 정보는 사용자 계정의 일부이므로 사용자와 함께 삭제되어야 함 (보안 및 데이터 정리)
========================================================= */
DROP TABLE IF EXISTS `user_auth_identities`;
CREATE TABLE `user_auth_identities` (
  auth_seq          INT AUTO_INCREMENT PRIMARY KEY COMMENT '인증 수단 고유 ID(PK)',
  u_seq             INT NOT NULL COMMENT '고객 번호(FK)',
  provider          VARCHAR(50) NOT NULL COMMENT '로그인 제공자(local, google, kakao)',
  provider_subject  VARCHAR(255) NOT NULL COMMENT '제공자 고유 식별자(로컬: 이메일, 구글: sub, 카카오: id)',
  provider_issuer   VARCHAR(255) NULL COMMENT '제공자 발급자(구글 iss 등)',
  email_at_provider VARCHAR(255) NULL COMMENT '제공자에서 받은 이메일',
  password          VARCHAR(255) NULL COMMENT '로컬 로그인 비밀번호 (로컬만)',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일자',
  last_login_at     DATETIME NULL COMMENT '마지막 로그인 일시',
  
  CONSTRAINT fk_user_auth_user
    FOREIGN KEY (u_seq) REFERENCES `user` (`u_seq`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  
  UNIQUE INDEX idx_provider_subject (provider, provider_subject),
  INDEX idx_user_auth_u_seq (u_seq),
  INDEX idx_user_auth_provider (provider)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 로그인 수단 매핑';

/* =========================================================
   STAFF : 직원 계정
========================================================= */
DROP TABLE IF EXISTS `staff`;
CREATE TABLE `staff` (
  s_seq      INT AUTO_INCREMENT PRIMARY KEY COMMENT '직원 고유 ID(PK)',
  s_id       VARCHAR(50)  NOT NULL COMMENT '직원 로그인 ID',
  br_seq     INT NOT NULL COMMENT '소속 지점 ID(FK)',
  s_password VARCHAR(255) NOT NULL COMMENT '직원 비밀번호(해시)',
  s_image    MEDIUMBLOB   NULL COMMENT '직원 프로필 이미지',
  s_rank     VARCHAR(100) COMMENT '직원 직급',
  s_phone    VARCHAR(30)  NOT NULL COMMENT '직원 전화번호',
  s_name     VARCHAR(255) NOT NULL COMMENT '직원명',
  s_superseq INT COMMENT '상급자 직원 ID(논리적 참조)',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일자',
  s_quit_date DATETIME NULL COMMENT '직원 탈퇴 일자',
  
  CONSTRAINT fk_staff_branch
    FOREIGN KEY (br_seq) REFERENCES `branch` (`br_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_staff_br_seq (br_seq),
  UNIQUE INDEX idx_staff_id (s_id),
  UNIQUE INDEX idx_staff_phone (s_phone),
  INDEX idx_staff_created_at (created_at),
  INDEX idx_staff_quit_date (s_quit_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='지점 직원 정보';

/* =========================================================
   MAKER : 제조사
========================================================= */
DROP TABLE IF EXISTS `maker`;
CREATE TABLE `maker` (
  m_seq     INT AUTO_INCREMENT PRIMARY KEY COMMENT '제조사 고유 ID(PK)',
  m_phone   VARCHAR(30)  COMMENT '제조사 전화번호',
  m_name    VARCHAR(255) NOT NULL COMMENT '제조사명',
  m_address VARCHAR(255) COMMENT '제조사 주소',
  
  UNIQUE INDEX idx_maker_name (m_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='신발 제조사 정보';

/* =========================================================
   CATEGORY TABLES
========================================================= */
DROP TABLE IF EXISTS `kind_category`;
CREATE TABLE `kind_category` (
  kc_seq  INT AUTO_INCREMENT PRIMARY KEY COMMENT '종류 카테고리 ID(PK)',
  kc_name VARCHAR(100) NOT NULL COMMENT '종류명(러닝/스니커즈/부츠 등)',
  
  UNIQUE INDEX idx_kind_category_name (kc_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='제품 종류 카테고리';
DROP TABLE IF EXISTS `color_category`;
CREATE TABLE `color_category` (
  cc_seq  INT AUTO_INCREMENT PRIMARY KEY COMMENT '색상 카테고리 ID(PK)',
  cc_name VARCHAR(100) NOT NULL COMMENT '색상명',
  
  UNIQUE INDEX idx_color_category_name (cc_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='제품 색상 카테고리';
DROP TABLE IF EXISTS `size_category`;
CREATE TABLE `size_category` (
  sc_seq  INT AUTO_INCREMENT PRIMARY KEY COMMENT '사이즈 카테고리 ID(PK)',
  sc_name VARCHAR(100) NOT NULL COMMENT '사이즈 값',
  
  UNIQUE INDEX idx_size_category_name (sc_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='제품 사이즈 카테고리';
DROP TABLE IF EXISTS `gender_category`;
CREATE TABLE `gender_category` (
  gc_seq  INT AUTO_INCREMENT PRIMARY KEY COMMENT '성별 카테고리 ID(PK)',
  gc_name VARCHAR(100) NOT NULL COMMENT '성별 구분',
  
  UNIQUE INDEX idx_gender_category_name (gc_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='제품 성별 카테고리';

/* =========================================================
   REFUND_REASON_CATEGORY : 반품 사유 카테고리
========================================================= */
DROP TABLE IF EXISTS `refund_reason_category`;
CREATE TABLE `refund_reason_category` (
  ref_re_seq  INT AUTO_INCREMENT PRIMARY KEY COMMENT '반품 사유 번호(PK)',
  ref_re_name VARCHAR(100) NOT NULL COMMENT '반품 사유명',
  
  UNIQUE INDEX idx_refund_reason_name (ref_re_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='반품 사유 카테고리';

/* =========================================================
   PRODUCT : 판매 상품(SKU)
========================================================= */
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  p_seq   INT AUTO_INCREMENT PRIMARY KEY COMMENT '제품 고유 ID(PK)',
  kc_seq  INT NOT NULL COMMENT '제품 종류 카테고리 ID(FK)',
  cc_seq  INT NOT NULL COMMENT '제품 색상 카테고리 ID(FK)',
  sc_seq  INT NOT NULL COMMENT '제품 사이즈 카테고리 ID(FK)',
  gc_seq  INT NOT NULL COMMENT '제품 성별 카테고리 ID(FK)',
  m_seq   INT NOT NULL COMMENT '제조사 ID(FK)',
  
  p_name        VARCHAR(255) COMMENT '제품명',
  p_price       INT DEFAULT 0 COMMENT '제품 가격',
  p_stock       INT NOT NULL DEFAULT 0 COMMENT '중앙 재고 수량',
  p_image       VARCHAR(255) COMMENT '제품 이미지 경로',
  p_description TEXT COMMENT '제품 설명',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '제품 등록일자',
  
  CONSTRAINT uq_product_color_size_maker_name
    UNIQUE (cc_seq, sc_seq, m_seq, p_name),
  
  CONSTRAINT fk_product_kind   
    FOREIGN KEY (kc_seq) REFERENCES `kind_category` (`kc_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_product_color  
    FOREIGN KEY (cc_seq) REFERENCES `color_category` (`cc_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_product_size   
    FOREIGN KEY (sc_seq) REFERENCES `size_category` (`sc_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_product_gender 
    FOREIGN KEY (gc_seq) REFERENCES `gender_category` (`gc_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_product_maker  
    FOREIGN KEY (m_seq) REFERENCES `maker` (`m_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_product_p_name (p_name),
  INDEX idx_product_m_seq (m_seq),
  INDEX idx_product_kc_seq (kc_seq),
  INDEX idx_product_cc_seq (cc_seq),
  INDEX idx_product_sc_seq (sc_seq),
  INDEX idx_product_gc_seq (gc_seq),
  INDEX idx_product_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='판매 상품(SKU)';

/* =========================================================
   PURCHASE_ITEM : 구매 내역
========================================================= */
DROP TABLE IF EXISTS `purchase_item`;
CREATE TABLE `purchase_item` (
  b_seq      INT AUTO_INCREMENT PRIMARY KEY COMMENT '구매 고유 ID(PK)',
  br_seq     INT NOT NULL COMMENT '수령 지점 ID(FK)',
  u_seq      INT NOT NULL COMMENT '구매 고객 ID(FK)',
  p_seq      INT NOT NULL COMMENT '구매 제품 ID(FK)',
  b_price    INT DEFAULT 0 COMMENT '구매 당시 가격',
  b_quantity INT DEFAULT 1 COMMENT '구매 수량',
  b_date     DATETIME NOT NULL COMMENT '구매 일시',
  b_tnum     VARCHAR(100) COMMENT '결제 트랜잭션 번호',
  b_status   VARCHAR(50) COMMENT '상품주문상태',
  
  CONSTRAINT fk_purchase_branch  
    FOREIGN KEY (br_seq) REFERENCES `branch` (`br_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_purchase_user    
    FOREIGN KEY (u_seq) REFERENCES `user` (`u_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_purchase_product 
    FOREIGN KEY (p_seq) REFERENCES `product` (`p_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_purchase_item_b_tnum (b_tnum),
  INDEX idx_purchase_item_b_date (b_date),
  INDEX idx_purchase_item_u_seq (u_seq),
  INDEX idx_purchase_item_br_seq (br_seq),
  INDEX idx_purchase_item_p_seq (p_seq),
  INDEX idx_purchase_item_b_status (b_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='고객 구매 내역';

/* =========================================================
   PICKUP : 오프라인 수령
========================================================= */
DROP TABLE IF EXISTS `pickup`;
CREATE TABLE `pickup` (
  pic_seq    INT AUTO_INCREMENT PRIMARY KEY COMMENT '수령 고유 ID(PK)',
  b_seq      INT NOT NULL COMMENT '구매 ID(FK)',
  u_seq      INT NOT NULL COMMENT '고객 번호(FK)',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수령 완료 일시',
  
  CONSTRAINT fk_pickup_purchase
    FOREIGN KEY (b_seq) REFERENCES `purchase_item` (`b_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pickup_user
    FOREIGN KEY (u_seq) REFERENCES `user` (`u_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_pickup_b_seq (b_seq),
  INDEX idx_pickup_u_seq (u_seq),
  INDEX idx_pickup_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='오프라인 수령 기록';

/* =========================================================
   REFUND : 반품/환불
========================================================= */
DROP TABLE IF EXISTS `refund`;
CREATE TABLE `refund` (
  ref_seq       INT AUTO_INCREMENT PRIMARY KEY COMMENT '반품 고유 ID(PK)',
  ref_date      DATETIME COMMENT '반품 처리 일시',
  ref_reason    VARCHAR(255) COMMENT '반품 사유',
  ref_re_seq    INT COMMENT '반품 사유 번호(FK)',
  ref_re_content VARCHAR(255) COMMENT '반품 사유 내용',
  u_seq         INT NOT NULL COMMENT '반품 요청 고객 ID(FK)',
  s_seq         INT NOT NULL COMMENT '반품 처리 직원 ID(FK)',
  pic_seq       INT NOT NULL COMMENT '수령 ID(FK)',
  
  CONSTRAINT fk_refund_user   
    FOREIGN KEY (u_seq) REFERENCES `user` (`u_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_refund_staff 
    FOREIGN KEY (s_seq) REFERENCES `staff` (`s_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_refund_pickup 
    FOREIGN KEY (pic_seq) REFERENCES `pickup` (`pic_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_refund_reason_category
    FOREIGN KEY (ref_re_seq) REFERENCES `refund_reason_category` (`ref_re_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_refund_u_seq (u_seq),
  INDEX idx_refund_s_seq (s_seq),
  INDEX idx_refund_pic_seq (pic_seq),
  INDEX idx_refund_ref_date (ref_date),
  INDEX idx_refund_ref_re_seq (ref_re_seq)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='오프라인 반품/환불 기록';

/* =========================================================
   RECEIVE : 입고(수주)
========================================================= */
DROP TABLE IF EXISTS `receive`;
CREATE TABLE `receive` (
  rec_seq      INT AUTO_INCREMENT PRIMARY KEY COMMENT '입고 고유 ID(PK)',
  rec_quantity INT DEFAULT 0 COMMENT '입고 수량',
  rec_date     DATETIME COMMENT '입고 처리 일시',
  s_seq        INT NOT NULL COMMENT '입고 처리 직원 ID(FK)',
  p_seq        INT NOT NULL COMMENT '입고 제품 ID(FK)',
  m_seq        INT NOT NULL COMMENT '제조사 ID(FK)',
  
  CONSTRAINT fk_receive_staff  
    FOREIGN KEY (s_seq) REFERENCES `staff` (`s_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_receive_product 
    FOREIGN KEY (p_seq) REFERENCES `product` (`p_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_receive_maker   
    FOREIGN KEY (m_seq) REFERENCES `maker` (`m_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_receive_s_seq (s_seq),
  INDEX idx_receive_p_seq (p_seq),
  INDEX idx_receive_m_seq (m_seq),
  INDEX idx_receive_rec_date (rec_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='제조사 입고 처리';

/* =========================================================
   REQUEST : 발주/품의
========================================================= */
DROP TABLE IF EXISTS `request`;
CREATE TABLE `request` (
  req_seq        INT AUTO_INCREMENT PRIMARY KEY COMMENT '발주/품의 고유 ID(PK)',
  req_date       DATETIME COMMENT '발주 요청 일시',
  req_content    TEXT COMMENT '발주 내용',
  req_quantity   INT DEFAULT 0 COMMENT '발주 수량',
  req_manappdate DATETIME COMMENT '팀장 결재 일시',
  req_dirappdate DATETIME COMMENT '이사 결재 일시',
  s_seq          INT NOT NULL COMMENT '발주 요청 직원 ID(FK)',
  p_seq          INT NOT NULL COMMENT '발주 제품 ID(FK)',
  m_seq          INT NOT NULL COMMENT '제조사 ID(FK)',
  s_superseq     INT COMMENT '승인자 직원 ID(논리 참조)',
  
  CONSTRAINT fk_request_staff  
    FOREIGN KEY (s_seq) REFERENCES `staff` (`s_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_request_product 
    FOREIGN KEY (p_seq) REFERENCES `product` (`p_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_request_maker   
    FOREIGN KEY (m_seq) REFERENCES `maker` (`m_seq`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  
  INDEX idx_request_s_seq (s_seq),
  INDEX idx_request_p_seq (p_seq),
  INDEX idx_request_m_seq (m_seq),
  INDEX idx_request_req_date (req_date),
  INDEX idx_request_req_manappdate (req_manappdate),
  INDEX idx_request_req_dirappdate (req_dirappdate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='재고 부족 시 발주/품의 기록';

/* =========================================================
   CHATTING : 고객-직원 채팅 세션
   
   참고: 실제 DB와 동일하게 외래 키 없이 논리적 참조만 사용
   - u_seq → user.u_seq (논리적 참조, 외래 키 없음)
   - s_seq → staff.s_seq (논리적 참조, 선택 사항, 외래 키 없음)
   - Firebase Firestore 연동 지원 (fb_doc_id 필드)
   - 외래 키를 사용하지 않는 이유:
     * 실시간 채팅 성능 최적화
     * Firebase Firestore와의 외부 시스템 연동 용이성
     * 탈퇴한 user의 chatting 기록 보존 필요
     * 애플리케이션 레벨에서 JOIN으로 검증 가능
========================================================= */
DROP TABLE IF EXISTS `chatting`;
CREATE TABLE `chatting` (
  chatting_seq INT AUTO_INCREMENT PRIMARY KEY COMMENT '채팅 세션 고유 ID(PK)',
  u_seq        INT NOT NULL COMMENT '고객 번호(논리적 참조 → user.u_seq)',
  fb_doc_id    VARCHAR(100) COMMENT 'Firebase Firestore 문서 ID',
  s_seq        INT COMMENT '담당 직원 번호(논리적 참조 → staff.s_seq, 선택 사항)',
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '채팅 세션 생성 일시',
  is_closed    TINYINT(1) NOT NULL DEFAULT 0 COMMENT '채팅 종료 여부 (0: 진행중, 1: 종료)',
  
  INDEX idx_chatting_u_seq (u_seq),
  INDEX idx_chatting_s_seq (s_seq),
  INDEX idx_chatting_created_at (created_at),
  INDEX idx_chatting_is_closed (is_closed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='고객-직원 채팅 세션';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
