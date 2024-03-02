import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/Anniversary.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_time_patterns.dart';

class ZaikoRepository {
  final zaikosManager = FirebaseFirestore.instance.collection('zaikos');

  ///
  /// データを取得する
  ///
  Future<List<QueryDocumentSnapshot<Zaiko>>> getAnniversaries() async {
    final dataRef = zaikosManager.withConverter<Zaiko>(
        fromFirestore: (snapshot, _) => Zaiko.fromJson(snapshot.data()!),
        toFirestore: (school, _) => school.toJson());
    final dataSnapshot = await dataRef.get();
    return dataSnapshot.docs;
  }

  // Future<Map<String, dynamic>> getAnniversaries(String userId) async {
  //   anniversariesManager.doc(userId).get().then(
  //     (DocumentSnapshot doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       // ...
  //       return data;
  //     },
  //     onError: (e) => print("Error getting document: $e"),
  //   );
  //   return {};
  // }

  ///
  /// データを保存する
  ///
  Future<String> insert(Zaiko zaiko) async {
    final data = await zaikosManager.add(zaiko.toJson());
    return data.id;
  }

  // データを更新する
  Future<void> update(Zaiko zaiko) async {
    await zaikosManager
        .where('userId', isEqualTo: zaiko.userId)
        .where('productId', isEqualTo: zaiko.productId)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikosManager.doc(f.reference.id).update(zaiko.toJson());
            }),
          },
        );
  }

  // Future insert(Anniversary anniversary, String userId) async {
  //   await anniversariesManager
  //       .doc(userId)
  //       .set(anniversary.toJson(), SetOptions(merge: true))
  //       .onError((e, _) => print("Error writing document: $e"));
  // }

  ///
  /// データを削除する
  ///
  Future<void> delete(Zaiko zaiko) async {
    await zaikosManager
        .where('userId', isEqualTo: zaiko.userId)
        .where('productId', isEqualTo: zaiko.productId)
        .get()
        .then(
          // 取得したdocIDを使ってドキュメント削除
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikosManager.doc(f.reference.id).delete();
            }),
          },
        );
  }

  ///
  /// 個数を減らす
  ///
  Future<void> decrement(Zaiko zaiko) async {
    String oldestId = await getOldestLimitDateId(zaiko);

    await zaikosManager
        .where('userId', isEqualTo: zaiko.userId)
        .where('productId', isEqualTo: zaiko.productId)
        .get()
        .then(
          // 取得したデータのhistoriesから、historyIdが一致する配列のisUsedをtrueに変更
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              var histories = f['histories'];

              for (var i = 0; i < histories.length; i++) {
                if (histories[i]['historyId'] == oldestId) {
                  histories[i]['isUsed'] = true;
                  histories[i]['usedDate'] = DateTime.now();
                }
              }

              zaikosManager.doc(f.reference.id).update({
                'histories': histories,
              });
            }),
          },
        );
  }

  // 未使用の中で、一番古いlimitDateを持つhistoryIdを返す
  Future<String> getOldestLimitDateId(Zaiko zaiko) async {
    DateTime oldestLimitDate = DateTime.now().add(Duration(days: 365 * 50));
    String oldestId = '';
    await zaikosManager
        .where('userId', isEqualTo: zaiko.userId)
        .where('productId', isEqualTo: zaiko.productId)
        .get()
        .then(
          // 取得したデータのhistoriesから、historyIdが一致する配列のisUsedをtrueに変更
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              var histories = f['histories'];

              for (var i = 0; i < histories.length; i++) {
                if (!histories[i]['isUsed']) {
                  var limitDate =
                      (histories[i]['limitDate']! as Timestamp).toDate();
                  if (oldestLimitDate.isAfter(limitDate)) {
                    // 他のデータのほうが古い日付
                    oldestLimitDate = limitDate;
                    oldestId = histories[i]['historyId'];
                  }
                }
              }
            }),
          },
        );
    return oldestId;
  }

  // 全ユーザーの中から、同じjancodeを持つ商品を取得し、その中で一番多いnameを3つ返す
  Future<List<String>> getPopularNames(String jancode) async {
    Map<String, int> nameCountMap = {};
    await zaikosManager.where('jancode', isEqualTo: jancode).get().then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              var name = f['name'];
              if (nameCountMap.containsKey(name)) {
                nameCountMap[name] = nameCountMap[name]! + 1;
              } else {
                nameCountMap[name] = 1;
              }
            }),
          },
        );

    // MapをListに変換し、多い順に並び替え
    List<MapEntry<String, int>> sortedList = nameCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 上位3つを返す
    List<String> popularNames = [];
    for (var i = 0; i < 3; i++) {
      if (i < sortedList.length) {
        popularNames.add(sortedList[i].key);
      }
    }
    return popularNames;
  }
}
