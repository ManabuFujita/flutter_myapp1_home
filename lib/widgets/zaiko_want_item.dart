import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/model/zaikoWantToBuy.dart';
import 'package:flutter_myapp1_home/repository/zaikoWantToBuyRepository.dart';
import "package:intl/intl.dart";

import '../constants/colors.dart';

class ZaikoWantItem extends StatefulWidget {
  final String name;
  final ZaikoWantToBuy zaikoWantToBuy;

  ZaikoWantItem({
    Key? key,
    required this.name,
    required this.zaikoWantToBuy,
  }) : super(key: key);

  @override
  State<ZaikoWantItem> createState() => _ZaikoWantItemState();
}

class _ZaikoWantItemState extends State<ZaikoWantItem> {
  // late String _name = widget.name;
  late ZaikoWantToBuy _zaikoWantToBuy = widget.zaikoWantToBuy;

  ZaikoWantToBuyRepository zaikoWantToBuyRepository =
      ZaikoWantToBuyRepository();

  // var _numberController = TextEditingController();

  @override
  void initState() {
    // _numberController.text = widget.buyNumber.toString();
    // _name = widget.name;
    _zaikoWantToBuy = widget.zaikoWantToBuy;

    super.initState();
  }

  title() {
    return Text(
      _zaikoWantToBuy.name,
      style: TextStyle(
        fontSize: 16,
        color: tdBlack,
      ),
    );
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
                  onDeleteItem();
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

  // データの削除
  void onDeleteItem() {
    zaikoWantToBuyRepository.delete(
        _zaikoWantToBuy.userId, _zaikoWantToBuy.name);
  }

  getDateFormatted(DateTime date) {
    // var formatter = new DateFormat('yyyy/MM/dd(E) HH:mm', "ja_JP");
    return DateFormat('yyyy年M月d日').format(date);
  }

  // zaikoWantToBuyRepositoryから削除
}
