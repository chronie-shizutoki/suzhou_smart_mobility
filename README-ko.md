# 쑤즈 출행(AI Generated)

쑤저우 스마트 버스 크로스 플랫폼 애플리케이션으로, 실시간 버스 추적, 노선 정보 및 정류장 상세 정보를 제공합니다. 공식 위챗 미니프로그램과 비교하여, 이 앱은 케어 모드, 다국어 지원 및 멀티스크린 적응과 같은 더 많은 기능을 제공하며, 특히 위챗 의존성을 피하여 더 독립적이고 완전한 기능 세트를 제공합니다.

## 프로젝트 소개

쑤즈 출행은 Flutter로 개발된 현대적인 애플리케이션으로, 사용자가 쑤저우 공공 교통 시스템을 효율적으로 이용할 수 있도록 설계되었습니다. 이 앱은 실시간 버스 도착 예측, 노선 상세 정보, 정류장 정보 및 포괄적인 검색 기능을 제공합니다.

### 핵심 기능

- **실시간 버스 추적**: 근처 정류장의 정확한 도착 시간을 확인합니다.
- **노선 정보**: 정류장, 시간표 및 운영 시간을 포함한 상세한 노선 정보를 확인합니다.
- **정류장 상세 정보**: 근처 노선 및 지하철 환승 정보를 포함한 포괄적인 정류장 정보에 접근합니다.
- **스마트 검색**: 지능적인 제안으로 정류장 및 노선을 검색합니다.
- **위치 기반 서비스**: 사용자 위치를 기반으로 근처 정류장을 자동으로 감지합니다.

## 주요 특징

### 1. 위챗 의존성 제거
- 위챗 의존성이 필요 없습니다.
- 기능이 완전한 독립 애플리케이션입니다.
- 개인정보 보호에 중점을 둡니다.

### 2. 다국어 지원 (미완료)
- 간체 중국어
- 번체 중국어
- 영어
- 일본어
- 한국어

### 3. 케어 모드 (계획 중)
- 어르신/케어 모드로, 더 큰 글꼴과 단순화된 인터페이스를 제공합니다.
- 모든 사용자의 가독성을 향상시킵니다.

### 4. 멀티스크린 적응 (계획 중)
- 스마트폰, 태블릿 및 데스크톱 장치에 적응합니다.
- 다양한 화면 크기에 대한 적응형 레이아웃을 구현합니다.
- 모든 장치에서 사용자 경험을 최적화합니다.

### 5. 리퀴드 글래스 UI 디자인
- 현대적인 글래스 모피즘 디자인 언어를 채택합니다.
- 부드러운 애니메이션 및 전환 효과를 구현합니다.
- 다크/라이트 테마를 지원합니다.
- 시스템 테마 설정을 따릅니다.

### 6. 풀 플랫폼 지원
- Android (테스트 완료)
- iOS (미테스트, 현재 Mac 장치가 없어 직접 빌드해 주세요.)
- Windows (테스트 완료)
- macOS (미테스트, 현재 Mac 장치가 없어 직접 빌드해 주세요.)
- Linux (미테스트, 직접 빌드해 주세요.)
- Web (계획 중, 현재 CORS 크로스 오리진 문제가 존재합니다.)

## API 사용 설명 (공식 서버)

### 기본 설정

- **기본 URL**: `app.szgjgs.com:58050`
- **API 경로**: `AppConfig`에서 구성합니다.
- **요청 방법**: GET
- **응답 형식**: JSON (암호화됨, 복호화 필요)

### 인증 헤더

모든 API 요청에는 다음 헤더가 필요합니다:
```dart
{
  'Host': 'app.szgjgs.com:58050',
  'Connection': 'keep-alive',
  'nonce': '<8자리 랜덤 문자열>',
  'content-type': 'application/json',
  'timestamp': '<Unix 타임스탬프>',
  'Accept-Encoding': 'gzip,compress,br,deflate',
  'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN'
}
```

