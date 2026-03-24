# 苏智出行

苏州智慧公交跨平台应用，提供实时公交追踪、线路信息和站点详情。相较官方微信小程序，该应用提供更多功能，如关怀模式、多语言支持和多屏幕适配，尤其是避免了微信依赖，提供了更独立、更完善的功能。

## 项目介绍

苏智出行是一款基于 Flutter 开发的现代化应用，旨在帮助用户高效地使用苏州公共交通系统。该应用提供实时公交到站预测、线路详情、站点信息和全面的搜索功能。

### 核心功能

- **实时公交追踪**：获取附近站点的准确到站时间
- **线路信息**：查看详细的线路信息，包括站点、时刻表和运营时间
- **站点详情**：访问全面的站点信息，包括附近线路和地铁换乘
- **智能搜索**：通过智能建议搜索站点和线路
- **基于位置的服务**：根据用户位置自动检测附近站点

## 特色功能

### 1. 避免微信依赖
- 无需依赖微信
- 独立应用，功能完整
- 注重隐私保护

### 2. 多语言支持（未完成）
- 简体中文
- 繁体中文
- English
- 日本語
- 한국어

### 3. 关怀模式
- 长辈/关怀模式，提供更大的字体和简化的界面
- 为所有用户增强可读性

### 4. 多屏幕适配（计划中）
- 适配手机、平板和桌面设备
- 针对不同屏幕尺寸的自适应布局
- 在所有设备上优化用户体验

### 5. 液态玻璃 UI 设计
- 现代化的玻璃拟态设计语言
- 流畅的动画和过渡效果
- 支持深色/浅色主题
- 跟随系统主题

### 6. 全平台支持
- Android（已测试）
- iOS（未测试，暂时没有Mac设备，请自行构建）
- Windows（已测试）
- macOS（未测试，暂时没有Mac设备，请自行构建）
- Linux（未测试，请自行构建）
- Web（计划中，目前存在CORS无法跨域问题）

## API 调用说明（官方服务器）

### 基础配置

- **基础 URL**: `app.szgjgs.com:58050`
- **API 路径**: 在 `AppConfig` 中配置
- **请求方法**: GET
- **响应格式**: JSON（加密，需要解密）

### 认证请求头

所有 API 请求都需要以下请求头：

```dart
{
  'Host': 'app.szgjgs.com:58050',
  'Connection': 'keep-alive',
  'nonce': '<8位随机字符串>',
  'content-type': 'application/json',
  'timestamp': '<Unix 时间戳>',
  'Accept-Encoding': 'gzip,compress,br,deflate',
  'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN'
}
```

### API 接口列表

#### 1. 查询附近站点
**接口**: `/Query_NearbyStatInfo`

**参数**:
- `longitude` (double): 用户经度
- `latitude` (double): 用户纬度
- `range` (int, 可选): 搜索范围（米），默认 800

**响应**:
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

#### 2. 查询站点车辆
**接口**: `/Query_ByStationID`

**参数**:
- `stationId` (string): 站点 ID
- `requestId` (string): 唯一请求 ID
- `longitude` (double, 可选): 用户经度
- `latitude` (double, 可选): 用户纬度
- `segmentId` (string, 可选): 线路分段 ID

**响应**:
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

#### 3. 按名称搜索站点
**接口**: `/Query_ByStationName`

**参数**:
- `stationName` (string): 站点名称

**响应**:
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

#### 4. 搜索线路
**接口**: `/Require_AllRouteData`

**参数**:
- `longitude` (double): 用户经度
- `latitude` (double): 用户纬度

**响应**:
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

#### 5. 获取线路详情
**接口**: `/Query_BusBySegmentID`

**参数**:
- `segmentId` (string): 线路分段 ID

**响应**:
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

#### 6. 获取时刻表
**接口**: `/Query_TimetableBySegmentID`

**参数**:
- `segmentId` (string): 线路分段 ID

**响应**:
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

#### 7. 获取线路公告
**接口**: `/Query_NoticeMsgByRouteID`

**参数**:
- `routeId` (string): 线路 ID

**响应**:
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

#### 8. 获取所有公告
**接口**: `/Query_NoticeMsg`

**参数**: 无

**响应**:
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

#### 9. 获取公告详情
**接口**: `/Query_NoticeMsgByNoticeID`

**参数**:
- `noticeId` (string): 公告 ID

**响应**:
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

#### 10. 获取线路站点数据
**接口**: `/Require_RouteStatData`

**参数**:
- `routeId` (string): 线路 ID

**响应**:
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

### 响应解密

所有 API 响应都已被后端加密：IV来自`X-Encryption-IV`、密钥使用公式`md5(nonce+'$'+timestamp)`生成，API被AES-CBC加密后使用Base64编码传输。因此前端需要使用 AES 加密进行解密。应用使用 `DecryptUtil` 类来处理解密：

```dart
final decrypted = DecryptUtil.decryptResponseToJson(response);
```

## 项目完成情况

### 已完成功能

- [x] 附近站点显示
- [x] 悬浮导航栏
- [x] 站点和线路搜索框架
- [x] 站点详情页面
- [x] 线路详情页面
- [x] 实时公交到站预测
- [x] 液态玻璃拟态时刻表弹窗
- [x] 运营时间状态（未开始/已结束/等待发车）
- [x] 附近站点高亮显示
- [x] 站点道路信息显示
- [x] 线路方向切换
- [x] 地铁换乘信息
- [x] 多语言支持（简体中文、英文）
- [x] 深色/浅色主题支持
- [x] 定位服务集成
- [x] 自动刷新功能
- [x] 长辈/关怀模式实现

### 计划中功能

- [ ] 地图集成，可视化线路
- [ ] 使用 ARB gen-i10n 完善国际化
- [ ] 大屏幕适配优化
- [ ] 繁体中文、日语、韩语支持
- [ ] 离线模式支持
- [ ] 线路规划
- [ ] 收藏管理

## 技术栈

- **框架**: Flutter 3.10.8+
- **语言**: Dart
- **HTTP 客户端**: http ^1.2.0
- **加密**: encrypt ^5.0.3, crypto ^3.0.3
- **定位**: geolocator ^12.0.0
- **权限**: permission_handler ^11.3.0
- **存储**: shared_preferences ^2.2.2

## 快速开始

### 前置要求

- Flutter SDK 3.10.8 或更高版本
- Android Studio / Xcode / VS Code
- Android 平台：Android SDK
- iOS 平台：Xcode 14.0 或更高版本
- 桌面平台：平台特定的 SDK

### 安装步骤

1. 克隆仓库：
```bash
git clone https://github.com/chronie-shizutoki/suzhou-smart-mobility.git
cd suzhou_smart_mobility
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行应用：
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

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎贡献！请随时提交 Issue 或 Pull Request。
