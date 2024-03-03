import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_myapp1_home/model/zaikoWantToBuy.dart';

class ZaikoWantToBuyRepository {
  final ZaikoWantToBuyManager =
      FirebaseFirestore.instance.collection('zaikoWantToBuys');

  // データの取得
  Future<List<ZaikoWantToBuy>> getZaikoWantToBuysList(String userId) async {
    List<ZaikoWantToBuy> zaikoWantToBuyList = [];

    await ZaikoWantToBuyManager.where('userId', isEqualTo: userId)
        // .orderBy('searchCount', descending: true)
        // .limit(limitCount)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikoWantToBuyList.add(
                  ZaikoWantToBuy.fromJson(f.data() as Map<String, Object?>));
            }),
          },
        );

    return zaikoWantToBuyList;
  }

  // データがあるか検索して、なければ新規登録する
  Future<void> insert(ZaikoWantToBuy zaikoWantToBuy) async {
    await ZaikoWantToBuyManager.where('userId',
            isEqualTo: zaikoWantToBuy.userId)
        .where('name', isEqualTo: zaikoWantToBuy.name)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            if (snapshot.docs.isEmpty)
              {
                ZaikoWantToBuyManager.add(zaikoWantToBuy.toJson()),
              },
          },
        );
  }

  // データの有無を返す
  Future<bool> isExist(String userId, String name) async {
    bool isExist = false;
    await ZaikoWantToBuyManager.where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            if (snapshot.docs.isNotEmpty) {isExist = true},
          },
        );
    return isExist;
  }

  // データを削除する
  Future<void> delete(String userId, String name) async {
    await ZaikoWantToBuyManager.where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              ZaikoWantToBuyManager.doc(f.reference.id).delete();
            }),
          },
        );
  }
}