### API 엔드포인트 목록

#### 1. 근처 정류장 검색
**엔드포인트**: `/Query_NearbyStatInfo`

**매개변수**:
- `longitude` (double): 사용자 경도.
- `latitude` (double): 사용자 위도.
- `range` (int, 선택): 검색 반경(미터), 기본값 800.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "stationId": "string",
      "stationName": "string",
      "latitude": double,
      "longitude": double,
      "distance": double,
      "isNearby": boolean
    }
  ]
}
```

#### 2. 정류장 차량 검색
**엔드포인트**: `/Query_ByStationID`

**매개변수**:
- `stationId` (string): 정류장 ID.
- `requestId` (string): 고유 요청 ID.
- `longitude` (double, 선택): 사용자 경도.
- `latitude` (double, 선택): 사용자 위도.
- `segmentId` (string, 선택): 노선 세그먼트 ID.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "busPredictList": [
        {
          "nearbyForecastStation": int,
          "nearbyForecastDistance": int,
          "predictArriveTime": int,
          "leaveTime": "string",
          "closeOperate": boolean
        }
      ]
    }
  ]
}
```

#### 3. 이름으로 정류장 검색
**엔드포인트**: `/Query_ByStationName`

**매개변수**:
- `stationName` (string): 정류장 이름.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "stationId": "string",
      "stationName": "string",
      "latitude": double,
      "longitude": double
    }
  ]
}
```

#### 4. 노선 검색
**엔드포인트**: `/Require_AllRouteData`

**매개변수**:
- `longitude` (double): 사용자 경도.
- `latitude` (double): 사용자 위도.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "routeId": "string",
      "routeName": "string",
      "segmentId": "string",
      "startStation": "string",
      "endStation": "string",
      "startTime": "string",
      "endTime": "string",
      "ticketPrice": "string",
      "ticketRule": "string"
    }
  ]
}
```

#### 5. 노선 상세 정보 가져오기
**엔드포인트**: `/Query_BusBySegmentID`

**매개변수**:
- `segmentId` (string): 노선 세그먼트 ID.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "busId": "string",
      "busName": "string",
      "busNo": "string",
      "arriveStationId": "string",
      "arriveStationName": "string",
      "crowdInCar": int,
      "arriveTime": "string"
    }
  ]
}
```

#### 6. 시간표 가져오기
**엔드포인트**: `/Query_TimetableBySegmentID`

**매개변수**:
- `segmentId` (string): 노선 세그먼트 ID.

**응답**:
```json
{
  "status": true,
  "items": {
    "highInterval": int,
    "plainInterval": int,
    "lowInterval": int,
    "timeExtendInfo": "string",
    "timetable": ["HH:MM", "HH:MM", ...]
  }
}
```

#### 7. 노선 공지사항 가져오기
**엔드포인트**: `/Query_NoticeMsgByRouteID`

**매개변수**:
- `routeId` (string): 노선 ID.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "noticeId": "string",
      "title": "string",
      "content": "string",
      "publishTime": "string"
    }
  ]
}
```

#### 8. 모든 공지사항 가져오기
**엔드포인트**: `/Query_NoticeMsg`

