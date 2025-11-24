<p align="right">
  <b><a href="./README.en.md">English</a></b>
</p>

<div align="center">
  <img src="./images/onboarding.png">
  <h1>Claudemeter</h1>
  <strong>Claude AI API 사용량을 모니터링하는 macOS 메뉴바 앱입니다.</strong>
  <p>
  <p>
</div>

<p align="center">
  <a href="https://github.com/in-up/claude-meter/releases/latest"><img src="https://img.shields.io/github/release/in-up/claude-meter/all.svg?colorB=97CA00&label=latest%20version"></a>
  <a href="https://github.com/in-up/claude-meter/releases"><img src="https://img.shields.io/github/downloads/in-up/claude-meter/total.svg?colorB=97CA00&label=total%20downloads"></a>
</p>

---

Claudemeter는 Claude.ai의 사용량 한도를 손쉽게 추적할 수 있도록 돕는 macOS 메뉴 바 애플리케이션입니다. 메뉴 막대 제어 항목을 통해 클로드 사용량에 빠르게 접근하세요.

### 주요 기능

- **실시간 사용량 모니터링**: 현재 세션 한도, 주간 한도, Opus 한도를 실시간으로 확인할 수 있어요.
  <img src="./images/popover.png" width="300px">
  <p>

- **사용량 소진 시간 예측**: 선형 회귀(Linear Regression)를 이용해 최근 사용량 변동을 분석하여 예상되는 사용량 소진 시간을 예측합니다.
    <details>
    <summary> 예측 소진 시간은 어떻게 확인하나요?</summary>
    '설정' > '모양' > '텍스트 형식'에서 '남은 시간'을 활성화하여 확인할 수 있습니다.
    
    예측 소진 시간은 다음 두 시점 중 **사용자에게 더 빠르게 도래하는 시점을 기준**으로 표시됩니다.

    1.  최근 사용량 변동으로부터 선형 회귀(Linear Regression)로 얻어진 소진 예측 시간
    2.  새로운 세션이 시작되는 시간

    **왜 이렇게 표시하나요?**

    만약 예상 소진 시점이 다음 세션 시작 시간보다 늦다면, 사용자는 세션을 모두 소진하기 전에 새 세션을 받게 됩니다. 따라서 사용자가 잔여 시간을 예측하고 계획적으로 사용량을 소진할 수 있도록 하나의 시간만을 표시합니다.

    </details>

  <p>


- **알림 및 경고 기능**: 새로운 세션이 시작되거나 설정한 사용량에 도달했을 때 사용자에게 알림을 제공합니다.

  <img src="./images/notification.png" width="300px">
  <img src="./images/usage.png" width="300px">
  <p>
- **사용자 커스터마이징**: 취향에 맞게 아이콘 모양, 보여지는 텍스트(남은 시간, 사용량(%) 등)를 선택할 수 있어요.

  <img src="./images/shape.png" width="300px">
  <img src="./images/customize.png" width="300px">
  <p>

- **라이트 & 다크 모드 지원**: macOS 26 Tahoe와 완벽하게 통합됩니다.
- **자동 업데이트 확인**: 최신 버전을 유지하여 Claude.ai의 API 및 기능 업데이트에 대응하세요.

---

### 설치

1.  [**Release**](https://github.com/in-up/claude-meter/releases/latest) 페이지로 이동합니다.
2.  `Claudemeter.dmg` 파일을 다운로드합니다.
3.  설치 파일을 열어 `Claudemeter.app`을 `응용 프로그램` 폴더로 드래그합니다.

### 세션 키는 어떻게 얻나요?

1.  Claudemeter 앱을 엽니다. 메뉴바에 새 아이콘이 표시됩니다.
2.  `sessionKey`를 얻으려면 [claude.ai](https://claude.ai)를 방문하여 브라우저의 개발자 도구를 열고, `Application`(또는 `Storage`) 탭으로 이동하여 `claude.ai`의 쿠키를 찾은 다음, `sessionKey` 쿠키의 값을 복사합니다.
3.  메뉴바에서 Claudemeter 아이콘을 클릭하고 **설정**을 엽니다.
4.  **일반** 탭에서 '세션 키' 입력 필드에 `sessionKey`를 붙여넣습니다.
5.  이제 사용량 데이터가 실시간으로 표시됩니다. 설정 화면에서 앱의 모양과 알림을 추가로 변경할 수 있습니다.

<p>


---

### 애플리케이션 라이선스
MIT License (Open Source License)

### 면책 조항
해당 애플리케이션은 Anthropic, PBC와 무관한 독립적인 서드파티 도구이며, 어떠한 제휴나 보증 및 후원 관계도 존재하지 않습니다. 'Claude', 'Claude.ai'는 Anthropic, PBC의 상표입니다. 기타 모든 제품명, 로고 및 브랜드의 소유권은 해당 소유자에게 있습니다.