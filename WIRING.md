# WIRING.md — MITM 新能力的 Dart 接线指南

本文档给下一棒（Dart 侧）用。Go 侧已全部实现并测试通过（commit 见文末），
Dart 侧只需做解析 + 传参，不需要改 Go。

> 接线完成后本文件可删除。

## 一、USER-AGENT 规则（`USER-AGENT,<pattern>,<policy>`）

### Go 侧已就绪（本 commit）

- `core/mitm/useragent.go`：
  - `UARejectKind(policy string) (kind, status string/int, ok bool)` ——
    只映射 REJECT 家族：`REJECT/-`→502空、`REJECT-200`→200空、
    `REJECT-DICT`/`REJECT-JSON`→200`{}`、`REJECT-ARRAY`→200`[]`、
    `REJECT-IMG`/`REJECT-TINYGIF`→1x1 GIF、`REJECT-VIDEO`→mp4。
    `PROXY`/`DIRECT`/分组名返回 `ok=false`（见下文限制）。
  - `CompileUARejectRule(pattern, kind, status)` —— Shadowrocket glob 转正则：
    `*`→`.*`，全串锚定，大小写不敏感（`(?i)`）。
  - `(p *Proxy) applyUARejectRules(req)` —— 匹配请求 `User-Agent` 头，返回首个命中的
    `*RewriteResult`，无命中返回 nil。
- `core/mitm/mitm.go`：`Config` 新增 `UARules []UARejectRule` 字段；
  `UpdateConfig` 现在拷贝 `UARules`（顺手修了之前漏拷 `RejectRules` 的 bug）。
- `core/mitm/server.go`：`handleHTTP` 在 host granular reject 之后调用
  `applyUARejectRules`，命中即渲染优雅空响应并返回（不走上游）。

### Dart 侧要做（3 处）

1. **`lib/common/shadowrocket.dart`**：仿照 `GranularRejectRule` /
   `parseGranularRejectLine`（第 816–870 行）新增：
   ```dart
   class UARejectRule {
     final String pattern; // Shadowrocket glob，原样透传，Go 侧转正则
     final String policy;  // REJECT 家族原样透传；PROXY/DIRECT/分组名直接丢弃
     Map<String, Object> toJson() => {'pattern': pattern, 'policy': policy};
   }
   UARejectRule? parseUARejectLine(String rawLine) // 解析 USER-AGENT,<pattern>,<policy>
   ```
   `Sgmodule` 加 `uaRejects` 字段（仿照 `granularRejects`，第 892/910/944/984–985 行）。
   注意第 780 行现在把 USER-AGENT 行降为注释（"Clash has no USER-AGENT rule type"）——
   **不要**往 mihomo YAML 里写 USER-AGENT，mihomo 原生不支持；执行路径只有 MITM。
   policy 映射表不要在 Dart 侧重复造：Go 的 `mitm.UARejectKind` 已经是唯一真源
   （见下）。
2. **`lib/common/mitm_manager.dart` 的 `syncAndStart`**：仿照 `rejectRules` 收集
   （第 55/112–117/196 行），从各 enabled module 的 `sg.uaRejects` 按模块顺序收集
   `uaRules`（`{'pattern': ..., 'policy': ...}`），加入 args map：`'uaRules': uaRules`。
   注意：UA 规则没有 host，不需要像 granular 那样 `addHosts`；但**只有 MITM 实际
   解密了流量 UA 规则才会触发**——如果某 profile/module 只有 UA 规则而没有任何
   hostname，`syncAndStart` 开头的空检查会直接 `stop()`，UA 规则永远跑不起来。
   这是符合预期的（无解密则无 UA 可见），但要在 UI/日志里让用户知道。
3. **`core/mitm_methods.go` 的 `mitmConfigFromArgs`**：仿照 `rejectRules` 那段
   解析 `args["uaRules"]`（list of `{pattern,policy}`），对每条调
   `mitm.UARejectKind(policy)`——`ok=false`（PROXY/DIRECT/分组名/空）直接
   `continue`；`ok=true` 则 `mitm.CompileUARejectRule(pattern, kind, status)`
   后 append 到 `cfg.UARules`。pattern 为空或编译失败时 `continue`。

