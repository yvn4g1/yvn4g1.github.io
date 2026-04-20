import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ────────────────────────────────────────────
// セット
// ────────────────────────────────────────────
class TrainingSet {
  final String id;
  double weight;
  int reps;
  int seconds; // timeOnly用（秒数）

  TrainingSet({
    String? id,
    this.weight = 60.0,
    this.reps = 10,
    this.seconds = 60,
  }) : id = id ?? _uuid.v4();

  TrainingSet copyWith({double? weight, int? reps, int? seconds}) =>
      TrainingSet(
        id: id,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        seconds: seconds ?? this.seconds,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'weight': weight, 'reps': reps, 'seconds': seconds};

  factory TrainingSet.fromJson(Map<String, dynamic> j) => TrainingSet(
        id: j['id'],
        weight: (j['weight'] as num).toDouble(),
        reps: j['reps'] ?? 10,
        seconds: j['seconds'] ?? 60,
      );
}

// ────────────────────────────────────────────
// 種目（1日の記録内）
// ────────────────────────────────────────────
class ExerciseEntry {
  final String id;
  String name;
  String part;
  String memo;
  String inputType;
  String unit1;
  String unit2;
  List<TrainingSet> sets;

  ExerciseEntry({
    String? id,
    required this.name,
    required this.part,
    this.memo = '',
    this.inputType = 'weightAndReps',
    this.unit1 = 'kg',
    this.unit2 = 'rep',
    List<TrainingSet>? sets,
  })  : id = id ?? _uuid.v4(),
        sets = sets ?? [TrainingSet()];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'part': part,
        'memo': memo,
        'inputType': inputType,
        'unit1': unit1,
        'unit2': unit2,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory ExerciseEntry.fromJson(Map<String, dynamic> j) => ExerciseEntry(
        id: j['id'],
        name: j['name'],
        part: j['part'],
        memo: j['memo'] ?? '',
        inputType: j['inputType'] ?? 'weightAndReps',
        unit1: j['unit1'] ?? 'kg',
        unit2: j['unit2'] ?? 'rep',
        sets: (j['sets'] as List).map((s) => TrainingSet.fromJson(s)).toList(),
      );
}

// ────────────────────────────────────────────
// 1日のトレーニング記録
// ────────────────────────────────────────────
class TrainingSession {
  final String id;
  final DateTime date;
  List<ExerciseEntry> exercises;

  TrainingSession({
    String? id,
    required this.date,
    List<ExerciseEntry>? exercises,
  })  : id = id ?? _uuid.v4(),
        exercises = exercises ?? [];

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory TrainingSession.fromJson(Map<String, dynamic> j) => TrainingSession(
        id: j['id'],
        date: DateTime.parse(j['date']),
        exercises:
            (j['exercises'] as List).map((e) => ExerciseEntry.fromJson(e)).toList(),
      );
}

// ────────────────────────────────────────────
// inputType 定数
// ────────────────────────────────────────────
// 'weightAndReps' : 重量 + 回数（デフォルト）
// 'repsOnly'      : 回数のみ（自重）
// 'timeOnly'      : 時間のみ（プランク等）

// ────────────────────────────────────────────
// プリセット種目
// ────────────────────────────────────────────
class PresetExercise {
  final String id;
  String name;
  String part;
  String meta;
  String inputType;
  String unit1; // 将来の拡張用
  String unit2; // 将来の拡張用

  PresetExercise({
    String? id,
    required this.name,
    required this.part,
    this.meta = '',
    this.inputType = 'weightAndReps',
    this.unit1 = 'kg',
    this.unit2 = 'rep',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'part': part,
        'meta': meta,
        'inputType': inputType,
        'unit1': unit1,
        'unit2': unit2,
      };

  factory PresetExercise.fromJson(Map<String, dynamic> j) => PresetExercise(
        id: j['id'],
        name: j['name'],
        part: j['part'],
        meta: j['meta'] ?? '',
        inputType: j['inputType'] ?? 'weightAndReps',
        unit1: j['unit1'] ?? 'kg',
        unit2: j['unit2'] ?? 'rep',
      );
}

// ────────────────────────────────────────────
// プリセットタブ（フォルダ）
// ────────────────────────────────────────────
class PresetFolder {
  final String id;
  String label;
  String part;
  List<PresetExercise> exercises;

