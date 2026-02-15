# RevenueCat 買い切りプラン実装計画

## 概要

RevenueCat を使って iOS / Android 両方に**広告削除の買い切り（Non-Consumable）プラン**を追加する。
購入後はインタースティシャル広告・ネイティブ広告がすべて非表示になる。

---

## 現状の整理

| 項目 | 現状 |
|------|------|
| 収益化 | AdMob（インタースティシャル + ネイティブ広告） |
| 課金機能 | なし |
| 状態管理 | StatefulWidget ベース（Provider 等未使用） |
| 広告制御 | `AdService`（シングルトン）が一元管理 |
| Bundle ID | `com.aphlo.simplehandwritingchat` |

---

## 全体アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│                   Flutter App                    │
│                                                  │
│  ┌──────────────┐  ┌─────────────────────────┐  │
│  │  AdService   │  │  PurchaseService         │  │
│  │  (既存)      │◄─┤  (新規・シングルトン)     │  │
│  │              │  │                           │  │
│  │  isPro を    │  │  - RevenueCat SDK 初期化  │  │
│  │  チェックし  │  │  - 購入処理               │  │
│  │  広告を出す  │  │  - リストア処理           │  │
│  │  /出さない   │  │  - 購入状態の公開         │  │
│  └──────────────┘  └─────────────────────────┘  │
│                                                  │
│  ┌──────────────┐  ┌─────────────────────────┐  │
│  │ MenuPage     │  │ MirrorDrawingPage        │  │
│  │ (購入ボタン  │  │ (広告非表示対応)          │  │
│  │  追加)       │  │                           │  │
│  └──────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────┐
│  RevenueCat API  │
│  (サーバー側)    │
└─────────────────┘
```

---

## ブラウザでの手作業手順（詳細）

> コード実装の前に、以下の 3 つのサービスをブラウザで設定する必要があります。
> 順番通りに進めてください。

---

### Phase A: App Store Connect（iOS プロダクト作成）

**URL**: https://appstoreconnect.apple.com

#### A-1. In-App Purchase Key（p8 キー）を作成

> Shared Secret は Legacy（非推奨）です。RevenueCat は StoreKit 2 対応の
> **In-App Purchase Key（p8）** 方式を推奨しています。
>
> 参考: https://www.revenuecat.com/docs/service-credentials/itunesconnect-app-specific-shared-secret/in-app-purchase-key-configuration

1. App Store Connect にログイン
2. **「ユーザとアクセス」** → **「統合」** を開く
   - 直リンク: https://appstoreconnect.apple.com/access/integrations/api/subs
3. 左サイドバーまたはタブで **「アプリ内課金」** を選択
4. **「アプリ内課金キーを生成」** をクリック（既にキーがある場合は「Active」ヘッダー横の「+」）
5. キー名を入力: `RevenueCat`（任意、管理用の名前）
6. 生成されたら **「API キーをダウンロード」** をクリック
   - ファイル名: `SubscriptionKey_XXXXXXXXXX.p8`
   - **ダウンロードは 1 回のみ**。安全な場所に保管すること
7. 以下の 2 つの値をメモする:
   - **Key ID**: 生成されたキーの一覧に表示される ID
   - **Issuer ID**: 同じページの上部に表示される
     - 表示されない場合は「App Store Connect API」タブで任意の API キーを 1 つ作成すると Issuer ID が表示されるようになる（Issuer ID は共通）

後で RevenueCat の **「In-app purchase key configuration」** に登録するもの:
- p8 ファイル（`SubscriptionKey_XXXXXXXXXX.p8`）
- Key ID
- Issuer ID

#### A-1b. App Store Connect API キーを作成

> RevenueCat がプロダクト情報の取得やステータス確認を行うために、
> In-App Purchase Key とは**別に** App Store Connect API キーも必要。

1. App Store Connect →**「ユーザとアクセス」→「統合」**
   - 直リンク: https://appstoreconnect.apple.com/access/integrations/api
2. **「App Store Connect API」** タブを選択（※「アプリ内課金」タブではない方）
3. **「+」** をクリックしてキーを生成
   - キー名: `RevenueCat`（任意）
   - アクセス: **「Admin」** または **「App Manager」**
4. **「API キーをダウンロード」** をクリック
   - ファイル名: `AuthKey_XXXXXXXXXX.p8`
   - **ダウンロードは 1 回のみ**。安全な場所に保管すること
5. **Key ID** をメモする（Issuer ID は A-1 と共通）

後で RevenueCat の **「App Store Connect API」** に登録するもの:
- p8 ファイル（`AuthKey_XXXXXXXXXX.p8`）
- Key ID
- Issuer ID（A-1 と同じ値）

> **まとめ: RevenueCat の iOS アプリ設定には 2 つのキーが必要**
>
> | RevenueCat のセクション | App Store Connect での場所 | ファイル名の形式 |
> |------------------------|--------------------------|----------------|
> | In-app purchase key configuration | 統合 →「アプリ内課金」タブ | `SubscriptionKey_XXXX.p8` |
> | App Store Connect API | 統合 →「App Store Connect API」タブ | `AuthKey_XXXX.p8` |

#### A-2. App 内課金プロダクトを作成

1. 「App 内課金」→「管理」→ 「+」ボタンをクリック
2. タイプ: **「非消耗型（Non-Consumable）」** を選択
3. 参照名: `Remove Ads`（内部管理用、ユーザーには見えない）
4. プロダクト ID: **`remove_ads`**
5. 「作成」をクリック

#### A-3. プロダクトの詳細設定

1. 作成したプロダクトの編集画面で:
2. **価格設定**
   - 「サブスクリプション価格」→「価格を追加」
   - 基準の国/地域: 日本
   - 価格: 任意（例: ¥500）
   - 他の国/地域は自動計算される（確認して「次へ」→「確認」）
3. **ローカライゼーション**
   - 「App Store のローカリゼーション」の「+」をクリック
   - **日本語**:
     - 表示名: `広告を削除`
     - 説明: `すべての広告を永久に非表示にします`
   - **英語**:
     - 表示名: `Remove Ads`
     - 説明: `Remove all ads permanently`
4. **審査用スクリーンショット**
   - App 内課金が表示される画面のスクリーンショットを 1 枚アップロード
   - （メニュー画面で「広告を削除」ボタンが見えるスクリーンショット）
5. **審査に関する備考**（任意）
   - 例: 「購入するとアプリ内のすべての広告が非表示になります」
6. ステータスが「送信準備完了」になっていることを確認
7. 「保存」をクリック

---

### Phase B: Google Play Console（Android プロダクト作成）

**URL**: https://play.google.com/console

#### B-1. サービスアカウントの作成（RevenueCat 連携用）

> 既にサービスアカウントがある場合はスキップ可能

1. Google Play Console にログイン
2. 左サイドバー「設定」→「API アクセス」
3. 「新しいサービスアカウントを作成」をクリック
4. Google Cloud Console にリダイレクトされる:
   - 「+ サービスアカウントを作成」
   - サービスアカウント名: `revenuecat`（任意）
   - 「作成して続行」
   - ロール: 不要（スキップ可）
   - 「完了」
5. 作成されたサービスアカウントの行 →「操作」→「鍵を管理」
6. 「鍵を追加」→「新しい鍵を作成」→ **JSON** を選択 →「作成」
7. JSON ファイルがダウンロードされる → **安全な場所に保管**（後で RevenueCat に登録）
8. Google Play Console に戻る
9. 「設定」→「API アクセス」で作成したサービスアカウントの行に「アクセスを許可」をクリック
10. **権限設定**:
    - 「アプリの権限」タブ → Simple Handwriting Chat を選択 →「適用」
    - 「アカウントの権限」タブ → 以下を有効化:
      - 「財務データ、注文、キャンセルのアンケート回答の表示」
      - 「注文と定期購入の管理」
11. 「ユーザーを招待」をクリック

> サービスアカウントの権限が反映されるまで最大 24 時間かかる場合があります。

#### B-2. アプリ内アイテムを作成

1. Google Play Console →「Simple Handwriting Chat」を選択
2. 左サイドバー「収益化」→「アプリ内アイテム」
3. 「アイテムを作成」をクリック
4. 設定:
   - プロダクト ID: **`remove_ads`**（App Store Connect と一致させる）
   - 名前: `広告を削除`
   - 説明: `すべての広告を永久に非表示にします`
5. 「価格を設定」
   - デフォルトの価格: 任意（例: ¥500）
   - 他の国/地域は自動計算
6. 「保存」→「有効にする」をクリック

> アプリ内アイテムのテストには、最低限「内部テスト」トラックに APK/AAB が
> アップロードされている必要があります。

---

### Phase C: RevenueCat ダッシュボード設定

**URL**: https://app.revenuecat.com

#### C-1. アカウント作成 & プロジェクト作成

1. https://app.revenuecat.com にアクセス
2. アカウントを作成（GitHub / Google / メール）
3. ログイン後「Create New Project」をクリック
4. Project name: **`Simple Handwriting Chat`**
5. 「Create Project」

#### C-2. iOS アプリの登録

1. プロジェクトのダッシュボード → 「Apps」 → 「+ New」
2. **App Store App** を選択
3. 設定:
   - App name: `Simple Handwriting Chat (iOS)`
   - App Bundle ID: **`com.aphlo.simplehandwritingchat`**
4. 「Save Changes」
5. **Public API Key が表示される → メモする**（`appl_XXXX...` の形式）
6. **In-app purchase key configuration** セクション:
   - **P8 key file**: Phase A-1 でダウンロードした `SubscriptionKey_XXXXXXXXXX.p8` をアップロード
   - **Key ID**: Phase A-1 でメモした Key ID を入力
   - **Issuer ID**: Phase A-1 でメモした Issuer ID を入力
7. **App Store Connect API** セクション:
   - **P8 key file**: Phase A-1b でダウンロードした `AuthKey_XXXXXXXXXX.p8` をアップロード
   - **Key ID**: Phase A-1b でメモした Key ID を入力
   - （Issuer ID は自動入力される、または A-1 と同じ値）
8. 「Save Changes」

#### C-3. Android アプリの登録

1. 「Apps」→「+ New」
2. **Play Store App** を選択
3. 設定:
   - App name: `Simple Handwriting Chat (Android)`
   - Package Name: **`com.aphlo.simplehandwritingchat`**
   - Service Account credentials JSON: **Phase B-1 でダウンロードした JSON をアップロード**
4. 「Save Changes」
5. **Public API Key が表示される → メモする**（`goog_XXXX...` の形式）

#### C-4. Entitlement の作成

1. 左サイドバー **「Product catalog」** をクリック
2. **「Entitlements」** タブを選択 →「+ New」
3. 設定:
   - Identifier: **`simple handwriting chat Pro`**
   - Description: `Remove all ads`（任意）
4. 「Save」

#### C-5. Product の登録

1. **「Product catalog」** → **「Products」** タブ →「+ New」
2. **iOS 用:**
   - App: `Simple Handwriting Chat (iOS)` を選択
   - Product Identifier: **`remove_ads`**
3. 「Save」
4. もう一度「+ New」
5. **Android 用:**
   - App: `Simple Handwriting Chat (Android)` を選択
   - Product Identifier: **`remove_ads`**
6. 「Save」

#### C-6. Entitlement に Product を紐付け

1. **「Product catalog」** → **「Entitlements」** タブ → 作成した **`simple handwriting chat Pro`** をクリック
2. 「Attach」→ iOS の `remove_ads` を選択 →「Attach」
3. もう一度「Attach」→ Android の `remove_ads` を選択 →「Attach」
4. 結果: `simple handwriting chat Pro` entitlement に 2 つの product が紐付いている状態

#### C-7. Offering の作成

1. **「Product catalog」** → **「Offerings」** タブ →「+ New」
2. 設定:
   - Identifier: **`default`**（SDK がデフォルトで参照する ID）
   - Description: `Default offering`（任意）
3. 「Save」
4. 作成した `default` offering をクリック
5. 「+ New Package」
6. 設定:
   - Identifier: **`Lifetime`**（ドロップダウンから選択）
7. 「Save」
8. 作成した Lifetime パッケージをクリック
9. 「Attach Product」→ iOS の `remove_ads` を選択 →「Attach」
10. もう一度「Attach Product」→ Android の `remove_ads` を選択 →「Attach」

#### C-8. 設定完了の確認

最終状態が以下のようになっていれば OK:

```
Project: Simple Handwriting Chat
├── Apps
│   ├── iOS (appl_XXXX...)
│   └── Android (goog_XXXX...)
├── Entitlements
│   └── simple handwriting chat Pro
│       ├── remove_ads (iOS)
│       └── remove_ads (Android)
└── Offerings
    └── default (Current)
        └── Lifetime package
            ├── remove_ads (iOS)
            └── remove_ads (Android)
