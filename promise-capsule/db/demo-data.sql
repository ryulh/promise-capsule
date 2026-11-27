-- 약속 캡슐 - 시연 데이터 (demo-data.sql)
--
-- 시연, 채점 확인용 예시 데이터. 공개된 시험 비밀번호 계정이 들어 있으니
-- 실제 운영 서버에서는 실행하지 마세요. 설치 필수가 아닙니다(schema.sql만으로 빈 서비스).
--
-- 시연 회원 6명(jimin, doyun, seoyeon, hajun, minji, yuna)의 시험 비밀번호: capsule2026
-- 사진 파일: db/demo-photos/ 아래 폴더를 설정 upload.dir 아래로 그대로 복사 (README).
-- 이메일은 모두 @example.com(받는 사람 없음). 메일을 받아 보려면 한 명만 자기 주소로 바꾸세요.
--
-- 시각은 실행 순간 기준 상대값 -> 언제 실행해도 같은 상태가 나온다.
--   A 작성 중, B 기한 경과, C 잠김, D 실행 1분 뒤 열림, E 개봉됨
-- 실행 순서: schema.sql 다음에 실행.

USE promise_capsule;
SET time_zone = '+09:00';
SET @now = NOW();

-- 회원
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (1, 'jimin', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '지민', 'jimin@example.com', TRUE, @now - INTERVAL 200 DAY);
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (2, 'doyun', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '도윤', 'doyun@example.com', TRUE, @now - INTERVAL 200 DAY);
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (3, 'seoyeon', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '서연', 'seoyeon@example.com', TRUE, @now - INTERVAL 200 DAY);
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (4, 'hajun', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '하준', 'hajun@example.com', TRUE, @now - INTERVAL 200 DAY);
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (5, 'minji', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '민지', 'minji@example.com', TRUE, @now - INTERVAL 200 DAY);
INSERT INTO users (id, login_id, password_hash, nickname, email, notify_on_open, created_at) VALUES (6, 'yuna', '73efc934c4163fb402bf7ba74fdb133a43fb0593eb63da7847bfe9ff22c6df78', '유나', 'yuna@example.com', TRUE, @now - INTERVAL 200 DAY);

-- 캡슐 (초대 코드: 혼동 문자 0, O, 1, I, L 제외)
INSERT INTO capsules (id, owner_id, title, description, open_at, status, invite_code, sealed_at, created_at) VALUES (1, 1, '우리 졸업 1년 뒤', '졸업하고 1년 뒤의 우리에게', @now + INTERVAL 30 DAY, 'DRAFT', 'A7K3M9PQ', NULL, @now - INTERVAL 5 DAY);
INSERT INTO capsules (id, owner_id, title, description, open_at, status, invite_code, sealed_at, created_at) VALUES (2, 2, '작년 여름 여행', '제주에서 보낸 나흘', @now - INTERVAL 1 DAY, 'DRAFT', 'B4N8R2TW', NULL, @now - INTERVAL 40 DAY);
INSERT INTO capsules (id, owner_id, title, description, open_at, status, invite_code, sealed_at, created_at) VALUES (3, 3, '1년 뒤 우리에게', '', @now + INTERVAL 100 DAY, 'SEALED', 'C6P9X3HZ', @now - INTERVAL 20 DAY, @now - INTERVAL 30 DAY);
INSERT INTO capsules (id, owner_id, title, description, open_at, status, invite_code, sealed_at, created_at) VALUES (4, 1, '곧 열리는 캡슐', '시연용: 실행 1분 뒤 열려요', @now + INTERVAL 1 MINUTE, 'SEALED', 'D2M7Q4YK', @now - INTERVAL 10 DAY, @now - INTERVAL 15 DAY);
INSERT INTO capsules (id, owner_id, title, description, open_at, status, invite_code, sealed_at, created_at) VALUES (5, 4, '101일 전의 우리', '졸업작품 발표 끝난 날', @now - INTERVAL 1 HOUR, 'SEALED', 'E8T3V6GJ', @now - INTERVAL 101 DAY - INTERVAL 1 HOUR, @now - INTERVAL 110 DAY);