### 硬性限制（必须如实呈现，不要"假装支持"）

- **只有 MITM 解密的流量能看到 UA**。未解密、走 `tunnelRaw` 直通的流量，
  Go 层看不到 HTTP 头，UA 规则不生效。
- **PROXY / DIRECT / 自定义分组 policy 不支持**：L7 层改不了连接的上游路由，
  Go 侧 `UARejectKind` 对它们返回 `ok=false`，Dart 侧应直接丢弃（可 log），
  不要传下去。
- 大小写不敏感是 Go 侧的实现选择（`(?i)`），Shadowrocket 原生是否区分大小写
  未核实——文档化假设，如真机对比发现不一致再调。
- Glob 语义：只有 `*` 是通配符（`?` 按字面处理），全串锚定
  （`AVOS*` = 以 AVOS 开头；`*ads*` = 包含 ads）。

## 二、响应头改写（Header Rewrite 响应方向）

### 背景

Shadowrocket 的 Header Rewrite 有方向概念：`type=http-request`（请求头，
已实现）/ `type=http-response`（响应头，本次新增）。生态里 Quantumult X 用
`response-header-*` 动作前缀表达方向。Go 侧采用**动作名前缀**方案：
`response-header-del` / `response-header-add` / `response-header-replace` /
`response-header-replace-regex`，行为与请求方向的四种完全一致。
`type=` 前缀不做解析（只认动作名）。

### Go 侧已就绪（本 commit）

- `core/mitm/header_rewrite.go`：
  - `isResponseHeaderAction(action)`：`response-header-` 前缀判定（大小写不敏感）。
  - `applyHeaderRewrites`（请求方向）：跳过 `response-header-*` 规则，旧行为不变。
  - 新增 `applyResponseHeaderRewrites(resp, urlStr)`：只执行 `response-header-*`
    规则，直接改 `resp.Header`。
  - 四种行为抽成共享函数 `applyHeaderAction(h, action, args)`，两方向同一套逻辑。
- `core/mitm/server.go` 的 `forward()`：在上游响应返回、脚本/Body 改写跑完之后、
  把头拷贝给客户端之前，调用 `p.applyResponseHeaderRewrites(resp, out.URL.String())`。
  只对**真实上游响应**生效；脚本合成的 `$done({response})`、Map Local 合成响应
  不走 `forward()`，不受影响（与现有请求头改写一致）。

### Dart 侧要做（1 处）

- `lib/common/shadowrocket.dart` 的 `parseHeaderRewriteLine` **不需要改**：
  它不对 action 做校验，直接透传 action 字符串。Dart 侧只需把
  `response-header-*` 的行也收进 `headerRewrites` 列表（现在是否过滤了
  action 名需确认——如果 `mitm_manager.dart` 或别处有 action 白名单，把四个
  `response-header-*` 加进去）。Go 侧 `CompileHeaderRewrite` 已接受这些动作名，
  未知动作名两边都是静默忽略（有测试覆盖）。

## 三、本 commit 内容

- `core/mitm/useragent.go`（新增）：UARejectRule / UARejectKind /
  CompileUARejectRule / applyUARejectRules。
- `core/mitm/mitm.go`：`Config.UARules` 字段；`UpdateConfig` 补拷
  `RejectRules`（bugfix）+ `UARules`。
- `core/mitm/header_rewrite.go`：抽出 `applyHeaderAction`；请求方向跳过
  `response-header-*`；新增 `applyResponseHeaderRewrites`。
- `core/mitm/server.go`：`handleHTTP` 接入 UA reject；`forward()` 接入响应头改写。
- 测试：`core/mitm/useragent_test.go`（新增，5 个 test）；
  `core/mitm/header_rewrite_test.go`（追加 4 个 test）。
- 本文件 `WIRING.md`（接线完可删）。

## 四、验证结果

- `go test -count=1 ./mitm/`：全过（含新增 9 个 test）。
- `CGO_ENABLED=0 go test -count=1 .`（core/ 根，CI 同款）：全过。
- `go vet ./mitm/`、`go vet .`、`GOOS=linux go vet ./platform`：干净。
- `gofmt`：干净。`tool/check_comment_density.sh`：通过。