```

---

### 取得した API Key の使い方

| キー | 形式 | 使う場所 |
|------|------|---------|
| iOS Public API Key | `appl_XXXX...` | `PurchaseService` の `_iosApiKey` |
| Android Public API Key | `goog_XXXX...` | `PurchaseService` の `_androidApiKey` |

> Public API Key はクライアントサイドで安全に使用できます（Secret Key ではない）。

---

## コード実装ステップ

### Step 1: Flutter パッケージ追加

`pubspec.yaml` に追加:

```yaml
dependencies:
  purchases_flutter: ^8.0.0
```

### Step 2: PurchaseService 実装

**新規ファイル**: `lib/services/purchase_service.dart`

```dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // RevenueCat Public API Keys（Step 1 で取得した値に差し替え）
  static const String _iosApiKey = 'appl_XXXXXXXXXXXXXXXXXX';
  static const String _androidApiKey = 'goog_XXXXXXXXXXXXXXXXXX';

  static const String _entitlementId = 'simple handwriting chat Pro';

  final ValueNotifier<bool> isPro = ValueNotifier(false);

  Future<void> initialize() async {
    final config = PurchasesConfiguration(
      Platform.isIOS ? _iosApiKey : _androidApiKey,
    );
    await Purchases.configure(config);

    // 初期状態を取得
    await _refreshStatus();

    // 購入状態の変化を監視
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateProStatus(customerInfo);
    });
  }

  Future<void> _refreshStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
    }
  }

  void _updateProStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[_entitlementId];
    isPro.value = entitlement?.isActive ?? false;
  }

  /// Offering を取得して商品情報を返す
  Future<Package?> getRemoveAdsPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.lifetime;
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  /// 購入処理
  Future<bool> purchaseRemoveAds() async {
    final package = await getRemoveAdsPackage();
    if (package == null) return false;

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _updateProStatus(customerInfo);
      return isPro.value;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  /// 購入の復元
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);
      return isPro.value;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }
}
```

**設計ポイント:**
- `AdService` と同様のシングルトンパターンで統一感を保つ
- `ValueNotifier<bool>` で購入状態を公開し、UI 側は `ValueListenableBuilder` で監視
- RevenueCat の `CustomerInfo` リスナーで状態を自動同期

### Step 3: AdService の改修

`lib/services/ad_service.dart` を改修して、Pro ユーザーは広告をスキップする。

**変更箇所:**

```dart
import 'purchase_service.dart';

