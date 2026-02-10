English | [简体中文](#README-zh-cn.md) | [繁體中文](#README-zh-tw.md) | [日本語](#README-ja.md) | [한국어(AI Generated)](#README-ko.md)

---
# Suzhou Smart Mobility

A cross-platform smart bus application for Suzhou, providing real-time bus tracking, route information, and stop details. Compared to the official WeChat mini-program, this app offers more features such as Care Mode, multi-language support, and multi-screen adaptation. Notably, it eliminates dependency on WeChat, providing a more independent and comprehensive feature set.

## Project Introduction

SuZhi Mobility is a modern application developed with Flutter, designed to help users efficiently utilize Suzhou's public transportation system. The app provides real-time bus arrival predictions, route details, stop information, and comprehensive search functionality.

### Core Features

- **Real-time Bus Tracking**: Get accurate arrival times for nearby stops.
- **Route Information**: View detailed route information, including stops, schedules, and operating hours.
- **Stop Details**: Access comprehensive stop information, including nearby routes and subway transfers.
- **Smart Search**: Search for stops and routes with intelligent suggestions.
- **Location-based Services**: Automatically detect nearby stops based on user location.

## Key Features

### 1. Eliminates WeChat Dependency
- No reliance on WeChat required.
- Independent application with complete functionality.
- Focus on privacy protection.

### 2. Multi-language Support (Incomplete)
- Simplified Chinese
- Traditional Chinese
- English
- Japanese
- Korean

### 3. Care Mode (Planned)
- Elderly/Care Mode with larger fonts and a simplified interface.
- Enhanced readability for all users.

### 4. Multi-screen Adaptation (Planned)
- Adaptation for mobile phones, tablets, and desktop devices.
- Adaptive layouts for different screen sizes.
- Optimized user experience across all devices.

### 5. Liquid Glass UI Design
- Modern glass morphism design language.
- Smooth animations and transitions.
- Support for dark/light themes.
- Follows system theme settings.

### 6. Full Platform Support
- Android (Tested)
- iOS (Not tested. No Mac device available temporarily, please build yourself.)
- Windows (Tested)
- macOS (Not tested. No Mac device available temporarily, please build yourself.)
- Linux (Not tested, please build yourself.)
- Web (Planned, currently has CORS cross-origin issues.)

## API Usage Documentation (Official Server)

### Base Configuration

- **Base URL**: `app.szgjgs.com:58050`
- **API Path**: Configured in `AppConfig`.
- **Request Method**: GET
- **Response Format**: JSON (Encrypted, requires decryption)

### Authentication Headers

All API requests require the following headers:
```dart
{
  'Host': 'app.szgjgs.com:58050',
  'Connection': 'keep-alive',
  'nonce': '<8-character random string>',
  'content-type': 'application/json',
  'timestamp': '<Unix timestamp>',
  'Accept-Encoding': 'gzip,compress,br,deflate',
  'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN'
}
```

### API Endpoint List

#### 1. Query Nearby Stops
**Endpoint**: `/Query_NearbyStatInfo`

**Parameters**:
- `longitude` (double): User longitude.
- `latitude` (double): User latitude.
- `range` (int, optional): Search radius in meters, default is 800.

**Response**:
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

#### 2. Query Vehicles at a Stop
**Endpoint**: `/Query_ByStationID`

**Parameters**:
- `stationId` (string): Stop ID.
- `requestId` (string): Unique request ID.
- `longitude` (double, optional): User longitude.
- `latitude` (double, optional): User latitude.
- `segmentId` (string, optional): Route segment ID.

**Response**:
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

#### 3. Search Stops by Name
**Endpoint**: `/Query_ByStationName`

**Parameters**:
- `stationName` (string): Stop name.

**Response**:
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

#### 4. Search Routes
**Endpoint**: `/Require_AllRouteData`

**Parameters**:
- `longitude` (double): User longitude.
- `latitude` (double): User latitude.

**Response**:
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

#### 5. Get Route Details
**Endpoint**: `/Query_BusBySegmentID`

**Parameters**:
- `segmentId` (string): Route segment ID.

**Response**:
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

#### 6. Get Timetable
**Endpoint**: `/Query_TimetableBySegmentID`

**Parameters**:
- `segmentId` (string): Route segment ID.

**Response**:
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

#### 7. Get Route Announcements
**Endpoint**: `/Query_NoticeMsgByRouteID`

**Parameters**:
- `routeId` (string): Route ID.

**Response**:
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

#### 8. Get All Announcements
**Endpoint**: `/Query_NoticeMsg`

**Parameters**: None.

**Response**:
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

#### 9. Get Announcement Details
**Endpoint**: `/Query_NoticeMsgByNoticeID`

**Parameters**:
- `noticeId` (string): Announcement ID.

**Response**:
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

#### 10. Get Route Stop Data
**Endpoint**: `/Require_RouteStatData`

**Parameters**:
- `routeId` (string): Route ID.

**Response**:
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

### Response Decryption

All API responses are encrypted by the backend: The IV comes from `X-Encryption-IV`, the key is generated using the formula `md5(nonce+'$'+timestamp)`, and the API data is AES-CBC encrypted and Base64 encoded for transmission. Therefore, the frontend needs to use AES decryption. The application uses the `DecryptUtil` class to handle decryption:
```dart
final decrypted = DecryptUtil.decryptResponseToJson(response);
```

## Project Completion Status

### Completed Features

- [x] Nearby stops display.
- [x] Floating navigation bar.
- [x] Framework for stop and route search.
- [x] Stop details page.
- [x] Route details page.
- [x] Real-time bus arrival prediction.
- [x] Liquid glass morphism timetable popup.
- [x] Operating hour status (Not Started/Ended/Waiting for Departure).
- [x] Highlight nearby stops.
- [x] Display stop road information.
- [x] Route direction switching.
- [x] Subway transfer information.
- [x] Multi-language support (Simplified Chinese, English).
- [x] Dark/Light theme support.
- [x] Location service integration.
- [x] Auto-refresh functionality.

### Planned Features

- [ ] Map integration for route visualization.
- [ ] Improve internationalization using ARB gen-i10n.
- [ ] Large screen adaptation optimization.
- [ ] Implementation of Elderly/Care Mode.
- [ ] Support for Traditional Chinese, Japanese, Korean.
- [ ] Offline mode support.
- [ ] Route planning.
- [ ] Favorites management.

## Tech Stack

- **Framework**: Flutter 3.10.8+
- **Language**: Dart
- **HTTP Client**: http ^1.2.0
- **Encryption**: encrypt ^5.0.3, crypto ^3.0.3
- **Location**: geolocator ^12.0.0
- **Permissions**: permission_handler ^11.3.0
- **Storage**: shared_preferences ^2.2.2

## Quick Start

### Prerequisites

- Flutter SDK 3.10.8 or higher.
- Android Studio / Xcode / VS Code.
- Android Platform: Android SDK.
- iOS Platform: Xcode 14.0 or higher.
- Desktop Platforms: Platform-specific SDKs.

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/chronie-shizutoki/suzhou-smart-mobility.git
cd suzhou_smart_mobility
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
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

## License

This project is licensed under the MIT License.

## Contributing

We like contributions! Please feel free to submit Issues or Pull Requests.