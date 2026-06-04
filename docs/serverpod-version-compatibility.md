# Serverpod 버전 호환성

## 요약

| | 버전 | 비고 |
|---|------|------|
| 본 패키지 의존 | `serverpod ^3.4.0`, `serverpod_auth_idp_server ^3.4.8`, `serverpod_auth_core_server ^3.4.8` (pub.dev stable) | 독립 개발/배포 기준 |
| 본 패키지 검증 | serverpod_cli **3.4.8** 로 `dart pub get` + `serverpod generate` + `dart analyze`(0 issue) + `dart test`(19 green) | ✅ |
| 소비처(kobic) | serverpod **3.5.0-beta.9** (git ref `435fb29`) | dependency_overrides로 통합 |

## 왜 3.4.8(stable)을 타깃하는가

재사용 가능한 공개 패키지는 **stable**을 타깃하는 것이 표준입니다. pub.dev에 publish 가능하고, 특정 베타에 고정되지 않습니다.

## beta.9(kobic)와 호환되는 근거

### 1. API 호환 — 구성상 보장(proven by construction)
provider 구현은 **kobic이 사용하는 바로 그 serverpod git ref(`435fb29`, = 3.5.0-beta 계열) 소스의 `github` provider를 미러링**해 작성했습니다. 따라서 사용하는 모든 공개 API가 beta.9에 **존재가 보장**됩니다:

- `IdentityProviderBuilder<T>` / `AuthServices`
- `OAuth2PkceUtil`, `OAuth2PkceServerConfig`, `OAuth2PkceTokenResponse`, `OAuth2*Exception`
- `AuthUsers.create/get`, `UserProfiles.createUserProfile/setUserImageFromUrl`
- `TokenIssuer.issueToken`, `AuthSuccess`, `AuthUserModel`, `UserProfileData`, `UserImageFromUrl`

동일한 코드가 **3.4.8 stable에서도** `serverpod generate` + `analyze`(0건) + `test`(19건) 통과 → 본 패키지가 의존하는 공개 API 표면은 **3.4.8 ↔ beta.9에서 동일**합니다.

### 2. 소스는 버전 비종속
패키지 `lib/` 소스는 위 안정적 공개 API만 사용합니다. 생성 코드(`lib/src/generated/**`, client `lib/src/protocol/**`)만 serverpod 버전에 종속됩니다.

### 3. 생성 코드는 소비처 버전으로 재생성
kobic에 통합되면 kobic의 `serverpod generate`(= beta.9 CLI)가 모듈 protocol을 **beta.9에 맞춰 재생성**합니다. 저장소에 커밋된 3.4.8 기준 생성 코드는 독립 사용/참조용입니다.

## kobic(beta.9) 통합 방법

kobic은 git ref serverpod를 쓰므로, kakao/naver 패키지를 추가할 때 **`dependency_overrides`로 serverpod 계열을 동일 git ref로 정렬**합니다. (git ref serverpod 프로젝트가 serverpod 의존 패키지를 소비하는 표준 패턴 — `^3.4.8` 제약은 override가 우회)

```yaml
# kobic 의 pubspec.yaml
dependencies:
  serverpod_auth_idp_kakao_server:
    git:
      url: https://github.com/coco-de/serverpod-auth-kr.git
      path: packages/serverpod_auth_idp_kakao_server
  serverpod_auth_idp_naver_server:
    git: { url: ..., path: packages/serverpod_auth_idp_naver_server }

dependency_overrides:
  # kobic 이 이미 쓰는 serverpod git ref 로 정렬 (예시 — 실제 ref 는 kobic 기준)
  serverpod:
    git: { url: https://github.com/serverpod/serverpod, ref: <kobic-ref>, path: packages/serverpod }
  serverpod_auth_idp_server:
    git: { url: ..., ref: <kobic-ref>, path: modules/serverpod_auth/serverpod_auth_idp/serverpod_auth_idp_server }
  serverpod_auth_core_server:
    git: { url: ..., ref: <kobic-ref>, path: modules/serverpod_auth/serverpod_auth_core/serverpod_auth_core_server }
  # client 측도 동일하게 정렬
```

통합 후 kobic 루트에서 `serverpod generate` 1회 → 모든 모듈 protocol이 beta.9 기준으로 재생성됩니다.

## 미검증 항목(정직한 한계)

- kobic 내부에서 beta.9로 실제 빌드한 라이브 검증은 아직 안 함(= serverpod 모노레포 내부 path override를 재현해야 해 비용이 큼). 위 1~3 근거상 안전하나, **확정 검증은 Phase 2 통합 시 kobic에 override 추가 + 재생성**으로 수행.
- 만약 beta.9에서 API가 달라지는 부분이 발견되면 소스 패치 범위는 작음(공개 API 표면이 좁음).

## 체크리스트 (Phase 2 통합)

- [ ] kobic pubspec 에 kakao/naver server+client+flutter 패키지 git 의존 추가
- [ ] `dependency_overrides` 로 serverpod / serverpod_auth_idp_server / serverpod_auth_core_server (+ client) 를 kobic git ref 로 정렬
- [ ] `serverpod generate`(kobic) 재실행 → 모듈 protocol beta.9 재생성
- [ ] `AuthServices.set(identityProviderBuilders: [..., KakaoIdpConfigFromPasswords(), NaverIdpConfigFromPasswords()])`
- [ ] `melos run analyze` + 통합 테스트
