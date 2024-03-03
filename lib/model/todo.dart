import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String userId;
  String id;
  String todoText;
  bool isDone;
  DateTime nextDate;

  // 月に2回の場合は、scheduleBaseに"month"、scheduleIntervalに2を設定
  String scheduleBase;
  int scheduleInterval;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Todo({
    required this.userId,
    required this.id,
    required this.todoText,
    required this.isDone,
    required this.nextDate,
    required this.scheduleBase,
    required this.scheduleInterval,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  //Firebaseからデータを取得する際の変換処理
  Todo.fromJson(Map<String, Object?> json)
      : this(
            userId: json['userId']! as String,
            id: json['id']! as String,
            todoText: json['todoText']! as String,
            isDone: json['isDone']! as bool,
            nextDate: (json['nextDate']! as Timestamp).toDate() as DateTime,
            scheduleBase: json['scheduleBase']! as String,
            scheduleInterval: json['scheduleInterval']! as int,
            createdAt: (json['createdAt']! as Timestamp).toDate() as DateTime,
            updatedAt: (json['updatedAt']! as Timestamp).toDate() as DateTime,
            deletedAt:
                (json['deletedAt'] as Timestamp?)?.toDate() as DateTime?);

  // DartのオブジェクトからFirebaseへ渡す際の変換処理
  Map<String, Object?> toJson() {
    Timestamp? deletedTimestamp;
    if (deletedAt != null) {
      deletedTimestamp = Timestamp.fromDate(deletedAt!);
    }
    return {
      'userId': userId,
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
      'nextDate': Timestamp.fromDate(nextDate),
      'scheduleBase': scheduleBase,
      'scheduleInterval': scheduleInterval,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedTimestamp,
    };
  }

  int restDays() {
    int todaysDayNumber =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    var restDays =
        nextDate.difference(DateTime(DateTime.now().year, 1, 1)).inDays -
            todaysDayNumber;
    if (restDays < 0) {
      restDays = 365 + restDays;
    }
    return restDays;
  }
}
