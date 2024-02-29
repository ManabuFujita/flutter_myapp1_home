import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import 'package:flutter_myapp1_home/repository/zaikoRepository.dart';
import 'package:flutter_myapp1_home/screens/home.dart';
import 'package:flutter_myapp1_home/widgets/anniversary_item.dart';
import 'package:flutter_myapp1_home/widgets/zaiko_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Anniversary.dart';
import '../constants/colors.dart';
import '../widgets/anniversary_item.dart';
import '../repository/anniversaryRepository.dart';

class ZaikoPage extends ConsumerStatefulWidget {
  const ZaikoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZaikoPage> createState() => _ZaikoPageState();
}

class _ZaikoPageState extends ConsumerState<ZaikoPage> {
  final aniversariesList = Anniversary.anniversaryList();
  // List<Anniversary> _foundAnniversary = [];
  final _anniversaryController = TextEditingController();

  final userId = FirebaseAuth.instance.currentUser!.uid;

  // final Stream<QuerySnapshot> _anniversariesStream = FirebaseFirestore.instance
  //     .collection('anniversaries')
  //     .where("userId", isEqualTo: userId)
  //     .snapshots();

  @override
  void initState() {
    // _foundAnniversary = aniversariesList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        // DBをリアルタイムで取得
        stream: FirebaseFirestore.instance
            .collection('zaikos')
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("Error snapshot.hasError");
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Error snapshot waiting");
            print("UserId: $userIdProvider");
            return const Text("Loading");
          }

          // DBから取得したデータを処理
          List<Zaiko> zaikos = snapshot.data!.docs.map((doc) {
            // スナップショットから Anniversary オブジェクトのリストを作成
            Zaiko zaiko = Zaiko.fromJson(doc.data() as Map<String, dynamic>);

            // return Anniversary.fromJson(doc.data() as Map<String, dynamic>);

            return zaiko;
          }).toList();

          // daynumver順にソートする
          // List<Anniversary> anniversariesSorted = zaikos
          //   ..sort((a, b) => a.restDays().compareTo(b.restDays()));

