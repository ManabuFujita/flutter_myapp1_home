import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoRepository {
  final anniversariesManager = FirebaseFirestore.instance.collection('todos');

  ///
  /// データを取得する
  ///
  // Future<List<QueryDocumentSnapshot<Anniversary>>> getAnniversaries() async {
  //   final dataRef = anniversariesManager.withConverter<Anniversary>(
  //       fromFirestore: (snapshot, _) => Anniversary.fromJson(snapshot.data()!),
  //       toFirestore: (school, _) => school.toJson());
  //   final dataSnapshot = await dataRef.get();
  //   return dataSnapshot.docs;
  // }

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
  Future<String> insert(Todo todo) async {
    final data = await anniversariesManager.add(todo.toJson());
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
  Future<void> delete(Todo todo) async {
    await anniversariesManager
        .where('userId', isEqualTo: todo.userId)
        .where('id', isEqualTo: todo.id)
        .get()
        .then(
          // 取得したdocIDを使ってドキュメント削除
          (QuerySnapshot snapshot) => {
            snapshot.docs.forEach((f) {
              anniversariesManager.doc(f.reference.id).delete();
            }),
          },
        );
  }
}
