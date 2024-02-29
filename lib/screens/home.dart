import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/screens/todoPage.dart';

import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: tdBGColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BuildAppBar(),
        ),
        body: user == null
            ? Text('home: no user')
            : Text('home: ' + user!.email!),
        drawer: BuildDrawer());
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
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

class BuildAppBar extends StatelessWidget {
  const BuildAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('app-name'),
        SizedBox(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/icon.png'),
          ),
        ),
      ]),
    );
  }
}

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: tdBlue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home', arguments: null);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Todo Page'),
            onTap: () {
              Navigator.pushNamed(context, '/todo', arguments: null);
            },
          ),
          ListTile(
            title: const Text('Aniversary Page'),
            onTap: () {
              Navigator.pushNamed(context, '/aniversary', arguments: null);
            },
          ),
          ListTile(
            title: const Text('Zaiko Page'),
            onTap: () {
              Navigator.pushNamed(context, '/zaiko', arguments: null);
            },
          ),
          ListTile(
            title: const Text('Test Page'),
            onTap: () {
              Navigator.pushNamed(context, '/test', arguments: null);
            },
          ),
        ],
      ),
    );
  }
}
