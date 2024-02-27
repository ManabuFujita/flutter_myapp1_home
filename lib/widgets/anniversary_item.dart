import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

import '../model/Anniversary.dart';
import '../constants/colors.dart';

class AnniversaryItem extends StatelessWidget {
  final Anniversary anniversary;
  final onAnniversaryChanged;
  final onDeleteItem;

  const AnniversaryItem({
    Key? key,
    required this.anniversary,
    required this.onAnniversaryChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  title() {
    return Text(
      anniversary.name!,
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
          child: anniversary.isHuman
              ? Text(
                  getDateFormatted(anniversary.date) +
                      '  ' +
                      getAgeAndSchoolGrade(anniversary.date) +
                      ' ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: tdBlack,
                  ),
                )
              : Text(
                  getDateFormatted(anniversary.date) +
                      '  ' +
                      getAnniversaryYearsCount(anniversary.date) +
                      ' ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: tdBlack,
                  ),
                ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text('${anniversary.restDays()}日後'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          onAnniversaryChanged(anniversary);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          anniversary.isHuman ? Icons.face : Icons.event,
          color: tdBlue,
        ),
        title: title(),
        subtitle: subTitle(),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdRed,
            borderRadius: BorderRadius.circular(5),
          ),
          // 削除ボタン
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: const Icon(Icons.delete),
            onPressed: () {
              // print('Clicked on delete icon');
              onDeleteItem(anniversary);
            },
          ),
        ),
      ),
    );
  }

  getDateFormatted(DateTime date) {
    // var formatter = new DateFormat('yyyy/MM/dd(E) HH:mm', "ja_JP");
    return DateFormat('yyyy年M月d日').format(date);
  }

  getAge(DateTime date) {
    var now = DateTime.now();
    var age = now.year - date.year;
    return age;
  }

  String getAgeAndSchoolGrade(DateTime date) {
    var age = getAge(date);
    var schoolGrade = null;
    if (age < 6) {
      schoolGrade = '年少';
    } else if (age < 12) {
      schoolGrade = '小学' + (age - 6).toString() + '年生';
    } else if (age < 15) {
      schoolGrade = '中学' + (age - 12).toString() + '年生';
    } else if (age < 18) {
      schoolGrade = '高校' + (age - 15).toString() + '年生';
    } else if (age < 22) {
      schoolGrade = '大学' + (age - 18).toString() + '年生';
    } else {
      schoolGrade = null;
    }
    return schoolGrade != null
        ? age.toString() + '歳 ' + schoolGrade
        : age.toString() + '歳 ';
  }

  String getAnniversaryYearsCount(DateTime date) {
    var now = DateTime.now();
    var years = now.year - date.year;
    return years.toString() + '年目';
  }
}
