![Onboarding](./images/onboarding.png)

## Claudemeter for macOS

> macOS Menu Bar App to monitor Claude.ai usage limits.

> Claude.ai의 플랜 사용량을 모니터링할 수 있는 macOS 메뉴 바 앱입니다.


### 구현 예정 기능

- [x] 프로젝트 초기화 및 아키텍처 설계
    - Xcode 프로젝트 설정 (MenuBarExtra, Info.plist)
    - MVC 폴더 구조화 (Model, View, Controller, Service, Utils)

- [x] Model 구현 (데이터 및 저장소)
    - UsageModel 구조체 설계 (남은 메시지, 리셋 시간, 플랜 정보)
    - PreferenceModel 구현 (SessionKey 및 사용자 플랜 저장)
    - 보안 저장소(Keychain) 또는 UserDefaults 연동 준비

- [x] Controller & Service 구현
    - APIService 구현 (SessionKey를 쿠키 헤더에 포함한 통신)
    - 내부 API 호출 구현 (조직 ID 조회 및 사용량 데이터 파싱)
    - UsageController 구현 (주기적 데이터 갱신 및 에러 처리)

- [x] View 구현 (UI/UX)
    - MenuBarView 구현 (게이지 바, 카운트다운 타이머)
    - SettingsView 구현 (Session Key 입력, 도움말 등)

- [x] 시스템 기능 통합
    - Launch at Login 구현 (맥 부팅 시 앱 자동 실행)
    - 알림 기능 구현 (리셋 시간 도달 시 알림)

- [x] 예외 처리 및 배포 준비
    - 네트워크 연결 끊김 및 잘못된 키 입력 예외 처리
    - 코드 리팩토링 및 최종 점검