  PresetFolder({
    String? id,
    required this.label,
    required this.part,
    List<PresetExercise>? exercises,
  })  : id = id ?? _uuid.v4(),
        exercises = exercises ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'part': part,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory PresetFolder.fromJson(Map<String, dynamic> j) => PresetFolder(
        id: j['id'],
        label: j['label'],
        part: j['part'],
        exercises:
            (j['exercises'] as List).map((e) => PresetExercise.fromJson(e)).toList(),
      );
}

// ────────────────────────────────────────────
// デフォルトプリセット
// ────────────────────────────────────────────
List<PresetFolder> defaultPresets() => [
      PresetFolder(label: '胸', part: 'chest', exercises: [
        PresetExercise(name: 'ベンチプレス', part: 'chest', meta: 'バーベル・コンパウンド'),
        PresetExercise(name: 'インクラインDB', part: 'chest', meta: 'ダンベル・コンパウンド'),
        PresetExercise(name: 'ペックフライ', part: 'chest', meta: 'マシン・アイソレーション'),
        PresetExercise(name: 'ディップス', part: 'chest', meta: '自重・コンパウンド',
            inputType: 'repsOnly', unit1: '', unit2: 'rep'),
        PresetExercise(name: 'クローズBP', part: 'chest', meta: 'バーベル・コンパウンド'),
      ]),
      PresetFolder(label: '背中', part: 'back', exercises: [
        PresetExercise(name: 'デッドリフト', part: 'back', meta: 'バーベル・コンパウンド'),
        PresetExercise(name: '懸垂', part: 'back', meta: '自重・コンパウンド',
            inputType: 'repsOnly', unit1: '', unit2: 'rep'),
        PresetExercise(name: 'バーベルロウ', part: 'back', meta: 'バーベル・コンパウンド'),
        PresetExercise(name: 'ラットプル', part: 'back', meta: 'マシン・コンパウンド'),
        PresetExercise(name: 'シーテッドロウ', part: 'back', meta: 'マシン・コンパウンド'),
      ]),
      PresetFolder(label: '脚', part: 'legs', exercises: [
        PresetExercise(name: 'スクワット', part: 'legs', meta: 'バーベル・コンパウンド'),
        PresetExercise(name: 'レッグプレス', part: 'legs', meta: 'マシン・コンパウンド'),
        PresetExercise(name: 'レッグエクステ', part: 'legs', meta: 'マシン・アイソレーション'),
        PresetExercise(name: 'レッグカール', part: 'legs', meta: 'マシン・アイソレーション'),
        PresetExercise(name: 'ルーマニアDL', part: 'legs', meta: 'バーベル・コンパウンド'),
      ]),
      PresetFolder(label: '腕', part: 'arms', exercises: [
        PresetExercise(name: 'バーベルカール', part: 'arms', meta: 'バーベル・アイソレーション'),
        PresetExercise(name: 'ダンベルカール', part: 'arms', meta: 'ダンベル・アイソレーション'),
        PresetExercise(name: 'プレスダウン', part: 'arms', meta: 'ケーブル・アイソレーション'),
        PresetExercise(name: 'キックバック', part: 'arms', meta: 'ダンベル・アイソレーション'),
      ]),
      PresetFolder(label: '肩', part: 'shoulders', exercises: [
        PresetExercise(name: 'オーバーヘッドP', part: 'shoulders', meta: 'バーベル・コンパウンド'),
        PresetExercise(name: 'ラテラルレイズ', part: 'shoulders', meta: 'ダンベル・アイソレーション'),
        PresetExercise(name: 'フロントレイズ', part: 'shoulders', meta: 'ダンベル・アイソレーション'),
      ]),
      PresetFolder(label: '体幹', part: 'core', exercises: [
        PresetExercise(name: 'クランチ', part: 'core', meta: '自重・アイソレーション',
            inputType: 'repsOnly', unit1: '', unit2: 'rep'),
        PresetExercise(name: 'プランク', part: 'core', meta: '自重・コンパウンド',
            inputType: 'timeOnly', unit1: '', unit2: 'min'),
        PresetExercise(name: 'レッグレイズ', part: 'core', meta: '自重・アイソレーション',
            inputType: 'repsOnly', unit1: '', unit2: 'rep'),
      ]),
    ];
