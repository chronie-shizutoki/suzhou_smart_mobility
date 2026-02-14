# 蘇智出行

蘇州スマートバス向けのクロスプラットフォームアプリケーションで、リアルタイムのバス追跡、路線情報、停留所の詳細情報を提供します。公式WeChatミニプログラムと比較して、このアプリは配慮モード、多言語対応、マルチスクリーン適応などの機能を追加しており、特にWeChatへの依存を避け、より独立した、より完全な機能セットを提供します。

## プロジェクト紹介

蘇智出行はFlutterで開発されたモダンなアプリケーションで、ユーザーが蘇州市の公共交通システムを効率的に利用できるように設計されています。このアプリは、リアルタイムのバス到着予測、路線の詳細情報、停留所情報、および包括的な検索機能を提供します。

### コア機能

- **リアルタイムバス追跡**: 近くの停留所の正確な到着時間を取得します。
- **路線情報**: 停留所、時刻表、運行時間を含む詳細な路線情報を表示します。
- **停留所の詳細**: 近くの路線や地下鉄乗り換え情報を含む包括的な停留所情報にアクセスします。
- **スマート検索**: インテリジェントな提案による停留所と路線の検索を行います。
- **位置情報ベースのサービス**: ユーザーの位置情報に基づいて近くの停留所を自動的に検出します。

## 主な特徴

### 1. WeChat依存の回避
- WeChatへの依存は不要です。
- 機能が完全な独立アプリケーションです。
- プライバシー保護を重視しています。

### 2. 多言語対応（未完了）
- 簡体字中国語
- 繁体字中国語
- English
- 日本語
- 한국어

### 3. 配慮モード（計画中）
- 高齢者/配慮モードで、より大きなフォントと簡略化されたインターフェースを提供します。
- すべてのユーザーの読みやすさを向上させます。

### 4. マルチスクリーン適応（計画中）
- スマートフォン、タブレット、デスクトップデバイスへの適応を行います。
- 異なる画面サイズに対する適応レイアウトを実装します。
- すべてのデバイスでユーザーエクスペリエンスを最適化します。

### 5. リキッドガラスUIデザイン
- モダンなガラスモーフィズムデザイン言語を採用しています。
- スムーズなアニメーションとトランジション効果を実装しています。
- ダーク/ライトテーマに対応しています。
- システムのテーマ設定に従います。

### 6. フルプラットフォーム対応
- Android（テスト済み）
- iOS（未テスト。現在Macデバイスがありませんので、ご自身でビルドしてください。）
- Windows（テスト済み）
- macOS（未テスト。現在Macデバイスがありませんので、ご自身でビルドしてください。）
- Linux（未テスト、ご自身でビルドしてください。）
- Web（計画中、現在CORSクロスオリジン問題が存在します。）

## API使用説明（公式サーバー）

### 基本設定

- **基本 URL**: `app.szgjgs.com:58050`
- **APIパス**: `AppConfig`で設定します。
- **リクエスト方法**: GET
- **レスポンス形式**: JSON（暗号化済み、復号が必要です。）

### 認証ヘッダー

すべてのAPIリクエストには以下のヘッダーが必要です：
```dart
{
  'Host': 'app.szgjgs.com:58050',
  'Connection': 'keep-alive',
  'nonce': '<8桁のランダム文字列>',
  'content-type': 'application/json',
  'timestamp': '<Unixタイムスタンプ>',
  'Accept-Encoding': 'gzip,compress,br,deflate',
  'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN'
}
```

### APIエンドポイントリスト

#### 1. 近くの停留所を検索
**エンドポイント**: `/Query_NearbyStatInfo`

**パラメーター**:
- `longitude` (double): ユーザーの経度。
- `latitude` (double): ユーザーの緯度。
- `range` (int, 任意): 検索半径（メートル）、デフォルトは800。

**レスポンス**:
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

#### 2. 停留所の車両を検索
**エンドポイント**: `/Query_ByStationID`

**パラメーター**:
- `stationId` (string): 停留所ID。
- `requestId` (string): ユニークリクエストID。
- `longitude` (double, 任意): ユーザーの経度。
- `latitude` (double, 任意): ユーザーの緯度。
- `segmentId` (string, 任意): 路線セグメントID。

**レスポンス**:
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

#### 3. 名前で停留所を検索
**エンドポイント**: `/Query_ByStationName`