-- 참여 (개설자 포함, 참여 순서 = 참여 일시)
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (1, 1, @now - INTERVAL 5 DAY + INTERVAL 0 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (1, 2, @now - INTERVAL 5 DAY + INTERVAL 2 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (1, 3, @now - INTERVAL 5 DAY + INTERVAL 4 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (1, 5, @now - INTERVAL 5 DAY + INTERVAL 6 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (2, 2, @now - INTERVAL 40 DAY + INTERVAL 0 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (2, 1, @now - INTERVAL 40 DAY + INTERVAL 2 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (2, 6, @now - INTERVAL 40 DAY + INTERVAL 4 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (3, 3, @now - INTERVAL 30 DAY + INTERVAL 0 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (3, 1, @now - INTERVAL 30 DAY + INTERVAL 2 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (3, 2, @now - INTERVAL 30 DAY + INTERVAL 4 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (3, 4, @now - INTERVAL 30 DAY + INTERVAL 6 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (3, 5, @now - INTERVAL 30 DAY + INTERVAL 8 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (4, 1, @now - INTERVAL 15 DAY + INTERVAL 0 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (4, 2, @now - INTERVAL 15 DAY + INTERVAL 2 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (4, 6, @now - INTERVAL 15 DAY + INTERVAL 4 HOUR, NULL, NULL, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 4, @now - INTERVAL 110 DAY + INTERVAL 0 HOUR, @now - INTERVAL 55 MINUTE, @now - INTERVAL 59 MINUTE, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 1, @now - INTERVAL 110 DAY + INTERVAL 2 HOUR, NULL, @now - INTERVAL 59 MINUTE, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 2, @now - INTERVAL 110 DAY + INTERVAL 4 HOUR, @now - INTERVAL 53 MINUTE, @now - INTERVAL 59 MINUTE, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 3, @now - INTERVAL 110 DAY + INTERVAL 6 HOUR, @now - INTERVAL 52 MINUTE, @now - INTERVAL 59 MINUTE, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 5, @now - INTERVAL 110 DAY + INTERVAL 8 HOUR, NULL, @now - INTERVAL 59 MINUTE, 0);
INSERT INTO capsule_members (capsule_id, user_id, joined_at, first_opened_at, notified_at, notify_fail_count) VALUES (5, 6, @now - INTERVAL 110 DAY + INTERVAL 10 HOUR, NULL, @now - INTERVAL 59 MINUTE, 0);

-- 편지 (철회는 본문 NULL + 철회 일시)
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (1, 1, 1, '1년 뒤의 우리에게.\n지금은 다들 졸업 준비로 정신없지만, 1년 뒤에는 조금 여유가 생겼으면 좋겠다.\n동아리방에서 밤새던 날들 잊지 말자!', @now - INTERVAL 4 DAY, @now - INTERVAL 4 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (2, 1, 2, '도윤이야. 1년 뒤에도 우리 이렇게 모일 수 있겠지?\n그때는 내가 밥 살게.', @now - INTERVAL 3 DAY, @now - INTERVAL 3 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (3, 2, 2, '여행 마지막 날 본 노을, 1년 뒤에 다시 보자.', @now - INTERVAL 35 DAY, @now - INTERVAL 35 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (4, 3, 3, '서연이가 1년 뒤의 우리에게. 다들 원하는 곳에 있기를.', @now - INTERVAL 25 DAY, @now - INTERVAL 25 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (5, 3, 1, '지민. 1년 뒤에 이 편지를 열면 꼭 연락하기!', @now - INTERVAL 24 DAY, @now - INTERVAL 24 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (6, 3, 2, NULL, @now - INTERVAL 23 DAY, @now - INTERVAL 23 DAY, @now - INTERVAL 2 DAY);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (7, 3, 4, '하준이야. 1년 동안 운동 꾸준히 했는지 확인할 거야.', @now - INTERVAL 22 DAY, @now - INTERVAL 22 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (8, 4, 1, '곧 열릴 캡슐이야. 열리면 다 같이 한마디 남기자.', @now - INTERVAL 12 DAY, @now - INTERVAL 12 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (9, 4, 2, '마지막 수업 끝나고 찍은 사진 넣어 둘게.', @now - INTERVAL 12 DAY, @now - INTERVAL 12 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (10, 4, 6, '유나. 이 캡슐이 열릴 때쯤엔 다들 어떤 모습일까?', @now - INTERVAL 11 DAY, @now - INTERVAL 11 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (11, 5, 4, '101일 전의 우리에게.\n발표 끝나고 다 같이 떡볶이 먹으러 간 거 기억나?\n그날 찍은 사진 두 장 넣어 둔다.', @now - INTERVAL 105 DAY, @now - INTERVAL 105 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (12, 5, 2, '도윤. 발표 전날 밤새서 슬라이드 고친 거, 지금 생각하면 웃기다.', @now - INTERVAL 104 DAY, @now - INTERVAL 104 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (13, 5, 3, '서연이야. 단체사진 넣어 둘게. 다들 표정 진짜 웃겨.', @now - INTERVAL 104 DAY, @now - INTERVAL 104 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (14, 5, 5, '민지. 도서관에서 같이 밤샌 날들이 제일 기억에 남을 것 같아.\n축제 부스 사진도 넣어 뒀어.', @now - INTERVAL 103 DAY, @now - INTERVAL 103 DAY, NULL);
INSERT INTO letters (id, capsule_id, user_id, body, created_at, updated_at, withdrawn_at) VALUES (15, 5, 6, NULL, @now - INTERVAL 103 DAY, @now - INTERVAL 103 DAY, @now - INTERVAL 30 DAY);

-- 사진 (stored_name = db/demo-photos/{캡슐번호}/ 아래 파일 이름)
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (1, 1, '졸업식_운동장.jpg', '졸업식_운동장.jpg', 'image/jpeg', 222412, 1, (SELECT created_at FROM letters WHERE id = 1));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (2, 1, '동아리방.png', '동아리방.png', 'image/png', 837552, 2, (SELECT created_at FROM letters WHERE id = 1));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (3, 5, 'IMG_0412.jpg', 'IMG_0412.jpg', 'image/jpeg', 231421, 1, (SELECT created_at FROM letters WHERE id = 5));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (4, 9, '마지막_수업.jpg', '마지막_수업.jpg', 'image/jpeg', 191795, 1, (SELECT created_at FROM letters WHERE id = 9));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (5, 11, '졸업작품_발표날.jpg', '졸업작품_발표날.jpg', 'image/jpeg', 88992, 1, (SELECT created_at FROM letters WHERE id = 11));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (6, 11, 'IMG_1180.jpg', 'IMG_1180.jpg', 'image/jpeg', 294907, 2, (SELECT created_at FROM letters WHERE id = 11));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (7, 13, '단체사진.png', '단체사진.png', 'image/png', 1805222, 1, (SELECT created_at FROM letters WHERE id = 13));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (8, 14, 'IMG_2041.jpg', 'IMG_2041.jpg', 'image/jpeg', 262765, 1, (SELECT created_at FROM letters WHERE id = 14));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (9, 14, '도서관_밤샘.png', '도서관_밤샘.png', 'image/png', 580212, 2, (SELECT created_at FROM letters WHERE id = 14));
INSERT INTO photos (id, letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at) VALUES (10, 14, '축제_부스.jpg', '축제_부스.jpg', 'image/jpeg', 148665, 3, (SELECT created_at FROM letters WHERE id = 14));

-- 한마디 (개봉된 E만, 1개는 수정됨)
INSERT INTO comments (id, capsule_id, user_id, body, created_at, edited_at) VALUES (1, 5, 2, '다들 101일 전에 이런 생각을 했구나 ㅋㅋ', @now - INTERVAL 40 MINUTE, NULL);
INSERT INTO comments (id, capsule_id, user_id, body, created_at, edited_at) VALUES (2, 5, 3, '이번 주말에 다 같이 모이자!', @now - INTERVAL 30 MINUTE, @now - INTERVAL 25 MINUTE);
INSERT INTO comments (id, capsule_id, user_id, body, created_at, edited_at) VALUES (3, 5, 4, '진짜 금방 갔다. 내년에 또 만들자', @now - INTERVAL 20 MINUTE, NULL);