// onClearButtonPressed メソッドに追加
Future<void> onClearButtonPressed() async {
  // Pro ユーザーは広告をスキップ
  if (PurchaseService().isPro.value) return;

  // ... 既存のロジック
}
```

### Step 4: main.dart の改修

`PurchaseService` の初期化を追加:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdService().initialize();
  await PurchaseService().initialize();  // ← 追加
  await ReviewService().incrementAppLaunchCount();
  runApp(const SimpleHandwritingChatApp());
}
```

### Step 5: MenuPage の改修

`lib/pages/menu_page.dart` に購入セクションを追加。

**変更内容:**

1. 言語設定の上に「広告を削除」セクションを追加
2. 購入済みの場合は「購入済み」バッジを表示
3. ネイティブ広告を Pro ユーザーには非表示にする
4. 「購入を復元」ボタンを追加

```dart
// ListView の先頭に追加
ValueListenableBuilder<bool>(
  valueListenable: PurchaseService().isPro,
  builder: (context, isPro, _) {
    if (isPro) {
      return ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.teal),
        title: Text(l10n.removeAdsPurchased),
      );
    }
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.remove_circle_outline),
          title: Text(l10n.removeAds),
          subtitle: Text(_removeAdsPrice ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: _purchaseRemoveAds,
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: Text(l10n.restorePurchases),
          trailing: const Icon(Icons.chevron_right),
          onTap: _restorePurchases,
        ),
        const Divider(),
      ],
    );
  },
),
```

