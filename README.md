<p align="right">
  <b><a href="./README.en.md">English</a></b>
</p>

<div align="center">
  <img src="./images/onboarding.png">
  <h1>Claudemeter for macOS</h1>
  <strong>Claude.ai 사용량을 한 눈에 모니터링하세요.</strong>
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

- **실시간 사용량 모니터링**: 현재 세션 한도와 주간 한도를 실시간으로 확인할 수 있어요.
  <img src="./images/popover.png" width="400px">
  <p>

- **사용량 소진 시간 예측(옵션)**: 선형 회귀(Linear Regression)를 이용해 최근 사용량 변동을 분석하여 예상 소진 시점을 보조 정보로 제공합니다.
    <details>
    <summary> 예측 소진 시간은 어떻게 확인하나요?</summary>
    '설정' > '일반'에서 `메뉴 막대에 텍스트 표시`를 켠 뒤, `사용량 소진 시간 예측 표시`를 활성화하면 팝업에서 확인할 수 있습니다.

    - 메뉴 막대의 `남은 시간` 및 `모두 표시`는 항상 **세션 재설정 시간 기준**으로 표시됩니다.
    - `사용량 소진 시간 예측 표시`가 켜져 있을 때만, 팝업의 각 막대 하단 텍스트에 `(n시간 n분 후 소진 예상)`이 추가됩니다.
    - 예측 소진 시점이 재설정 시점보다 늦으면 해당 보조 문구는 표시되지 않습니다.

    </details>

  <p>


- **알림 및 경고 기능**: 새로운 세션이 시작되거나 설정한 사용량에 도달했을 때 사용자에게 알림을 제공합니다.

  <img src="./images/notification.png" width="300px">

  <img src="./images/usage.png" width="300px">
  <p>
- **사용자 커스터마이징**: 메뉴 막대 텍스트 형식(남은 시간, 사용량, 모두 표시)과 소진 예측 표시 여부를 선택할 수 있어요.

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

### 보안 경고 해결하기
앱 실행 시 보안 경고가 뜬다면, Control 키를 누른 상태로 앱을 클릭한 뒤 **열기(Open)를** 선택하거나, 터미널에서 아래 명령어를 입력해주세요.

```Bash
xattr -cr /Applications/Claudemeter.app
```

---

### 애플리케이션 라이선스

<img src="./images/logo.png" width="64px">


**MIT License (Open Source License)**

### 면책 조항
해당 애플리케이션은 Anthropic, PBC와 무관한 독립적인 서드파티 도구이며, 어떠한 제휴나 보증 및 후원 관계도 존재하지 않습니다. 'Claude', 'Claude.ai'는 Anthropic, PBC의 상표입니다. 기타 모든 제품명, 로고 및 브랜드의 소유권은 해당 소유자에게 있습니다.
