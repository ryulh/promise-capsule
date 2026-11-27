# 약속 캡슐

경기대학교 지능웹설계 기말 프로젝트입니다.

약속 캡슐은 여러 사람이 함께 쓰는 타임캡슐 웹 서비스입니다. 개설자가 캡슐을 만들고 초대 링크로 친구를 부르면, 참여자들이 편지와 사진을 남깁니다. 봉인한 캡슐은 정한 개봉 일시가 되어야 열 수 있습니다. JSP와 MySQL로 만든 Eclipse Dynamic Web Project입니다.

## 폴더 구성

- `promise-capsule/src/main/java`: Java 소스(DAO, DTO, DB 연결, 메일 작업)와 화면 문구 파일(`bundle`)
- `promise-capsule/src/main/webapp`: JSP, CSS, JavaScript, 이미지. 시작 화면은 `index.jsp`
- `promise-capsule/db`: DB를 만드는 `schema.sql`, 시연 데이터 `demo-data.sql`, 시연 사진

## 개발 환경

- JDK 20
- Eclipse IDE for Enterprise Java and Web Developers
- Apache Tomcat 10.1
- MySQL 8.0
- 문자 인코딩 UTF-8

## 실행 방법

1. **DB 만들기**: MySQL에서 `promise-capsule/db/schema.sql`을 실행하면 `promise_capsule` DB와 빈 테이블이 만들어집니다. 같은 이름의 테이블이 있으면 지우고 새로 만듭니다.
2. **시연 데이터 넣기(선택)**: 이어서 `promise-capsule/db/demo-data.sql`을 실행합니다. 실행한 시각을 기준으로 작성 중, 여는 날 지남, 잠김, 1분 뒤 열림, 열림 상태의 캡슐이 만들어집니다. 시연 계정은 아래 "시연 데이터 둘러보기"에 적었습니다.
3. **시연 사진 복사(선택)**: 2번을 했다면 `promise-capsule/db/demo-photos/` 안의 폴더들을 사진 저장 폴더(`C:/promise-capsule/photos`) 아래로 그대로 복사합니다.
4. **설정 파일 만들기**: `promise-capsule/src/main/webapp/WEB-INF/config/app.properties.example`을 같은 폴더에 `app.properties`라는 이름으로 복사하고, `db.user`와 `db.password`에 MySQL 아이디와 비밀번호를 적습니다. 비밀번호가 들어가는 파일이라 저장소에는 올리지 않았습니다.
5. **Eclipse로 가져오기**: File > Import > General > Existing Projects into Workspace에서 이 저장소 폴더를 고르고 `promise-capsule`을 가져옵니다. JDK 20과 Tomcat 10.1이 Eclipse에 등록되어 있어야 합니다.
6. **실행**: Servers의 Tomcat에 `promise-capsule`을 추가하고 서버를 시작한 뒤 http://localhost:8080/promise-capsule/ 를 엽니다.

설정 파일에 대한 참고 사항입니다.

- 개봉 알림 메일은 `mail.user`, `mail.password`, `mail.from`을 채워야 보내집니다. Gmail을 쓸 때 `mail.password`에는 계정 비밀번호가 아니라 Google에서 만든 앱 비밀번호를 넣습니다. 비워 두면 메일만 보내지 않고 나머지 기능은 그대로 동작합니다.
- `seal.minIntervalMinutes=1`은 시연을 위해 봉인 후 1분 뒤부터 열 수 있게 한 값입니다. 이 줄을 지우면 봉인 후 하루가 지나야 열 수 있습니다.

## 시연 데이터 둘러보기

`demo-data.sql`을 넣으면 회원 6명이 만들어집니다. 아이디는 `jimin`, `doyun`, `seoyeon`, `hajun`, `minji`, `yuna`이고 비밀번호는 모두 `capsule2026`입니다.

`jimin`으로 로그인하면 내 캡슐 목록에서 다섯 가지 상태의 캡슐을 모두 볼 수 있습니다.

| 캡슐 | 상태 | 볼 수 있는 것 |
|---|---|---|
| 우리 졸업 1년 뒤 | 작성 중 | 편지 쓰기, 사진 올리기, 초대 링크, 봉인(`jimin`이 개설자) |
| 작년 여름 여행 | 여는 날 지남 | 봉인하지 못한 채 여는 날이 지난 캡슐의 안내 |
| 1년 뒤 우리에게 | 잠김 | 남은 시간 표시 |
| 곧 열리는 캡슐 | 1분 뒤 열림 | 데이터를 넣고 1분이 지나면 열림 |
| 101일 전의 우리 | 열림 | 처음 들어가면 개봉 연출, 그 뒤 편지와 사진, 한마디 |

시연 회원의 이메일은 모두 `@example.com`이라 실제로 메일이 가지 않습니다. 알림 메일을 받아 보려면 메일 설정을 채운 뒤 내 정보 화면에서 한 명의 이메일을 자기 주소로 바꿉니다.

## 사용한 라이브러리 (`WEB-INF/lib`)

| jar | 버전 | 받은 곳 | 쓰임 |
|---|---|---|---|
| `mysql-connector-j-8.0.33.jar` | 8.0.33 | 수업 자료 | MySQL 연결(JDBC) |
| `cos2.jar` | Tomcat 10용 | 수업 자료 | 사진 업로드(`MultipartRequest`) |
| `jakarta.servlet.jsp.jstl-api-2.0.0.jar` | 2.0.0 | 수업 자료 | JSTL |
| `jakarta.servlet.jsp.jstl-2.0.0.jar` | 2.0.0 | 수업 자료 | JSTL |
| `jakarta.mail-api-2.1.5.jar` | 2.1.5 | Maven Central | 개봉 알림 메일 |
| `angus-mail-2.0.5.jar` | 2.0.5 | Maven Central | 개봉 알림 메일 |
| `jakarta.activation-api-2.1.4.jar` | 2.1.4 | Maven Central | 개봉 알림 메일 |
| `angus-activation-2.0.3.jar` | 2.0.3 | Maven Central | 개봉 알림 메일 |

메일 라이브러리 4개는 Tomcat에 들어 있지 않아서 직접 받아 함께 넣었습니다.

글꼴은 Pretendard와 검은고딕(SIL OFL 1.1), 아이콘은 Lucide(ISC 라이선스)를 썼고, 라이선스 파일은 각 폴더에 함께 두었습니다.