**パラメーター**:
- `stationName` (string): 停留所名。

**レスポンス**:
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

#### 4. 路線を検索
**エンドポイント**: `/Require_AllRouteData`

**パラメーター**:
- `longitude` (double): ユーザーの経度。
- `latitude` (double): ユーザーの緯度。

**レスポンス**:
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

#### 5. 路線の詳細を取得
**エンドポイント**: `/Query_BusBySegmentID`

**パラメーター**:
- `segmentId` (string): 路線セグメントID。

**レスポンス**:
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

#### 6. 時刻表を取得
**エンドポイント**: `/Query_TimetableBySegmentID`

**パラメーター**:
- `segmentId` (string): 路線セグメントID。

**レスポンス**:
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

#### 7. 路線のお知らせを取得
**エンドポイント**: `/Query_NoticeMsgByRouteID`

**パラメーター**:
- `routeId` (string): 路線ID。

**レスポンス**:
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

#### 8. すべてのお知らせを取得
**エンドポイント**: `/Query_NoticeMsg`

**パラメーター**: なし。

**レスポンス**:
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

#### 9. お知らせの詳細を取得
**エンドポイント**: `/Query_NoticeMsgByNoticeID`

**パラメーター**:
- `noticeId` (string): お知らせID。

**レスポンス**:
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

#### 10. 路線の停留所データを取得
**エンドポイント**: `/Require_RouteStatData`

**パラメーター**:
- `routeId` (string): 路線ID。

**レスポンス**:
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

### レスポンスの復号

すべてのAPIレスポンスはバックエンドによって暗号化されています：IVは`X-Encryption-IV`から、キーは公式`md5(nonce+'$'+timestamp)`を使用して生成され、APIデータはAES-CBCで暗号化され、Base64エンコードされて送信されます。したがって、フロントエンドはAES復号を使用する必要があります。アプリケーションは`DecryptUtil`クラスを使用して復号を処理します：
```dart
final decrypted = DecryptUtil.decryptResponseToJson(response);
```

## プロジェクト完了状況

### 完了した機能

- [x] 近くの停留所の表示。
- [x] フローティングナビゲーションバー。
- [x] 停留所と路線検索のフレームワーク。
- [x] 停留所の詳細ページ。
- [x] 路線の詳細ページ。
- [x] リアルタイムのバス到着予測。
- [x] リキッドガラスモーフィズムの時刻表ポップアップ。
- [x] 運行時間ステータス（未開始/終了/出発待ち）。
- [x] 近くの停留所のハイライト表示。
- [x] 停留所の道路情報の表示。
- [x] 路線方向の切り替え。
- [x] 地下鉄乗り換え情報。
- [x] 多言語対応（簡体字中国語、英語）。
- [x] ダーク/ライトテーマ対応。
- [x] 位置情報サービスの統合。
- [x] 自動更新機能。
- [x] 高齢者/配慮モードの実装。

### 計画中の機能

- [ ] 路線を視覚化するための地図の統合。
- [ ] ARB gen-i10nを使用した国際化の改善。
- [ ] 大画面適応の最適化。
- [ ] 繁体字中国語、日本語、韓国語の対応。
- [ ] オフラインモードの対応。
- [ ] 路線計画。
- [ ] お気に入り管理。

## 技術スタック

- **フレームワーク**: Flutter 3.10.8+
- **言語**: Dart
- **HTTPクライアント**: http ^1.2.0
- **暗号化**: encrypt ^5.0.3, crypto ^3.0.3
- **位置情報**: geolocator ^12.0.0
- **権限**: permission_handler ^11.3.0
- **ストレージ**: shared_preferences ^2.2.2

## クイックスタート

### 前提条件

- Flutter SDK 3.10.8 以降。
- Android Studio / Xcode / VS Code。
- Android プラットフォーム：Android SDK。
- iOS プラットフォーム：Xcode 14.0 以降。
- デスクトッププラットフォーム：プラットフォーム固有のSDK。

### インストール手順

1. リポジトリをクローンします：
```bash
git clone https://github.com/chronie-shizutoki/suzhou-smart-mobility.git
cd suzhou_smart_mobility
```

2. 依存関係をインストールします：
```bash
flutter pub get
```

3. アプリケーションを実行します：
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

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。

## 貢献

貢献を歓迎します！ Issue や Pull Request を自由に提出してください。