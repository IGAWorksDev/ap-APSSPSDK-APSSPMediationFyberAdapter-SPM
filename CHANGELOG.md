# APSSPMediationFyber

`Fyber (DT Exchange)` 미디에이션 어댑터 변경 이력

> **각 항목의 제목이 SPM 설치 시 입력하는 버전(태그)입니다.**
> SemVer 3자리 제약으로 어댑터 버전이 인코딩되어 발행됩니다. (`8.1.7.0` → `8010700.0.0`)

---

## 최소 요구사항

| 항목 | 요구 버전 |
|---|---|
| **APSSPSDK (코어)** | `3.4.0` 이상 |
| **iOS Deployment Target** | **`13.0` 이상** |
| Swift Tools | `5.9` 이상 |

**설치**

```swift
.package(url: "https://github.com/IGAWorksDev/ap-APSSPSDK-APSSPMediationFyberAdapter-SPM.git",
         exact: "8041000.0.0")
```

> `Other Linker Flags` 에 **`-ObjC`** 추가 필수. 미설정 시 어댑터가 런타임에 인식되지 않습니다.

---

## 8041000.0.0

DTExchangeSDK `8.4.10` 대응
어댑터 버전 `8.4.10.0`

2026-08-05

## 8040900.0.0

DTExchangeSDK `8.4.9` 대응
어댑터 버전 `8.4.9.0`

2026-07-28

## 8040800.0.0

DTExchangeSDK `8.4.8` 대응
어댑터 버전 `8.4.8.0`

2026-06-28

## 8040700.0.0

DTExchangeSDK `8.4.7` 대응
어댑터 버전 `8.4.7.0`

2026-05-07

## 8040600.0.0

DTExchangeSDK `8.4.6` 대응
어댑터 버전 `8.4.6.0`

2026-03-29

## 8040500.0.0

DTExchangeSDK `8.4.5` 대응
어댑터 버전 `8.4.5.0`

2026-02-17

## 8040400.0.0

DTExchangeSDK `8.4.4` 대응
어댑터 버전 `8.4.4.0`

2026-02-17

## 8040300.0.0

DTExchangeSDK `8.4.3` 대응
어댑터 버전 `8.4.3.0`

2025-12-30

## 8040200.0.0

DTExchangeSDK `8.4.2` 대응 · SPM 개별 배포 시작
어댑터 버전 `8.4.2.0`

2025-12-22
