import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/Anniversary.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}
