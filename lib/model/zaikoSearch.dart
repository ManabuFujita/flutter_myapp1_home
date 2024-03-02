import 'package:cloud_firestore/cloud_firestore.dart';

class ZaikoSearch {
  String userId;
  String searchWord;
  int searchCount;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  ZaikoSearch({
    required this.userId,
    required this.searchWord,
    required this.searchCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  //Firebaseからデータを取得する際の変換処理
  ZaikoSearch.fromJson(Map<String, Object?> json)
      : this(
            userId: json['userId']! as String,
            searchWord: json['searchWord']! as String,
            searchCount: json['searchCount']! as int,
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
      'searchWord': searchWord,
      'searchCount': searchCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedTimestamp,
    };
  }
}
