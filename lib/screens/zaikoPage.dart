import 'package:flutter/material.dart';
// import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/yahooProduct.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import 'package:flutter_myapp1_home/model/zaikoWantToBuy.dart';
// import 'package:flutter_myapp1_home/model/zaikoSearch.dart';
import 'package:flutter_myapp1_home/repository/zaikoRepository.dart';
import 'package:flutter_myapp1_home/repository/zaikoSearchRepository.dart';
import 'package:flutter_myapp1_home/repository/zaikoWantToBuyRepository.dart';
import 'package:flutter_myapp1_home/screens/home.dart';
// import 'package:flutter_myapp1_home/widgets/anniversary_item.dart';
import 'package:flutter_myapp1_home/widgets/zaiko_item.dart';
import 'package:flutter_myapp1_home/widgets/zaiko_want_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// import '../model/Anniversary.dart';
import '../constants/colors.dart';
// import '../widgets/anniversary_item.dart';
// import '../repository/anniversaryRepository.dart';
// import 'package:http/http.dart' as http;

class ZaikoPage extends ConsumerStatefulWidget {
  const ZaikoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZaikoPage> createState() => _ZaikoPageState();
}

class _ZaikoPageState extends ConsumerState<ZaikoPage> {
  // final aniversariesList = Anniversary.anniversaryList();
  // List<Anniversary> _foundAnniversary = [];

  final _textSearchWantController = TextEditingController();
  bool _isShopping = false;

  late String userId;

  // final Stream<QuerySnapshot> _anniversariesStream = FirebaseFirestore.instance
  //     .collection('anniversaries')
  //     .where("userId", isEqualTo: userId)
  //     .snapshots();
  ZaikoSearchRepository zaikoSearchRepository = ZaikoSearchRepository();
  ZaikoWantToBuyRepository zaikoWantToBuyRepository =
      ZaikoWantToBuyRepository();

  List<ZaikoList> _zaikoLists = [];
  List<String> _zaikoListSearches = [];
  List<ZaikoWantToBuy> _zaikoWantToBuyList = [];

  //   final userProvider = StateProvider((ref) {
  //   return _zaikoLists;
  // });