**매개변수**: 없음.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "noticeId": "string",
      "title": "string",
      "content": "string",
      "publishTime": "string"
    }
  ]
}
```

#### 9. 공지사항 상세 정보 가져오기
**엔드포인트**: `/Query_NoticeMsgByNoticeID`

**매개변수**:
- `noticeId` (string): 공지사항 ID.

**응답**:
```json
{
  "status": true,
  "items": {
    "noticeId": "string",
    "title": "string",
    "content": "string",
    "publishTime": "string"
  }
}
```

#### 10. 노선 정류장 데이터 가져오기
**엔드포인트**: `/Require_RouteStatData`

**매개변수**:
- `routeId` (string): 노선 ID.

**응답**:
```json
{
  "status": true,
  "items": [
    {
      "routeId": "string",
      "routeName": "string",
      "segmentId": "string",
      "startStation": "string",
      "endStation": "string",
      "startTime": "string",
      "endTime": "string",
      "ticketPrice": "string",
      "ticketRule": "string",
      "isShowTimetable": boolean,
      "highInterval": int,
      "plainInterval": int,
      "lowInterval": int,
      "timeExtendInfo": "string",
      "stations": [
        {
          "stationId": "string",
          "stationName": "string",
          "stationSort": int,
          "latitude": double,
          "longitude": double,
          "isNearby": boolean,
          "stationRoad": "string",
          "metroTransferList": [
            {
              "metroName": "string",
              "metroColor": "string"
            }
          ]
        }
      ]
    }
  ]
}
```

### 응답 복호화

모든 API 응답은 백엔드에서 암호화됩니다: IV는 `X-Encryption-IV`에서, 키는 공식 `md5(nonce+'$'+timestamp)`를 사용하여 생성되며, API 데이터는 AES-CBC로 암호화되어 Base64 인코딩되어 전송됩니다. 따라서 프론트엔드는 AES 복호화를 사용해야 합니다. 애플리케이션은 `DecryptUtil` 클래스를 사용하여 복호화를 처리합니다:
```dart
final decrypted = DecryptUtil.decryptResponseToJson(response);
```

## 프로젝트 완료 현황

### 완료된 기능

- [x] 근처 정류장 표시.
- [x] 플로팅 내비게이션 바.
- [x] 정류장 및 노선 검색 프레임워크.
- [x] 정류장 상세 페이지.
- [x] 노선 상세 페이지.
- [x] 실시간 버스 도착 예측.
- [x] 리퀴드 글래스 모피즘 시간표 팝업.
- [x] 운영 시간 상태 (시작 전/종료/출발 대기).
- [x] 근처 정류장 하이라이트 표시.
- [x] 정류장 도로 정보 표시.
- [x] 노선 방향 전환.
- [x] 지하철 환승 정보.
- [x] 다국어 지원 (간체 중국어, 영어).
- [x] 다크/라이트 테마 지원.
- [x] 위치 서비스 통합.
- [x] 자동 새로 고침 기능.

### 계획 중인 기능

- [ ] 노선 시각화를 위한 지도 통합.
- [ ] ARB gen-i10n을 사용한 국제화 개선.
- [ ] 대화면 적응 최적화.
- [ ] 어르신/케어 모드 구현.
- [ ] 번체 중국어, 일본어, 한국어 지원.
- [ ] 오프라인 모드 지원.
- [ ] 노선 계획.
- [ ] 즐겨찾기 관리.

## 기술 스택

- **프레임워크**: Flutter 3.10.8+
- **언어**: Dart
- **HTTP 클라이언트**: http ^1.2.0
- **암호화**: encrypt ^5.0.3, crypto ^3.0.3
- **위치 정보**: geolocator ^12.0.0
- **권한**: permission_handler ^11.3.0
- **저장소**: shared_preferences ^2.2.2

## 빠른 시작

### 필수 조건

- Flutter SDK 3.10.8 이상.
- Android Studio / Xcode / VS Code.
- Android 플랫폼: Android SDK.
- iOS 플랫폼: Xcode 14.0 이상.
- 데스크톱 플랫폼: 플랫폼별 SDK.

### 설치 단계

1. 저장소를 복제합니다:
```bash
git clone https://github.com/chronie-shizutoki/suzhou-smart-mobility.git
cd suzhou_smart_mobility
```

2. 종속성을 설치합니다:
```bash
flutter pub get
```

3. 애플리케이션을 실행합니다:
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 라이선스

이 프로젝트는 MIT 라이선스에 따라 라이선스가 부여됩니다.

## 기여

기여를 환영합니다! Issue 또는 Pull Request를 자유롭게 제출해 주세요.