**ネイティブ広告の非表示:**

```dart
// 既存のネイティブ広告表示部分を修正
ValueListenableBuilder<bool>(
  valueListenable: PurchaseService().isPro,
  builder: (context, isPro, _) {
    if (isPro || !_isNativeAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }
    return Container(/* 既存の広告ウィジェット */);
  },
),
```

### Step 6: ローカライズ対応

#### `lib/l10n/app_en.arb` に追加:

```json
{
  "removeAds": "Remove Ads",
  "removeAdsPurchased": "Ads Removed",
  "restorePurchases": "Restore Purchases",
  "purchaseSuccess": "Purchase successful! Ads have been removed.",
  "purchaseFailed": "Purchase failed. Please try again.",
  "restoreSuccess": "Purchases restored successfully!",
  "restoreNoPurchases": "No previous purchases found."
}
```

#### `lib/l10n/app_ja.arb` に追加:

```json
{
  "removeAds": "広告を削除",
  "removeAdsPurchased": "広告削除済み",
  "restorePurchases": "購入を復元",
  "purchaseSuccess": "購入が完了しました！広告が非表示になります。",
  "purchaseFailed": "購入に失敗しました。もう一度お試しください。",
  "restoreSuccess": "購入の復元が完了しました！",
  "restoreNoPurchases": "過去の購入が見つかりませんでした。"
}
```

