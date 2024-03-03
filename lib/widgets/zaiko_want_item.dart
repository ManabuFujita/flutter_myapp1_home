import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

import '../model/Anniversary.dart';
import '../constants/colors.dart';

class ZaikoWantItem extends StatefulWidget {
  final name;

  ZaikoWantItem({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  State<ZaikoWantItem> createState() => _ZaikoWantItemState();
}

class _ZaikoWantItemState extends State<ZaikoWantItem> {
  late String _name;

  var _numberController = TextEditingController();

  @override
  title() {
    return Text(
      _name,
      style: TextStyle(
        fontSize: 16,
        color: tdBlack,
      ),
    );
  }

  @override
  void initState() {
    // _numberController.text = widget.buyNumber.toString();
    _name = widget.name;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          // widget.onSelectItem(widget.zaiko);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          Icons.cake,
          color: tdBlue,
        ),
        title: title(),
        // subtitle: subTitle(),
        trailing: Wrap(
          spacing: 12,

          // ボタン
          children: [
            ElevatedButton(
                // isWantItem == trueのときは、中に色があり、falseのときは中が白で枠線のみあり
                style: ElevatedButton.styleFrom(
                  // backgroundColor: tdBlue,
                  foregroundColor: tdRed,
                  side: BorderSide(color: tdRed),
                ),
                onPressed: () {
                  // _onWantItem(
                  //   _zaiko,
                  // );
                },
                child: Text('削除')),

            // IconButton(
            //   color: Colors.red,
            //   iconSize: 18,
            //   icon: const Icon(Icons.delete),
            //   onPressed: () {
            //     // print('Clicked on delete icon');
            //     onDeleteItem(zaiko);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  getDateFormatted(DateTime date) {
    // var formatter = new DateFormat('yyyy/MM/dd(E) HH:mm', "ja_JP");
    return DateFormat('yyyy年M月d日').format(date);
  }

  // zaikoWantToBuyRepositoryから削除
}
