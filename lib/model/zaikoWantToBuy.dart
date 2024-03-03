import 'package:cloud_firestore/cloud_firestore.dart';

class ZaikoWantToBuy {
  String userId;
  String name;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  ZaikoWantToBuy({
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  //Firebaseからデータを取得する際の変換処理
  ZaikoWantToBuy.fromJson(Map<String, Object?> json)
      : this(
          userId: json['userId']! as String,
          name: json['name']! as String,
          createdAt: (json['createdAt']! as Timestamp).toDate() as DateTime,
          updatedAt: (json['updatedAt']! as Timestamp).toDate() as DateTime,
          deletedAt: (json['deletedAt'] as Timestamp?)?.toDate() as DateTime?,
        );

  // DartのオブジェクトからFirebaseへ渡す際の変換処理
  Map<String, Object?> toJson() {
    Timestamp? deletedTimestamp;
    if (deletedAt != null) {
      deletedTimestamp = Timestamp.fromDate(deletedAt!);
    }
    return {
      'userId': userId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedTimestamp,
    };
  }
}