### Step 7: iOS 固有の設定

#### `ios/Podfile`

特別な変更は不要。`purchases_flutter` が自動で CocoaPods 経由で追加される。

#### StoreKit 設定ファイル（テスト用）

Xcode で StoreKit Configuration File を作成すると Sandbox 不要でローカルテスト可能:

1. Xcode → File → New → StoreKit Configuration File
2. Product を追加（Non-Consumable, ID: `remove_ads`）
3. Scheme → Run → Options → StoreKit Configuration で選択

### Step 8: Android 固有の設定

#### `android/app/build.gradle.kts`

特別な変更は不要。`purchases_flutter` が自動で Gradle 経由で追加される。

#### `android/app/src/main/AndroidManifest.xml`

Billing パーミッションを追加:

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

## ファイル変更サマリ

| ファイル | 変更種別 | 内容 |
|---------|---------|------|
| `pubspec.yaml` | 変更 | `purchases_flutter` 追加 |
| `lib/services/purchase_service.dart` | **新規** | RevenueCat 連携サービス |
| `lib/services/ad_service.dart` | 変更 | Pro ユーザーの広告スキップ |
| `lib/main.dart` | 変更 | `PurchaseService` 初期化追加 |
| `lib/pages/menu_page.dart` | 変更 | 購入UI・広告非表示対応 |
| `lib/l10n/app_en.arb` | 変更 | 英語翻訳追加 |
| `lib/l10n/app_ja.arb` | 変更 | 日本語翻訳追加 |
| `android/app/src/main/AndroidManifest.xml` | 変更 | BILLING パーミッション追加 |

---

## テスト計画

### iOS ローカルテスト（StoreKit Configuration File）

StoreKit Configuration File を使うと、Apple の Sandbox サーバーに接続せずに
**シミュレータ・実機どちらでも**課金フローをローカルテストできる。

#### 手順 1: StoreKit Configuration File の作成

1. Xcode で `ios/Runner.xcworkspace` を開く
2. メニュー: **File → New → File...**
3. 検索欄に「storekit」と入力
4. **「StoreKit Configuration File」** を選択 →「Next」
5. ファイル名: `StoreKit.storekit`
6. 保存先: `ios/Runner/` 配下
7. **「Sync this file with an app in App Store Connect」のチェックは外す**
   - （App Store Connect にプロダクトを作る前でもテスト可能にするため）
