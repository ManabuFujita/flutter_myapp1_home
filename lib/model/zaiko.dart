import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/anniversaryRepository.dart';

class Zaiko {
  String userId;
  String productId;

  String name;
  String code;
  DateTime lastBuyDate;
  bool isStrictLimit;
  String unitName;

  List<History> histories;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  Zaiko({
    required this.userId,
    required this.productId,
    required this.name,
    required this.code,
    required this.lastBuyDate,
    required this.isStrictLimit,
    required this.unitName,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static List<Zaiko> zaikoList() {
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
  Zaiko.fromJson(Map<String, Object?> json)
      : this(
            userId: json['userId']! as String,
            productId: json['productId']! as String,
            name: json['name']! as String,
            code: json['code']! as String,
            lastBuyDate:
                (json['lastBuyDate']! as Timestamp).toDate() as DateTime,
            isStrictLimit: json['isStrictLimit']! as bool,
            histories: (json['histories']! as List)
                .map((e) => History.fromJson(e as Map<String, Object?>))
                .toList(),
            unitName: json['unitName']! as String,
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
      'productId': productId,
      'name': name,
      'code': code,
      'lastBuyDate': Timestamp.fromDate(lastBuyDate),
      'isStrictLimit': isStrictLimit,
      'histories': histories.map((e) => e.toJson()).toList(),
      'unitName': unitName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedTimestamp,
    };
  }

  // 残り個数
  int restNumber() {
    int restNum = 0;
    for (var i = 0; i < histories.length; i++) {
      if (histories[i].isUsed == false) {
        restNum++;
      }
    }
    return restNum;
  }

  // histriesから、buydateとusedateの差分の平均を返す
  double averageUseDays() {
    int restDays = 0;
    int restNum = 0;
    for (var i = 0; i < histories.length; i++) {
      if (histories[i].isUsed) {
        restDays +=
            histories[i].buyDate.difference(histories[i].useDate!).inDays;
        restNum++;
      }
    }
    return restDays / restNum;
  }

  // histriesから、buydateとlimitdateの差分の平均を返す
  double averageLimitDays() {
    int limitDays = 0;
    int limitNum = 0;
    for (var i = 0; i < histories.length; i++) {
      limitDays +=
          histories[i].buyDate.difference(histories[i].limitDate).inDays;
      limitNum++;
    }
    return limitDays / limitNum;
  }

  // histriesから、isUsed==falseで最古のlimitdateを返す
  DateTime nearestLimitDate() {
    DateTime oldestDate = DateTime.now().add(Duration(days: 365 * 50));
    for (var i = 0; i < histories.length; i++) {
      if (!histories[i].isUsed) {
        if (oldestDate.isAfter(histories[i].limitDate)) {
          oldestDate = histories[i].limitDate;
        }
      }
    }
    return oldestDate;
  }

  // historiesから、limitDateと個数のmapを返す
  Map<DateTime, int> unusedlimitDateRestNumMap() {
    Map<DateTime, int> limitDateMap = {};
    for (var i = 0; i < histories.length; i++) {
      var limitDate = histories[i].limitDate;
      if (!histories[i].isUsed) {
        if (limitDateMap.containsKey(limitDate)) {
          limitDateMap[limitDate] = limitDateMap[limitDate]! + 1;
        } else {
          limitDateMap[limitDate] = 1;
        }
      }
    }
    return limitDateMap;
  }

  // int restDays() {
  //   int todaysDayNumber =
  //       DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  //   var restDays = dayNumber - todaysDayNumber;
  //   if (restDays < 0) {
  //     restDays = 365 + restDays;
  //   }
  //   return restDays;
  // }
}

class History {
  String productId;
  String historyId;

  bool isUsed;
  DateTime buyDate;
  DateTime limitDate;
  DateTime? useDate;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  History({
    required this.productId,
    required this.historyId,
    required this.isUsed,
    required this.buyDate,
    required this.limitDate,
    this.useDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  //Firebaseからデータを取得する際の変換処理
  History.fromJson(Map<String, Object?> json)
      : this(
            productId: json['productId']! as String,
            historyId: json['historyId']! as String,
            isUsed: json['isUsed']! as bool,
            buyDate: (json['buyDate']! as Timestamp).toDate() as DateTime,
            limitDate: (json['limitDate']! as Timestamp).toDate() as DateTime,
            useDate: (json['useDate'] as Timestamp?)?.toDate() as DateTime?,
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
      'productId': productId,
      'historyId': historyId,
      'isUsed': isUsed,
      'buyDate': Timestamp.fromDate(buyDate),
      'limitDate': Timestamp.fromDate(limitDate),
      'useDate': useDate != null ? Timestamp.fromDate(useDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedTimestamp,
    };
  }
}
