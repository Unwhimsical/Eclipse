// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static String m0(count) => "Imported ${count} node(s)";

  static String m1(code) =>
      "Windows が EclipseCore.exe の実行を拒否しました（エラー ${code}）。スマート アプリ コントロールや AppLocker などのアプリ制御ポリシーは未署名のプログラムをブロックします。ポリシーで Eclipse を許可するか、ポリシーを無効にしてから再試行してください。";

  static String m2(name) =>
      "アプリの起動が2回連続で完了しませんでした。クラッシュループを断ち切るため、プロファイル ${name} の選択を解除し、今回の自動セットアップをスキップしました。いつでも選択し直せます。";

  static String m3(url) => "${url} からプロファイルを作成しますか？";

  static String m4(count) => "${count} 日前";

  static String m5(name) => "モジュール「${name}」を削除しますか？";

  static String m6(label) => "選択した${label}を削除してもよろしいですか？";

  static String m7(label) => "この${label}を削除してもよろしいですか？";

  static String m8(label) => "${label}の詳細";

  static String m9(label) => "${label}は空にできません";

  static String m10(count) => "${count} 件";

  static String m11(label) => "${label}はすでに存在します";

  static String m12(name) => "${name} はすでに最新です";

  static String m13(name) => "${name} を更新しました";

  static String m14(count) => "${count} 時間前";

  static String m15(count) => "${count} 時間";

  static String m16(target) => "${target} は無効なポリシーです";

  static String m17(proxyName) => "${proxyName} は無効なプロキシです";

  static String m18(providerName) => "${providerName} は無効なプロキシプロバイダーです";

  static String m19(subRule) => "${subRule} は無効な SUB_RULE です";

  static String m20(appName) =>
      "1. システム設定 > プライバシーとセキュリティ を開く\n2. 位置情報サービス を選択\n3. リストで ${appName} を見つけてチェックを入れる\n\n設定が完了したらアプリに戻ると、通常どおり使用できます。ご協力ありがとうございます。";

  static String m21(label, max) => "${label}は最大${max}文字です";

  static String m22(count) => "${count} 分前";

  static String m23(author) => "作者：${author}";

  static String m24(count) => "Host：${count}";

  static String m25(name) => "モジュールをインポートしました：${name}";

  static String m26(count) => "URL リライト：${count}";

  static String m27(count) => "ルール：${count}";

  static String m28(count) => "スクリプト：${count}";

  static String m29(ruleCount, rewriteCount, scriptCount) =>
      "ルール ${ruleCount} · リライト ${rewriteCount} · スクリプト ${scriptCount}";

  static String m30(count) => "${count} か月前";

  static String m31(label) => "${label}はまだありません";

  static String m32(label) => "${label}は数値である必要があります";

  static String m33(label) => "${label} は 1024〜49151 の範囲で指定してください";

  static String m34(count) => "プロキシ ${count} 件";

  static String m35(count) => "ルール ${count} 件";

  static String m36(count) => "${count} 件のルールをインポートしました";

  static String m37(count) => "${count} 秒";

  static String m38(count) => "${count} 件選択中";

  static String m39(count) => "Effective rules (${count})";

  static String m40(index, total) => "Rule ${index} of ${total}";

  static String m41(label) => "${label}はURLである必要があります";

  static String m42(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "accessControl": MessageLookupByLibrary.simpleMessage("アクセス制御"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリのみVPNを経由します",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシを利用するアプリを設定します",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "アプリアクセス制御は無効です",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリはVPNから除外されます",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("アクセス制御の設定"),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "action": MessageLookupByLibrary.simpleMessage("アクション"),
    "actionMode": MessageLookupByLibrary.simpleMessage("モード切替"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "actionStart": MessageLookupByLibrary.simpleMessage("開始/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("表示/非表示"),
    "add": MessageLookupByLibrary.simpleMessage("追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイルを追加"),
    "addProxies": MessageLookupByLibrary.simpleMessage("プロキシを追加"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを追加"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダーを追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "addScene": MessageLookupByLibrary.simpleMessage("シーンを追加"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSIDを追加"),
    "addSubscription": MessageLookupByLibrary.simpleMessage("サブスクリプションを追加"),
    "addWidget": MessageLookupByLibrary.simpleMessage("ウィジェットを追加"),
    "addedRules": MessageLookupByLibrary.simpleMessage("追加ルール"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage("追加パラメータ"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーのアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "有効なWebDAVアドレスを入力してください",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage("多彩な設定項目を提供します"),
    "agree": MessageLookupByLibrary.simpleMessage("同意する"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("アプリによるVPNバイパスを許可"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、一部のアプリがVPNをバイパスできます",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LANプロキシ"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN経由でのプロキシ利用を許可します"),
    "alwaysRealIp": MessageLookupByLibrary.simpleMessage("常に実IP"),
    "app": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("アプリアクセス制御"),
    "appearance": MessageLookupByLibrary.simpleMessage("外観"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage("ダーク・ライト・システム連動"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを追加"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "設定にシステムDNSを強制的に追加します",
    ),
    "application": MessageLookupByLibrary.simpleMessage("アプリケーション"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "アプリケーション関連の設定を変更します",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("認証"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルプロキシポートに認証を要求し、他のアプリによる無断利用を防ぎます",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "認証が有効な間は適用されません",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("許可"),
    "authorized": MessageLookupByLibrary.simpleMessage("許可済み"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("更新の自動チェック"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "アプリ起動時に更新を自動的にチェックします",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("接続を自動的に閉じる"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "ノードの切り替え後、接続を自動的に閉じます",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自動起動"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage("システム起動時に自動的に起動します"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動実行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("アプリを開いたときに自動的に実行します"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを自動設定"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔（分）"),
    "back": MessageLookupByLibrary.simpleMessage("戻る"),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVまたはファイルでデータを同期します",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップが完了しました"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("基本設定"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage("基本設定をグローバルに変更します"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基本情報"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基本ポリシー"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンドでの動作を維持するため、このアプリの電池の最適化を無効にしてください。タップすると設定を開きます。",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "システムの制限により、実行中は電池の最適化の状態を正しく取得できません",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("連携"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("ブラックリストモード"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("接続をブロック"),
    "bodyRewrite": MessageLookupByLibrary.simpleMessage("Body Rewrite"),
    "bodyRewriteDesc": MessageLookupByLibrary.simpleMessage(
      "正規表現やjqでリクエスト/レスポンスボディを書き換え",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("除外ドメイン"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "システムプロキシが有効な場合のみ適用されます",
    ),
    "caCenter": MessageLookupByLibrary.simpleMessage("CAセンター"),
    "caCenterDesc": MessageLookupByLibrary.simpleMessage(
      "MITMルート証明書を生成し、インストールと信頼設定を案内",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("すべて選択解除"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "プロキシの切り替えに失敗したため、前回の選択に戻しました",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("破壊的変更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新機能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("不具合修正"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("パフォーマンス"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("取り消し"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS証明書を検証"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "信頼できない証明書を拒否します。無効にすると、サブスクリプションやバックアップが中間者攻撃にさらされます",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("更新を確認"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("すでに最新バージョンです"),
    "clearData": MessageLookupByLibrary.simpleMessage("データを消去"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("検索をクリア"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("クリップボードへエクスポート"),
    "clipboardIgnore": MessageLookupByLibrary.simpleMessage("Ignore"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("クリップボードからインポート"),
    "clipboardImportFailed": MessageLookupByLibrary.simpleMessage(
      "Could not parse the link",
    ),
    "clipboardImported": m0,
    "clipboardLinkCopied": MessageLookupByLibrary.simpleMessage("Link copied"),
    "clipboardLinkFound": MessageLookupByLibrary.simpleMessage(
      "Node link found in clipboard",
    ),
    "clipboardLinkFoundDesc": MessageLookupByLibrary.simpleMessage(
      "Import it into the current profile?",
    ),
    "clipboardLinkImport": MessageLookupByLibrary.simpleMessage("Import"),
    "clipboardLinkMessage": MessageLookupByLibrary.simpleMessage(
      "A node share link was detected in the clipboard.",
    ),
    "clipboardLinkTitle": MessageLookupByLibrary.simpleMessage(
      "Node Link Found",
    ),
    "close": MessageLookupByLibrary.simpleMessage("閉じる"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("接続を閉じる"),
    "color": MessageLookupByLibrary.simpleMessage("カラー"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("カラースキーム"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("近日公開"),
    "comingSoonDesc": MessageLookupByLibrary.simpleMessage("この機能は近日公開予定です。"),
    "compatMode": MessageLookupByLibrary.simpleMessage("Compatibility Mode"),
    "compatModeDesc": MessageLookupByLibrary.simpleMessage(
      "Trade some features for wider compatibility with strict networks and older systems",
    ),
    "compatModeEffect1": MessageLookupByLibrary.simpleMessage(
      "Prefers TCP-based handshakes and disables UDP fast paths that strict networks may block",
    ),
    "compatModeEffect2": MessageLookupByLibrary.simpleMessage(
      "Falls back to plain HTTP CONNECT where enhanced transports fail",
    ),
    "compatModeEffects": MessageLookupByLibrary.simpleMessage(
      "What changes when enabled",
    ),
    "compatModeIosNote": MessageLookupByLibrary.simpleMessage(
      "iOS note: due to system restrictions, compatibility mode cannot change the TUN stack or packet behavior on iOS; it only adjusts app-level fallbacks",
    ),
    "compatModeSwitch": MessageLookupByLibrary.simpleMessage(
      "Enable compatibility mode",
    ),
    "compatibilityMode": MessageLookupByLibrary.simpleMessage("互換モード"),
    "compatible": MessageLookupByLibrary.simpleMessage("互換モード"),
    "config": MessageLookupByLibrary.simpleMessage("設定"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "設定内にデータが見つかりました",
    ),
    "configDetail": MessageLookupByLibrary.simpleMessage("設定詳細"),
    "confirm": MessageLookupByLibrary.simpleMessage("OK"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "すべてのデータを消去してもよろしいですか？",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "このプロキシグループを削除してもよろしいですか？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "現在のウィンドウを閉じてもよろしいですか？",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "コアを強制クラッシュさせてもよろしいですか？",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "確定すると既存のデータを上書きします",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "connecting": MessageLookupByLibrary.simpleMessage("接続中..."),
    "connection": MessageLookupByLibrary.simpleMessage("接続"),
    "connections": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("現在の接続データを表示します"),
    "connectivity": MessageLookupByLibrary.simpleMessage("接続状態："),
    "connectivityTest": MessageLookupByLibrary.simpleMessage("接続テスト"),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容は空にできません"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("コンテンツ"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "グローバル追加ルールを管理",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("環境変数をコピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "core": MessageLookupByLibrary.simpleMessage("コア"),
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows のスマート アプリ コントロールが、署名されていない EclipseCore.exe をブロックしました。Windows セキュリティ → アプリとブラウザーの制御 → スマート アプリ コントロールの設定で「オフ」を選び、Eclipse を再起動してください。一度オフにすると、Windows を再インストールしない限り再度オンにはできません。",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コアの状態"),
    "coreUnsupported": MessageLookupByLibrary.simpleMessage("コアがサポートしていません"),
    "country": MessageLookupByLibrary.simpleMessage("地域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("クラッシュを検出しました"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("クラッシュ分析"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "有効にすると、アプリのクラッシュ時に機密情報を含まないクラッシュログを自動的にアップロードします",
    ),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "createProfile": MessageLookupByLibrary.simpleMessage("プロファイルを作成"),
    "createProfileFromUrlTip": m3,
    "creationTime": MessageLookupByLibrary.simpleMessage("作成日時"),
    "currentNode": MessageLookupByLibrary.simpleMessage("現在のノード"),
    "custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ダッシュボード"),
    "data": MessageLookupByLibrary.simpleMessage("データ"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "データの変更を検出しました。保存しますか？",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "本アプリは、安定性向上のために Firebase Crashlytics を使用してクラッシュ情報を収集します。\n収集されるデータにはデバイス情報とクラッシュの詳細が含まれますが、個人の機密データは含まれません。\nこの機能は設定で無効にできます。",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage("データ収集について"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "変更の保存に失敗したため、元に戻しました",
    ),
    "daysAgo": m4,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("デフォルトネームサーバー"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNSサーバーの名前解決に使用します",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "delay": MessageLookupByLibrary.simpleMessage("遅延"),
    "delayTest": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "delayTestAll": MessageLookupByLibrary.simpleMessage("全ノード遅延テスト"),
    "delayTestDesc": MessageLookupByLibrary.simpleMessage("ノードの遅延をテスト"),
    "delayTestMethod": MessageLookupByLibrary.simpleMessage("遅延テスト方法"),
    "delayTestMethodConnect": MessageLookupByLibrary.simpleMessage("CONNECT"),
    "delayTestMethodConnectDesc": MessageLookupByLibrary.simpleMessage(
      "テストURLへHTTP HEADを送信、実用性に最も近い",
    ),
    "delayTestMethodIcmp": MessageLookupByLibrary.simpleMessage("ICMP"),
    "delayTestMethodIcmpDesc": MessageLookupByLibrary.simpleMessage(
      "ICMPエコーの往復時間",
    ),
    "delayTestMethodTcp": MessageLookupByLibrary.simpleMessage("TCP"),
    "delayTestMethodTcpDesc": MessageLookupByLibrary.simpleMessage(
      "TCP接続の往復時間",
    ),
    "delayTestUrl": MessageLookupByLibrary.simpleMessage("テストURL"),
    "delayTestUrlHint": MessageLookupByLibrary.simpleMessage(
      "https://www.gstatic.com/generate_204",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteModuleConfirm": m5,
    "deleteMultipTip": m6,
    "deleteTip": m7,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMetaベースのマルチプラットフォーム対応プロキシクライアント。シンプルで使いやすく、オープンソースで広告もありません。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "details": m8,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "サードパーティAPIに依存しているため、参考値です",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("開発者モード"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "開発者モードが有効になりました。",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "directDnsServers": MessageLookupByLibrary.simpleMessage("ダイレクトDNSサーバー"),
    "disableStun": MessageLookupByLibrary.simpleMessage("STUNを無効化"),
    "disableStunDesc": MessageLookupByLibrary.simpleMessage(
      "WebRTCのSTUNによるグローバルIP取得を防止",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDPを無効化"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責事項"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは、学習・交流や研究などの非商用目的でのみ使用できます。商用目的での使用は固く禁じられています。いかなる商業行為も本ソフトウェアとは一切関係ありません。",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("切断済み"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンが見つかりました",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS関連の設定を更新します"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNSハイジャック"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNSモード"),
    "dnsServers": MessageLookupByLibrary.simpleMessage("DNSサーバー"),
    "domain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "duplicateProfile": MessageLookupByLibrary.simpleMessage("設定を複製"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editArguments": MessageLookupByLibrary.simpleMessage("引数を編集"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルールを編集"),
    "editProxy": MessageLookupByLibrary.simpleMessage("プロキシを編集"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループを編集"),
    "editRule": MessageLookupByLibrary.simpleMessage("ルールを編集"),
    "editScene": MessageLookupByLibrary.simpleMessage("シーンを編集"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSIDを編集"),
    "emptyTip": m9,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "entries": MessageLookupByLibrary.simpleMessage(" 件"),
    "entriesCount": m10,
    "exclude": MessageLookupByLibrary.simpleMessage("最近のタスクから隠す"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンド時に、最近のタスクからアプリを隠します",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage("除外ノードフィルター"),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("除外SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "除外したSSIDのWi-Fiに接続すると、アプリの実行状態が自動的に切り替わります",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("除外タイプ"),
    "existsTip": m11,
    "exit": MessageLookupByLibrary.simpleMessage("終了"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("全画面表示を終了"),
    "expand": MessageLookupByLibrary.simpleMessage("標準"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("期待するステータス"),
    "expireTime": MessageLookupByLibrary.simpleMessage("有効期限"),
    "exportFile": MessageLookupByLibrary.simpleMessage("ファイルをエクスポート"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("ログをエクスポート"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポートが完了しました"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("エクスプレッシブ"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部コントローラー"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、ポート9090でClashコアを制御できます",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部取得"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部リンク"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IPフィルター"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP範囲"),
    "fallback": MessageLookupByLibrary.simpleMessage("フォールバック"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("通常は国外のDNSを使用します"),
    "fallbackDnsServers": MessageLookupByLibrary.simpleMessage(
      "フォールバックDNSサーバー",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("フォールバックフィルター"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("フィデリティ"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("プロファイルファイルを直接アップロードします"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "ファイルが変更されています。変更を保存しますか？",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("プロセス検出"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、パフォーマンスが多少低下します",
    ),
    "followProfile": MessageLookupByLibrary.simpleMessage("プロファイルに従う"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("フォント"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "コアを強制再起動してもよろしいですか？",
    ),
    "frontProxy": MessageLookupByLibrary.simpleMessage("Front Proxy"),
    "frontProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Route all traffic through an extra upstream HTTP/SOCKS5 node first",
    ),
    "frontProxyEmpty": MessageLookupByLibrary.simpleMessage(
      "No HTTP/SOCKS5 nodes in the current profile",
    ),
    "frontProxyNone": MessageLookupByLibrary.simpleMessage("None (direct)"),
    "frontProxyOnlyHttpSocks": MessageLookupByLibrary.simpleMessage(
      "Only HTTP and SOCKS5 nodes are listed",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("フルーツサラダ"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "generalSection": MessageLookupByLibrary.simpleMessage("一般"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("一般設定"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔"),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自動更新間隔は0より大きくしてください",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geoオプション"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geoリソース"),
    "geoSkipped": m12,
    "geoUpdate": MessageLookupByLibrary.simpleMessage("Geoデータ更新"),
    "geoUpdated": m13,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低メモリモード"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、低メモリのGeoローダーを使用します",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIPコード"),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "globalRoute": MessageLookupByLibrary.simpleMessage("グローバルルーティング"),
    "go": MessageLookupByLibrary.simpleMessage("開く"),
    "goDownload": MessageLookupByLibrary.simpleMessage("ダウンロードへ"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("スクリプト設定へ移動"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "headerRewrite": MessageLookupByLibrary.simpleMessage("ヘッダーリライト"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper サービスが利用できないため、TUN モードを有効にできません。Eclipse を再インストールしてください。",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("リストから隠す"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("パスワードを隠す"),
    "home": MessageLookupByLibrary.simpleMessage("ホーム"),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostSection": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Hostsを追加します"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("ホットキーが競合しています"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("ホットキー管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "キーボードでアプリを操作します",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("時間"),
    "hoursAgo": m14,
    "hoursCount": m15,
    "httpsDecryption": MessageLookupByLibrary.simpleMessage("HTTPS復号"),
    "icon": MessageLookupByLibrary.simpleMessage("アイコン"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("アイコン履歴"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("アイコンスタイル"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("アイコンURL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "電池の最適化を無視",
    ),
    "import": MessageLookupByLibrary.simpleMessage("インポート"),
    "importConfRules": MessageLookupByLibrary.simpleMessage(".conf ルールをインポート"),
    "importExport": MessageLookupByLibrary.simpleMessage("インポートとエクスポート"),
    "importFile": MessageLookupByLibrary.simpleMessage("ファイルからインポート"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "importFromUrl": MessageLookupByLibrary.simpleMessage("URL からインポート"),
    "importModule": MessageLookupByLibrary.simpleMessage("モジュールをインポート"),
    "importModuleFromFile": MessageLookupByLibrary.simpleMessage(
      ".sgmodule ファイルからインポート",
    ),
    "importRules": MessageLookupByLibrary.simpleMessage("ルールをインポート"),
    "importRulesFromFile": MessageLookupByLibrary.simpleMessage(
      ".conf ファイルからインポート",
    ),
    "importSubscription": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションをインポート",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "inbound": MessageLookupByLibrary.simpleMessage("インバウンド"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage("すべてのプロキシを含める"),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "プロキシグループに属さないすべてのプロキシを取り込みます。下でプロキシグループを追加できます",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "すべてのプロキシプロバイダーを含める",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "有効にすると、取り込んだプロキシプロバイダーを上書きします",
    ),
    "includeUrl": MessageLookupByLibrary.simpleMessage("インクルードURL"),
    "includeUrlDesc": MessageLookupByLibrary.simpleMessage(
      "インポート時にマージされたリモート設定。参照用に保持されます。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("無期限"),
    "init": MessageLookupByLibrary.simpleMessage("初期化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "正しいホットキーを入力してください",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名を入力してください",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("ルールの内容を入力してください"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "アプリ一覧の権限が拒否されたため、インストール済みアプリを取得できません。システム設定から手動で許可してください。",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "このシステムでは、許可するまでインストール済みアプリの一覧が提供されません。許可すると、アプリごとのプロキシを設定できます。",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "アプリ一覧の権限が必要です",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("スマート選択"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("インターフェース名"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "アウトバウンド接続に使用するネットワークインターフェース名",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "アウトバウンドインターフェース",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("クリア"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("設定に従う"),
    "internet": MessageLookupByLibrary.simpleMessage("インターネット"),
    "interval": MessageLookupByLibrary.simpleMessage("間隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("イントラネットIP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("無効なバックアップファイル"),
    "invalidPolicy": m16,
    "invalidProxy": m17,
    "invalidProxyProvider": m18,
    "invalidSubRule": m19,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、IPv6トラフィックを受信できます",
    ),
    "ipv6FollowConfig": MessageLookupByLibrary.simpleMessage("グローバル設定に従う"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("IPv6インバウンドを許可します"),
    "ipv6Off": MessageLookupByLibrary.simpleMessage("IPv6を無効化"),
    "ipv6On": MessageLookupByLibrary.simpleMessage("IPv6を有効化"),
    "ja": MessageLookupByLibrary.simpleMessage("日本語"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCPキープアライブ間隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("起動が完了しませんでした"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "前回、アプリは起動中に予期せず終了しました。今回の自動セットアップはスキップしました。手動で起動して再試行できます。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リッスン"),
    "loading": MessageLookupByLibrary.simpleMessage("読み込み中..."),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localAddress": MessageLookupByLibrary.simpleMessage("ローカルアドレス"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "ローカルにデータをバックアップします",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置情報の権限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が拒否されたため、現在の Wi-Fi 名を取得できません。システム設定で位置情報の権限を手動で有効にしてください。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "システムの要件により、Wi-Fi 名の取得には位置情報の権限が必要です。Android では「常に許可」を選択してください。そうしないと、アプリがバックグラウンドにあるときに Wi-Fi 名を取得できません。",
    ),
    "locationPermissionGuide": m20,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "位置情報の権限が必要です",
    ),
    "log": MessageLookupByLibrary.simpleMessage("ログ"),
    "logLevel": MessageLookupByLibrary.simpleMessage("ログレベル"),
    "logcat": MessageLookupByLibrary.simpleMessage("ログキャプチャ"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("無効にするとログの入り口が非表示になります"),
    "logs": MessageLookupByLibrary.simpleMessage("ログ"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("キャプチャしたログの記録"),
    "logsTest": MessageLookupByLibrary.simpleMessage("ログテスト"),
    "loopback": MessageLookupByLibrary.simpleMessage("ループバック解除ツール"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("UWPのループバック解除に使用します"),
    "loose": MessageLookupByLibrary.simpleMessage("ゆったり"),
    "mapLocal": MessageLookupByLibrary.simpleMessage("Map Local"),
    "mapLocalDesc": MessageLookupByLibrary.simpleMessage(
      "一致したリクエストのレスポンスをローカルコンテンツに置換",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("送信元IPにマッチ"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET を対象にしたルールの行き先。既定ではこのプロファイル末尾の MATCH ルールのターゲットを使います。",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("マッチ先"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失敗回数"),
    "maxLengthTip": m21,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("これはメッセージです。"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("終了時に最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "システム標準の終了動作を変更します",
    ),
    "minutesAgo": m22,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixedポート"),
    "mode": MessageLookupByLibrary.simpleMessage("モード"),
    "module": MessageLookupByLibrary.simpleMessage("モジュール"),
    "moduleAuthor": m23,
    "moduleDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "ダウンロードに失敗したか、有効なモジュールが見つかりません",
    ),
    "moduleHostCount": m24,
    "moduleImported": m25,
    "moduleInvalid": MessageLookupByLibrary.simpleMessage("有効なモジュールが見つかりません"),
    "moduleMitmNote": MessageLookupByLibrary.simpleMessage(
      "MITM 解読が必要なコンテンツを含みます。現在は静的ルールとして適用されます",
    ),
    "moduleRewriteCount": m26,
    "moduleRuleCount": m27,
    "moduleScriptCount": m28,
    "moduleStatsSummary": m29,
    "modules": MessageLookupByLibrary.simpleMessage("モジュール"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "monthsAgo": m30,
    "more": MessageLookupByLibrary.simpleMessage("その他"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "複数の値はカンマで区切ってください",
    ),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameserver": MessageLookupByLibrary.simpleMessage("ネームサーバー"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("ドメインの名前解決に使用します"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("ネームサーバーポリシー"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインごとのネームサーバーポリシーを指定します",
    ),
    "network": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("ネットワーク関連の設定を変更します"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("ネットワーク検出"),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "ネットワークエラーです。接続を確認してから再試行してください",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("ネットワーク速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワーク種別"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("ニュートラル"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("次の一致"),
    "noActiveConnections": MessageLookupByLibrary.simpleMessage(
      "このノードを経由する接続がありません",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("データがありません"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("ホットキーはまだありません"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報がありません"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("今後表示しない"),
    "noModulesDesc": MessageLookupByLibrary.simpleMessage(
      "モジュールがありません。+ をタップして .sgmodule をインポート",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークがありません"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("ネットワーク不使用アプリ"),
    "noNodesDesc": MessageLookupByLibrary.simpleMessage(
      "ノードがありません。サブスクリプションを追加してください。",
    ),
    "noProfileSelected": MessageLookupByLibrary.simpleMessage(
      "プロファイルが選択されていません",
    ),
    "noRecords": MessageLookupByLibrary.simpleMessage("記録がありません"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IPを解決しない"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("ホスト名を解決しない"),
    "noRulesInConf": MessageLookupByLibrary.simpleMessage(".conf にルールが見つかりません"),
    "nodeDetail": MessageLookupByLibrary.simpleMessage("ノード詳細"),
    "nodeImportExport": MessageLookupByLibrary.simpleMessage(
      "ノードのインポート/エクスポート",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("ノード"),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループは選択できません",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルがありません。先にプロファイルを追加してください",
    ),
    "nullTip": m31,
    "numberTip": m32,
    "onDemand": MessageLookupByLibrary.simpleMessage("オンデマンド"),
    "onDemandAlwaysOn": MessageLookupByLibrary.simpleMessage("Always on"),
    "onDemandAlwaysOnDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the VPN connected and reconnect automatically after reboots or drops",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "特定のシナリオでのアプリの実行状態を設定します",
    ),
    "onDemandDisconnectOnSleep": MessageLookupByLibrary.simpleMessage(
      "Disconnect while asleep",
    ),
    "onDemandDisconnectOnSleepDesc": MessageLookupByLibrary.simpleMessage(
      "Disconnect the VPN when the device sleeps to save battery",
    ),
    "onDemandExtras": MessageLookupByLibrary.simpleMessage("On-Demand Extras"),
    "onDemandExtrasDesc": MessageLookupByLibrary.simpleMessage(
      "常時接続、スリープ時切断、切断通知",
    ),
    "onDemandShowDisconnectInfo": MessageLookupByLibrary.simpleMessage(
      "Show disconnect notices",
    ),
    "onDemandShowDisconnectInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Notify when the VPN unexpectedly disconnects",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("アイコンのみ"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("プロキシのみ集計"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロキシのトラフィックのみを集計します",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("任意"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("その他の貢献者"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "override": MessageLookupByLibrary.simpleMessage("上書き"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNSを上書き"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロファイル内のDNS設定を上書きします",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("上書きモード"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("上書きスクリプト"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "カスタムモード：プロキシグループとルールを完全にカスタマイズできます",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("パレット"),
    "paramOff": MessageLookupByLibrary.simpleMessage("オフ"),
    "paramOn": MessageLookupByLibrary.simpleMessage("オン"),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "paste": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "pasteImport": MessageLookupByLibrary.simpleMessage("クリップボードから貼り付け"),
    "pasteImportDesc": MessageLookupByLibrary.simpleMessage(
      "クリップボードからノードリンクを読み取ってインポート",
    ),
    "permClipboard": MessageLookupByLibrary.simpleMessage("Clipboard"),
    "permClipboardDesc": MessageLookupByLibrary.simpleMessage(
      "Detect node share links copied to the clipboard and offer one-tap import",
    ),
    "permLocation": MessageLookupByLibrary.simpleMessage("Location"),
    "permLocationDesc": MessageLookupByLibrary.simpleMessage(
      "Scene mode reads the Wi-Fi name to auto-switch profiles; the system requires the location permission for this",
    ),
    "permNotification": MessageLookupByLibrary.simpleMessage("Notifications"),
    "permNotificationDesc": MessageLookupByLibrary.simpleMessage(
      "Script results, subscription updates and VPN disconnect alerts",
    ),
    "permOpenSettings": MessageLookupByLibrary.simpleMessage(
      "Open system settings",
    ),
    "permOpenSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Open the system settings page for Eclipse",
    ),
    "permissionNotes": MessageLookupByLibrary.simpleMessage("権限の説明"),
    "permissions": MessageLookupByLibrary.simpleMessage("Permissions"),
    "permissionsDesc": MessageLookupByLibrary.simpleMessage(
      "Eclipse needs these system permissions to work properly. You can change them anytime in the system settings.",
    ),
    "permissionsInfo": MessageLookupByLibrary.simpleMessage("Permissions"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("アルバムから選択"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("最前面に固定"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAVを連携してください"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "スクリプト名を入力してください",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "有効なQRコードをアップロードしてください",
    ),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("別のポートを入力してください"),
    "portTip": m33,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("DoHでHTTP/3を優先します"),
    "preferIpv6": MessageLookupByLibrary.simpleMessage("IPv6を優先"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前提条件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("キーを押してください"),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("前の一致"),
    "privateIpAnswer": MessageLookupByLibrary.simpleMessage("プライベートIP応答"),
    "process": MessageLookupByLibrary.simpleMessage("プロセス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な間隔を入力してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("自動更新間隔を入力してください"),
    "profileCopySuffix": MessageLookupByLibrary.simpleMessage("コピー"),
    "profileDuplicated": MessageLookupByLibrary.simpleMessage("設定を複製しました"),
    "profileFiles": MessageLookupByLibrary.simpleMessage("設定ファイル"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されています。自動更新を無効にしますか？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル名を入力してください",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルのURLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイルの並べ替え"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "providers": MessageLookupByLibrary.simpleMessage("外部リソース"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxiesCount": m34,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("プロキシが空です"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "選択したプロキシに異常が見つかりました",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("ノードフィルター"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループに異常が見つかりました",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("プロキシグループが空です"),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名が重複しています",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシグループ名は空にできません",
    ),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("プロキシネームサーバー"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシノードのドメイン解決に使用します",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "選択したプロキシプロバイダーに異常が見つかりました",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーが空です",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーは空にできません",
    ),
    "proxyServers": MessageLookupByLibrary.simpleMessage("プロキシサーバー"),
    "proxySharing": MessageLookupByLibrary.simpleMessage("Proxy Sharing"),
    "proxySharingAddress": MessageLookupByLibrary.simpleMessage("LAN address"),
    "proxySharingCertTip": MessageLookupByLibrary.simpleMessage(
      "To decrypt HTTPS on the other device, install and trust the Eclipse CA certificate there first",
    ),
    "proxySharingCopied": MessageLookupByLibrary.simpleMessage(
      "Address copied",
    ),
    "proxySharingCopy": MessageLookupByLibrary.simpleMessage("Copy address"),
    "proxySharingDesc": MessageLookupByLibrary.simpleMessage(
      "Expose the HTTP proxy on the LAN so other devices can use it",
    ),
    "proxySharingOffTip": MessageLookupByLibrary.simpleMessage(
      "Sharing is off; the proxy only listens on this device",
    ),
    "proxySharingSteps": MessageLookupByLibrary.simpleMessage(
      "On the other device, set the HTTP proxy to the address above. No username or password is required.",
    ),
    "proxySharingSwitch": MessageLookupByLibrary.simpleMessage(
      "Enable sharing",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("プロキシタイプ"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("キャッシュを整理"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("ピュアブラックモード"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QRコードをスキャンしてプロファイルを取得します",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("クイック入力"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("レインボー"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直す"),
    "refresh": MessageLookupByLibrary.simpleMessage("更新"),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteAddress": MessageLookupByLibrary.simpleMessage("リモートアドレス"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVにデータをバックアップします",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "remove": MessageLookupByLibrary.simpleMessage("削除"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("最近のリクエスト記録を表示します"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "このページには変更があります。リセットしてもよろしいですか？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("リセットしてもよろしいですか？"),
    "resources": MessageLookupByLibrary.simpleMessage("リソース"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部リソースの関連情報"),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルールに従う"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS接続がルールに従います。proxy-server-nameserverの設定が必要です",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("再起動"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("コアを再起動してもよろしいですか？"),
    "restore": MessageLookupByLibrary.simpleMessage("復元"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("すべてのデータを復元"),
    "restoreDefault": MessageLookupByLibrary.simpleMessage("デフォルトに戻す"),
    "restoreException": MessageLookupByLibrary.simpleMessage("復元エラー"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "ファイルからデータを復元します",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVからデータを復元します",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("プロファイルのみ復元"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("復元方式"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("互換"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("上書き"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("復元が完了しました"),
    "rewrite": MessageLookupByLibrary.simpleMessage("書き換え"),
    "routeAdd": MessageLookupByLibrary.simpleMessage("Add"),
    "routeAddHint": MessageLookupByLibrary.simpleMessage("e.g. 192.168.0.0/16"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("ルートアドレス"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "リッスンするルートアドレスを設定します",
    ),
    "routeConfig": MessageLookupByLibrary.simpleMessage("設定"),
    "routeDirect": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "routeEmpty": MessageLookupByLibrary.simpleMessage("Empty"),
    "routeExcluded": MessageLookupByLibrary.simpleMessage("Excluded routes"),
    "routeExcludedDesc": MessageLookupByLibrary.simpleMessage(
      "These destinations bypass the TUN interface",
    ),
    "routeExists": MessageLookupByLibrary.simpleMessage("Already in the list"),
    "routeIncluded": MessageLookupByLibrary.simpleMessage("Included routes"),
    "routeIncludedDesc": MessageLookupByLibrary.simpleMessage(
      "Only these destinations go through the TUN interface",
    ),
    "routeInvalid": MessageLookupByLibrary.simpleMessage(
      "Not a valid IP or CIDR",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("ルートモード"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "プライベートアドレスをバイパス",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("設定を使用"),
    "routeProxy": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "routeScene": MessageLookupByLibrary.simpleMessage("シーン"),
    "ru": MessageLookupByLibrary.simpleMessage("ロシア語"),
    "rule": MessageLookupByLibrary.simpleMessage("ルール"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("論理ルール AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("完全なドメインにマッチ"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインキーワードにマッチ",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインの正規表現でマッチ",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインサフィックスにマッチ",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "ワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCPマークにマッチ（tproxy udpインバウンドのみ）",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "宛先ポート範囲にマッチ",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("IPの国コードにマッチ"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite 内のドメインにマッチ",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("インバウンド名にマッチ"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドポートにマッチ",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドタイプにマッチ",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "インバウンドユーザー名にマッチ（/ で複数指定可）",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "IPが属するASNにマッチ",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IPアドレス範囲にマッチ（IP-CIDR6 は別名です）",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "IPアドレス範囲にマッチ",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IPサフィックス範囲にマッチ",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "すべてのリクエストにマッチ（条件不要）",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCPまたはUDPにマッチ",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("論理ルール NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("論理ルール OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名でマッチ（Androidではパッケージ名にマッチ）",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名の正規表現でマッチ（Androidではパッケージ名にマッチ）",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "プロセス名のワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスのフルパスでマッチ",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスパスの正規表現でマッチ",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "プロセスパスのワイルドカードでマッチ（* と ? のみ対応）",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "再マッチ名にマッチ（複数は / で区切る）",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "ルールセットを参照します。rule-providersの設定が必要です",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPの国コードにマッチ",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPが属するASNにマッチ",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPアドレス範囲にマッチ",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "送信元IPサフィックス範囲にマッチ",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "送信元ポート範囲にマッチ",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "サブルールへマッチします。括弧の使い方に注意してください",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "LinuxのユーザーIDにマッチ",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("ルールが空です"),
    "ruleName": MessageLookupByLibrary.simpleMessage("ルール名"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("ルールセット"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルールターゲット"),
    "rules": MessageLookupByLibrary.simpleMessage("ルール"),
    "rulesCount": m35,
    "rulesDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "ダウンロードに失敗したか、内容が空です",
    ),
    "rulesImported": m36,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "sceneDeleteConfirm": MessageLookupByLibrary.simpleMessage("このシーンを削除しますか？"),
    "sceneEmpty": MessageLookupByLibrary.simpleMessage("シーンがありません"),
    "sceneIosForegroundNote": MessageLookupByLibrary.simpleMessage(
      "iOS では、アプリがフォアグラウンドにある場合のみネットワークの変化を検出してシーンを切り替えます",
    ),
    "sceneKeepCurrent": MessageLookupByLibrary.simpleMessage("現状維持"),
    "sceneMode": MessageLookupByLibrary.simpleMessage("シーンモード"),
    "sceneModeDesc": MessageLookupByLibrary.simpleMessage(
      "ネットワークに応じてプロファイル・モード・出口ノードを自動切替",
    ),
    "sceneNoSwitch": MessageLookupByLibrary.simpleMessage("切り替えない"),
    "sceneSsidHint": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi名を入力（大文字・小文字を区別）",
    ),
    "sceneTargetMode": MessageLookupByLibrary.simpleMessage("ルーティングモード"),
    "sceneTargetProfile": MessageLookupByLibrary.simpleMessage("対象プロファイル"),
    "sceneTargetProxy": MessageLookupByLibrary.simpleMessage("出口ノード"),
    "sceneTrigger": MessageLookupByLibrary.simpleMessage("トリガー"),
    "sceneTriggerCellular": MessageLookupByLibrary.simpleMessage("モバイル通信"),
    "sceneTriggerFallback": MessageLookupByLibrary.simpleMessage("フォールバック"),
    "sceneTriggerSsid": MessageLookupByLibrary.simpleMessage("Wi-Fi名"),
    "script": MessageLookupByLibrary.simpleMessage("スクリプト"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "スクリプトモード：外部の拡張スクリプトを使用し、ワンクリックで設定を上書きします",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("選択項目へスクロール"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m37,
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "MATCH-TARGET を選択",
    ),
    "selectNode": MessageLookupByLibrary.simpleMessage("ノードを選択"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("プロキシを選択"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "プロキシプロバイダーを選択",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("ルールセットを選択してください"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略を選択してください",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage("サブルールを選択してください"),
    "selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "selectedCountTitle": m38,
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "settingsSectionDisplay": MessageLookupByLibrary.simpleMessage("表示と言語"),
    "settingsSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "ネットワークとプロキシ",
    ),
    "settingsSectionSecurity": MessageLookupByLibrary.simpleMessage(
      "セキュリティと権限",
    ),
    "show": MessageLookupByLibrary.simpleMessage("表示"),
    "showLess": MessageLookupByLibrary.simpleMessage("折りたたむ"),
    "showMore": MessageLookupByLibrary.simpleMessage("展開"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知に停止ボタンを表示",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "常駐通知に停止ボタンを表示します。これが原因で通知が常に展開される場合はオフにしてください",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("パスワードを表示"),
    "shrink": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("サイレント起動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("バックグラウンドで起動します"),
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "skipProxy": MessageLookupByLibrary.simpleMessage("プロキシ除外"),
    "skipProxyDesc": MessageLookupByLibrary.simpleMessage(
      "TUN経由のままにし、ポリシーはルールチェーンが決定します。",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKSポート"),
    "sort": MessageLookupByLibrary.simpleMessage("並べ替え"),
    "sortModules": MessageLookupByLibrary.simpleMessage("モジュールの並べ替え"),
    "source": MessageLookupByLibrary.simpleMessage("ソース"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("速度統計"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("振り分け戦略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "振り分け戦略は空にできません",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDが空です"),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準モード：基本設定を上書きし、シンプルなルール追加機能を提供します",
    ),
    "start": MessageLookupByLibrary.simpleMessage("開始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPNを起動しています..."),
    "statByPolicy": MessageLookupByLibrary.simpleMessage("Traffic by policy"),
    "statConnPolicy": MessageLookupByLibrary.simpleMessage("Policy"),
    "statConnProtocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "statConnRule": MessageLookupByLibrary.simpleMessage("Rule"),
    "statConnections": MessageLookupByLibrary.simpleMessage("Connections"),
    "statDirect": MessageLookupByLibrary.simpleMessage("Direct"),
    "statNetTypeNote": MessageLookupByLibrary.simpleMessage(
      "Per-connection network type (Wi-Fi/cellular) is not reported by the core yet",
    ),
    "statNoConnections": MessageLookupByLibrary.simpleMessage(
      "No active connections",
    ),
    "statOther": MessageLookupByLibrary.simpleMessage("Other"),
    "statProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "statReject": MessageLookupByLibrary.simpleMessage("Rejected"),
    "statTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
    "status": MessageLookupByLibrary.simpleMessage("状態"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("無効にすると、システムDNSを使用します"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPNを停止しています..."),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "subRule": MessageLookupByLibrary.simpleMessage("サブルール"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("サブルールが空です"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage("サブルールは空にできません"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("サブスクリプション情報"),
    "subscriptions": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "suspended": MessageLookupByLibrary.simpleMessage("一時停止中..."),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "system": MessageLookupByLibrary.simpleMessage("システム"),
    "systemApp": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("システムプロキシを設定します"),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("タブアニメーション"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage("モバイル表示でのみ有効です"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("タップして許可"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP同時接続"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "有効にすると、TCPの同時接続を許可します",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("テスト間隔"),
    "testRules": MessageLookupByLibrary.simpleMessage("Test Rules"),
    "testRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Check which rule a domain, URL, IP or port hits",
    ),
    "testRulesEffectiveRules": m39,
    "testRulesEmptyInput": MessageLookupByLibrary.simpleMessage(
      "Enter a domain, URL or IP first",
    ),
    "testRulesInputHint": MessageLookupByLibrary.simpleMessage(
      "e.g. example.com or 1.1.1.1",
    ),
    "testRulesInputLabel": MessageLookupByLibrary.simpleMessage(
      "Domain / URL / IP",
    ),
    "testRulesMatchedRule": MessageLookupByLibrary.simpleMessage(
      "Matched rule",
    ),
    "testRulesNoMatch": MessageLookupByLibrary.simpleMessage(
      "No rule matched; the final policy applies",
    ),
    "testRulesNoProfile": MessageLookupByLibrary.simpleMessage(
      "Select a profile first",
    ),
    "testRulesPortLabel": MessageLookupByLibrary.simpleMessage("Port"),
    "testRulesProtocolLabel": MessageLookupByLibrary.simpleMessage("Protocol"),
    "testRulesRuleOrder": m40,
    "testRulesTest": MessageLookupByLibrary.simpleMessage("Test"),
    "testRulesUnsupportedRule": MessageLookupByLibrary.simpleMessage(
      "This rule type is evaluated by the core and cannot be previewed here",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("テストURL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用時にテスト"),
    "textScale": MessageLookupByLibrary.simpleMessage("テキストの拡大縮小"),
    "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "themeColor": MessageLookupByLibrary.simpleMessage("テーマカラー"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("ダークモードの設定と色の調整"),
    "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "tight": MessageLookupByLibrary.simpleMessage("コンパクト"),
    "time": MessageLookupByLibrary.simpleMessage("時刻"),
    "timeout": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "toggle": MessageLookupByLibrary.simpleMessage("切り替え"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("ラベルを切り替え"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("トーナルスポット"),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "torch": MessageLookupByLibrary.simpleMessage("ライト"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("合計トラフィック"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxyポート"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("トラフィック統計"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("管理者モードでのみ有効"),
    "tunExcludedRoutes": MessageLookupByLibrary.simpleMessage("TUN除外ルート"),
    "tunExcludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "TUNから除外するCIDRルート",
    ),
    "tunIncludedRoutes": MessageLookupByLibrary.simpleMessage("TUN包含ルート"),
    "tunIncludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "TUNに含めるCIDRルート",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("トンネル"),
    "tunnelAdd": MessageLookupByLibrary.simpleMessage("Add"),
    "tunnelAddHint": MessageLookupByLibrary.simpleMessage(
      "e.g. 192.168.0.0/16",
    ),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage(
      "Control which destinations bypass or require the TUN interface",
    ),
    "tunnelEmpty": MessageLookupByLibrary.simpleMessage("No routes yet"),
    "tunnelExcluded": MessageLookupByLibrary.simpleMessage("Excluded routes"),
    "tunnelIncluded": MessageLookupByLibrary.simpleMessage("Included routes"),
    "tunnelNoProfile": MessageLookupByLibrary.simpleMessage(
      "Select a profile first",
    ),
    "tunnelRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "tunnelRoutes": MessageLookupByLibrary.simpleMessage("Routes"),
    "tunnelRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Control which destinations bypass or require the TUN interface",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("オフにする"),
    "turnOn": MessageLookupByLibrary.simpleMessage("オンにする"),
    "udpForward": MessageLookupByLibrary.simpleMessage("UDP転送"),
    "udpForwardDesc": MessageLookupByLibrary.simpleMessage("ノードのUDP転送を許可"),
    "udpForwardStun": MessageLookupByLibrary.simpleMessage("UDP転送とSTUN"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("統一遅延"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "ハンドシェイクなどの余分な遅延を除きます",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("不明"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("不明なネットワークエラー"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unnamed": MessageLookupByLibrary.simpleMessage("名称未設定"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("固定を解除"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URLからプロファイルを取得します"),
    "urlRewrite": MessageLookupByLibrary.simpleMessage("URLリライト"),
    "urlTip": m41,
    "useHosts": MessageLookupByLibrary.simpleMessage("Hostsを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムのHostsを使用"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("使用済みトラフィック"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("ビブラント"),
    "view": MessageLookupByLibrary.simpleMessage("表示"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN関連の設定変更を検出しました",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VpnServiceでシステムの全トラフィックを自動的にルーティングします",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("変更はVPNの再起動後に有効になります"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("ホワイトリストモード"),
    "wifiUpload": MessageLookupByLibrary.simpleMessage("Wi-Fi Upload"),
    "wifiUploadAddress": MessageLookupByLibrary.simpleMessage(
      "Service address",
    ),
    "wifiUploadBadType": MessageLookupByLibrary.simpleMessage(
      "Only .conf and .sgmodule files are supported",
    ),
    "wifiUploadCopy": MessageLookupByLibrary.simpleMessage("Copy address"),
    "wifiUploadCopyAddress": MessageLookupByLibrary.simpleMessage(
      "Copy address",
    ),
    "wifiUploadDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "wifiUploadDesc": MessageLookupByLibrary.simpleMessage(
      "Transfer .conf / .sgmodule files over the LAN between devices",
    ),
    "wifiUploadDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "wifiUploadEmpty": MessageLookupByLibrary.simpleMessage("No files yet"),
    "wifiUploadFiles": MessageLookupByLibrary.simpleMessage("Files"),
    "wifiUploadHowTo": MessageLookupByLibrary.simpleMessage(
      "On the other device, open the address above in a browser to upload or download files. Both devices must be on the same Wi-Fi network.",
    ),
    "wifiUploadImport": MessageLookupByLibrary.simpleMessage("Import file"),
    "wifiUploadNoFiles": MessageLookupByLibrary.simpleMessage("No files yet"),
    "wifiUploadOffTip": MessageLookupByLibrary.simpleMessage(
      "Start the service to share files over Wi-Fi",
    ),
    "wifiUploadQrNote": MessageLookupByLibrary.simpleMessage(
      "Open the address above in the other device\'s browser to upload or download files",
    ),
    "wifiUploadRunning": MessageLookupByLibrary.simpleMessage(
      "Service running",
    ),
    "wifiUploadStart": MessageLookupByLibrary.simpleMessage("Start service"),
    "wifiUploadStop": MessageLookupByLibrary.simpleMessage("Stop service"),
    "wifiUploadStopped": MessageLookupByLibrary.simpleMessage(
      "Service stopped",
    ),
    "wifiUploadSwitch": MessageLookupByLibrary.simpleMessage("Enable sharing"),
    "yearsAgo": m42,
    "zhCN": MessageLookupByLibrary.simpleMessage("簡体字中国語"),
  };
}