  @override
  void initState() {
    // _foundAnniversary = aniversariesList;
    _textSearchWantController.text = '';
    _isShopping = false;

    userId = FirebaseAuth.instance.currentUser!.uid;

    Future(() async {
      _zaikoListSearches =
          await zaikoSearchRepository.getSearchWordsList(userId, 5);

      _zaikoWantToBuyList =
          await zaikoWantToBuyRepository.getZaikoWantToBuysList(userId);
    });

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
            // return const Text("Loading");
            // return Container(
            //     alignment: Alignment.center,
            //     child: const CircularProgressIndicator(
            //       color: Colors.green,
            //     ));

            if (snapshot.data == null) {
              return Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: Colors.green,
                  ));
            }
          }

          // DBから取得したsnapshotデータを処理
          makeZaikoList(snapshot);

          // 在庫リストの欲しいもの
          var hasZaikoWantItem =
              _zaikoLists.any((element) => element.zaiko.isWantToBuy);

          // 在庫にない欲しいもの
          var hasWantList = _zaikoWantToBuyList.isNotEmpty;

          // 全ての欲しいもの
          var hasWant = hasZaikoWantItem || hasWantList;

          // ZaikoList作成

          var lists = [
            //　欲しいものリストがある場合のみ表示
            hasWant
                ? Container(
                    margin: const EdgeInsets.only(
                      top: 50,
                      bottom: 20,
                    ),
                    child: const Text(
                      '買いたいものリスト',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Container(),
            // zaikoWantToBuyListを表示
            for (ZaikoWantToBuy item in _zaikoWantToBuyList)
              ZaikoWantItem(name: item.name),

            // zaikolistの数だけ、isWantToBuyがtrueのものを表示
            for (ZaikoList item in _zaikoLists)
              if (item.zaiko.isWantToBuy)
                ZaikoItem(
                  zaiko: item.zaiko,
                  restNumber: item.restNumber,
                  limitDate: item.limitDate,
                  onDeleteItem: _deleteZaikoItem,
                  onUsedItem: _usedZaikoItem,
                  onSelectItem: _changeZaikoItem,
                  onWantItem: _toggleWantItem,
                  isWantItem: item.zaiko.isWantToBuy,
                  isShopping: _isShopping,
                  estimatedLimitDate: item.zaiko.estimatedLimitDate(),
                  selectedDate: item.zaiko.estimatedLimitDate(),
                  // onSelectCalender: _selectItemCalender,
                  limitCalenderDate: item.limitCalenderDate,
                  buyNumber: item.buyNumber,
                ),

            // 在庫リスト
            Container(
              margin: const EdgeInsets.only(
                top: 36,
                bottom: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '在庫リスト',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  _textSearchWantController.text != ''
                      ? Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () {
                                _clearFilter();
                              },
                              child: Text(
                                  'Filter: ${_textSearchWantController.text} ×')),
                        )
                      : Container(),
                ],
              ),
            ),

            // zaikolist
            for (ZaikoList item in _zaikoLists)
              ZaikoItem(
                zaiko: item.zaiko,
                restNumber: item.restNumber,
                limitDate: item.limitDate,
                onDeleteItem: _deleteZaikoItem,
                onUsedItem: _usedZaikoItem,
                onSelectItem: _changeZaikoItem,
                onWantItem: _toggleWantItem,
                isWantItem: item.zaiko.isWantToBuy,
                isShopping: _isShopping,
                estimatedLimitDate: item.zaiko.estimatedLimitDate(),
                selectedDate: item.zaiko.estimatedLimitDate(),
                // onSelectCalender: _selectItemCalender,
                limitCalenderDate: item.limitCalenderDate,
                buyNumber: item.buyNumber,
              ),
          ];

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
                        // 検索バー
                        searchBox(),

                        // 買い物中ボタン
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: _isShopping ? tdBlue : Colors.white,
                                onPrimary: _isShopping ? Colors.white : tdBlue,
                                side: BorderSide(color: tdBlue),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isShopping = !_isShopping;
                                });
                              },
                              child: Text(_isShopping ? '買い物中' : '買い物する'),
                            ),
                          ],
                        ),

                        // フィルターがかかっている場合のみ表示
                        _textSearchWantController.text != ''
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _clearFilter();
                                        },
                                        child: Text(
                                            'Filter: ${_textSearchWantController.text} ×')),
                                  ),
                                ],
                              )
                            : Container(),

                        Expanded(
                          child: ListView(
                            children: lists,
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

  // zaikoItems(BuildContext context) {
  //   _zaikoLists.forEach((item) => ZaikoItem(
  //         zaiko: item.zaiko,
  //         restNumber: item.restNumber,
  //         limitDate: item.limitDate,
  //         onDeleteItem: _deleteZaikoItem,
  //         onUsedItem: _usedZaikoItem,
  //         onSelectItem: _changeZaikoItem,
  //         onWantItem: _toggleWantItem,
  //         isWantItem: item.zaiko.isWantToBuy,
  //         isShopping: _isShopping,
  //         estimatedLimitDate: item.zaiko.estimatedLimitDate(),
  //         selectedDate: item.zaiko.estimatedLimitDate(),
  //         onSelectCalender: _selectItemCalender,
  //         limitCalenderDate: item.limitCalenderDate,
  //       ));
  //   // Add a return statement at the end of the function
  //   // return Container();
  // }

  makeZaikoList(AsyncSnapshot<QuerySnapshot> snapshot) {
    _zaikoLists = snapshot.data!.docs.map((doc) {
      // スナップショットから Anniversary オブジェクトのリストを作成
      Zaiko zaiko = Zaiko.fromJson(doc.data() as Map<String, dynamic>);

      ZaikoList zaikoList = ZaikoList(
          zaiko: zaiko,
          restNumber: zaiko.restNumber(),
          limitDate: zaiko.nearestLimitDate(),
          limitCalenderDate: zaiko.nearestLimitDate(),
          buyNumber: 1);
      // return Anniversary.fromJson(doc.data() as Map<String, dynamic>);

      return zaikoList;
    }).toList();

    // limitdate降順にソートする
    // zaikos.sort((a, b) => b.limitDate.compareTo(a.limitDate));

    // limitdate昇順にソートする
    _zaikoLists.sort((a, b) => a.limitDate.compareTo(b.limitDate));

    // 検索バーのフィルター処理
    if (_textSearchWantController.text.isNotEmpty) {
      _zaikoLists = _zaikoLists
          .where((item) => item.zaiko!.name
              .toLowerCase()
              .contains(_textSearchWantController.text.toLowerCase()))
          .toList();
    }
  }

  void _deleteZaikoItem(Zaiko zaiko) async {
    // setState(() {
    //   aniversariesList.removeWhere((item) => item.id == id);
    // });

    // DB保存
    ZaikoRepository zaikoRepository = ZaikoRepository();
    await zaikoRepository.delete(zaiko);
  }

  void _usedZaikoItem(Zaiko zaiko) async {
    // setState(() {
    //   aniversariesList.removeWhere((item) => item.id == id);
    // });

    // DB保存
    ZaikoRepository zaikoRepository = ZaikoRepository();
    await zaikoRepository.decrement(zaiko);
  }

  // Future<void> _selectItemCalender(
  //     BuildContext context, ZaikoItem zaikoItem, DateTime selectedDate) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate, // 最初に表示する日付
  //     firstDate: DateTime(1900), // 選択できる日付の最小値
  //     lastDate: DateTime(2101), // 選択できる日付の最大値
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       // 選択された日付を変数に代入
  //       zaikoItem.limitCalenderDate = picked;
  //       // selectedDate = picked;
  //     });
  //   }
  // }

  void _changeZaikoItem(Zaiko zaiko) async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        // 遷移先の画面としてリスト追加画面を指定
        return ZaikoAddPage(zaiko: zaiko);
      }),
    );
  }

  void _toggleWantItem(Zaiko zaiko) async {
    // DB保存
    ZaikoRepository zaikoRepository = ZaikoRepository();
    if (zaiko.isWantToBuy) {
      await zaikoRepository.removeWant(zaiko);
    } else {
      await zaikoRepository.addWant(zaiko);
    }

    setState(() {
      // _textSearchWantController.text = '';
    });
  }

  void _setFilter(String enteredKeyword) {
    setState(() {
      _textSearchWantController.text = enteredKeyword;
    });
  }

  void _clearFilter() {
    setState(() {
      _textSearchWantController.text = '';
    });
  }

  void _updateSearchQuery(String newQuery) {
    if (newQuery == '') {
      return;
    }
    zaikoSearchRepository.updateSearchCount(userId, newQuery);
  }

  Widget searchBox() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Autocomplete(
              optionsBuilder: (textEdigingValue) {
                // if (textEdigingValue.text == '') {
                //   return const Iterable<String>.empty();
                // }
                return _zaikoListSearches
                    .where((option) => option.contains(textEdigingValue.text));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: _textSearchWantController,
                  onChanged: (value) => _setFilter(value),
                  onSubmitted: (value) => _updateSearchQuery(value),
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: tdBlack,
                      size: 20,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      maxHeight: 20,
                      minWidth: 25,
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          _clearFilter();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: tdBlack,
                          size: 20,
                        )),
                    suffixIconConstraints: const BoxConstraints(
                      maxHeight: 20,
                      minWidth: 25,
                    ),
                    border: InputBorder.none,
                    hintText: '検索 / 買いたいものを追加',
                    hintStyle: TextStyle(color: tdGrey),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: ElevatedButton(
            onPressed: () {
              // 追加処理
              _addWantItem();
            },
            child: Text('新しく買いたいものを追加'),
          ),
        ),
      ]),
    );
  }

  void _addWantItem() async {
    // zaikoListを検索して、なければzaikoWantToBuyに追加する
    ZaikoRepository zaikoRepository = ZaikoRepository();

    var hasZaiko = await zaikoRepository.isExistName(
        userId, _textSearchWantController.text);
    var hasWantList;

    if (hasZaiko) {
      // zaikoListにあれば、isWantToBuyをtrueに変更
      var productId = await zaikoRepository.getProductIdByName(
          userId, _textSearchWantController.text);
      var zaiko = await zaikoRepository.getZaikoByProductId(userId, productId);

      // zaikoのisWantToBuyをtrueに変更
      if (zaiko != null) {
        await zaikoRepository.addWant(zaiko);
      }
    } else {
      // 欲しいものリストに無ければ追加
      ZaikoWantToBuyRepository zaikoWantToBuyRepository =
          ZaikoWantToBuyRepository();
      hasWantList = await zaikoWantToBuyRepository.isExist(
          userId, _textSearchWantController.text);

      if (!hasWantList) {
        // zaikoWantToBuyに追加
        var zaikoWantToBuy = ZaikoWantToBuy(
          userId: userId,
          name: _textSearchWantController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await zaikoWantToBuyRepository.insert(zaikoWantToBuy);
      }
    }
  }

  // final List<String> _optionList = [
  //   "option1",
  //   "option2",
  //   "option3",
  //   "option4",
  //   "option5",
  // ];
}