8. 「Create」

#### 手順 2: プロダクトの追加

1. 作成した `StoreKit.storekit` を開く
2. 左下の「+」→ **「Add Non-Consumable In-App Purchase」**
3. 設定:
   - Reference Name: `Remove Ads`
   - Product ID: **`remove_ads`**（コード側と一致させる）
   - Price: `4.99`（テスト用、任意の値）
4. **Localization** セクション:
   - Display Name: `Remove Ads`
   - Description: `Remove all ads permanently`

#### 手順 3: Scheme に StoreKit Configuration を紐付け

1. Xcode 上部の Scheme（「Runner」）を長押し → **「Edit Scheme...」**
2. 左サイドバーで **「Run」** を選択
3. **「Options」** タブを開く
4. **「StoreKit Configuration」** ドロップダウンで `StoreKit.storekit` を選択
5. 「Close」

#### 手順 4: テスト実行

1. Xcode または `rake run_ios` でアプリを起動
2. メニュー画面の「広告を削除」をタップ
3. **ローカルの購入ダイアログ**が表示される（Apple ID 不要）
4. 「Confirm」で購入完了
5. 広告が非表示になることを確認

#### StoreKit テストの便利な機能

| 操作 | 方法 |
|------|------|
| 購入履歴のリセット | Xcode メニュー: **Debug → StoreKit → Manage Transactions** → 全削除 |
| トランザクション一覧 | Xcode メニュー: **Debug → StoreKit → Manage Transactions** |
| 購入失敗のシミュレート | `StoreKit.storekit` → Editor → **「Enable Interrupted Purchases」** |
| ネットワークエラーのテスト | `StoreKit.storekit` → Editor → 各種 Fail Transaction オプション |

#### 注意点

- StoreKit Configuration を使ったテストは **RevenueCat の Sandbox モードとは別物**
- RevenueCat ダッシュボード上にはトランザクションが記録されない（完全ローカル）
- RevenueCat SDK を通した完全な E2E テストをしたい場合は、後述の Sandbox テストを使う

---

### iOS Sandbox テスト（RevenueCat 経由の E2E テスト）

StoreKit Configuration を**外した状態**で実機テストすると、Apple の Sandbox 環境を通る。

#### 前提条件

- App Store Connect にプロダクト `remove_ads` が作成済み
- RevenueCat ダッシュボードの設定が完了済み

#### 手順

1. Xcode の Scheme → Run → Options → **StoreKit Configuration を「None」に戻す**
2. **Sandbox テスターアカウントを作成**:
   - App Store Connect →「ユーザとアクセス」→「Sandbox」→「テスター」
   - 「+」→ テスト用のメールアドレス・パスワードを設定
   - ※ 実在するメールアドレスである必要はない（適当でOK）
3. **実機**の設定:
   - 設定 → App Store → 「サンドボックスアカウント」にテスターを追加
   - または、購入時に自動でサインインを求められる
4. アプリを実機で起動して購入フローをテスト
5. Sandbox では**実際の課金は発生しない**
6. RevenueCat ダッシュボードの **「Customers」** でトランザクションを確認可能

---

### Android ローカルテスト

Android はストアのテスト環境を使う必要がある（iOS の StoreKit のような完全ローカルの仕組みはない）。

#### 前提条件

- Google Play Console にアプリ内アイテム `remove_ads` が作成済み
- **内部テストトラック**に APK / AAB が 1 つ以上アップロードされている
  - 課金テスト用のビルドは不完全でもOK（アプリ内アイテムが取得できればよい）

#### 手順 1: テスターの登録

1. Google Play Console →「Simple Handwriting Chat」
2. 左サイドバー「テスト」→「内部テスト」
3. 「テスター」タブ → メーリングリストを作成
4. テスト用の Google アカウントのメールアドレスを追加
5. 「変更を保存」

#### 手順 2: ライセンステスターの設定（課金テスト用）

1. Google Play Console → 左サイドバー **「設定」→「ライセンステスト」**
2. テスト用の Google アカウントのメールアドレスを追加
3. ライセンスのレスポンス: **「LICENSED」** を選択
4. 「変更を保存」

