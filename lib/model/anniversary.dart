import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/anniversaryRepository.dart';

class Anniversary {
  String userId;
  String id;
  String name;
  DateTime date;
  int dayNumber;
  bool isHuman;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Anniversary({
    required this.userId,
    required this.id,
    required this.name,
    required this.date,
    required this.dayNumber,
    this.isHuman = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static List<Anniversary> anniversaryList() {
    return [
      // Anniversary(
      //     id: '01',
      //     name: 'Marriage Anniversary',
      //     date: DateTime(2018, 01, 01),
      //     isHuman: false),
      // Anniversary(
      //     id: '02',
      //     name: 'Manabu',
      //     date: DateTime(1991, 08, 30),
      //     isHuman: true),
    ];
  }

  //Firebaseからデータを取得する際の変換処理
  Anniversary.fromJson(Map<String, Object?> json)
      : this(
            userId: json['userId']! as String,
            id: json['id']! as String,
            name: json['name']! as String,
            date: (json['date']! as Timestamp).toDate() as DateTime,
            dayNumber: json['dayNumber'] as int,
            isHuman: json['isHuman']! as bool,
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
      'name': name,
      'date': Timestamp.fromDate(date), //DartのDateTimeからFirebaseのTimestampへ変換
      'dayNumber': date
          .difference(DateTime(date.year, 1, 1))
          .inDays, // dateと同年の1/1からの経過日数
      'isHuman': isHuman,
      'createdAt':
          Timestamp.fromDate(createdAt), //DartのDateTimeからFirebaseのTimestampへ変換
      'updatedAt':
          Timestamp.fromDate(updatedAt), //DartのDateTimeからFirebaseのTimestampへ変換
      'deletedAt': deletedTimestamp
    };
  }

  int restDays() {
    int todaysDayNumber =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    var restDays = dayNumber - todaysDayNumber;
    if (restDays < 0) {
      restDays = 365 + restDays;
    }
    return restDays;
  }
}
