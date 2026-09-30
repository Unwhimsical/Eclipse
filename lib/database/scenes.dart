part of 'database.dart';

@DataClassName('RawScene')
class Scenes extends Table {
  @override
  String get tableName => 'scenes';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get triggerType => textEnum<SceneTriggerType>()();

  TextColumn get ssid => text().nullable()();

  IntColumn get targetProfileId => integer().nullable()();

  TextColumn get mode => textEnum<Mode>().nullable()();

  TextColumn get targetProxy => text().nullable()();

  IntColumn get order => integer().withDefault(const Constant(0))();
}

@DriftAccessor(tables: [Scenes])
class ScenesDao extends DatabaseAccessor<Database> with _$ScenesDaoMixin {
  ScenesDao(super.attachedDatabase);

  Selectable<Scene> queryAll() {
    final stmt = scenes.select()
      ..orderBy([(t) => OrderingTerm(expression: t.order)]);
    return stmt.map((item) => item.toScene());
  }

  Future<int> put(Scene scene) {
    final companion = scene.toCompanion();
    if (scene.id <= 0) {
      return into(scenes).insert(companion.copyWith(id: const Value.absent()));
    }
    return into(scenes).insertOnConflictUpdate(companion);
  }

  Future<int> deleteScene(int id) {
    return (scenes.delete()..where((t) => t.id.equals(id))).go();
  }
}

extension RawSceneExt on RawScene {
  Scene toScene() {
    return Scene(
      id: id,
      name: name,
      triggerType: triggerType,
      ssid: ssid,
      targetProfileId: targetProfileId,
      mode: mode,
      targetProxy: targetProxy,
      order: order,
    );
  }
}

extension ScenesCompanionExt on Scene {
  ScenesCompanion toCompanion() {
    return ScenesCompanion.insert(
      id: id <= 0 ? const Value.absent() : Value(id),
      name: name,
      triggerType: triggerType,
      ssid: Value(ssid),
      targetProfileId: Value(targetProfileId),
      mode: Value(mode),
      targetProxy: Value(targetProxy),
      order: Value(order),
    );
  }
}
