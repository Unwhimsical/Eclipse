// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(count) => "Imported ${count} node(s)";

  static String m1(code) =>
      "Windows отказалась запускать EclipseCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите Eclipse в этой политике или отключите её и повторите попытку.";

  static String m2(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, профиль ${name} снят с выбора, а автоматическая настройка пропущена. Вы можете выбрать его снова в любой момент.";

  static String m3(url) => "Создать профиль по ссылке ${url}?";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m5(name) => "Удалить модуль «${name}»?";

  static String m6(label) =>
      "Вы уверены, что хотите удалить выбранные элементы (${label})?";

  static String m7(label) => "Вы уверены, что хотите удалить «${label}»?";

  static String m8(label) => "Сведения: ${label}";

  static String m9(label) => "Поле «${label}» не может быть пустым";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} запись', few: '${count} записи', many: '${count} записей', other: '${count} записи')}";

  static String m11(label) => "«${label}» уже существует";

  static String m12(name) => "${name}: уже последняя версия";

  static String m13(name) => "${name}: обновлено";

  static String m14(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m15(count) =>
      "${Intl.plural(count, one: '${count} час', few: '${count} часа', many: '${count} часов', other: '${count} часа')}";

  static String m16(target) => "${target} — недопустимая политика";

  static String m17(proxyName) => "${proxyName} — недопустимый прокси";

  static String m18(providerName) =>
      "${providerName} — недопустимый провайдер прокси";

  static String m19(subRule) => "${subRule} — недопустимый SUB_RULE";

  static String m20(appName) =>
      "1. Откройте Системные настройки > Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nПосле настройки вернитесь в приложение и продолжайте работу. Спасибо за сотрудничество.";

  static String m21(label, max) => "«${label}» — не более ${max} символов";

  static String m22(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m23(author) => "Автор: ${author}";

  static String m24(count) => "Хосты: ${count}";

  static String m25(name) => "Модуль импортирован: ${name}";

  static String m26(count) => "Перезаписи URL: ${count}";

  static String m27(count) => "Правила: ${count}";

  static String m28(count) => "Скрипты: ${count}";

  static String m29(ruleCount, rewriteCount, scriptCount) =>
      "Правил: ${ruleCount} · перезаписей: ${rewriteCount} · скриптов: ${scriptCount}";

  static String m30(name) => "Модуль обновлён: ${name}";

  static String m31(done, total) => "Обновлено модулей: ${done} из ${total}";

  static String m32(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m33(label) => "Пока нет: ${label}";

  static String m34(label) => "Значение «${label}» должно быть числом";

  static String m35(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m36(count) => "${count} прокси";

  static String m37(count) =>
      "${Intl.plural(count, one: '${count} правило', few: '${count} правила', many: '${count} правил', other: '${count} правила')}";

  static String m38(count) => "Импортировано правил: ${count}";

  static String m39(count) =>
      "${Intl.plural(count, one: '${count} секунда', few: '${count} секунды', many: '${count} секунд', other: '${count} секунды')}";

  static String m40(count) => "Выбрано: ${count}";

  static String m41(name) => "Горячая клавиша обновлена: ${name}";

  static String m42(count) => "Effective rules (${count})";

  static String m43(index, total) => "Rule ${index} of ${total}";

  static String m44(label) => "Значение «${label}» должно быть URL";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN проходят только выбранные приложения",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Выбор приложений, использующих прокси",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений отключён",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения исключаются из VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки контроля доступа",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Старт/Стоп"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "activeConnections": MessageLookupByLibrary.simpleMessage(
      "Активные соединения",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addModule": MessageLookupByLibrary.simpleMessage("Добавить модуль"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Добавить прокси"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Добавить группу прокси",
    ),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Добавить провайдеров прокси",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addScene": MessageLookupByLibrary.simpleMessage("Добавить сцену"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Добавить SSID"),
    "addSubscription": MessageLookupByLibrary.simpleMessage(
      "Добавить подписку",
    ),
    "addWidget": MessageLookupByLibrary.simpleMessage("Добавить виджет"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Добавленные правила"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Дополнительные параметры",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес WebDAV",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Расширенная конфигурация",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Разнообразные параметры конфигурации",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "При включении некоторые приложения смогут обходить VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Разрешить LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить доступ к прокси из локальной сети",
    ),
    "alwaysRealIp": MessageLookupByLibrary.simpleMessage("Всегда реальный IP"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Название"),
    "appVersion": MessageLookupByLibrary.simpleMessage("Версия"),
    "appearance": MessageLookupByLibrary.simpleMessage("Оформление"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Тёмная, светлая или системная",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Добавлять системный DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Принудительно добавлять системный DNS в конфигурацию",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки, связанные с приложением",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Требовать учётные данные для локального порта прокси, чтобы другие приложения не могли использовать его",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Не применяется, пока включена аутентификация",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "authorized": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Автопроверка обновлений",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически проверять обновления при запуске приложения",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Автозакрытие соединений",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически закрывать соединения после смены узла",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться автоматически при старте системы",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автовключение"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Включаться автоматически при открытии приложения",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автонастройка системного DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (минуты)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана",
    ),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Базовая конфигурация"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Глобальное изменение базовой конфигурации",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Основная информация"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Базовые политики"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Чтобы приложение работало в фоне, отключите для него оптимизацию батареи. Нажмите, чтобы перейти к настройкам.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Из-за системных ограничений во время работы невозможно корректно получить статус оптимизации батареи",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим чёрного списка",
    ),
    "blockConnection": MessageLookupByLibrary.simpleMessage(
      "Заблокировать соединение",
    ),
    "bodyRewrite": MessageLookupByLibrary.simpleMessage("Body Rewrite"),
    "bodyRewriteDesc": MessageLookupByLibrary.simpleMessage(
      "Изменять тело запроса/ответа через regex или jq",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключённые домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только при включённом системном прокси",
    ),
    "caCenter": MessageLookupByLibrary.simpleMessage("CA-центр"),
    "caCenterDesc": MessageLookupByLibrary.simpleMessage(
      "Создание корневого сертификата MITM, установка и доверие",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить его?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Снять выделение"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось переключить прокси; восстановлен предыдущий выбор",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Важные изменения",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Новые функции"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Исправления"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage(
      "Производительность",
    ),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Откаты"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Проверять TLS-сертификаты",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Отклонять недоверенные сертификаты. Отключение подвергает подписки и резервные копии атаке «человек посередине»",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "У вас уже последняя версия",
    ),
    "clearAction": MessageLookupByLibrary.simpleMessage("Очистить"),
    "clearConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Все записи будут удалены без возможности восстановления.",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clearLogs": MessageLookupByLibrary.simpleMessage("Очистить журнал"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Очистить поиск"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт в буфер обмена",
    ),
    "clipboardIgnore": MessageLookupByLibrary.simpleMessage("Ignore"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Импорт из буфера обмена",
    ),
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
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "closeConnection": MessageLookupByLibrary.simpleMessage(
      "Закрыть соединение",
    ),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Закрыть соединения",
    ),
    "closeDialogOrClear": MessageLookupByLibrary.simpleMessage(
      "Закрыть диалог / очистить поиск",
    ),
    "collapseEditor": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "comingSoonDesc": MessageLookupByLibrary.simpleMessage(
      "Эта функция скоро появится.",
    ),
    "commandPalette": MessageLookupByLibrary.simpleMessage("Палитра команд"),
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
      "Режим совместимости",
    ),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "config": MessageLookupByLibrary.simpleMessage("Конфиг"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "В конфигурации обнаружены данные",
    ),
    "configDetail": MessageLookupByLibrary.simpleMessage("Детали конфигурации"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить все данные?",
    ),
    "confirmDeleteMessage": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо.",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить эту группу прокси?",
    ),
    "confirmDeleteTitle": MessageLookupByLibrary.simpleMessage("Удалить?"),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите закрыть текущее окно?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно завершить ядро со сбоем?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "После подтверждения существующие данные будут перезаписаны",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение..."),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр данных о текущих соединениях",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение: "),
    "connectivityTest": MessageLookupByLibrary.simpleMessage(
      "Проверка соединения",
    ),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Содержимое не может быть пустым",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Управление глобальными добавленными правилами",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyAction": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control в Windows заблокировал неподписанный EclipseCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите Eclipse. Повторно включить Smart App Control без переустановки Windows нельзя.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "coreUnsupported": MessageLookupByLibrary.simpleMessage(
      "Не поддерживается ядром",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Обнаружен сбой"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Аналитика сбоев"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "При включении в случае сбоя приложения автоматически загружаются логи сбоя без конфиденциальной информации",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Создать профиль"),
    "createProfileFromUrlTip": m3,
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "currentNode": MessageLookupByLibrary.simpleMessage("Текущий узел"),
    "custom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель"),
    "data": MessageLookupByLibrary.simpleMessage("Данные"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Обнаружены изменения данных. Сохранить их?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "Это приложение использует Firebase Crashlytics для сбора информации о сбоях, чтобы повысить стабильность.\nСобираемые данные включают сведения об устройстве и подробности сбоя и не содержат личных конфиденциальных данных.\nЭту функцию можно отключить в настройках.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Уведомление о сборе данных",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить изменение; оно отменено",
    ),
    "daysAgo": m4,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS-сервер по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения адресов DNS-серверов",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "delayTestAll": MessageLookupByLibrary.simpleMessage(
      "Проверить все задержки",
    ),
    "delayTestDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка задержки узлов",
    ),
    "delayTestMethod": MessageLookupByLibrary.simpleMessage(
      "Метод теста задержки",
    ),
    "delayTestMethodConnect": MessageLookupByLibrary.simpleMessage("CONNECT"),
    "delayTestMethodConnectDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP HEAD на тестовый URL, ближе всего к реальной доступности",
    ),
    "delayTestMethodIcmp": MessageLookupByLibrary.simpleMessage("ICMP"),
    "delayTestMethodIcmpDesc": MessageLookupByLibrary.simpleMessage(
      "Время ICMP-эха туда-обратно",
    ),
    "delayTestMethodTcp": MessageLookupByLibrary.simpleMessage("TCP"),
    "delayTestMethodTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Время TCP-подключения туда-обратно",
    ),
    "delayTestUrl": MessageLookupByLibrary.simpleMessage("Тестовый URL"),
    "delayTestUrlHint": MessageLookupByLibrary.simpleMessage(
      "https://www.gstatic.com/generate_204",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteModuleConfirm": m5,
    "deleteMultipTip": m6,
    "deleteSelectedRow": MessageLookupByLibrary.simpleMessage(
      "Удалить выбранную строку",
    ),
    "deleteTip": m7,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Многоплатформенный прокси-клиент на основе ClashMeta: простой и удобный, с открытым исходным кодом и без рекламы.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "GeoIP назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "ASN IP назначения",
    ),
    "details": m8,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Использует сторонний API; только для справки",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Прямой"),
    "directDnsServers": MessageLookupByLibrary.simpleMessage(
      "Прямые DNS-серверы",
    ),
    "disableAction": MessageLookupByLibrary.simpleMessage("Выключить"),
    "disableStun": MessageLookupByLibrary.simpleMessage("Отключить STUN"),
    "disableStunDesc": MessageLookupByLibrary.simpleMessage(
      "Блокировать STUN-запросы WebRTC против утечки IP",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Отключить UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Отказ от ответственности",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Это программное обеспечение предназначено только для некоммерческого использования: обучения, обмена опытом и научных исследований. Коммерческое использование строго запрещено; любая коммерческая деятельность не имеет отношения к этому программному обеспечению.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки, связанные с DNS",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "dnsServers": MessageLookupByLibrary.simpleMessage("DNS-серверы"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "duplicateProfile": MessageLookupByLibrary.simpleMessage(
      "Дублировать конфигурацию",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Длительность"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editArguments": MessageLookupByLibrary.simpleMessage("Изменить аргументы"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Редактировать глобальные правила",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Редактировать прокси"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Редактировать группу прокси",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Редактировать правило"),
    "editScene": MessageLookupByLibrary.simpleMessage("Редактировать сцену"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Изменить SSID"),
    "emptyTip": m9,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enableAction": MessageLookupByLibrary.simpleMessage("Включить"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "entriesCount": m10,
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать приложение из недавних задач, когда оно в фоне",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Фильтр исключения узлов",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Исключённые SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "При подключении к Wi-Fi с исключённым SSID состояние работы приложения переключается автоматически",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Исключаемые типы"),
    "existsTip": m11,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Выйти из полноэкранного режима",
    ),
    "expand": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "expandEditor": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Ожидаемый статус"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportAction": MessageLookupByLibrary.simpleMessage("Экспорт"),
    "exportFailed": MessageLookupByLibrary.simpleMessage("Ошибка экспорта"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт выполнен"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивная"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "При включении ядром Clash можно управлять через порт 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("Внешнее получение"),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр Fake-IP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон Fake-IP"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Обычно зарубежный DNS",
    ),
    "fallbackDnsServers": MessageLookupByLibrary.simpleMessage(
      "Резервные DNS-серверы",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Фильтр fallback"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Точная передача"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузить файл профиля напрямую",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл изменён. Сохранить изменения?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Поиск процесса"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "При включении возможна небольшая потеря производительности",
    ),
    "focusSearch": MessageLookupByLibrary.simpleMessage("Фокус на поиске"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Как в профиле"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Как в системе"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно перезапустить ядро?",
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
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "generalSection": MessageLookupByLibrary.simpleMessage("Общие"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("Общие настройки"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления должен быть больше 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Настройки Geo"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Ресурсы Geo"),
    "geoSkipped": m12,
    "geoUpdate": MessageLookupByLibrary.simpleMessage("Обновление Geo-баз"),
    "geoUpdated": m13,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo: экономия памяти",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "При включении используется Geo-загрузчик с низким потреблением памяти",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Код GeoIP"),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "globalRoute": MessageLookupByLibrary.simpleMessage(
      "Глобальная маршрутизация",
    ),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goAddNode": MessageLookupByLibrary.simpleMessage("Добавить узлы"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Перейти к настройке скрипта",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Кэшировать изменения?",
    ),
    "headerRewrite": MessageLookupByLibrary.simpleMessage(
      "Перезапись заголовков",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите Eclipse.",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Скрыть из списка"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Скрыть пароль"),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hostSection": MessageLookupByLibrary.simpleMessage("Host"),
    "hosts": MessageLookupByLibrary.simpleMessage("Хосты"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Добавить записи hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Конфликт горячих клавиш",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление приложением с клавиатуры",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursAgo": m14,
    "hoursCount": m15,
    "httpsDecryption": MessageLookupByLibrary.simpleMessage(
      "Расшифровка HTTPS",
    ),
    "icon": MessageLookupByLibrary.simpleMessage("Значок"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("История значков"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль значков"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL значка"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Игнорировать оптимизацию батареи",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importConfRules": MessageLookupByLibrary.simpleMessage(
      "Импортировать правила .conf",
    ),
    "importExport": MessageLookupByLibrary.simpleMessage("Импорт и экспорт"),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "importFromUrl": MessageLookupByLibrary.simpleMessage(
      "Импортировать из URL",
    ),
    "importModule": MessageLookupByLibrary.simpleMessage("Импорт модуля"),
    "importModuleFromFile": MessageLookupByLibrary.simpleMessage(
      "Импортировать из файла .sgmodule",
    ),
    "importRules": MessageLookupByLibrary.simpleMessage(
      "Импортировать правила",
    ),
    "importRulesFromFile": MessageLookupByLibrary.simpleMessage(
      "Импортировать из файла .conf",
    ),
    "importSubscription": MessageLookupByLibrary.simpleMessage(
      "Импорт подписки",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage("Импорт по URL"),
    "inUse": MessageLookupByLibrary.simpleMessage("Активен"),
    "inbound": MessageLookupByLibrary.simpleMessage("Входящие"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Включить все прокси",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Подключает все прокси вне групп; ниже можно добавить дополнительные группы прокси",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Включить всех провайдеров прокси",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "При включении переопределяет подключённых провайдеров прокси",
    ),
    "includeUrl": MessageLookupByLibrary.simpleMessage(
      "URL включаемой конфигурации",
    ),
    "includeUrlDesc": MessageLookupByLibrary.simpleMessage(
      "Удалённая конфигурация, объединённая при импорте; хранится для справки.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочно"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Введите корректную горячую клавишу",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Введите название группы прокси",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Введите содержимое правила",
    ),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на список приложений отклонено, поэтому установленные приложения недоступны. Предоставьте его вручную в системных настройках.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Эта система не выдаёт список установленных приложений без разрешения. Предоставьте его, чтобы настроить прокси для отдельных приложений.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на список приложений",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Имя интерфейса"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сетевой интерфейс для исходящих соединений",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Исходящий интерфейс",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Как в конфигурации",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Внутренний IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Недопустимый файл резервной копии",
    ),
    "invalidPolicy": m16,
    "invalidProxy": m17,
    "invalidProxyProvider": m18,
    "invalidRule": MessageLookupByLibrary.simpleMessage(
      "Недопустимый формат правила",
    ),
    "invalidSubRule": m19,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "При включении можно принимать трафик IPv6",
    ),
    "ipv6FollowConfig": MessageLookupByLibrary.simpleMessage(
      "Как в глобальных настройках",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящий IPv6",
    ),
    "ipv6Off": MessageLookupByLibrary.simpleMessage("IPv6 выключен"),
    "ipv6On": MessageLookupByLibrary.simpleMessage("IPv6 включён"),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал TCP keep-alive",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Запуск не завершён",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена; вы можете запустить её вручную.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "level": MessageLookupByLibrary.simpleMessage("Уровень"),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
    "local": MessageLookupByLibrary.simpleMessage("Локально"),
    "localAddress": MessageLookupByLibrary.simpleMessage("Локальный адрес"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных локально",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию отклонено, поэтому невозможно получить имя текущей сети Wi-Fi. Включите разрешение на геолокацию вручную в системных настройках.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "По требованию системы для получения имени сети Wi-Fi необходимо разрешение на геолокацию. На Android выберите «Разрешить всегда», иначе имя сети Wi-Fi нельзя получить, пока приложение в фоне.",
    ),
    "locationPermissionGuide": m20,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на геолокацию",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Захват логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "При отключении раздел логов будет скрыт",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage(
      "Записи захваченных логов",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Инструмент разблокировки loopback",
    ),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Для снятия ограничения loopback у UWP-приложений",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "mapLocal": MessageLookupByLibrary.simpleMessage("Map Local"),
    "mapLocalDesc": MessageLookupByLibrary.simpleMessage(
      "Заменять ответы подходящих запросов локальным содержимым",
    ),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage(
      "Сопоставлять IP источника",
    ),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "Куда направляются правила с целью MATCH-TARGET. По умолчанию — цель последнего правила MATCH этого профиля.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("Цель MATCH"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "Макс. число неудач",
    ),
    "maxLengthTip": m21,
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "min": MessageLookupByLibrary.simpleMessage("Минимальный"),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменяет стандартное поведение при выходе",
    ),
    "minimizeToTray": MessageLookupByLibrary.simpleMessage(
      "Сворачивать в трей при закрытии",
    ),
    "minimizeToTrayDesc": MessageLookupByLibrary.simpleMessage(
      "При закрытии окна Eclipse остаётся в трее",
    ),
    "minutesAgo": m22,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "module": MessageLookupByLibrary.simpleMessage("Модуль"),
    "moduleAuthor": m23,
    "moduleDetailEmpty": MessageLookupByLibrary.simpleMessage(
      "Выберите модуль для просмотра",
    ),
    "moduleDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось скачать или действительный модуль не найден",
    ),
    "moduleHostCount": m24,
    "moduleImported": m25,
    "moduleInvalid": MessageLookupByLibrary.simpleMessage(
      "Действительный модуль не найден",
    ),
    "moduleMitmNote": MessageLookupByLibrary.simpleMessage(
      "Содержит контент, требующий расшифровки MITM; сейчас применяется как статические правила",
    ),
    "moduleParams": MessageLookupByLibrary.simpleMessage("Параметры"),
    "moduleRewriteCount": m26,
    "moduleRuleCount": m27,
    "moduleRuleStats": MessageLookupByLibrary.simpleMessage(
      "Статистика правил",
    ),
    "moduleScriptCount": m28,
    "moduleStatsSummary": m29,
    "moduleUpdated": m30,
    "modules": MessageLookupByLibrary.simpleMessage("Модули"),
    "modulesUpdated": m31,
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m32,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "Разделяйте несколько значений запятыми",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "nameserver": MessageLookupByLibrary.simpleMessage("DNS-сервер"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика DNS-серверов",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Задать политику DNS-серверов для доменов",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Настройки, связанные с сетью",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Проверка сети"),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети. Проверьте подключение и повторите попытку",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральная"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Следующее совпадение"),
    "noActiveConnections": MessageLookupByLibrary.simpleMessage(
      "Нет активных соединений через этот узел",
    ),
    "noConnections": MessageLookupByLibrary.simpleMessage(
      "Нет активных соединений",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Горячих клавиш пока нет"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noLogs": MessageLookupByLibrary.simpleMessage("Нет журналов"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Больше не напоминать",
    ),
    "noModuleParams": MessageLookupByLibrary.simpleMessage("Нет параметров"),
    "noModules": MessageLookupByLibrary.simpleMessage("Нет модулей"),
    "noModulesDesc": MessageLookupByLibrary.simpleMessage(
      "Нажмите +, чтобы импортировать .sgmodule",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noNodes": MessageLookupByLibrary.simpleMessage("В профиле нет узлов"),
    "noNodesDesc": MessageLookupByLibrary.simpleMessage(
      "Нет узлов. Добавьте подписку или импортируйте узлы.",
    ),
    "noOverrideRules": MessageLookupByLibrary.simpleMessage(
      "Нет правил переопределения",
    ),
    "noProfileSelected": MessageLookupByLibrary.simpleMessage(
      "Профиль не выбран",
    ),
    "noProfiles": MessageLookupByLibrary.simpleMessage("Нет профилей"),
    "noProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Импортируйте или создайте профиль",
    ),
    "noRecords": MessageLookupByLibrary.simpleMessage("Записей пока нет"),
    "noRequests": MessageLookupByLibrary.simpleMessage("Нет запросов"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не разрешать IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Не разрешать имя хоста",
    ),
    "noRuleItems": MessageLookupByLibrary.simpleMessage("Нет правил"),
    "noRules": MessageLookupByLibrary.simpleMessage("Нет правил"),
    "noRulesInConf": MessageLookupByLibrary.simpleMessage(
      "В файле .conf правила не найдены",
    ),
    "noSearchResult": MessageLookupByLibrary.simpleMessage("Ничего не найдено"),
    "noSettingsResult": MessageLookupByLibrary.simpleMessage(
      "Настройки не найдены",
    ),
    "noUpdatableModules": MessageLookupByLibrary.simpleMessage(
      "Нет модулей с сохранённым URL обновления",
    ),
    "nodeDetail": MessageLookupByLibrary.simpleMessage("Сведения об узле"),
    "nodeImportExport": MessageLookupByLibrary.simpleMessage(
      "Импорт/экспорт узлов",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Узлы"),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notRebindable": MessageLookupByLibrary.simpleMessage("Фиксировано"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущую группу прокси нельзя выбрать",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Профилей пока нет. Сначала добавьте профиль",
    ),
    "nullTip": m33,
    "numberTip": m34,
    "onDemand": MessageLookupByLibrary.simpleMessage("По условию"),
    "onDemandAlwaysOn": MessageLookupByLibrary.simpleMessage("Always on"),
    "onDemandAlwaysOnDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the VPN connected and reconnect automatically after reboots or drops",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Настройте состояние работы приложения для определённых сценариев",
    ),
    "onDemandDisconnectOnSleep": MessageLookupByLibrary.simpleMessage(
      "Disconnect while asleep",
    ),
    "onDemandDisconnectOnSleepDesc": MessageLookupByLibrary.simpleMessage(
      "Disconnect the VPN when the device sleeps to save battery",
    ),
    "onDemandExtras": MessageLookupByLibrary.simpleMessage("On-Demand Extras"),
    "onDemandExtrasDesc": MessageLookupByLibrary.simpleMessage(
      "Всегда включено, отключение во сне и уведомления",
    ),
    "onDemandShowDisconnectInfo": MessageLookupByLibrary.simpleMessage(
      "Show disconnect notices",
    ),
    "onDemandShowDisconnectInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Notify when the VPN unexpectedly disconnects",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только значок"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Учитывать только прокси",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "При включении учитывается только трафик через прокси",
    ),
    "openCommandPalette": MessageLookupByLibrary.simpleMessage(
      "Открыть палитру команд",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "override": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределить DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "При включении настройки DNS профиля переопределяются",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage(
      "Режим переопределения",
    ),
    "overrideRules": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overrideScript": MessageLookupByLibrary.simpleMessage(
      "Скрипт переопределения",
    ),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage(
      "Пользовательский",
    ),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Пользовательский режим: полная настройка групп прокси и правил",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "paramOff": MessageLookupByLibrary.simpleMessage("Выкл."),
    "paramOn": MessageLookupByLibrary.simpleMessage("Вкл."),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pasteImport": MessageLookupByLibrary.simpleMessage(
      "Вставить из буфера обмена",
    ),
    "pasteImportDesc": MessageLookupByLibrary.simpleMessage(
      "Читать ссылки узлов из буфера обмена и импортировать",
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
    "permissionNotes": MessageLookupByLibrary.simpleMessage("О разрешениях"),
    "permissions": MessageLookupByLibrary.simpleMessage("Permissions"),
    "permissionsDesc": MessageLookupByLibrary.simpleMessage(
      "Eclipse needs these system permissions to work properly. You can change them anytime in the system settings.",
    ),
    "permissionsInfo": MessageLookupByLibrary.simpleMessage("Permissions"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Выбрать из галереи"),
    "pinWindow": MessageLookupByLibrary.simpleMessage(
      "Закрепить поверх всех окон",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Введите название скрипта",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Загрузите корректный QR-код",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portTip": m35,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Предпочитать HTTP/3 для DoH",
    ),
    "preferIpv6": MessageLookupByLibrary.simpleMessage("Предпочитать IPv6"),
    "prerequisites": MessageLookupByLibrary.simpleMessage(
      "Предварительные условия",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Нажмите клавишу"),
    "pressKeys": MessageLookupByLibrary.simpleMessage("Нажмите клавиши…"),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "previousMatch": MessageLookupByLibrary.simpleMessage(
      "Предыдущее совпадение",
    ),
    "privateIpAnswer": MessageLookupByLibrary.simpleMessage(
      "Ответ приватным IP",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите корректный интервал"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileCopySuffix": MessageLookupByLibrary.simpleMessage("копия"),
    "profileDuplicated": MessageLookupByLibrary.simpleMessage(
      "Конфигурация продублирована",
    ),
    "profileFiles": MessageLookupByLibrary.simpleMessage("Файлы конфигурации"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль изменён. Отключить автообновление?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите название профиля",
    ),
    "profileUrlHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте URL подписки или оставьте пустым для выбора файла",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesCount": m36,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Список прокси пуст"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочка прокси"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Обнаружены отклонения в выбранных прокси",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Фильтр узлов"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Обнаружены отклонения в текущей группе прокси",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Группа прокси пуста",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Название группы прокси уже используется",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Название группы прокси не может быть пустым",
    ),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("Группы прокси"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "DNS-сервер для прокси",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разрешения доменов прокси-узлов",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Обнаружены отклонения в выбранных провайдерах прокси",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Список провайдеров прокси пуст",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Провайдеры прокси не могут быть пустыми",
    ),
    "proxyServers": MessageLookupByLibrary.simpleMessage("Прокси-серверы"),
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
    "proxyType": MessageLookupByLibrary.simpleMessage("Тип прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто чёрный режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код, чтобы получить профиль",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Быстрое заполнение"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радуга"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Порт Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённо"),
    "remoteAddress": MessageLookupByLibrary.simpleMessage("Удалённый адрес"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных в WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Убрать"),
    "rename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр последних запросов",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На этой странице есть изменения. Вы уверены, что хотите выполнить сброс?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выполнить сброс?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Сведения о внешних ресурсах",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Соблюдать правила"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-соединения следуют правилам; требуется настроить proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите перезапустить ядро?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "restoreDefault": MessageLookupByLibrary.simpleMessage(
      "Восстановить по умолчанию",
    ),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("Сбросить"),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Ошибка восстановления",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные из файла",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные из WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Восстановить только профили",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия восстановления",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Совместимость",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Перезапись",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление выполнено",
    ),
    "rewrite": MessageLookupByLibrary.simpleMessage("Перезапись"),
    "rewrites": MessageLookupByLibrary.simpleMessage("Перезаписи"),
    "routeAdd": MessageLookupByLibrary.simpleMessage("Add"),
    "routeAddHint": MessageLookupByLibrary.simpleMessage("e.g. 192.168.0.0/16"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Адреса маршрутов"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить прослушиваемые адреса маршрутов",
    ),
    "routeConfig": MessageLookupByLibrary.simpleMessage("Конфиг"),
    "routeDirect": MessageLookupByLibrary.simpleMessage("Напрямую"),
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
    "routeMode": MessageLookupByLibrary.simpleMessage("Режим маршрутизации"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Обходить частные адреса",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage(
      "Использовать конфигурацию",
    ),
    "routeProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "routeScene": MessageLookupByLibrary.simpleMessage("Сценарий"),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правило"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить полный домен",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ключевое слово в домене",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению домена",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить суффикс домена",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставление по маске; поддерживаются только * и ?",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить метку DSCP (только для входящих tproxy UDP)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон портов назначения",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить код страны IP-адреса",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить домены из Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя входящего подключения",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить входящий порт",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить тип входящего подключения",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя пользователя входящего подключения; несколько имён разделяются /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ASN, которой принадлежит IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов; IP-CIDR6 — просто псевдоним",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон суффиксов IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставляет все запросы, условия не нужны",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить TCP или UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage(
      "Логическое правило OR",
    ),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по имени процесса; на Android соответствует имени пакета",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению имени процесса; на Android соответствует имени пакета",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по маске имени процесса; поддерживаются только * и ?",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по полному пути процесса",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по регулярному выражению пути процесса",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить по маске пути процесса; поддерживаются только * и ?",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить имя повторного сопоставления; несколько имён разделяются /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Ссылка на набор правил; требуется настроить rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить код страны IP источника",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить ASN IP источника",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон IP-адресов источника",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон суффиксов IP источника",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить диапазон портов источника",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Переход к подправилу; обратите внимание на скобки",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Сопоставить Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Правило пусто"),
    "ruleHits": MessageLookupByLibrary.simpleMessage("Срабатывания правил"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Название правила"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Набор правил"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "rules": MessageLookupByLibrary.simpleMessage("Правила"),
    "rulesCount": m37,
    "rulesDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось скачать или содержимое пустое",
    ),
    "rulesImported": m38,
    "rulesReadonly": MessageLookupByLibrary.simpleMessage(
      "Встроенные правила (только чтение)",
    ),
    "runDelayTest": MessageLookupByLibrary.simpleMessage(
      "Запустить тест задержки",
    ),
    "runStatus": MessageLookupByLibrary.simpleMessage("Состояние"),
    "running": MessageLookupByLibrary.simpleMessage("Работает"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "sceneDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить эту сцену?",
    ),
    "sceneEmpty": MessageLookupByLibrary.simpleMessage("Сцен пока нет"),
    "sceneIosForegroundNote": MessageLookupByLibrary.simpleMessage(
      "На iOS изменения сети обнаруживаются и сцены переключаются только когда приложение на переднем плане",
    ),
    "sceneKeepCurrent": MessageLookupByLibrary.simpleMessage(
      "Оставить как есть",
    ),
    "sceneMode": MessageLookupByLibrary.simpleMessage("Режим сцен"),
    "sceneModeDesc": MessageLookupByLibrary.simpleMessage(
      "Автопереключение профиля, режима и выходного узла по сети",
    ),
    "sceneNoSwitch": MessageLookupByLibrary.simpleMessage("Не переключать"),
    "sceneSsidHint": MessageLookupByLibrary.simpleMessage(
      "Введите имя Wi-Fi (с учетом регистра)",
    ),
    "sceneTargetMode": MessageLookupByLibrary.simpleMessage(
      "Режим маршрутизации",
    ),
    "sceneTargetProfile": MessageLookupByLibrary.simpleMessage(
      "Целевой профиль",
    ),
    "sceneTargetProxy": MessageLookupByLibrary.simpleMessage("Выходной узел"),
    "sceneTrigger": MessageLookupByLibrary.simpleMessage("Триггер"),
    "sceneTriggerCellular": MessageLookupByLibrary.simpleMessage(
      "Сотовая сеть",
    ),
    "sceneTriggerFallback": MessageLookupByLibrary.simpleMessage(
      "Запасная сцена",
    ),
    "sceneTriggerSsid": MessageLookupByLibrary.simpleMessage("Имя Wi-Fi"),
    "scopeCommands": MessageLookupByLibrary.simpleMessage("Команды"),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Режим скрипта: использует внешние скрипты-расширения для переопределения конфигурации в один клик",
    ),
    "scripts": MessageLookupByLibrary.simpleMessage("Скрипты"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Прокрутить к выбранному",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "searchModules": MessageLookupByLibrary.simpleMessage("Поиск модулей"),
    "searchProfiles": MessageLookupByLibrary.simpleMessage("Поиск профилей"),
    "searchRules": MessageLookupByLibrary.simpleMessage("Поиск правил"),
    "searchSettings": MessageLookupByLibrary.simpleMessage("Поиск настроек"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "secondsCount": m39,
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "Выбрать MATCH-TARGET",
    ),
    "selectNode": MessageLookupByLibrary.simpleMessage("Выбрать узел"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Выбрать прокси"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Выбрать провайдеров прокси",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Выберите набор правил",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Выберите стратегию распределения",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Выберите подправило",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m40,
    "setAsCurrent": MessageLookupByLibrary.simpleMessage("Выбрать текущим"),
    "setAsDefault": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "settingsGroupAbout": MessageLookupByLibrary.simpleMessage("О приложении"),
    "settingsGroupAppearance": MessageLookupByLibrary.simpleMessage(
      "Внешний вид",
    ),
    "settingsGroupNetwork": MessageLookupByLibrary.simpleMessage("Сеть и ядро"),
    "settingsGroupShortcuts": MessageLookupByLibrary.simpleMessage(
      "Горячие клавиши",
    ),
    "settingsGroupTray": MessageLookupByLibrary.simpleMessage(
      "Уведомления и трей",
    ),
    "settingsSectionDisplay": MessageLookupByLibrary.simpleMessage(
      "Отображение и язык",
    ),
    "settingsSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "Сеть и прокси",
    ),
    "settingsSectionSecurity": MessageLookupByLibrary.simpleMessage(
      "Безопасность и разрешения",
    ),
    "shortcutUpdated": m41,
    "shortcuts": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Кнопка остановки в уведомлении",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать кнопку остановки в постоянном уведомлении. Отключите, если из-за неё система всегда разворачивает уведомление",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Показать пароль"),
    "shrink": MessageLookupByLibrary.simpleMessage("Компактный"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться в фоновом режиме",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "skipProxy": MessageLookupByLibrary.simpleMessage("Обход прокси"),
    "skipProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Остаются в TUN-туннеле; политика определяется цепочкой правил.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Порт SOCKS"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "sortModules": MessageLookupByLibrary.simpleMessage("Порядок модулей"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP источника"),
    "spaceKey": MessageLookupByLibrary.simpleMessage("Пробел"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "speed": MessageLookupByLibrary.simpleMessage("Скорость"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Статистика скорости",
    ),
    "splitStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения",
    ),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Стратегия распределения не может быть пустой",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("Список SSID пуст"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартный режим: переопределяет базовую конфигурацию и позволяет просто добавлять правила",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Старт"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN..."),
    "startup": MessageLookupByLibrary.simpleMessage("Запуск при старте"),
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
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "При отключении используется системный DNS",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN..."),
    "stopped": MessageLookupByLibrary.simpleMessage("Остановлено"),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Подправило пусто"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Подправило не может быть пустым",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Информация о подписке",
    ),
    "subscriptionLink": MessageLookupByLibrary.simpleMessage(
      "Ссылка на подписку",
    ),
    "subscriptions": MessageLookupByLibrary.simpleMessage("Подписки"),
    "suspended": MessageLookupByLibrary.simpleMessage("Приостановлено..."),
    "switchNode": MessageLookupByLibrary.simpleMessage("Сменить"),
    "switchPage": MessageLookupByLibrary.simpleMessage("Сменить страницу"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Сменить профиль"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Настроить системный прокси",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только в мобильном виде",
    ),
    "tableAction": MessageLookupByLibrary.simpleMessage("Действие"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы разрешить",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("Параллельный TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "При включении разрешает параллельные TCP-подключения",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал тестирования",
    ),
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
    "testUrl": MessageLookupByLibrary.simpleMessage("URL для теста"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage(
      "Тестировать при использовании",
    ),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Тёмный режим и настройка цветов",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "tight": MessageLookupByLibrary.simpleMessage("Плотный"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "timeout": MessageLookupByLibrary.simpleMessage("Тайм-аут"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("Переключить подписи"),
    "toggleRun": MessageLookupByLibrary.simpleMessage("Включить / выключить"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Всего получено"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Всего отправлено"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Порт TProxy"),
    "trafficTrend": MessageLookupByLibrary.simpleMessage("График трафика"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "trayTitle": MessageLookupByLibrary.simpleMessage("Скорость в трее"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только в режиме администратора",
    ),
    "tunExcludedRoutes": MessageLookupByLibrary.simpleMessage(
      "Исключённые маршруты TUN",
    ),
    "tunExcludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "CIDR-маршруты, исключённые из TUN",
    ),
    "tunIncludedRoutes": MessageLookupByLibrary.simpleMessage(
      "Включённые маршруты TUN",
    ),
    "tunIncludedRoutesDesc": MessageLookupByLibrary.simpleMessage(
      "CIDR-маршруты, включённые в TUN",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Туннель"),
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
    "turnOff": MessageLookupByLibrary.simpleMessage("Выключить"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "udpForward": MessageLookupByLibrary.simpleMessage("Пересылка UDP"),
    "udpForwardDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить узлам пересылать UDP-трафик",
    ),
    "udpForwardStun": MessageLookupByLibrary.simpleMessage(
      "Пересылка UDP и STUN",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Единая задержка"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Убирает лишние задержки, например рукопожатие",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Свернуть в окно"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без названия"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Открепить окно"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateAll": MessageLookupByLibrary.simpleMessage("Обновить все"),
    "upload": MessageLookupByLibrary.simpleMessage("Отдача"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Получить профиль по URL"),
    "urlRewrite": MessageLookupByLibrary.simpleMessage("Перезапись URL"),
    "urlTip": m44,
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системный hosts",
    ),
    "usedTraffic": MessageLookupByLibrary.simpleMessage(
      "Использованный трафик",
    ),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркая"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено изменение настроек VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически направляет весь системный трафик через VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Изменения вступят в силу после перезапуска VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
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
    "yearsAgo": m45,
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
  };
}
