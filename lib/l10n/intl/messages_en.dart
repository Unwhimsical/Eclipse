// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) => "Imported ${count} node(s)";

  static String m1(code) =>
      "Windows refused to run EclipseCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow Eclipse in that policy or turn it off, then try again.";

  static String m2(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m3(url) => "Do you want to create a profile from ${url}?";

  static String m4(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m5(name) => "Delete module \"${name}\"?";

  static String m6(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m7(label) => "Are you sure you want to delete this ${label}?";

  static String m8(label) => "${label} details";

  static String m9(label) => "${label} cannot be empty";

  static String m10(count) =>
      "${Intl.plural(count, one: '1 entry', other: '${count} entries')}";

  static String m11(label) => "${label} already exists";

  static String m12(name) => "${name} is already up to date";

  static String m13(name) => "${name} updated";

  static String m14(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m15(count) =>
      "${Intl.plural(count, one: '1 hour', other: '${count} hours')}";

  static String m16(target) => "${target} is an invalid policy";

  static String m17(proxyName) => "${proxyName} is an invalid proxy";

  static String m18(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m19(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m20(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m21(label, max) => "${label} must be at most ${max} characters";

  static String m22(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m23(author) => "Author: ${author}";

  static String m24(count) => "Hosts: ${count}";

  static String m25(name) => "Imported module: ${name}";

  static String m26(count) => "URL rewrites: ${count}";

  static String m27(count) => "Rules: ${count}";

  static String m28(count) => "Scripts: ${count}";

  static String m29(ruleCount, rewriteCount, scriptCount) =>
      "${ruleCount} rules · ${rewriteCount} rewrites · ${scriptCount} scripts";

  static String m30(name) => "Updated module: ${name}";

  static String m31(done, total) => "Updated ${done}/${total} modules";

  static String m32(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m33(label) => "No ${label} yet";

  static String m34(label) => "${label} must be a number";

  static String m35(label) => "${label} must be between 1024 and 49151";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 proxy', other: '${count} proxies')}";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 rule', other: '${count} rules')}";

  static String m38(count) => "Imported ${count} rules";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m40(count) => "${count} selected";

  static String m41(name) => "Shortcut updated: ${name}";

  static String m42(count) => "Effective rules (${count})";

  static String m43(index, total) => "Rule ${index} of ${total}";

  static String m44(label) => "${label} must be a URL";

  static String m45(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only selected apps go through the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Control which apps use the proxy",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "App access control is disabled",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Selected apps are excluded from the VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access control settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "activeConnections": MessageLookupByLibrary.simpleMessage(
      "Active connections",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addModule": MessageLookupByLibrary.simpleMessage("Add module"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Add proxies"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Add proxy providers",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addScene": MessageLookupByLibrary.simpleMessage("Add scene"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addSubscription": MessageLookupByLibrary.simpleMessage("Add subscription"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Add widget"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Provides diverse configuration options",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow apps to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, some apps can bypass the VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow proxy access over the LAN",
    ),
    "alwaysRealIp": MessageLookupByLibrary.simpleMessage("Always Real IP"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("App name"),
    "appVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Dark, light or follow system",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append system DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Force-append the system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust application settings",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentication"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Require credentials on the local proxy port to keep other local apps from using it",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Not applied while authentication is enabled",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Check for updates automatically when the app starts",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Close connections automatically after switching nodes",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch automatically at system startup",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Run automatically when the app opens",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto-set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval (minutes)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup successful"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Basic configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the basic configuration globally",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategies"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "To keep the app running in the background, disable battery optimization for it. Tap to open settings.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Due to system limitations, the battery optimization status cannot be read correctly while running",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("Block connection"),
    "bodyRewrite": MessageLookupByLibrary.simpleMessage("Body Rewrite"),
    "bodyRewriteDesc": MessageLookupByLibrary.simpleMessage(
      "Rewrite request/response body with regex or jq",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domains"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect while the system proxy is enabled",
    ),
    "caCenter": MessageLookupByLibrary.simpleMessage("CA Center"),
    "caCenterDesc": MessageLookupByLibrary.simpleMessage(
      "Generate the MITM root certificate, with install and trust guidance",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupted. Clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect all"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to switch proxy; the previous selection has been restored",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Breaking changes",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("New features"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Bug fixes"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Performance"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Reverts"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Verify TLS certificates",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Reject untrusted certificates. Turning this off exposes subscriptions and backups to man-in-the-middle attacks",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The app is already up to date",
    ),
    "clearAction": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "This will clear all records.",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear data"),
    "clearLogs": MessageLookupByLibrary.simpleMessage("Clear logs"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to clipboard",
    ),
    "clipboardIgnore": MessageLookupByLibrary.simpleMessage("Ignore"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from clipboard",
    ),
    "clipboardImportFailed": MessageLookupByLibrary.simpleMessage(
      "Could not parse the link",
    ),
    "clipboardImported": m0,
    "clipboardLinkCopied": MessageLookupByLibrary.simpleMessage("链接已复制"),
    "clipboardLinkFound": MessageLookupByLibrary.simpleMessage(
      "Node link found in clipboard",
    ),
    "clipboardLinkFoundDesc": MessageLookupByLibrary.simpleMessage(
      "Import it into the current profile?",
    ),
    "clipboardLinkImport": MessageLookupByLibrary.simpleMessage("导入"),
    "clipboardLinkMessage": MessageLookupByLibrary.simpleMessage(
      "检测到剪贴板中有节点分享链接。",
    ),
    "clipboardLinkTitle": MessageLookupByLibrary.simpleMessage("发现节点链接"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeConnection": MessageLookupByLibrary.simpleMessage("Close connection"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "closeDialogOrClear": MessageLookupByLibrary.simpleMessage(
      "Close dialog / clear search",
    ),
    "collapseEditor": MessageLookupByLibrary.simpleMessage("Collapse"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "comingSoonDesc": MessageLookupByLibrary.simpleMessage(
      "This feature is coming soon.",
    ),
    "commandPalette": MessageLookupByLibrary.simpleMessage("Command palette"),
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
    "compatibilityMode": MessageLookupByLibrary.simpleMessage(
      "Compatibility mode",
    ),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "config": MessageLookupByLibrary.simpleMessage("Config"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "Data detected in the configuration",
    ),
    "configDetail": MessageLookupByLibrary.simpleMessage("Config detail"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "This cannot be undone.",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this proxy group?",
    ),
    "confirmDeleteTitle": MessageLookupByLibrary.simpleMessage("Delete?"),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the current window?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "Confirming will overwrite existing data",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connection data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity: "),
    "connectivityTest": MessageLookupByLibrary.simpleMessage(
      "Connectivity test",
    ),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyAction": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked EclipseCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start Eclipse again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "coreUnsupported": MessageLookupByLibrary.simpleMessage(
      "Not supported by the core",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Crash analytics"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, crash logs without sensitive information are uploaded automatically when the app crashes",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Create profile"),
    "createProfileFromUrlTip": m3,
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "currentNode": MessageLookupByLibrary.simpleMessage("Current node"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "data": MessageLookupByLibrary.simpleMessage("Data"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Data changes detected. Save them?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "This app uses Firebase Crashlytics to collect crash information to improve stability.\nThe collected data includes device information and crash details, and contains no personally sensitive data.\nYou can turn this off in settings.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Data collection notice",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to save the change; it has been rolled back",
    ),
    "daysAgo": m4,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve DNS servers",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay test"),
    "delayTestAll": MessageLookupByLibrary.simpleMessage("Test all delays"),
    "delayTestDesc": MessageLookupByLibrary.simpleMessage("Test node delays"),
    "delayTestMethod": MessageLookupByLibrary.simpleMessage(
      "Delay test method",
    ),
    "delayTestMethodConnect": MessageLookupByLibrary.simpleMessage("CONNECT"),
    "delayTestMethodConnectDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP HEAD to the test URL, closest to real usability",
    ),
    "delayTestMethodIcmp": MessageLookupByLibrary.simpleMessage("ICMP"),
    "delayTestMethodIcmpDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP echo round-trip time",
    ),
    "delayTestMethodTcp": MessageLookupByLibrary.simpleMessage("TCP"),
    "delayTestMethodTcpDesc": MessageLookupByLibrary.simpleMessage(
      "TCP handshake round-trip time",
    ),
    "delayTestUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "delayTestUrlHint": MessageLookupByLibrary.simpleMessage(
      "https://www.gstatic.com/generate_204",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteModuleConfirm": m5,
    "deleteMultipTip": m6,
    "deleteSelectedRow": MessageLookupByLibrary.simpleMessage(
      "Delete selected row",
    ),
    "deleteTip": m7,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IP ASN",
    ),
    "details": m8,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "directDnsServers": MessageLookupByLibrary.simpleMessage(
      "Direct DNS Servers",
    ),
    "disableAction": MessageLookupByLibrary.simpleMessage("Disable"),
    "disableStun": MessageLookupByLibrary.simpleMessage("Disable STUN"),
    "disableStunDesc": MessageLookupByLibrary.simpleMessage(
      "Block WebRTC STUN requests to prevent public IP leaks",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is intended only for non-commercial uses such as learning and research. Using it for any commercial purpose is strictly prohibited; any commercial activity is unrelated to this software.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS-related settings",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsServers": MessageLookupByLibrary.simpleMessage("DNS Servers"),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "duplicateProfile": MessageLookupByLibrary.simpleMessage(
      "Duplicate config",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editArguments": MessageLookupByLibrary.simpleMessage("Edit arguments"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editScene": MessageLookupByLibrary.simpleMessage("Edit scene"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "emptyTip": m9,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enableAction": MessageLookupByLibrary.simpleMessage("Enable"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "entriesCount": m10,
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide the app from recent tasks while it is in the background",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Exclude proxy filter",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Exclude type"),
    "existsTip": m11,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Exit full screen"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expandEditor": MessageLookupByLibrary.simpleMessage("Expand"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportAction": MessageLookupByLibrary.simpleMessage("Export"),
    "exportFailed": MessageLookupByLibrary.simpleMessage("Export failed"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the Clash core can be controlled on port 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP range"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Usually an overseas DNS",
    ),
    "fallbackDnsServers": MessageLookupByLibrary.simpleMessage(
      "Fallback DNS Servers",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Upload a profile file directly",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Save the changes?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling causes some performance loss",
    ),
    "focusSearch": MessageLookupByLibrary.simpleMessage("Focus search"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Follow profile"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font family"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
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
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Fruit salad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalSection": MessageLookupByLibrary.simpleMessage("General"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("General Settings"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "The auto-update interval must be greater than 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo options"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo resources"),
    "geoSkipped": m12,
    "geoUpdate": MessageLookupByLibrary.simpleMessage("Geo database update"),
    "geoUpdated": m13,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo low-memory mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Use the low-memory Geo loader",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP code"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "globalRoute": MessageLookupByLibrary.simpleMessage("Global routing"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goAddNode": MessageLookupByLibrary.simpleMessage("Add nodes"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to script configuration",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Cache the changes?",
    ),
    "headerRewrite": MessageLookupByLibrary.simpleMessage("Header rewrite"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall Eclipse to restore it.",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostSection": MessageLookupByLibrary.simpleMessage("Host"),
    "hosts": MessageLookupByLibrary.simpleMessage("Hosts"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Append hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Control the app with the keyboard",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m14,
    "hoursCount": m15,
    "httpsDecryption": MessageLookupByLibrary.simpleMessage("HTTPS decryption"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importConfRules": MessageLookupByLibrary.simpleMessage(
      "Import .conf rules",
    ),
    "importExport": MessageLookupByLibrary.simpleMessage("Import & export"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importFromUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importModule": MessageLookupByLibrary.simpleMessage("Import module"),
    "importModuleFromFile": MessageLookupByLibrary.simpleMessage(
      "Import from .sgmodule file",
    ),
    "importRules": MessageLookupByLibrary.simpleMessage("Import rules"),
    "importRulesFromFile": MessageLookupByLibrary.simpleMessage(
      "Import from .conf file",
    ),
    "importSubscription": MessageLookupByLibrary.simpleMessage(
      "Import subscription",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inUse": MessageLookupByLibrary.simpleMessage("In use"),
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Include all proxies",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Imports all proxies outside proxy groups; extra proxy groups can be added below",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Include all proxy providers",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, the imported proxy providers are overridden",
    ),
    "includeUrl": MessageLookupByLibrary.simpleMessage("Include URL"),
    "includeUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Remote config merged at import; kept for reference.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid hotkey",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Enter the proxy group name",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Enter the rule content",
    ),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "App list permission required",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Smart selection",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interface name"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Network interface used for outbound connections",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Outbound interface",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Clear"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Follow config",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidPolicy": m16,
    "invalidProxy": m17,
    "invalidProxyProvider": m18,
    "invalidRule": MessageLookupByLibrary.simpleMessage("Invalid rule format"),
    "invalidSubRule": m19,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When enabled, IPv6 traffic can be received",
    ),
    "ipv6FollowConfig": MessageLookupByLibrary.simpleMessage(
      "Follow global setting",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ipv6Off": MessageLookupByLibrary.simpleMessage("IPv6 off"),
    "ipv6On": MessageLookupByLibrary.simpleMessage("IPv6 on"),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Launch did not finish",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "level": MessageLookupByLibrary.simpleMessage("Level"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localAddress": MessageLookupByLibrary.simpleMessage("Local address"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data locally",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.",
    ),
    "locationPermissionGuide": m20,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling hides the log entry point",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Captured log records"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback exemption",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "mapLocal": MessageLookupByLibrary.simpleMessage("Map Local"),
    "mapLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Replace matched request responses with local content",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "Where rules targeting MATCH-TARGET go. Defaults to the target of the final MATCH rule in this profile.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("Match target"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failures"),
    "maxLengthTip": m21,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Minimal"),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Override the default system exit behavior",
    ),
    "minimizeToTray": MessageLookupByLibrary.simpleMessage(
      "Minimize to tray on close",
    ),
    "minimizeToTrayDesc": MessageLookupByLibrary.simpleMessage(
      "Closing the window keeps Eclipse running in the tray",
    ),
    "minutesAgo": m22,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "module": MessageLookupByLibrary.simpleMessage("Module"),
    "moduleAuthor": m23,
    "moduleDetailEmpty": MessageLookupByLibrary.simpleMessage(
      "Select a module to view details",
    ),
    "moduleDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Download failed or no valid module found",
    ),
    "moduleHostCount": m24,
    "moduleImported": m25,
    "moduleInvalid": MessageLookupByLibrary.simpleMessage(
      "No valid module found",
    ),
    "moduleMitmNote": MessageLookupByLibrary.simpleMessage(
      "Contains content requiring MITM decryption; currently applied as static rules",
    ),
    "moduleParams": MessageLookupByLibrary.simpleMessage("Parameters"),
    "moduleRewriteCount": m26,
    "moduleRuleCount": m27,
    "moduleRuleStats": MessageLookupByLibrary.simpleMessage("Rule stats"),
    "moduleScriptCount": m28,
    "moduleStatsSummary": m29,
    "moduleUpdated": m30,
    "modules": MessageLookupByLibrary.simpleMessage("Modules"),
    "modulesUpdated": m31,
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m32,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "Separate multiple values with commas",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve domains",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the nameserver policy for matching domains",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network error, please check your connection and try again",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Next match"),
    "noActiveConnections": MessageLookupByLibrary.simpleMessage(
      "No active connections through this node",
    ),
    "noConnections": MessageLookupByLibrary.simpleMessage(
      "No active connections",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No hotkeys yet"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noLogs": MessageLookupByLibrary.simpleMessage("No logs yet"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me again",
    ),
    "noModuleParams": MessageLookupByLibrary.simpleMessage("No parameters"),
    "noModules": MessageLookupByLibrary.simpleMessage("No modules yet"),
    "noModulesDesc": MessageLookupByLibrary.simpleMessage(
      "Tap + to import a .sgmodule file",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No-network apps"),
    "noNodes": MessageLookupByLibrary.simpleMessage(
      "This profile has no nodes",
    ),
    "noNodesDesc": MessageLookupByLibrary.simpleMessage(
      "No nodes yet. Add a subscription or import nodes to get started.",
    ),
    "noOverrideRules": MessageLookupByLibrary.simpleMessage(
      "No override rules yet",
    ),
    "noProfileSelected": MessageLookupByLibrary.simpleMessage(
      "No profile selected",
    ),
    "noProfiles": MessageLookupByLibrary.simpleMessage("No profiles yet"),
    "noProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Import or create one to get started",
    ),
    "noRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "noRequests": MessageLookupByLibrary.simpleMessage("No requests yet"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Don\'t resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Don\'t resolve hostname",
    ),
    "noRuleItems": MessageLookupByLibrary.simpleMessage("No rules"),
    "noRules": MessageLookupByLibrary.simpleMessage("No rules"),
    "noRulesInConf": MessageLookupByLibrary.simpleMessage(
      "No rules found in the .conf file",
    ),
    "noSearchResult": MessageLookupByLibrary.simpleMessage(
      "No matching results",
    ),
    "noSettingsResult": MessageLookupByLibrary.simpleMessage(
      "No matching settings",
    ),
    "noUpdatableModules": MessageLookupByLibrary.simpleMessage(
      "No modules with a stored update URL",
    ),
    "nodeDetail": MessageLookupByLibrary.simpleMessage("Node detail"),
    "nodeImportExport": MessageLookupByLibrary.simpleMessage(
      "Node import & export",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Nodes"),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notRebindable": MessageLookupByLibrary.simpleMessage("Fixed"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profiles yet, please add one first",
    ),
    "nullTip": m33,
    "numberTip": m34,
    "onDemand": MessageLookupByLibrary.simpleMessage("On demand"),
    "onDemandAlwaysOn": MessageLookupByLibrary.simpleMessage("Always on"),
    "onDemandAlwaysOnDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the VPN connected and reconnect automatically after reboots or drops",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the app\'s running state for specific scenarios",
    ),
    "onDemandDisconnectOnSleep": MessageLookupByLibrary.simpleMessage(
      "Disconnect while asleep",
    ),
    "onDemandDisconnectOnSleepDesc": MessageLookupByLibrary.simpleMessage(
      "Disconnect the VPN when the device sleeps to save battery",
    ),
    "onDemandExtras": MessageLookupByLibrary.simpleMessage("On-Demand Extras"),
    "onDemandExtrasDesc": MessageLookupByLibrary.simpleMessage(
      "Always-on, disconnect on sleep and disconnect alerts",
    ),
    "onDemandShowDisconnectInfo": MessageLookupByLibrary.simpleMessage(
      "Show disconnect notices",
    ),
    "onDemandShowDisconnectInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Notify when the VPN unexpectedly disconnects",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon only"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only count proxy traffic",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, only proxy traffic is counted",
    ),
    "openCommandPalette": MessageLookupByLibrary.simpleMessage(
      "Open command palette",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Open settings"),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the DNS options in the profile are overridden",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideRules": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Custom mode: fully customize proxy groups and rules",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "paramOff": MessageLookupByLibrary.simpleMessage("Off"),
    "paramOn": MessageLookupByLibrary.simpleMessage("On"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pasteImport": MessageLookupByLibrary.simpleMessage("Paste from clipboard"),
    "pasteImportDesc": MessageLookupByLibrary.simpleMessage(
      "Read node links from the clipboard and import them",
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
      "打开 Eclipse 的系统设置页面",
    ),
    "permissionNotes": MessageLookupByLibrary.simpleMessage("Permission notes"),
    "permissions": MessageLookupByLibrary.simpleMessage("权限说明"),
    "permissionsDesc": MessageLookupByLibrary.simpleMessage(
      "Eclipse 需要以下系统权限才能正常工作，可随时在系统设置中更改。",
    ),
    "permissionsInfo": MessageLookupByLibrary.simpleMessage("Permissions"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Choose from album"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Pin window"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m35,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prefer HTTP/3 for DoH",
    ),
    "preferIpv6": MessageLookupByLibrary.simpleMessage("Prefer IPv6"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Please press a key"),
    "pressKeys": MessageLookupByLibrary.simpleMessage("Press keys…"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Previous match"),
    "privateIpAnswer": MessageLookupByLibrary.simpleMessage(
      "Private IP Answer",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto-update interval",
        ),
    "profileCopySuffix": MessageLookupByLibrary.simpleMessage("copy"),
    "profileDuplicated": MessageLookupByLibrary.simpleMessage(
      "Config duplicated",
    ),
    "profileFiles": MessageLookupByLibrary.simpleMessage("Config Files"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Turn off auto update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile name",
    ),
    "profileUrlHint": MessageLookupByLibrary.simpleMessage(
      "Paste a subscription URL, or leave empty to pick a file",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m36,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Proxies are empty"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chain"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The selected proxies are abnormal",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Proxy filter"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The current proxy group is abnormal",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Duplicate proxy group name",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group name cannot be empty",
    ),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("Proxy groups"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve proxy node domains",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The selected proxy providers are abnormal",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers are empty",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers cannot be empty",
    ),
    "proxyServers": MessageLookupByLibrary.simpleMessage("Proxy servers"),
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
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to obtain a profile",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Quick fill"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir port"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteAddress": MessageLookupByLibrary.simpleMessage("Remote address"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recent request records",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Information about external resources",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connections follow rules; requires proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreDefault": MessageLookupByLibrary.simpleMessage("Restore default"),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("Restore defaults"),
    "restoreException": MessageLookupByLibrary.simpleMessage("Restore error"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from a file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore profiles only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Override"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restore successful",
    ),
    "rewrite": MessageLookupByLibrary.simpleMessage("Rewrite"),
    "rewrites": MessageLookupByLibrary.simpleMessage("Rewrites"),
    "routeAdd": MessageLookupByLibrary.simpleMessage("Add"),
    "routeAddHint": MessageLookupByLibrary.simpleMessage("e.g. 192.168.0.0/16"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route addresses"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the listened route addresses",
    ),
    "routeConfig": MessageLookupByLibrary.simpleMessage("Config"),
    "routeDirect": MessageLookupByLibrary.simpleMessage("Direct"),
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
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private addresses",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("Use config"),
    "routeProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "routeScene": MessageLookupByLibrary.simpleMessage("Scene"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Match the full domain",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain keyword",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain regex",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain suffix",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard match; only * and ? are supported",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Match the DSCP mark (tproxy UDP inbound only)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the destination port range",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s country code",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Match domains in Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound name",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound port",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound type",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound username; separate multiple usernames with /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s ASN",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range; IP-CIDR6 is just an alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP suffix range",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Match all requests, no conditions needed",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Match TCP or UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Logical rule OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name; matches the package name on Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name regex; matches the package name on Android",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name wildcard; only * and ? are supported",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match by the full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path regex",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path wildcard; only * and ? are supported",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the rematch name; separate multiple names with /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Reference a rule set; requires rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s country code",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP address range",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP suffix range",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source port range",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Match into a sub-rule; mind the parentheses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Match the Linux user ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Rule is empty"),
    "ruleHits": MessageLookupByLibrary.simpleMessage("Rule hits"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "rules": MessageLookupByLibrary.simpleMessage("Rules"),
    "rulesCount": m37,
    "rulesDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Download failed or content is empty",
    ),
    "rulesImported": m38,
    "rulesReadonly": MessageLookupByLibrary.simpleMessage(
      "Built-in rules (read-only)",
    ),
    "runDelayTest": MessageLookupByLibrary.simpleMessage("Run delay test"),
    "runStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "sceneDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete this scene?",
    ),
    "sceneEmpty": MessageLookupByLibrary.simpleMessage("No scenes yet"),
    "sceneIosForegroundNote": MessageLookupByLibrary.simpleMessage(
      "On iOS, network changes are detected and scenes switch only while the app is in the foreground",
    ),
    "sceneKeepCurrent": MessageLookupByLibrary.simpleMessage("Keep current"),
    "sceneMode": MessageLookupByLibrary.simpleMessage("Scene Mode"),
    "sceneModeDesc": MessageLookupByLibrary.simpleMessage(
      "Auto-switch profile, mode and exit node by network",
    ),
    "sceneNoSwitch": MessageLookupByLibrary.simpleMessage("Don\'t switch"),
    "sceneSsidHint": MessageLookupByLibrary.simpleMessage(
      "Enter the Wi-Fi name (case-sensitive)",
    ),
    "sceneTargetMode": MessageLookupByLibrary.simpleMessage("Routing mode"),
    "sceneTargetProfile": MessageLookupByLibrary.simpleMessage(
      "Target profile",
    ),
    "sceneTargetProxy": MessageLookupByLibrary.simpleMessage("Exit node"),
    "sceneTrigger": MessageLookupByLibrary.simpleMessage("Trigger"),
    "sceneTriggerCellular": MessageLookupByLibrary.simpleMessage("Cellular"),
    "sceneTriggerFallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "sceneTriggerSsid": MessageLookupByLibrary.simpleMessage("Wi-Fi name"),
    "scopeCommands": MessageLookupByLibrary.simpleMessage("Commands"),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode: uses external extension scripts to override the configuration in one click",
    ),
    "scripts": MessageLookupByLibrary.simpleMessage("Scripts"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchModules": MessageLookupByLibrary.simpleMessage("Search modules"),
    "searchProfiles": MessageLookupByLibrary.simpleMessage("Search profiles"),
    "searchRules": MessageLookupByLibrary.simpleMessage("Search rules"),
    "searchSettings": MessageLookupByLibrary.simpleMessage("Search settings"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "secondsCount": m39,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "Select MATCH-TARGET",
    ),
    "selectNode": MessageLookupByLibrary.simpleMessage("Select node"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Select proxies"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Select proxy providers",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select a rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select a split strategy",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Please select a sub-rule",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m40,
    "setAsCurrent": MessageLookupByLibrary.simpleMessage("Set as current"),
    "setAsDefault": MessageLookupByLibrary.simpleMessage("Set as default"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsGroupAbout": MessageLookupByLibrary.simpleMessage("About"),
    "settingsGroupAppearance": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "settingsGroupNetwork": MessageLookupByLibrary.simpleMessage(
      "Network & core",
    ),
    "settingsGroupShortcuts": MessageLookupByLibrary.simpleMessage("Shortcuts"),
    "settingsGroupTray": MessageLookupByLibrary.simpleMessage(
      "Notifications & tray",
    ),
    "settingsSectionDisplay": MessageLookupByLibrary.simpleMessage(
      "Display & language",
    ),
    "settingsSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "Network & proxy",
    ),
    "settingsSectionSecurity": MessageLookupByLibrary.simpleMessage(
      "Security & permissions",
    ),
    "shortcutUpdated": m41,
    "shortcuts": MessageLookupByLibrary.simpleMessage("Shortcuts"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showLess": MessageLookupByLibrary.simpleMessage("Collapse"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expand"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Stop button in notification",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "Show a stop button on the persistent notification. Turn it off if your system keeps the notification expanded because of it",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "shrink": MessageLookupByLibrary.simpleMessage("Compact"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skipProxy": MessageLookupByLibrary.simpleMessage("Skip Proxy"),
    "skipProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Kept on the TUN path; the rule chain still decides the policy.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "sortModules": MessageLookupByLibrary.simpleMessage("Sort modules"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "spaceKey": MessageLookupByLibrary.simpleMessage("Space"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Special rules"),
    "speed": MessageLookupByLibrary.simpleMessage("Speed"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs are empty"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode: overrides the basic configuration and offers simple rule additions",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "startup": MessageLookupByLibrary.simpleMessage("Launch at startup"),
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
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "When disabled, the system DNS is used",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "stopped": MessageLookupByLibrary.simpleMessage("Stopped"),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub-rule"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Sub-rule is empty"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Sub-rule cannot be empty",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "subscriptionLink": MessageLookupByLibrary.simpleMessage(
      "Subscription link",
    ),
    "subscriptions": MessageLookupByLibrary.simpleMessage("Subscriptions"),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended..."),
    "switchNode": MessageLookupByLibrary.simpleMessage("Switch"),
    "switchPage": MessageLookupByLibrary.simpleMessage("Switch page"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch profile"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System apps"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Set the system proxy",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Only effective in mobile view",
    ),
    "tableAction": MessageLookupByLibrary.simpleMessage("Action"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Allow concurrent TCP connections",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testRules": MessageLookupByLibrary.simpleMessage("Test Rules"),
    "testRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Check which rule a domain, URL, IP or port hits",
    ),
    "testRulesEffectiveRules": m42,
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
    "testRulesRuleOrder": m43,
    "testRulesTest": MessageLookupByLibrary.simpleMessage("Test"),
    "testRulesUnsupportedRule": MessageLookupByLibrary.simpleMessage(
      "This rule type is evaluated by the core and cannot be previewed here",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode and adjust colors",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("Toggle labels"),
    "toggleRun": MessageLookupByLibrary.simpleMessage("Enable / disable"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Tonal spot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Total download"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Total upload"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "trafficTrend": MessageLookupByLibrary.simpleMessage("Traffic trend"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "trayTitle": MessageLookupByLibrary.simpleMessage("Show speed in tray"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Only effective in administrator mode",
    ),
    "tunExcludedRoutes": MessageLookupByLibrary.simpleMessage(
      "TUN Excluded Routes",
    ),
    "tunExcludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "CIDR routes excluded from TUN",
    ),
    "tunIncludedRoutes": MessageLookupByLibrary.simpleMessage(
      "TUN Included Routes",
    ),
    "tunIncludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "CIDR routes included in TUN",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Tunnel"),
    "tunnelAdd": MessageLookupByLibrary.simpleMessage("添加"),
    "tunnelAddHint": MessageLookupByLibrary.simpleMessage("例如 192.168.0.0/16"),
    "tunnelDesc": MessageLookupByLibrary.simpleMessage("控制哪些目标绕过或必须经过 TUN 接口"),
    "tunnelEmpty": MessageLookupByLibrary.simpleMessage("暂无路由"),
    "tunnelExcluded": MessageLookupByLibrary.simpleMessage("排除路由"),
    "tunnelIncluded": MessageLookupByLibrary.simpleMessage("包含路由"),
    "tunnelNoProfile": MessageLookupByLibrary.simpleMessage("请先选择一个配置"),
    "tunnelRemove": MessageLookupByLibrary.simpleMessage("移除"),
    "tunnelRoutes": MessageLookupByLibrary.simpleMessage("Routes"),
    "tunnelRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "Control which destinations bypass or require the TUN interface",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
    "udpForward": MessageLookupByLibrary.simpleMessage("UDP forwarding"),
    "udpForwardDesc": MessageLookupByLibrary.simpleMessage(
      "Allow nodes to forward UDP traffic",
    ),
    "udpForwardStun": MessageLookupByLibrary.simpleMessage(
      "UDP forwarding & STUN",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove extra delays such as handshakes",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restore down"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Unpin window"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateAll": MessageLookupByLibrary.simpleMessage("Update all"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain a profile from a URL",
    ),
    "urlRewrite": MessageLookupByLibrary.simpleMessage("URL rewrite"),
    "urlTip": m44,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Used traffic"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-related configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Route all system traffic through VpnService automatically",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "wifiUpload": MessageLookupByLibrary.simpleMessage("Wi-Fi Upload"),
    "wifiUploadAddress": MessageLookupByLibrary.simpleMessage(
      "Service address",
    ),
    "wifiUploadBadType": MessageLookupByLibrary.simpleMessage(
      "仅支持 .conf 和 .sgmodule 文件",
    ),
    "wifiUploadCopy": MessageLookupByLibrary.simpleMessage("复制地址"),
    "wifiUploadCopyAddress": MessageLookupByLibrary.simpleMessage(
      "Copy address",
    ),
    "wifiUploadDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "wifiUploadDesc": MessageLookupByLibrary.simpleMessage(
      "Transfer .conf / .sgmodule files over the LAN between devices",
    ),
    "wifiUploadDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "wifiUploadEmpty": MessageLookupByLibrary.simpleMessage("暂无文件"),
    "wifiUploadFiles": MessageLookupByLibrary.simpleMessage("Files"),
    "wifiUploadHowTo": MessageLookupByLibrary.simpleMessage(
      "在另一台设备上用浏览器打开上方地址即可上传或下载文件，两台设备需连接同一 Wi-Fi。",
    ),
    "wifiUploadImport": MessageLookupByLibrary.simpleMessage("Import file"),
    "wifiUploadNoFiles": MessageLookupByLibrary.simpleMessage("No files yet"),
    "wifiUploadOffTip": MessageLookupByLibrary.simpleMessage(
      "启动服务后可通过 Wi-Fi 分享文件",
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
    "wifiUploadSwitch": MessageLookupByLibrary.simpleMessage("开启共享"),
    "yearsAgo": m45,
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
