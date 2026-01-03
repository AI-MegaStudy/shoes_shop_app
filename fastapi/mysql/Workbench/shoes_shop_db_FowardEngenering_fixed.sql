-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema shoes_shop_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema shoes_shop_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `shoes_shop_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `shoes_shop_db` ;

-- -----------------------------------------------------
-- Table `shoes_shop_db`.`branch`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`branch` (
  `br_seq` INT NOT NULL AUTO_INCREMENT COMMENT '지점 고유 ID(PK)',
  `br_phone` VARCHAR(30) NULL DEFAULT NULL COMMENT '지점 전화번호',
  `br_address` VARCHAR(255) NULL DEFAULT NULL COMMENT '지점 주소',
  `br_name` VARCHAR(100) NOT NULL COMMENT '지점명',
  `br_lat` DECIMAL(10,7) NULL DEFAULT NULL COMMENT '지점 위도',
  `br_lng` DECIMAL(10,7) NULL DEFAULT NULL COMMENT '지점 경도',
  PRIMARY KEY (`br_seq`),
  UNIQUE INDEX `idx_branch_name` (`br_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '오프라인 지점 정보';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`user` (
  `u_seq` INT NOT NULL AUTO_INCREMENT COMMENT '고객 고유 ID(PK)',
  `u_email` VARCHAR(255) NOT NULL COMMENT '고객 이메일 (로컬/소셜 모두 필수, UNIQUE)',
  `u_name` VARCHAR(255) NULL DEFAULT NULL COMMENT '고객 이름 (선택 사항)',
  `u_phone` VARCHAR(30) NULL DEFAULT NULL COMMENT '고객 전화번호 (선택 사항)',
  `u_image` MEDIUMBLOB NULL DEFAULT NULL COMMENT '고객 프로필 이미지',
  `u_address` VARCHAR(255) NULL DEFAULT NULL COMMENT '고객 주소',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '고객 가입일자',
  `u_quit_date` DATETIME NULL DEFAULT NULL COMMENT '고객 탈퇴일자',
  PRIMARY KEY (`u_seq`),
  UNIQUE INDEX `idx_user_email` (`u_email` ASC) VISIBLE,
  UNIQUE INDEX `idx_user_phone` (`u_phone` ASC) VISIBLE,
  INDEX `idx_user_created_at` (`created_at` ASC) VISIBLE,
  INDEX `idx_user_quit_date` (`u_quit_date` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '고객 계정 정보';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`user_auth_identities`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`user_auth_identities` (
  `auth_seq` INT NOT NULL AUTO_INCREMENT COMMENT '인증 수단 고유 ID(PK)',
  `u_seq` INT NOT NULL COMMENT '고객 번호(FK)',
  `provider` VARCHAR(50) NOT NULL COMMENT '로그인 제공자(local, google, kakao)',
  `provider_subject` VARCHAR(255) NOT NULL COMMENT '제공자 고유 식별자(로컬: 이메일, 구글: sub, 카카오: id)',
  `provider_issuer` VARCHAR(255) NULL DEFAULT NULL COMMENT '제공자 발급자(구글 iss 등)',
  `email_at_provider` VARCHAR(255) NULL DEFAULT NULL COMMENT '제공자에서 받은 이메일',
  `password` VARCHAR(255) NULL DEFAULT NULL COMMENT '로컬 로그인 비밀번호 (로컬만)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일자',
  `last_login_at` DATETIME NULL DEFAULT NULL COMMENT '마지막 로그인 일시',
  PRIMARY KEY (`auth_seq`),
  UNIQUE INDEX `idx_provider_subject` (`provider` ASC, `provider_subject` ASC) VISIBLE,
  INDEX `idx_user_auth_u_seq` (`u_seq` ASC) VISIBLE,
  INDEX `idx_user_auth_provider` (`provider` ASC) VISIBLE,
  INDEX `fk_user_auth_user` (`u_seq` ASC) VISIBLE,
  CONSTRAINT `fk_user_auth_user`
    FOREIGN KEY (`u_seq`)
    REFERENCES `shoes_shop_db`.`user` (`u_seq`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '사용자 로그인 수단 매핑';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`staff` (
  `s_seq` INT NOT NULL AUTO_INCREMENT COMMENT '직원 고유 ID(PK)',
  `s_id` VARCHAR(50) NOT NULL COMMENT '직원 로그인 ID',
  `br_seq` INT NOT NULL COMMENT '소속 지점 ID(FK)',
  `s_password` VARCHAR(255) NOT NULL COMMENT '직원 비밀번호(해시)',
  `s_image` MEDIUMBLOB NULL DEFAULT NULL COMMENT '직원 프로필 이미지',
  `s_rank` VARCHAR(100) NULL DEFAULT NULL COMMENT '직원 직급',
  `s_phone` VARCHAR(30) NOT NULL COMMENT '직원 전화번호',
  `s_name` VARCHAR(255) NOT NULL COMMENT '직원명',
  `s_superseq` INT NULL DEFAULT NULL COMMENT '상급자 직원 ID(논리적 참조)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성일자',
  `s_quit_date` DATETIME NULL DEFAULT NULL COMMENT '직원 탈퇴 일자',
  PRIMARY KEY (`s_seq`),
  INDEX `idx_staff_br_seq` (`br_seq` ASC) VISIBLE,
  UNIQUE INDEX `idx_staff_id` (`s_id` ASC) VISIBLE,
  UNIQUE INDEX `idx_staff_phone` (`s_phone` ASC) VISIBLE,
  INDEX `idx_staff_created_at` (`created_at` ASC) VISIBLE,
  INDEX `idx_staff_quit_date` (`s_quit_date` ASC) VISIBLE,
  INDEX `fk_staff_branch` (`br_seq` ASC) VISIBLE,
  CONSTRAINT `fk_staff_branch`
    FOREIGN KEY (`br_seq`)
    REFERENCES `shoes_shop_db`.`branch` (`br_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '지점 직원 정보';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`maker`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`maker` (
  `m_seq` INT NOT NULL AUTO_INCREMENT COMMENT '제조사 고유 ID(PK)',
  `m_phone` VARCHAR(30) NULL DEFAULT NULL COMMENT '제조사 전화번호',
  `m_name` VARCHAR(255) NOT NULL COMMENT '제조사명',
  `m_address` VARCHAR(255) NULL DEFAULT NULL COMMENT '제조사 주소',
  PRIMARY KEY (`m_seq`),
  UNIQUE INDEX `idx_maker_name` (`m_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '신발 제조사 정보';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`kind_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`kind_category` (
  `kc_seq` INT NOT NULL AUTO_INCREMENT COMMENT '종류 카테고리 ID(PK)',
  `kc_name` VARCHAR(100) NOT NULL COMMENT '종류명(러닝/스니커즈/부츠 등)',
  PRIMARY KEY (`kc_seq`),
  UNIQUE INDEX `idx_kind_category_name` (`kc_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '제품 종류 카테고리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`color_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`color_category` (
  `cc_seq` INT NOT NULL AUTO_INCREMENT COMMENT '색상 카테고리 ID(PK)',
  `cc_name` VARCHAR(100) NOT NULL COMMENT '색상명',
  PRIMARY KEY (`cc_seq`),
  UNIQUE INDEX `idx_color_category_name` (`cc_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '제품 색상 카테고리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`size_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`size_category` (
  `sc_seq` INT NOT NULL AUTO_INCREMENT COMMENT '사이즈 카테고리 ID(PK)',
  `sc_name` VARCHAR(100) NOT NULL COMMENT '사이즈 값',
  PRIMARY KEY (`sc_seq`),
  UNIQUE INDEX `idx_size_category_name` (`sc_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '제품 사이즈 카테고리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`gender_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`gender_category` (
  `gc_seq` INT NOT NULL AUTO_INCREMENT COMMENT '성별 카테고리 ID(PK)',
  `gc_name` VARCHAR(100) NOT NULL COMMENT '성별 구분',
  PRIMARY KEY (`gc_seq`),
  UNIQUE INDEX `idx_gender_category_name` (`gc_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '제품 성별 카테고리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`refund_reason_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`refund_reason_category` (
  `ref_re_seq` INT NOT NULL AUTO_INCREMENT COMMENT '반품 사유 번호(PK)',
  `ref_re_name` VARCHAR(100) NOT NULL COMMENT '반품 사유명',
  PRIMARY KEY (`ref_re_seq`),
  UNIQUE INDEX `idx_refund_reason_name` (`ref_re_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '반품 사유 카테고리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`product` (
  `p_seq` INT NOT NULL AUTO_INCREMENT COMMENT '제품 고유 ID(PK)',
  `kc_seq` INT NOT NULL COMMENT '제품 종류 카테고리 ID(FK)',
  `cc_seq` INT NOT NULL COMMENT '제품 색상 카테고리 ID(FK)',
  `sc_seq` INT NOT NULL COMMENT '제품 사이즈 카테고리 ID(FK)',
  `gc_seq` INT NOT NULL COMMENT '제품 성별 카테고리 ID(FK)',
  `m_seq` INT NOT NULL COMMENT '제조사 ID(FK)',
  `p_name` VARCHAR(255) NULL DEFAULT NULL COMMENT '제품명',
  `p_price` INT NULL DEFAULT 0 COMMENT '제품 가격',
  `p_stock` INT NOT NULL DEFAULT 0 COMMENT '중앙 재고 수량',
  `p_image` VARCHAR(255) NULL DEFAULT NULL COMMENT '제품 이미지 경로',
  `p_description` TEXT NULL DEFAULT NULL COMMENT '제품 설명',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '제품 등록일자',
  PRIMARY KEY (`p_seq`),
  UNIQUE INDEX `uq_product_color_size_maker_name` (`cc_seq` ASC, `sc_seq` ASC, `m_seq` ASC, `p_name` ASC) VISIBLE,
  INDEX `idx_product_p_name` (`p_name` ASC) VISIBLE,
  INDEX `idx_product_m_seq` (`m_seq` ASC) VISIBLE,
  INDEX `idx_product_kc_seq` (`kc_seq` ASC) VISIBLE,
  INDEX `idx_product_cc_seq` (`cc_seq` ASC) VISIBLE,
  INDEX `idx_product_sc_seq` (`sc_seq` ASC) VISIBLE,
  INDEX `idx_product_gc_seq` (`gc_seq` ASC) VISIBLE,
  INDEX `idx_product_created_at` (`created_at` ASC) VISIBLE,
  INDEX `fk_product_kind` (`kc_seq` ASC) VISIBLE,
  INDEX `fk_product_size` (`sc_seq` ASC) VISIBLE,
  INDEX `fk_product_gender` (`gc_seq` ASC) VISIBLE,
  INDEX `fk_product_maker` (`m_seq` ASC) VISIBLE,
  CONSTRAINT `fk_product_kind`
    FOREIGN KEY (`kc_seq`)
    REFERENCES `shoes_shop_db`.`kind_category` (`kc_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_product_color`
    FOREIGN KEY (`cc_seq`)
    REFERENCES `shoes_shop_db`.`color_category` (`cc_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_product_size`
    FOREIGN KEY (`sc_seq`)
    REFERENCES `shoes_shop_db`.`size_category` (`sc_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_product_gender`
    FOREIGN KEY (`gc_seq`)
    REFERENCES `shoes_shop_db`.`gender_category` (`gc_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_product_maker`
    FOREIGN KEY (`m_seq`)
    REFERENCES `shoes_shop_db`.`maker` (`m_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '판매 상품(SKU)';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`purchase_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`purchase_item` (
  `b_seq` INT NOT NULL AUTO_INCREMENT COMMENT '구매 고유 ID(PK)',
  `br_seq` INT NOT NULL COMMENT '수령 지점 ID(FK)',
  `u_seq` INT NOT NULL COMMENT '구매 고객 ID(FK)',
  `p_seq` INT NOT NULL COMMENT '구매 제품 ID(FK)',
  `b_price` INT NULL DEFAULT 0 COMMENT '구매 당시 가격',
  `b_quantity` INT NULL DEFAULT 1 COMMENT '구매 수량',
  `b_date` DATETIME NOT NULL COMMENT '구매 일시',
  `b_tnum` VARCHAR(100) NULL DEFAULT NULL COMMENT '결제 트랜잭션 번호',
  `b_status` VARCHAR(50) NULL DEFAULT NULL COMMENT '상품주문상태',
  PRIMARY KEY (`b_seq`),
  INDEX `idx_purchase_item_b_tnum` (`b_tnum` ASC) VISIBLE,
  INDEX `idx_purchase_item_b_date` (`b_date` ASC) VISIBLE,
  INDEX `idx_purchase_item_u_seq` (`u_seq` ASC) VISIBLE,
  INDEX `idx_purchase_item_br_seq` (`br_seq` ASC) VISIBLE,
  INDEX `idx_purchase_item_p_seq` (`p_seq` ASC) VISIBLE,
  INDEX `idx_purchase_item_b_status` (`b_status` ASC) VISIBLE,
  INDEX `fk_purchase_branch` (`br_seq` ASC) VISIBLE,
  INDEX `fk_purchase_user` (`u_seq` ASC) VISIBLE,
  INDEX `fk_purchase_product` (`p_seq` ASC) VISIBLE,
  CONSTRAINT `fk_purchase_branch`
    FOREIGN KEY (`br_seq`)
    REFERENCES `shoes_shop_db`.`branch` (`br_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_purchase_user`
    FOREIGN KEY (`u_seq`)
    REFERENCES `shoes_shop_db`.`user` (`u_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_purchase_product`
    FOREIGN KEY (`p_seq`)
    REFERENCES `shoes_shop_db`.`product` (`p_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '고객 구매 내역';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`pickup`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`pickup` (
  `pic_seq` INT NOT NULL AUTO_INCREMENT COMMENT '수령 고유 ID(PK)',
  `b_seq` INT NOT NULL COMMENT '구매 ID(FK)',
  `u_seq` INT NOT NULL COMMENT '고객 번호(FK)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '수령 완료 일시',
  PRIMARY KEY (`pic_seq`),
  INDEX `idx_pickup_b_seq` (`b_seq` ASC) VISIBLE,
  INDEX `idx_pickup_u_seq` (`u_seq` ASC) VISIBLE,
  INDEX `idx_pickup_created_at` (`created_at` ASC) VISIBLE,
  INDEX `fk_pickup_purchase` (`b_seq` ASC) VISIBLE,
  INDEX `fk_pickup_user` (`u_seq` ASC) VISIBLE,
  CONSTRAINT `fk_pickup_purchase`
    FOREIGN KEY (`b_seq`)
    REFERENCES `shoes_shop_db`.`purchase_item` (`b_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pickup_user`
    FOREIGN KEY (`u_seq`)
    REFERENCES `shoes_shop_db`.`user` (`u_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '오프라인 수령 기록';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`refund`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`refund` (
  `ref_seq` INT NOT NULL AUTO_INCREMENT COMMENT '반품 고유 ID(PK)',
  `ref_date` DATETIME NULL DEFAULT NULL COMMENT '반품 처리 일시',
  `ref_reason` VARCHAR(255) NULL DEFAULT NULL COMMENT '반품 사유',
  `ref_re_seq` INT NULL DEFAULT NULL COMMENT '반품 사유 번호(FK)',
  `ref_re_content` VARCHAR(255) NULL DEFAULT NULL COMMENT '반품 사유 내용',
  `u_seq` INT NOT NULL COMMENT '반품 요청 고객 ID(FK)',
  `s_seq` INT NOT NULL COMMENT '반품 처리 직원 ID(FK)',
  `pic_seq` INT NOT NULL COMMENT '수령 ID(FK)',
  PRIMARY KEY (`ref_seq`),
  INDEX `idx_refund_u_seq` (`u_seq` ASC) VISIBLE,
  INDEX `idx_refund_s_seq` (`s_seq` ASC) VISIBLE,
  INDEX `idx_refund_pic_seq` (`pic_seq` ASC) VISIBLE,
  INDEX `idx_refund_ref_date` (`ref_date` ASC) VISIBLE,
  INDEX `idx_refund_ref_re_seq` (`ref_re_seq` ASC) VISIBLE,
  INDEX `fk_refund_user` (`u_seq` ASC) VISIBLE,
  INDEX `fk_refund_staff` (`s_seq` ASC) VISIBLE,
  INDEX `fk_refund_pickup` (`pic_seq` ASC) VISIBLE,
  INDEX `fk_refund_reason_category` (`ref_re_seq` ASC) VISIBLE,
  CONSTRAINT `fk_refund_user`
    FOREIGN KEY (`u_seq`)
    REFERENCES `shoes_shop_db`.`user` (`u_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_refund_staff`
    FOREIGN KEY (`s_seq`)
    REFERENCES `shoes_shop_db`.`staff` (`s_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_refund_pickup`
    FOREIGN KEY (`pic_seq`)
    REFERENCES `shoes_shop_db`.`pickup` (`pic_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_refund_reason_category`
    FOREIGN KEY (`ref_re_seq`)
    REFERENCES `shoes_shop_db`.`refund_reason_category` (`ref_re_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '오프라인 반품/환불 기록';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`receive`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`receive` (
  `rec_seq` INT NOT NULL AUTO_INCREMENT COMMENT '입고 고유 ID(PK)',
  `rec_quantity` INT NULL DEFAULT 0 COMMENT '입고 수량',
  `rec_date` DATETIME NULL DEFAULT NULL COMMENT '입고 처리 일시',
  `s_seq` INT NOT NULL COMMENT '입고 처리 직원 ID(FK)',
  `p_seq` INT NOT NULL COMMENT '입고 제품 ID(FK)',
  `m_seq` INT NOT NULL COMMENT '제조사 ID(FK)',
  PRIMARY KEY (`rec_seq`),
  INDEX `idx_receive_s_seq` (`s_seq` ASC) VISIBLE,
  INDEX `idx_receive_p_seq` (`p_seq` ASC) VISIBLE,
  INDEX `idx_receive_m_seq` (`m_seq` ASC) VISIBLE,
  INDEX `idx_receive_rec_date` (`rec_date` ASC) VISIBLE,
  INDEX `fk_receive_staff` (`s_seq` ASC) VISIBLE,
  INDEX `fk_receive_product` (`p_seq` ASC) VISIBLE,
  INDEX `fk_receive_maker` (`m_seq` ASC) VISIBLE,
  CONSTRAINT `fk_receive_staff`
    FOREIGN KEY (`s_seq`)
    REFERENCES `shoes_shop_db`.`staff` (`s_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_receive_product`
    FOREIGN KEY (`p_seq`)
    REFERENCES `shoes_shop_db`.`product` (`p_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_receive_maker`
    FOREIGN KEY (`m_seq`)
    REFERENCES `shoes_shop_db`.`maker` (`m_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '제조사 입고 처리';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`request`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`request` (
  `req_seq` INT NOT NULL AUTO_INCREMENT COMMENT '발주/품의 고유 ID(PK)',
  `req_date` DATETIME NULL DEFAULT NULL COMMENT '발주 요청 일시',
  `req_content` TEXT NULL DEFAULT NULL COMMENT '발주 내용',
  `req_quantity` INT NULL DEFAULT 0 COMMENT '발주 수량',
  `req_manappdate` DATETIME NULL DEFAULT NULL COMMENT '팀장 결재 일시',
  `req_dirappdate` DATETIME NULL DEFAULT NULL COMMENT '이사 결재 일시',
  `s_seq` INT NOT NULL COMMENT '발주 요청 직원 ID(FK)',
  `p_seq` INT NOT NULL COMMENT '발주 제품 ID(FK)',
  `m_seq` INT NOT NULL COMMENT '제조사 ID(FK)',
  `s_superseq` INT NULL DEFAULT NULL COMMENT '승인자 직원 ID(논리 참조)',
  PRIMARY KEY (`req_seq`),
  INDEX `idx_request_s_seq` (`s_seq` ASC) VISIBLE,
  INDEX `idx_request_p_seq` (`p_seq` ASC) VISIBLE,
  INDEX `idx_request_m_seq` (`m_seq` ASC) VISIBLE,
  INDEX `idx_request_req_date` (`req_date` ASC) VISIBLE,
  INDEX `idx_request_req_manappdate` (`req_manappdate` ASC) VISIBLE,
  INDEX `idx_request_req_dirappdate` (`req_dirappdate` ASC) VISIBLE,
  INDEX `fk_request_staff` (`s_seq` ASC) VISIBLE,
  INDEX `fk_request_product` (`p_seq` ASC) VISIBLE,
  INDEX `fk_request_maker` (`m_seq` ASC) VISIBLE,
  CONSTRAINT `fk_request_staff`
    FOREIGN KEY (`s_seq`)
    REFERENCES `shoes_shop_db`.`staff` (`s_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_request_product`
    FOREIGN KEY (`p_seq`)
    REFERENCES `shoes_shop_db`.`product` (`p_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_request_maker`
    FOREIGN KEY (`m_seq`)
    REFERENCES `shoes_shop_db`.`maker` (`m_seq`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '재고 부족 시 발주/품의 기록';


-- -----------------------------------------------------
-- Table `shoes_shop_db`.`chatting`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `shoes_shop_db`.`chatting` (
  `chatting_seq` INT NOT NULL AUTO_INCREMENT COMMENT '채팅 세션 고유 ID(PK)',
  `u_seq` INT NOT NULL COMMENT '고객 번호(논리적 참조 → user.u_seq)',
  `fb_doc_id` VARCHAR(100) NULL DEFAULT NULL COMMENT 'Firebase Firestore 문서 ID',
  `s_seq` INT NULL DEFAULT NULL COMMENT '담당 직원 번호(논리적 참조 → staff.s_seq, 선택 사항)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '채팅 세션 생성 일시',
  `is_closed` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '채팅 종료 여부 (0: 진행중, 1: 종료)',
  PRIMARY KEY (`chatting_seq`),
  INDEX `idx_chatting_u_seq` (`u_seq` ASC) VISIBLE,
  INDEX `idx_chatting_s_seq` (`s_seq` ASC) VISIBLE,
  INDEX `idx_chatting_created_at` (`created_at` ASC) VISIBLE,
  INDEX `idx_chatting_is_closed` (`is_closed` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = '고객-직원 채팅 세션';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
