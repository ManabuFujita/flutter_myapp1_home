import 'package:flutter/material.dart';
import 'package:flutter_myapp1_home/model/zaiko.dart';
import "package:intl/intl.dart";

import '../constants/colors.dart';

class ZaikoItem extends StatefulWidget {
  final Zaiko zaiko;
  final restNumber;
  DateTime limitDate;
  final onDeleteItem;
  final onUsedItem;
  final onSelectItem;
  final onWantItem;
  final isWantItem;
  final isShopping;
  final estimatedLimitDate;
  final selectedDate;
  // final onSelectCalender;
  DateTime limitCalenderDate;
  var buyNumber;

  ZaikoItem({
    Key? key,
    required this.zaiko,
    required this.restNumber,
    required this.limitDate,
    required this.onDeleteItem,
    required this.onUsedItem,
    required this.onSelectItem,
    required this.onWantItem,
    required this.isWantItem,
    required this.isShopping,
    required this.estimatedLimitDate,
    required this.selectedDate,
    // required this.onSelectCalender,
    required this.limitCalenderDate,
    required this.buyNumber,
  }) : super(key: key);

  @override
  State<ZaikoItem> createState() => _ZaikoItemState();
}

class _ZaikoItemState extends State<ZaikoItem> {
  late Zaiko _zaiko;
  // late int _restNumber;
  late DateTime _limitDate;
  // var _onDeleteItem;
  // var _onUsedItem;
  // var _onSelectItem;
  var _onWantItem;
  late bool _isWantItem;
  // late bool _isShopping;
  // var _estimatedLimitDate;
  // var _selectedDate;
  // final onSelectCalender;
  late DateTime _limitCalenderDate;
  // var _buyNumber;

  var _numberController = TextEditingController();

  title() {
    return Text(
      widget.zaiko.name!,
      style: TextStyle(
        fontSize: 16,
        color: tdBlack,
      ),
    );
  }

  subTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Text(
          makeSubtitleString(),
          style: const TextStyle(
            fontSize: 16,
            color: tdBlack,
          ),
        )),
      ],
    );
  }

  String makeSubtitleString() {
    String text = '';
    text += '残り${widget.zaiko.restNumber().toString()}${widget.zaiko.unitName}';
    if (widget.zaiko.restNumber() > 0) {
      text += ' / ';
      text += '${_getLimitDateString()}';

      if (widget.zaiko.hasUsedHistory()) {
        text += ' / ';
        text +=
            '${widget.zaiko.hasUsedHistory() ? '${_getUseDateString()}までに使い切りそう' : ''}';
      }
    }

    return text;
  }

  @override
  void initState() {
    _numberController.text = widget.buyNumber.toString();
    _isWantItem = widget.isWantItem;
    _onWantItem = widget.onWantItem;

    _zaiko = widget.zaiko;
    // _restNumber = widget.restNumber;
    _limitDate = widget.limitDate;
    // _onDeleteItem = widget.onDeleteItem;
    // _onUsedItem = widget.onUsedItem;
    // _onSelectItem = widget.onSelectItem;
    _onWantItem = widget.onWantItem;
    _isWantItem = widget.isWantItem;
    // _isShopping = widget.isShopping;
    // _estimatedLimitDate = widget.estimatedLimitDate;
    // _selectedDate = widget.selectedDate;
    // onSelectCalender = widget.onSelectCalender;
    _limitCalenderDate = widget.limitCalenderDate;
    // _buyNumber = widget.buyNumber;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          widget.onSelectItem(widget.zaiko);
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
        subtitle: subTitle(),
        trailing: widget.isShopping
            ? Wrap(
                spacing: 12,

                // ボタン
                children: [
// 個数増減用のボタン
                  // Container(
                  //   margin: const EdgeInsets.only(
                  //     bottom: 20,
                  //     // right: 20,
                  //     // left: 20,
                  //   ),
                  //   padding: const EdgeInsets.symmetric(
                  //       // horizontal: 20,
                  //       // vertical: 5,
                  //       ),
                  //   child: Row(
                  //     children: [
                  //       // numcontrollerの値を減らすボタン
                  //       ElevatedButton(
                  //         style: OutlinedButton.styleFrom(
                  //           primary: Colors.black,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: const BorderSide(color: Colors.grey),
                  //           backgroundColor: Colors.white,
                  //         ),
                  //         onPressed: () {
                  //           setState(() {
                  //             // numcontrollerの値を減らす
                  //             _numberController.text =
                  //                 (int.parse(_numberController.text) - 1)
                  //                     .toString();
                  //           });
                  //         },
                  //         child: const Text('-'),
                  //       ),
                  //       // numcontrollerの値を増やすボタン
                  //       ElevatedButton(
                  //         style: OutlinedButton.styleFrom(
                  //           primary: Colors.black,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           side: const BorderSide(color: Colors.grey),
                  //           backgroundColor: Colors.white,
                  //         ),
                  //         onPressed: () {
                  //           setState(() {
                  //             // numcontrollerの値を増やす
                  //             _numberController.text =
                  //                 (int.parse(_numberController.text) + 1)
                  //                     .toString();
                  //           });
                  //         },
                  //         child: const Text('+'),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // カレンダー用のボタン
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: myNowCalenderButton, // background
                      // foregroundColor: Colors.white, // foreground
                    ),
                    onPressed: () {
                      // カレンダー画面に遷移
                      _selectItemCalender2();
                    },
                    child: Text(
                        '期限 ${_limitCalenderDate.year}/${_limitCalenderDate.month}/${_limitCalenderDate.day} ?'),
                  ),
                  ElevatedButton(
                      // isWantItem == trueのときは、中に色があり、falseのときは中が白で枠線のみあり
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.isWantItem ? tdBlue : Colors.white,
                        foregroundColor:
                            widget.isWantItem ? Colors.white : tdBlue,
                        side: BorderSide(color: tdBlue),
                      ),
                      onPressed: () {
                        widget.onWantItem(
                          widget.zaiko,
                        );
                      },
                      child: Text('買いたい')),
                ],
              )
            : Wrap(
                spacing: 12,

                // ボタン
                children: [
                  ElevatedButton(
                      // isWantItem == trueのときは、中に色があり、falseのときは中が白で枠線のみあり
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWantItem ? tdBlue : Colors.white,
                        foregroundColor: _isWantItem ? Colors.white : tdBlue,
                        side: BorderSide(color: tdBlue),
                      ),
                      onPressed: () {
                        _onWantItem(
                          _zaiko,
                        );
                      },
                      child: Text('買いたい')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          // backgroundColor: Colors.yellow,
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange)),
                      onPressed: () {
                        _onWantItem(
                          _zaiko,
                        );
                      },
                      child: Text('1つ使った')),

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

  String _getUseDateString() {
    return _getDateTimeString(widget.zaiko.estimatedAllUseDate());
  }

  String _getLimitDateString() {
    return widget.zaiko.isStrictLimit
        ? '消費期限:${_getDateTimeString(_limitDate)}'
        : '賞味期限:${_getDateTimeString(_limitDate)}';
  }

  String _getDateTimeString(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  Future<void> _selectItemCalender2() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _limitCalenderDate, // 最初に表示する日付
      firstDate: DateTime(1900), // 選択できる日付の最小値
      lastDate: DateTime(2101), // 選択できる日付の最大値
    );

    if (picked != null) {
      setState(() {
        // 選択された日付を変数に代入
        _limitCalenderDate = picked;
        // selectedDate = picked;
      });
    }
  }
}
