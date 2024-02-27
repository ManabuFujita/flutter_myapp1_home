import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/screens/home.dart';
import 'package:flutter_myapp1_home/widgets/anniversary_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Anniversary.dart';
import '../constants/colors.dart';
import '../widgets/anniversary_item.dart';
import '../repository/anniversaryRepository.dart';

class AnniversaryPage extends ConsumerStatefulWidget {
  const AnniversaryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends ConsumerState<AnniversaryPage> {
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
            .collection('anniversaries')
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
          List<Anniversary> anniversaries = snapshot.data!.docs.map((doc) {
            // スナップショットから Anniversary オブジェクトのリストを作成
            Anniversary anni =
                Anniversary.fromJson(doc.data() as Map<String, dynamic>);

            // return Anniversary.fromJson(doc.data() as Map<String, dynamic>);

            return anni;
          }).toList();

          // daynumver順にソートする
          List<Anniversary> anniversariesSorted = anniversaries
            ..sort((a, b) => a.restDays().compareTo(b.restDays()));

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
                                  'Anniversary',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              for (Anniversary item in anniversariesSorted)
                                AnniversaryItem(
                                  anniversary: item,
                                  onAnniversaryChanged:
                                      _handleAnniversaryChange,
                                  onDeleteItem: _deleteAnniversaryItem,
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
                      return AnniversaryAddPage();
                    }),
                  );
                },
                child: Icon(Icons.add),
              ),
              drawer: BuildDrawer());
        });
  }

  void _handleAnniversaryChange(Anniversary anniversary) {
    setState(() {
      anniversary.isHuman = !anniversary.isHuman;
    });
  }

  void _deleteAnniversaryItem(Anniversary anniversary) async {
    // setState(() {
    //   aniversariesList.removeWhere((item) => item.id == id);
    // });

    // DB保存
    AnniversaryRepository anniversaryRepository = AnniversaryRepository();
    await anniversaryRepository.delete(anniversary);
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

class AnniversaryAddPage extends StatefulWidget {
  @override
  State<AnniversaryAddPage> createState() => _AnniversaryAddPageState();
}

class _AnniversaryAddPageState extends State<AnniversaryAddPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  String _inputText = '';

  final _textController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _radioValue = '誕生日';

  @override
  void initState() {
    _selectedDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // *** 追加する部分 ***
      appBar: AppBar(
        title: Text('新規登録'),
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
              title: Text('誕生日'),
              leading: Radio<String>(
                value: '誕生日',
                groupValue: _radioValue,
                onChanged: (String? value) {
                  setState(() {
                    _radioValue = value!;
                  });
                },
                autofocus: true,
              ),
            ),
            ListTile(
                tileColor: Colors.blue,
                title: Text('記念日'),
                leading: Radio<String>(
                  value: '記念日',
                  groupValue: _radioValue,
                  onChanged: (String? value) {
                    setState(() {
                      _radioValue = value!;
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
                        hintText: 'Add a new Anniversary item',
                        border: InputBorder.none),
                  ),
                ),
              ),
              // カレンダー用のボタン
              Row(
                children: [
                  Text(
                    '${getCalenderLabel()}:',
                    style: TextStyle(fontSize: 20),
                  ),
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
                  _addAnniversaryItem(_textController.value.text);
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

  String getCalenderLabel() {
    return _radioValue == '誕生日' ? '生年月日' : '記念日';
  }

  void _onRadioChanged(String value) {
    setState(() {
      _radioValue = value;
    });
  }

  void _addAnniversaryItem(String name) async {
    Anniversary anniversary = Anniversary(
        userId: userId,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        date: _selectedDate,
        dayNumber:
            _selectedDate.difference(DateTime(_selectedDate.year, 1, 1)).inDays,
        isHuman: _radioValue == '誕生日' ? true : false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    // DB保存
    AnniversaryRepository anniversaryRepository = AnniversaryRepository();
    await anniversaryRepository.insert(anniversary);

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
}
