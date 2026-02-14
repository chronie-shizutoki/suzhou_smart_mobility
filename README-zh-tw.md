# 蘇智出行

蘇州智慧公交跨平台應用，提供即時公交追蹤、線路資訊和站點詳情。相較官方微信小程序，該應用提供更多功能，如關懷模式、多語言支援和多螢幕適配，特別是避免了微信依賴，提供了更獨立、更完善的功能。

## 專案介紹

蘇智出行是一款基於 Flutter 開發的現代化應用，旨在幫助用戶高效地使用蘇州公共交通系統。該應用提供即時公交到站預測、線路詳情、站點資訊和全面的搜尋功能。

### 核心功能

- **即時公交追蹤**：獲取附近站點的準確到站時間
- **線路資訊**：查看詳細的線路資訊，包括站點、時刻表和營運時間
- **站點詳情**：存取全面的站點資訊，包括附近線路和地鐵換乘
- **智慧搜尋**：透過智慧建議搜尋站點和線路
- **基於位置的服務**：根據用戶位置自動檢測附近站點

## 特色功能

### 1. 避免微信依賴
- 無需依賴微信
- 獨立應用，功能完整
- 注重隱私保護

### 2. 多語言支援（未完成）
- 簡體中文
- 繁體中文
- English
- 日本語
- 한국어

### 3. 關懷模式（計劃中）
- 長輩/關懷模式，提供更大的字型和簡化的介面
- 為所有用戶增強可讀性

### 4. 多螢幕適配（計劃中）
- 適配手機、平板和桌面裝置
- 針對不同螢幕尺寸的自適應佈局
- 在所有裝置上優化用戶體驗

### 5. 液態玻璃 UI 設計
- 現代化的玻璃擬態設計語言
- 流暢的動畫和過渡效果
- 支援深色/淺色主題
- 跟隨系統主題

### 6. 全平台支援
- Android（已測試）
- iOS（未測試，暫時沒有Mac設備，請自行建構）
- Windows（已測試）
- macOS（未測試，暫時沒有Mac設備，請自行建構）
- Linux（未測試，請自行建構）
- Web（計劃中，目前存在CORS無法跨域問題）

## API 呼叫說明（官方伺服器）

### 基礎配置

- **基礎 URL**: `app.szgjgs.com:58050`
- **API 路徑**: 在 `AppConfig` 中配置
- **請求方法**: GET
- **回應格式**: JSON（加密，需要解密）

### 認證請求頭

所有 API 請求都需要以下請求頭：

```dart
{
  'Host': 'app.szgjgs.com:58050',
  'Connection': 'keep-alive',
  'nonce': '<8位隨機字串>',
  'content-type': 'application/json',
  'timestamp': '<Unix 時間戳>',
  'Accept-Encoding': 'gzip,compress,br,deflate',
  'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN'
}
```

### API 介面列表

#### 1. 查詢附近站點
**介面**: `/Query_NearbyStatInfo`

**參數**:
- `longitude` (double): 用戶經度
- `latitude` (double): 用戶緯度
- `range` (int, 選填): 搜尋範圍（米），預設 800

**回應**:
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

#### 2. 查詢站點車輛
**介面**: `/Query_ByStationID`

**參數**:
- `stationId` (string): 站點 ID
- `requestId` (string): 唯一請求 ID
- `longitude` (double, 選填): 用戶經度
- `latitude` (double, 選填): 用戶緯度
- `segmentId` (string, 選填): 線路分段 ID

**回應**:
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

#### 3. 按名稱搜尋站點
**介面**: `/Query_ByStationName`

**參數**:
- `stationName` (string): 站點名稱

**回應**:
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

#### 4. 搜尋線路
**介面**: `/Require_AllRouteData`

**參數**:
- `longitude` (double): 用戶經度
- `latitude` (double): 用戶緯度

**回應**:
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

#### 5. 取得線路詳情
**介面**: `/Query_BusBySegmentID`

**參數**:
- `segmentId` (string): 線路分段 ID

**回應**:
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

#### 6. 取得時刻表
**介面**: `/Query_TimetableBySegmentID`

**參數**:
- `segmentId` (string): 線路分段 ID

**回應**:
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

#### 7. 取得線路公告
**介面**: `/Query_NoticeMsgByRouteID`

**參數**:
- `routeId` (string): 線路 ID

**回應**:
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

#### 8. 取得所有公告
**介面**: `/Query_NoticeMsg`

**參數**: 無

**回應**:
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

#### 9. 取得公告詳情
**介面**: `/Query_NoticeMsgByNoticeID`

**參數**:
- `noticeId` (string): 公告 ID

**回應**:
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

#### 10. 取得線路站點數據
**介面**: `/Require_RouteStatData`

**參數**:
- `routeId` (string): 線路 ID

**回應**:
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

### 回應解密

所有 API 回應都已被後端加密：IV來自X-Encryption-IV、金鑰使用公式md5(nonce+'$'+timestamp)生成，API被AES-CBC加密後使用Base64編碼傳輸。因此前端需要使用 AES 加密進行解密。應用使用 `DecryptUtil` 類來處理解密：

```dart
final decrypted = DecryptUtil.decryptResponseToJson(response);
```

## 專案完成情況

### 已完成功能

- [x] 附近站點顯示
- [x] 懸浮導航列
- [x] 站點和線路搜尋框架
- [x] 站點詳情頁面
- [x] 線路詳情頁面
- [x] 即時公交到站預測
- [x] 液態玻璃擬態時刻表彈窗
- [x] 營運時間狀態（未開始/已結束/等待發車）
- [x] 附近站點高亮顯示
- [x] 站點道路資訊顯示
- [x] 線路方向切換
- [x] 地鐵換乘資訊
- [x] 多語言支援（簡體中文、英文）
- [x] 深色/淺色主題支援
- [x] 定位服務整合
- [x] 自動重新整理功能
- [x] 長輩/關懷模式實現

### 計劃中功能

- [ ] 地圖整合，視覺化線路
- [ ] 使用 ARB gen-i10n 完善國際化
- [ ] 大螢幕適配優化
- [ ] 繁體中文、日語、韓語支援
- [ ] 離線模式支援
- [ ] 線路規劃
- [ ] 收藏管理

## 技術棧

- **框架**: Flutter 3.10.8+
- **語言**: Dart
- **HTTP 客戶端**: http ^1.2.0
- **加密**: encrypt ^5.0.3, crypto ^3.0.3
- **定位**: geolocator ^12.0.0
- **權限**: permission_handler ^11.3.0
- **儲存**: shared_preferences ^2.2.2

## 快速開始

### 前置要求

- Flutter SDK 3.10.8 或更高版本
- Android Studio / Xcode / VS Code
- Android 平台：Android SDK
- iOS 平台：Xcode 14.0 或更高版本
- 桌面平台：平台特定的 SDK

### 安裝步驟

1. 複製倉庫：
```bash
git clone https://github.com/chronie-shizutoki/suzhou-smart-mobility.git
cd suzhou_smart_mobility
```

2. 安裝依賴：
```bash
flutter pub get
```

3. 執行應用：
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

## 授權許可

本專案採用 MIT 授權許可。

## 貢獻

歡迎貢獻！請隨時提交 Issue 或 Pull Request。