          return Scaffold(
              backgroundColor: tdBGColor,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: BuildAppBar(),
              ),
              body: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Column(
                      children: [
                        searchBox(),
                        Expanded(
                          child: ListView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 50,
                                  bottom: 20,
                                ),
                                child: const Text(
                                  'Zaiko',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              for (Zaiko item in zaikos)
                                ZaikoItem(
                                  zaiko: item,
                                  onAnniversaryChanged: _handleZaikoChange,
                                  onDeleteItem: _deleteZaikoItem,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // "push"で新規画面に遷移
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      // 遷移先の画面としてリスト追加画面を指定
                      return ZaikoAddPage();
                    }),
                  );
                },
                child: Icon(Icons.add),
              ),
              drawer: BuildDrawer());
        });
  }

  void _handleZaikoChange(Zaiko zaiko) {
    setState(() {
      // zaiko.isHuman = !zaiko.isHuman;
    });
  }

  void _deleteZaikoItem(Zaiko zaiko) async {
    // setState(() {
    //   aniversariesList.removeWhere((item) => item.id == id);
    // });

    // DB保存
    ZaikoRepository zaikoRepository = ZaikoRepository();
    await zaikoRepository.delete(zaiko);
  }

  // void _addAnniversaryItem(String name) async {
  //   // setState(() {
  //   //   aniversariesList.add(Anniversary(
  //   //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //   //       name: name,
  //   //       date: DateTime.now()));
  //   // });
  //   final user = ref.watch(userProvider);

  //   Anniversary anniversary = Anniversary(
  //       userId: user!.uid,
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       name: name,
  //       date: DateTime.now(),
  //       isHuman: false,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now());

  //   // DB保存
  //   AnniversaryRepository anniversaryRepository = AnniversaryRepository();
  //   await anniversaryRepository.insert(anniversary);

  //   _anniversaryController.clear();
  // }

  void _runFilter(String enteredKeyword) {
    List<Anniversary> results = [];
    if (enteredKeyword.isEmpty) {
      results = aniversariesList;
    } else {
      results = aniversariesList
          .where((item) =>
              item.name!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      // _foundAnniversary = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}

class ZaikoAddPage extends StatefulWidget {
  @override
  State<ZaikoAddPage> createState() => _ZaikoAddPageState();
}

class _ZaikoAddPageState extends State<ZaikoAddPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  String _inputText = '';

  final _textController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _radioValueStrictLimit = false;
  final _numberController = TextEditingController();

  @override
  void initState() {
    _selectedDate = DateTime.now();
    _numberController.text = '1';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // *** 追加する部分 ***
      appBar: AppBar(
        title: Text('zaiko新規登録'),
      ),
      // *** 追加する部分 ***
      body: Container(
        // 余白を付ける
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              tileColor: Colors.blue,
              title: Text('賞味期限'),
              leading: Radio<bool>(
                value: false,
                groupValue: _radioValueStrictLimit,
                onChanged: (bool? value) {
                  setState(() {
                    _radioValueStrictLimit = value ?? false;
                  });
                },
                autofocus: true,
              ),
            ),
            ListTile(
                tileColor: Colors.blue,
                title: Text('消費期限'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: _radioValueStrictLimit,
                  onChanged: (bool? value) {
                    setState(() {
                      _radioValueStrictLimit = value ?? false;
                    });
                  },
                )),

            const Row(children: [
              SizedBox(
                height: 40,
              )
            ]),
            // テキスト入力
            Row(children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                        hintText: 'Add a new Zaiko item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              // 個数選択
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                        hintText: 'Number', border: InputBorder.none),
                  ),
                ),
              ),
              // 個数増減用のボタン
              Row(
                children: [
                  Column(
                    children: [
                      // numcontrollerの値を増やすボタン
                      ElevatedButton(
                        onPressed: () {
                          // numcontrollerの値を増やす
                          _numberController.text =
                              (int.parse(_numberController.text) + 1)
                                  .toString();
                        },
                        child: const Text('+'),
                      ),
                      // numcontrollerの値を減らすボタン
                      ElevatedButton(
                        onPressed: () {
                          // numcontrollerの値を減らす
                          _numberController.text =
                              (int.parse(_numberController.text) - 1)
                                  .toString();
                        },
                        child: const Text('-'),
                      ),
                    ],
                  )
                ],
              ),
              // カレンダー用のボタン
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // カレンダー画面に遷移
                      _selectCalender(context);
                    },
                    child: Text(
                        '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 8),
            Container(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                // color: Colors.blue,
                onPressed: () {
                  // 追加処理
                  _addZaikoItem(_textController.value.text);
                  Navigator.of(context).pop();
                },
                child: Text('追加'),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // キャンセルボタン
              child: TextButton(
                // ボタンをクリックした時の処理
                onPressed: () {
                  // "pop"で前の画面に戻る
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addZaikoItem(String name) async {
    final now = new DateTime.now();
    final productId = now.millisecondsSinceEpoch.toString();

    // numcontroller分のhistory listを作成
    List<History> histories = [];
    for (var i = 0; i < int.parse(_numberController.text); i++) {
      History history = newHistory(productId, now, _selectedDate);
      histories.add(history);
    }

    Zaiko zaiko = Zaiko(
        userId: userId,
        productId: productId,
        name: name,
        code: 'code',
        lastBuyDate: now,
        isStrictLimit: _radioValueStrictLimit,
        histories: histories,
        createdAt: now,
        updatedAt: now,
        deletedAt: null);

    // DB保存
    ZaikoRepository zaikoRepository = ZaikoRepository();
    await zaikoRepository.insert(zaiko);

    // クリア
    _textController.clear();
  }

  Future<void> _selectCalender(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // 最初に表示する日付
      firstDate: DateTime(1900), // 選択できる日付の最小値
      lastDate: DateTime(2101), // 選択できる日付の最大値
    );

    if (picked != null) {
      setState(() {
        // 選択された日付を変数に代入
        _selectedDate = picked;
      });
    }
  }

  History newHistory(String productId, DateTime now, DateTime limitDate) {
    return History(
      productId: productId,
      isUsed: false,
      buyDate: now,
      limitDate: limitDate,
      useDate: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }
}
