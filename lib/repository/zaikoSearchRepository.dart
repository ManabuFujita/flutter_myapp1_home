import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import 'package:flutter_myapp1_home/model/zaikoSearch.dart';

class ZaikoSearchRepository {
  final zaikoSearchManager =
      FirebaseFirestore.instance.collection('zaikoSearches');

  // データを取得する
  // Future<List<QueryDocumentSnapshot<ZaikoSearch>>> getZaikoSearches() async {
  //   final dataRef = zaikoSearchManager.withConverter<ZaikoSearch>(
  //       fromFirestore: (snapshot, _) => ZaikoSearch.fromJson(snapshot.data()!),
  //       toFirestore: (zaikoSearch, _) => zaikoSearch.toJson());
  //   final dataSnapshot = await dataRef.get();
  //   return dataSnapshot.docs;
  // }

  // ユーザーの検索履歴を、指定個数分、searchCountの多い順に取得する
  Future<Map<String, ZaikoSearch>> _getZaikoSearchesMap(String userId,
      {int limitCount = 999}) async {
    Map<String, ZaikoSearch> zaikoSearchMap = {};

    await zaikoSearchManager
        .where('userId', isEqualTo: userId)
        // .orderBy('searchCount', descending: true)
        // .limit(limitCount)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikoSearchMap[f.reference.id] =
                  ZaikoSearch.fromJson(f.data() as Map<String, Object?>);
            }),
          },
        );

    return zaikoSearchMap;
  }

  // zaikoSearchListから検索ワードのリストを作成
  Future<List<String>> getSearchWordsList(String userId, int limitCount) async {
    Map<String, ZaikoSearch> zaikoSearchMap =
        await _getZaikoSearchesMap(userId, limitCount: limitCount);

    List<String> searchWordsList = [];
    zaikoSearchMap.forEach((docId, zaikoSearch) {
      searchWordsList.add(zaikoSearch.searchWord);
    });

    return searchWordsList;
  }

  // ユーザーidから、searhWordを検索して、見つかれば検索回数を更新する。見つからなければ新規登録する
  Future<void> updateSearchCount(String userId, String searchWord) async {
    Map<String, ZaikoSearch> zaikoSearchMap =
        await _getZaikoSearchesMap(userId);
    bool isExist = false;

    zaikoSearchMap.forEach((docId, zaikoSearch) {
      if (zaikoSearch.searchWord == searchWord) {
        isExist = true;
        // ユーザーidとsearchWordが一致するデータを更新
        zaikoSearchManager.doc(docId).update({
          'searchCount': zaikoSearch.searchCount + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    });

    if (!isExist) {
      zaikoSearchManager.add({
        'userId': userId,
        'searchWord': searchWord,
        'searchCount': 1,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  // データを更新する
  Future<void> update(Zaiko zaiko) async {
    await zaikoSearchManager
        .where('userId', isEqualTo: zaiko.userId)
        .get()
        .then(
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikoSearchManager.doc(f.reference.id).update(zaiko.toJson());
            }),
          },
        );
  }

  // データを削除する
  Future<void> delete(Zaiko zaiko) async {
    await zaikoSearchManager
        .where('userId', isEqualTo: zaiko.userId)
        .where('productId', isEqualTo: zaiko.productId)
        .get()
        .then(
          // 取得したdocIDを使ってドキュメント削除
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              zaikoSearchManager.doc(f.reference.id).delete();
            }),
          },
        );
  }
}
