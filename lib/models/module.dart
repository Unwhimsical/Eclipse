/// An imported `.sgmodule`. Stored as a file under the app dir; this index
/// record lives in SharedPreferences so no database migration is needed.
class ModuleInfo {
  final String id;
  final String name;
  final String desc;
  final String? author;
  final bool enabled;
  final int ruleCount;
  final int hostCount;
  final int rewriteCount;
  final int scriptCount;
  final bool needsMitm;
  final DateTime importDate;

  const ModuleInfo({
    required this.id,
    required this.name,
    this.desc = '',
    this.author,
    this.enabled = true,
    this.ruleCount = 0,
    this.hostCount = 0,
    this.rewriteCount = 0,
    this.scriptCount = 0,
    this.needsMitm = false,
    required this.importDate,
  });

  ModuleInfo copyWith({
    String? name,
    String? desc,
    String? author,
    bool? enabled,
    int? ruleCount,
    int? hostCount,
    int? rewriteCount,
    int? scriptCount,
    bool? needsMitm,
  }) {
    return ModuleInfo(
      id: id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      author: author ?? this.author,
      enabled: enabled ?? this.enabled,
      ruleCount: ruleCount ?? this.ruleCount,
      hostCount: hostCount ?? this.hostCount,
      rewriteCount: rewriteCount ?? this.rewriteCount,
      scriptCount: scriptCount ?? this.scriptCount,
      needsMitm: needsMitm ?? this.needsMitm,
      importDate: importDate,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'author': author,
      'enabled': enabled,
      'ruleCount': ruleCount,
      'hostCount': hostCount,
      'rewriteCount': rewriteCount,
      'scriptCount': scriptCount,
      'needsMitm': needsMitm,
      'importDate': importDate.toIso8601String(),
    };
  }

  factory ModuleInfo.fromJson(Map<String, Object?> json) {
    return ModuleInfo(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      desc: '${json['desc'] ?? ''}',
      author: json['author'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      ruleCount: (json['ruleCount'] as num?)?.toInt() ?? 0,
      hostCount: (json['hostCount'] as num?)?.toInt() ?? 0,
      rewriteCount: (json['rewriteCount'] as num?)?.toInt() ?? 0,
      scriptCount: (json['scriptCount'] as num?)?.toInt() ?? 0,
      needsMitm: json['needsMitm'] as bool? ?? false,
      importDate:
          DateTime.tryParse('${json['importDate'] ?? ''}') ?? DateTime.now(),
    );
  }
}
