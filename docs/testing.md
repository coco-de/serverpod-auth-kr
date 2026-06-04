# 테스트 가이드

## 단위 테스트 (DB 불필요)

순수 파싱 로직(`parse{Kakao,Naver}Profile`, `parse*TokenResponse`) — codegen/DB 없이 즉시 실행.

```bash
cd packages/serverpod_auth_idp_naver_server && dart test test/naver_profile_test.dart
cd packages/serverpod_auth_idp_kakao_server && dart test test/kakao_profile_test.dart
```

## 통합 테스트 (withServerpod + PostgreSQL)

`authenticate()` 전체 흐름을 **실 PostgreSQL 테스트 DB**에 대해 검증 — userinfo HTTP는 `MockClient`로 목킹, AuthUser/Account 생성·dedup을 실제 DB row로 확인.

### 사전 준비 (패키지별)

```bash
cd packages/serverpod_auth_idp_naver_server   # 또는 _kakao_server

# 1. 시크릿 파일 생성 (gitignore — 로컬 전용)
cp config/passwords.example.yaml config/passwords.yaml

# 2. serverpod 코드 생성 + 마이그레이션 (최초 1회)
dart pub get
serverpod generate
serverpod create-migration   # 이미 migrations/ 있으면 생략 가능

# 3. 테스트 DB 기동 (naver=9090, kakao=9092)
docker compose up -d postgres_test

# 4. 통합 테스트 실행 (withServerpod가 마이그레이션 자동 적용)
dart test test/integration
```

> **docker client/daemon API 불일치 시**: `DOCKER_API_VERSION=1.44 docker compose ...` / `DOCKER_API_VERSION=1.44 dart test ...`.

### 검증 범위

| 케이스 | 검증 |
|--------|------|
| 신규 사용자 | AuthUser + `{Provider}Account` row 생성, userIdentifier·email(소문자) 매핑 |
| 동일 id 재인증 | AuthUser 재사용(dedup), account row 1개 유지 |
| 이메일 미동의(Kakao) | email null 저장 |
| 미인증 세션 getAccount | null 반환 |

### 정리

```bash
docker compose down            # 컨테이너 중지
docker compose down -v         # 볼륨까지 삭제(DB 초기화)
```

## 현재 커버리지

| 패키지 | 단위 | 통합 | 합계 |
|--------|------|------|------|
| naver_server | 10 | 3 | 13 |
| kakao_server | 9 | 3 | 12 |
