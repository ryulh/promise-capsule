-- 약속 캡슐 - DB 스키마 (MySQL 8.0, InnoDB, utf8mb4)
--
-- 새 서버 설치는 이 파일만 실행한다. 빈 테이블이 만들어진다.
-- 시연, 채점 확인용 예시 데이터는 demo-data.sql (선택, 운영 서버에서는 실행하지 않음).
--
-- 주의: 맨 앞에서 기존 테이블을 지운다. 이미 쓰고 있는 DB에서는 실행하지 마세요.
-- 실행 예: mysql -u <사용자> -p < schema.sql

CREATE DATABASE IF NOT EXISTS promise_capsule
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE promise_capsule;

-- 참조하는 쪽부터 지운다.
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS letters;
DROP TABLE IF EXISTS capsule_members;
DROP TABLE IF EXISTS capsules;
DROP TABLE IF EXISTS users;

-- 회원
CREATE TABLE users (
  id             INT          NOT NULL AUTO_INCREMENT,
  login_id       VARCHAR(20)  NOT NULL,
  password_hash  CHAR(64)     NOT NULL,   -- SHA-256 -> 16진수 64자
  nickname       VARCHAR(12)  NOT NULL,
  email          VARCHAR(100) NOT NULL,
  notify_on_open BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at     DATETIME     NOT NULL,
  CONSTRAINT pk_users          PRIMARY KEY (id),
  CONSTRAINT uq_users_login_id UNIQUE (login_id),
  CONSTRAINT uq_users_nickname UNIQUE (nickname)
) ENGINE = InnoDB;

-- 캡슐 (개설자는 owner_id에만)
CREATE TABLE capsules (
  id          INT          NOT NULL AUTO_INCREMENT,
  owner_id    INT          NOT NULL,
  title       VARCHAR(40)  NOT NULL,
  description VARCHAR(200) NOT NULL DEFAULT '',
  open_at     DATETIME     NOT NULL,
  status      VARCHAR(10)  NOT NULL DEFAULT 'DRAFT',
  invite_code CHAR(8)      NOT NULL,
  sealed_at   DATETIME     NULL,
  created_at  DATETIME     NOT NULL,
  CONSTRAINT pk_capsules                  PRIMARY KEY (id),
  CONSTRAINT uq_capsules_invite_code      UNIQUE (invite_code),
  CONSTRAINT fk_capsules_owner_id         FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE RESTRICT,
  CONSTRAINT ck_capsules_status           CHECK (status IN ('DRAFT', 'SEALED')),
  CONSTRAINT ck_capsules_sealed_at        CHECK ((status = 'DRAFT'  AND sealed_at IS NULL)
                                              OR (status = 'SEALED' AND sealed_at IS NOT NULL)),
  CONSTRAINT ck_capsules_seal_before_open CHECK (sealed_at IS NULL OR sealed_at < open_at),
  INDEX ix_capsules_status_open_at (status, open_at)
) ENGINE = InnoDB;

-- 참여 (회원 M:N 캡슐, 역할 열 없음). 캡슐을 지우면 참여, 편지, 사진, 한마디가 함께 지워진다(CASCADE).
CREATE TABLE capsule_members (
  capsule_id        INT      NOT NULL,
  user_id           INT      NOT NULL,
  joined_at         DATETIME NOT NULL,
  first_opened_at   DATETIME NULL,
  notified_at       DATETIME NULL,
  notify_fail_count INT      NOT NULL DEFAULT 0,
  CONSTRAINT pk_capsule_members            PRIMARY KEY (capsule_id, user_id),
  CONSTRAINT fk_capsule_members_capsule_id FOREIGN KEY (capsule_id) REFERENCES capsules (id) ON DELETE CASCADE,
  CONSTRAINT fk_capsule_members_user_id    FOREIGN KEY (user_id)    REFERENCES users (id)    ON DELETE RESTRICT,
  CONSTRAINT ck_capsule_members_fail_count CHECK (notify_fail_count >= 0)
) ENGINE = InnoDB;

-- 편지 (참여 행에 복합 외래 키, 철회하면 본문 NULL)
CREATE TABLE letters (
  id           INT           NOT NULL AUTO_INCREMENT,
  capsule_id   INT           NOT NULL,
  user_id      INT           NOT NULL,
  body         VARCHAR(2000) NULL,
  created_at   DATETIME      NOT NULL,
  updated_at   DATETIME      NOT NULL,
  withdrawn_at DATETIME      NULL,
  CONSTRAINT pk_letters              PRIMARY KEY (id),
  CONSTRAINT uq_letters_capsule_user UNIQUE (capsule_id, user_id),
  CONSTRAINT fk_letters_member       FOREIGN KEY (capsule_id, user_id)
                                     REFERENCES capsule_members (capsule_id, user_id) ON DELETE CASCADE,
  CONSTRAINT ck_letters_withdrawn    CHECK ((withdrawn_at IS NULL     AND body IS NOT NULL)
                                         OR (withdrawn_at IS NOT NULL AND body IS NULL))
) ENGINE = InnoDB;

-- 사진 (파일은 {upload.dir}/{캡슐번호}/{stored_name})
CREATE TABLE photos (
  id            INT          NOT NULL AUTO_INCREMENT,
  letter_id     INT          NOT NULL,
  stored_name   VARCHAR(255) NOT NULL,   -- 캡슐 폴더 안 파일 이름(같은 이름이면 cos가 뒤에 번호를 붙임)
  original_name VARCHAR(255) NOT NULL,
  mime_type     VARCHAR(20)  NOT NULL,
  size_bytes    INT          NOT NULL,
  sort_order    INT          NOT NULL,
  created_at    DATETIME     NOT NULL,
  CONSTRAINT pk_photos              PRIMARY KEY (id),
  CONSTRAINT uq_photos_letter_order UNIQUE (letter_id, sort_order),
  CONSTRAINT fk_photos_letter_id    FOREIGN KEY (letter_id) REFERENCES letters (id) ON DELETE CASCADE,
  CONSTRAINT ck_photos_mime_type    CHECK (mime_type IN ('image/jpeg', 'image/png')),
  CONSTRAINT ck_photos_size_bytes   CHECK (size_bytes > 0)
) ENGINE = InnoDB;

-- 한마디 (참여 행에 복합 외래 키)
CREATE TABLE comments (
  id         INT          NOT NULL AUTO_INCREMENT,
  capsule_id INT          NOT NULL,
  user_id    INT          NOT NULL,
  body       VARCHAR(300) NOT NULL,
  created_at DATETIME     NOT NULL,
  edited_at  DATETIME     NULL,
  CONSTRAINT pk_comments           PRIMARY KEY (id),
  CONSTRAINT fk_comments_member    FOREIGN KEY (capsule_id, user_id)
                                   REFERENCES capsule_members (capsule_id, user_id) ON DELETE CASCADE,
  CONSTRAINT ck_comments_edited_at CHECK (edited_at IS NULL OR edited_at >= created_at)
) ENGINE = InnoDB;