> ライセンステスターに登録された Google アカウントで購入すると
> **実際の課金は発生しない**（テストカードが自動的に使用される）。

#### 手順 3: テスト用 APK のアップロード

1. ビルド: `rake build_apk`
2. Google Play Console →「テスト」→「内部テスト」→「新しいリリースを作成」
3. APK をアップロード →「リリースを確認」→「公開開始」
4. 内部テストの参加リンクをコピーし、テスト用アカウントのブラウザで開いてオプトイン

#### 手順 4: テスト実行

1. テスト用 Google アカウントでサインインした実機（またはエミュレータ）を用意
2. **実機にデバッグビルドをインストール**: `rake run_android`
   - ※ Play Store からインストールする必要はない。デバッグビルドでも課金テスト可能
     （ただし署名が一致する必要あり、または ライセンステスター設定済みなら OK）
3. メニュー画面の「広告を削除」をタップ
4. Google Play の購入ダイアログが表示される（テストカード使用）
5. 「購入」で完了 → 広告が非表示になることを確認

#### テスト購入のリセット

- Google Play Console →「注文管理」で テストトランザクションを払い戻し可能
- RevenueCat ダッシュボード →「Customers」→ 該当ユーザーを検索 → 購入状態を確認

---

### テスト方法の比較

| | iOS StoreKit Local | iOS Sandbox | Android 内部テスト |
|---|---|---|---|
| Apple ID / Google アカウント | 不要 | Sandbox テスター必要 | ライセンステスター必要 |
| ストア側プロダクト設定 | 不要 | 必要 | 必要 |
| RevenueCat ダッシュボード | 不要 | 必要 | 必要 |
| 実機 | 不要（シミュレータ可） | 必要 | 実機推奨 |
| RevenueCat で確認 | 不可 | 可能 | 可能 |
| おすすめ用途 | UI・フローの初期確認 | リリース前の E2E テスト | リリース前の E2E テスト |

---

### 動作確認チェックリスト

- [ ] 未購入状態で広告が表示される
- [ ] 「広告を削除」タップで購入フローが開始される
- [ ] 購入完了後、即座に広告が非表示になる
- [ ] 購入完了後、インタースティシャル広告が出ない
- [ ] 購入完了後、メニューに「購入済み」が表示される
- [ ] アプリ再起動後も購入状態が維持される
- [ ] 「購入を復元」で過去の購入が復元される
- [ ] 復元成功後、広告が非表示になる
- [ ] 購入履歴がない状態で復元→適切なメッセージ表示
- [ ] ネットワークエラー時に適切なエラーハンドリング
- [ ] iOS / Android 両方で動作確認

---

## 実装の優先順位

| 順序 | 作業 | 種別 | 参照 |
|------|------|------|------|
| 1 | App Store Connect でプロダクト作成 | 手作業 | Phase A |
| 2 | Google Play Console でプロダクト作成 | 手作業 | Phase B |
| 3 | RevenueCat ダッシュボード設定 | 手作業 | Phase C |
| 4 | `purchases_flutter` パッケージ追加 | コード | Step 1 |
| 5 | `PurchaseService` 実装 | コード | Step 2 |
| 6 | `AdService` 改修 | コード | Step 3 |
| 7 | `main.dart` 改修 | コード | Step 4 |
| 8 | `MenuPage` 改修 | コード | Step 5 |
| 9 | ローカライズ追加 | コード | Step 6 |
| 10 | iOS / Android 固有設定 | コード | Step 7-8 |
| 11 | テスト | 検証 | テスト計画 |

---

## 注意事項

- **Apple のレビューガイドライン**: 「購入を復元」ボタンの設置は必須（App Store Review Guidelines 3.1.1）
- **RevenueCat の無料枠**: 月間 $2,500 の MTR まで無料
- **Entitlement ベースの設計**: プロダクト ID ではなく Entitlement (`simple handwriting chat Pro`) で判定することで、将来プロダクトを変更しても影響を最小化できる
- **オフライン対応**: RevenueCat SDK はキャッシュを持つため、オフラインでも購入状態を正しく反映する