class ZaikoList {
  Zaiko zaiko;
  int restNumber;
  DateTime limitDate;
  DateTime limitCalenderDate;
  int buyNumber;

  ZaikoList({
    required this.zaiko,
    required this.restNumber,
    required this.limitDate,
    required this.limitCalenderDate,
    required this.buyNumber,
  });
}

/// -------------------------------------
/// 新規追加ページ
/// -------------------------------------
class ZaikoAddPage extends StatefulWidget {
  final Zaiko? zaiko;

  const ZaikoAddPage({Key? key, this.zaiko}) : super(key: key);

  @override
  State<ZaikoAddPage> createState() => _ZaikoAddPageState();
}

class _ZaikoAddPageState extends State<ZaikoAddPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final _textNameController = TextEditingController();
  final _textCodeController = TextEditingController();
  final _textProductController = TextEditingController();
  final _textUnitNameController = TextEditingController();

  List<String> _kohoListFromUser = [];
  List<String> _kohoListFromYahoo = [];

  String code = '';

  Map<DateTime, int> _zaikoLimitDate = {};
  DateTime _selectedDate = DateTime.now();

  bool _radioValueStrictLimit = false;
  final _numberController = TextEditingController();

  Zaiko? zaiko;

  // 今日の日付を取得
  late DateTime _now;
  late DateTime _today;

  @override
  void initState() {
    zaiko = widget.zaiko;
    _now = DateTime.now();
    _today = DateTime(_now.year, _now.month, _now.day);

    if (zaiko == null) {
      _textNameController.text = '';
      _textCodeController.text = code;
      _textProductController.text = '';
      _radioValueStrictLimit = false;
      _zaikoLimitDate = {};
      _selectedDate = _today;
      _numberController.text = '1';
      _textUnitNameController.text = '';
    } else {
      _textNameController.text = zaiko!.name;
      _textCodeController.text = zaiko!.code;
      _textProductController.text = '';
      _radioValueStrictLimit = zaiko!.isStrictLimit;
      _zaikoLimitDate = zaiko!.unusedlimitDateRestNumMap();
      _selectedDate = _today;
      // _numberController.text = zaiko!.restNumber().toString();
      _numberController.text = '1';
      _textUnitNameController.text = zaiko!.unitName;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // *** 追加する部分 ***
      appBar: AppBar(
        title: Text(zaiko == null ? 'zaiko追加' : 'zaiko変更'),
      ),
      // *** 追加する部分 ***
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                // 余白を付ける
                padding: EdgeInsets.all(64),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 在庫情報
                      Container(
                        alignment: Alignment.topCenter,
                        // margin: const EdgeInsets.only(
                        //   bottom: 20,
                        //   // right: 20,
                        //   left: 20,
                        // ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        color: Color.fromARGB(255, 230, 230, 230),
                        width: 200,
                        // child: getZaikoInfo(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getZaikoInfo(),
                        ),
                      ),

                      // 余白
                      SizedBox(
                        width: 16,
                      ),

                      // 縦線
                      VerticalDivider(
                        width: 1,
                      ),

                      // 余白
                      SizedBox(
                        width: 16,
                      ),

                      // 入力フォーム
                      Expanded(
                        child: Container(
                          color: const Color.fromARGB(255, 230, 230, 230),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(children: [
                                SizedBox(
                                  height: 10,
                                )
                              ]),

                              // カメラアイコン、JANコード入力
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 20,
                                        // right: 20,
                                        left: 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        // vertical: 5,
                                      ),
                                      child: ElevatedButton(
                                        child: Icon(Icons.camera_alt_outlined,
                                            size: 40, color: Colors.grey),
                                        onPressed: () async {
                                          var code = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CameraPage(),
                                              ));
                                          setData(code);
                                        },
                                      ),
                                    ),
                                    inputLabel('バーコード'),
                                    Expanded(
                                        child: inputArea(_textCodeController,
                                            '商品のバーコード（任意）'))
                                  ]),

                              SizedBox(
                                height: 24,
                              ),

                              // 商品名入力
                              Row(children: [
                                inputLabel('商品名'),
                                Expanded(
                                    child: inputArea(
                                        _textNameController, '新しい商品名を追加'))
                              ]),

                              // 商品名の候補
                              getKoho(),

                              // 個数選択
                              Row(children: [
                                inputLabel('追加する個数'),
                                Expanded(
                                    child: inputArea(
                                        _numberController, '購入した個数を入力')),

                                Expanded(
                                  child: inputArea(
                                      _textUnitNameController, '単位',
                                      width: 60),
                                ),

                                // 個数増減用のボタン
                                Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                    // right: 20,
                                    // left: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      // horizontal: 20,
                                      // vertical: 5,
                                      ),
                                  child: Row(
                                    children: [
                                      // numcontrollerの値を減らすボタン
                                      ElevatedButton(
                                        style: OutlinedButton.styleFrom(
                                          primary: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          side: const BorderSide(
                                              color: Colors.grey),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            // numcontrollerの値を減らす
                                            _numberController.text = (int.parse(
                                                        _numberController
                                                            .text) -
                                                    1)
                                                .toString();
                                          });
                                        },
                                        child: const Text('-'),
                                      ),
                                      // numcontrollerの値を増やすボタン
                                      ElevatedButton(
                                        style: OutlinedButton.styleFrom(
                                          primary: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          side: const BorderSide(
                                              color: Colors.grey),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            // numcontrollerの値を増やす
                                            _numberController.text = (int.parse(
                                                        _numberController
                                                            .text) +
                                                    1)
                                                .toString();
                                          });
                                        },
                                        child: const Text('+'),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: SizedBox())
                              ]),

                              // 賞味期限/消費期限
                              Row(
                                children: [
                                  inputLabel('期限'),
                                  Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 20,
                                        right: 20,
                                        // left: 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        // vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // boxShadow: const [
                                        //   BoxShadow(
                                        //     color: Colors.grey,
                                        //     offset: Offset(0.0, 0.0),
                                        //     blurRadius: 10.0,
                                        //     spreadRadius: 0.0,
                                        //   ),
                                        // ],
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Radio<bool>(
                                            value: false,
                                            groupValue: _radioValueStrictLimit,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _radioValueStrictLimit =
                                                    value ?? false;
                                              });
                                            },
                                            autofocus: true,
                                          ),
                                          Text('賞味期限'),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Radio<bool>(
                                            value: true,
                                            groupValue: _radioValueStrictLimit,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _radioValueStrictLimit =
                                                    value ?? false;
                                              });
                                            },
                                          ),
                                          Text('消費期限'),

                                          SizedBox(
                                            width: 32,
                                          ),
                                          // カレンダー用のボタン
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  myNowCalenderButton, // background
                                              // foregroundColor: Colors.white, // foreground
                                            ),
                                            onPressed: () {
                                              // カレンダー画面に遷移
                                              _selectCalender(context);
                                            },
                                            child: Text(
                                                '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
                                          ),
                                        ],
                                      )),
                                  // 余白を埋める
                                  Expanded(child: SizedBox()),
                                ],
                              ),

                              // 追加ボタン
                              const SizedBox(height: 8),
                              Container(
                                // 横幅いっぱいに広げる
                                width: double.infinity,
                                // リスト追加ボタン
                                child: ElevatedButton(
                                  // color: Colors.blue,
                                  onPressed: () {
                                    // 追加処理
                                    _addZaikoItem(zaiko);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('追加'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget inputLabel(String labelName) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(
        bottom: 20,
        // right: 20,
        left: 20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: myLabelColor,
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.grey,
        //     offset: Offset(0.0, 0.0),
        //     blurRadius: 10.0,
        //     spreadRadius: 0.0,
        //   ),
        // ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(

            // labelText: '商品名',
            hintText: labelName,
            border: InputBorder.none),
      ),
    );
  }

  Widget inputArea(TextEditingController controller, String hint,
      {double width = 0}) {
    return Container(
      width: width > 0 ? 60 : null,
      margin: const EdgeInsets.only(
        bottom: 20,
        right: 20,
        // left: 20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.grey,
        //     offset: Offset(0.0, 0.0),
        //     blurRadius: 10.0,
        //     spreadRadius: 0.0,
        //   ),
        // ],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            // labelText: '商品名',
            hintText: hint,
            border: InputBorder.none),
      ),
      // child: Text('test')
    );
  }

  // 商品名の候補を表示するWidget
  Widget getKoho() {
    List<Widget> _kohoWidgetList = [];
    int listedCount = 0; // 既に表示した個数（全体で5個まで表示する）

    if (_kohoListFromUser.length > 0 || _kohoListFromYahoo.length > 0) {
      _kohoWidgetList.add(Text('おすすめ商品名（タップで選択）'));
    }

    // 全ユーザーの商品名からの候補
    _kohoListFromUser.forEach((element) {
      _kohoWidgetList.add(_getKohoListField(element));
      listedCount++;
    });

    // Yahooの商品名からの候補
    for (var i = 0; i < (_kohoListFromYahoo.length - listedCount); i++) {
      _kohoWidgetList.add(_getKohoListField(_kohoListFromYahoo[i]));
    }

    return _kohoWidgetList.length > 0
        ? Container(
            margin: EdgeInsets.only(left: 160, right: 20, bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _kohoWidgetList,
            ),
          )
        : Container();
  }

  _getKohoListField(String productName) {
    return TextFormField(
      initialValue: productName,
      readOnly: true,
      onTap: () {
        setState(() {
          _textNameController.text = productName;
          _kohoListFromYahoo = []; // クリアして表示させないようにする
        });
      },
    );
  }

  // _zaikoLimitDateの個数分の日付と個数のWidgetを作成
  List<Widget> getZaikoInfo() {
    List<Widget> _limitDateWidgetList = [];
    _limitDateWidgetList.add(Row(children: [Text('◆在庫')]));

    List<MapEntry<DateTime, int>> sortedList = _zaikoLimitDate.entries.toList();
    sortedList.sort((a, b) => (a.key as DateTime).compareTo(b.key as DateTime));

    sortedList.forEach((element) {
      _limitDateWidgetList.add(SizedBox(
        height: 10,
      ));
      _limitDateWidgetList.add(
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // カレンダー画面に遷移
                _selectCalender(context);
              },
              child: Text(
                  '${element.key.year}/${element.key.month}/${element.key.day}'),
            ),
            SizedBox(
              width: 8,
            ),
            Text('${element.value}個'),
          ],
        ),
      );
    });

    // 現在追加中の情報
    _limitDateWidgetList.add(SizedBox(height: 10));
    _limitDateWidgetList.add(Divider(height: 1));
    _limitDateWidgetList.add(SizedBox(height: 10));
    _limitDateWidgetList.add(Row(children: [Text('◆追加分')]));
    _limitDateWidgetList.add(getNewZaikoInfo());

    return _limitDateWidgetList;
  }

  Widget getNewZaikoInfo() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: myNowCalenderButton, // background
            // foregroundColor: Colors.white, // foreground
          ),
          onPressed: () {
            // カレンダー画面に遷移
            _selectCalender(context);
          },
          child: Text(
              '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
        ),
        SizedBox(
          width: 8,
        ),
        Text('${_numberController.text}個'),
      ],
    );
  }

  setData(String code) async {
    print(
        '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    final YahooProduct = YahooProductList(janCode: code);
    final productInfo = await YahooProduct.getProductList();
    final ProductNameFromUser = await ZaikoRepository().getPopularNames(code);

    setState(() {
      _textCodeController.text = code;
      _textProductController.text = productInfo[0].name;
      _kohoListFromYahoo = productInfo.map((e) => e.name).toList();
      _kohoListFromUser = ProductNameFromUser;
    });
  }

  void _addZaikoItem(Zaiko? zaiko) async {
    final now = new DateTime.now();
    var productId;

    if (zaiko == null) {
      // 新規追加
      productId = now.millisecondsSinceEpoch.toString();

      // numcontroller分のhistory listを作成
      List<History> histories = [];
      for (var i = 0; i < int.parse(_numberController.text); i++) {
        String historyId = now
            .add(Duration(milliseconds: i))
            .millisecondsSinceEpoch
            .toString();
        History history = newHistory(productId, historyId, now, _selectedDate);
        histories.add(history);
      }

      zaiko = Zaiko(
          userId: userId,
          productId: productId,
          name: _textNameController.text,
          code: _textCodeController.text,
          lastBuyDate: now,
          isStrictLimit: _radioValueStrictLimit,
          histories: histories,
          unitName: _textUnitNameController.text,
          isWantToBuy: false,
          createdAt: now,
          updatedAt: now,
          deletedAt: null);

      // DB追加
      ZaikoRepository zaikoRepository = ZaikoRepository();
      await zaikoRepository.insert(zaiko!);
    } else {
      // 更新
      productId = zaiko.productId;

      zaiko.name = _textNameController.text;
      zaiko.code = _textCodeController.text;
      zaiko.isStrictLimit = _radioValueStrictLimit;
      zaiko.unitName = _textUnitNameController.text;
      zaiko.updatedAt = now;

      // historiesの追加
      List<History> histories = zaiko.histories;
      for (var i = 0; i < int.parse(_numberController.text); i++) {
        String historyId = now
            .add(Duration(milliseconds: i))
            .millisecondsSinceEpoch
            .toString();
        History history = newHistory(productId, historyId, now, _selectedDate);
        histories.add(history);
      }

      // zaikoの更新
      zaiko.histories = histories;

      // DB更新
      ZaikoRepository zaikoRepository = ZaikoRepository();
      await zaikoRepository.update(zaiko!);
    }

    // クリア
    _textNameController.clear();
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

  History newHistory(String productId, String historyId, DateTime buyDate,
      DateTime limitDate) {
    return History(
      productId: productId,
      historyId: historyId,
      // isUsed: false,
      buyDate: buyDate,
      limitDate: limitDate,
      useDate: null,
      createdAt: buyDate,
      updatedAt: buyDate,
      deletedAt: null,
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  MobileScannerController cameraController = MobileScannerController();
  String scannedValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Scanner'),
        actions: [
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => {setState(() => cameraController.toggleTorch())},
          ),
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: MobileScanner(
                // controller: MobileScannerController(
                // detectionSpeed:
                //     DetectionSpeed.noDuplicates, // 同じ QR コードを連続でスキャンさせない
                // ),
                controller: MobileScannerController(
                    facing: CameraFacing.front, torchEnabled: false),
                allowDuplicates: false,
                onDetect: (barcode, args) {
                  // QR コード検出時の処理
                  final String code = barcode.rawValue!;

                  // final List<Barcode> barcodes = capture.barcodes;
                  // final value = barcodes[0].rawValue;
                  if (code != null) {
                    // 検出した QR コードの値でデータを更新
                    handleGetCode(code);
                  }
                },
              ),
            ),
            Text(
              scannedValue == '' ? 'QR コードをスキャンしてください。' : 'QRコードを検知しました。',
              style: const TextStyle(fontSize: 15),
            ),
            // QR コードの値を表示
            Text(scannedValue == '' ? "" : "value: $scannedValue"),
          ],
        ),
      ),
    );
  }

  handleGetCode(String code) {
    setState(() {
      scannedValue = code;
    });
    debugPrint(code);

    // 前の画面に戻る
    Navigator.of(context).pop(code);
  }
}
