import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/main.dart';
import 'package:flutter_myapp1_home/model/todo.dart';
import 'package:flutter_myapp1_home/screens/home.dart';
import 'package:flutter_myapp1_home/widgets/todo_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/colors.dart';
import '../repository/todoRepository.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  // final todoList = Todo.TodoList();
  // List<Todo> _foundTodo = [];
  // final _TodoController = TextEditingController();

  final userId = FirebaseAuth.instance.currentUser!.uid;

  // final Stream<QuerySnapshot> _anniversariesStream = FirebaseFirestore.instance
  //     .collection('anniversaries')
  //     .where("userId", isEqualTo: userId)
  //     .snapshots();

  @override
  void initState() {
    // _foundTodo = todoPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        // DBをリアルタイムで取得
        stream: FirebaseFirestore.instance
            .collection('todos')
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
          List<Todo> anniversaries = snapshot.data!.docs.map((doc) {
            // スナップショットから Todo オブジェクトのリストを作成
            Todo anni = Todo.fromJson(doc.data() as Map<String, dynamic>);

            // return Todo.fromJson(doc.data() as Map<String, dynamic>);

            return anni;
          }).toList();

          // daynumver順にソートする
          List<Todo> todosSorted = anniversaries
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
                                  'Todo',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              for (Todo item in todosSorted)
                                TodoItem(
                                  todo: item,
                                  onTodoChanged: _handleTodoChange,
                                  onDeleteItem: _deleteTodoItem,
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
                      return TodoAddPage();
                    }),
                  );
                },
                child: Icon(Icons.add),
              ),
              drawer: BuildDrawer());
        });
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      // Todo.isHuman = !Todo.isHuman;
    });
  }

  void _deleteTodoItem(Todo todo) async {
    // setState(() {
    //   todoPage.removeWhere((item) => item.id == id);
    // });

    // DB保存
    TodoRepository todoRepository = TodoRepository();
    await todoRepository.delete(todo);
  }

  // void _addTodoItem(String name) async {
  //   // setState(() {
  //   //   todoPage.add(Todo(
  //   //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //   //       name: name,
  //   //       date: DateTime.now()));
  //   // });
  //   final user = ref.watch(userProvider);

  //   Todo Todo = Todo(
  //       userId: user!.uid,
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       name: name,
  //       date: DateTime.now(),
  //       isHuman: false,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now());

  //   // DB保存
  //   TodoRepository TodoRepository = TodoRepository();
  //   await TodoRepository.insert(Todo);

  //   _TodoController.clear();
  // }

  void _runFilter(String enteredKeyword) {
    // List<Todo> results = [];
    // if (enteredKeyword.isEmpty) {
    //   results = todoList;
    // } else {
    //   results = todoList
    //       .where((item) =>
    //           item.name!.toLowerCase().contains(enteredKeyword.toLowerCase()))
    //       .toList();
    // }

    setState(() {
      // _foundTodo = results;
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

class TodoAddPage extends StatefulWidget {
  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // String _inputText = '';

  final _textController = TextEditingController();
  final _textIntervalController = TextEditingController();

  bool _isScheduled = false;

  DateTime _selectedDate = DateTime.now();
  // String _radioValue = '誕生日';

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
          children: [
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
                        hintText: 'やること', border: InputBorder.none),
                  ),
                ),
              ),
              // カレンダー用のボタン
              // Row(
              //   children: [
              //     Text(
              //       '${getCalenderLabel()}:',
              //       style: TextStyle(fontSize: 20),
              //     ),
              //     ElevatedButton(
              //       onPressed: () {
              //         // カレンダー画面に遷移
              //         _selectCalender(context);
              //       },
              //       child: Text(
              //           '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
              //     ),
              //   ],
              // ),
            ]),

            // スケジュール設定のチェックボックス
            Row(children: [
              Checkbox(
                value: _isScheduled,
                onChanged: (bool? value) {
                  setState(() {
                    _isScheduled = value!;
                  });
                },
              ),
              Text('スケジュール設定'),
            ]),

            // スケジュールの間隔
            Row(children: [
              Container(
                width: 100,
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
                  controller: _textIntervalController,
                  decoration: const InputDecoration(
                      hintText: '', border: InputBorder.none),
                ),
              ),
              Expanded(child: Container(child: Text('日ごとにやる'))),
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
                  _addTodoItem(_textController.value.text);
                  Navigator.of(context).pop();
                },
                child: Text('追加'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String getCalenderLabel() {
  //   return _radioValue == '誕生日' ? '生年月日' : '記念日';
  // }

  void _onRadioChanged(String value) {
    setState(() {
      // _radioValue = value;
    });
  }

  void _addTodoItem(String name) async {
    int interval = _textIntervalController.text.isEmpty
        ? 0
        : int.parse(_textIntervalController.text);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime nextDate = today.add(Duration(days: interval));

    Todo todo = Todo(
        userId: userId,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: name,
        isDone: false,
        nextDate: nextDate,
        scheduleBase: 'day',
        scheduleInterval: interval,
        createdAt: now,
        updatedAt: now);

    // DB保存
    TodoRepository todoRepository = TodoRepository();
    await todoRepository.insert(todo);

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
