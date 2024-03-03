import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YahooProductList {
  String janCode;
  List<YahooProduct>? productList;

  YahooProductList({
    required this.janCode,
    this.productList,
  });

  // YahooAPIから取得した商品情報をリストに変換する
  Future<List<YahooProduct>> getProductList() async {
    final jsonResponse = await _getProductInfo();
    return _makeProductList(jsonResponse);
  }

  // YahooAPIを使用して、JANコードから商品情報を取得する
  Future<Map<String, dynamic>> _getProductInfo() async {
    final yahooAppClientId = dotenv.env['YAHOO_API_CLIENT_ID'];

    final url =
        // ignore: prefer_interpolation_to_compose_strings
        'https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch?' +
            'appid=$yahooAppClientId' +
            '&jan_code=$janCode' +
            '&image_size=132' +
            '&results=5' +
            '&sort=-score';
    var uri = Uri.parse(url);
    print(uri);
    var response = await http.get(uri);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // ステータスコード 200 はリクエストが成功した場合に返されるコード
      var jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      // エラーハンドリングの処理

      throw Exception('Failed to fetch data from YahooAPI');
    }
  }

  List<YahooProduct> _makeProductList(Map<String, dynamic> json) {
    // var product = jsonDecode(json);
    print(json);

    var hits = json['hits'];

    // YahooProductのリストを作成
    List<YahooProduct> productList = [];
    hits.forEach((hit) {
      // var productInfo = hit['_attributes'];

      var yahooProduct = YahooProduct(
        janCode: janCode,
        name: hit['name'] ?? 'no name',
        imageUrl: hit['image']['medium'] ?? 'no image',
      );
      productList.add(yahooProduct);
    });
    return productList;
  }

  // //Firebaseからデータを取得する際の変換処理
  // YahooProduct.fromJson(Map<String, Object?> json)
  //     : this(
  //           userId: json['userId']! as String,
  //           productId: json['productId']! as String,
  //           name: json['name']! as String,
  //           code: json['code']! as String,
  //           lastBuyDate:
  //               (json['lastBuyDate']! as Timestamp).toDate() as DateTime,
  //           isStrictLimit: json['isStrictLimit']! as bool,
  //           createdAt: (json['createdAt']! as Timestamp).toDate() as DateTime,
  //           updatedAt: (json['updatedAt']! as Timestamp).toDate() as DateTime,
  //           deletedAt:
  //               (json['deletedAt'] as Timestamp?)?.toDate() as DateTime?);

  // // DartのオブジェクトからFirebaseへ渡す際の変換処理
  // Map<String, Object?> toJson() {
  //   Timestamp? deletedTimestamp;
  //   if (deletedAt != null) {
  //     deletedTimestamp = Timestamp.fromDate(deletedAt!);
  //   }
  //   return {
  //     'userId': userId,
  //     'productId': productId,
  //     'name': name,
  //     'code': code,
  //     'lastBuyDate': Timestamp.fromDate(lastBuyDate),
  //     'isStrictLimit': isStrictLimit,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //     'deletedAt': deletedTimestamp,
  //   };
  // }

  // // 残り個数
  // int restNumber() {
  //   int restNum = 0;
  //   for (var i = 0; i < histories.length; i++) {
  //     if (histories[i].isUsed == false) {
  //       restNum++;
  //     }
  //   }
  //   return restNum;
  // }

  // // histriesから、isUsed==falseで最古のlimitdateを返す
  // DateTime nearestLimitDate() {
  //   DateTime oldestDate = DateTime.now();
  //   for (var i = 0; i < histories.length; i++) {
  //     if (!histories[i].isUsed) {
  //       if (oldestDate.isAfter(histories[i].limitDate)) {
  //         oldestDate = histories[i].limitDate;
  //       }
  //     }
  //   }
  //   return oldestDate;
  // }

  // int restDays() {
  //   int todaysDayNumber =
  //       DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  //   var restDays = dayNumber - todaysDayNumber;
  //   if (restDays < 0) {
  //     restDays = 365 + restDays;
  //   }
  //   return restDays;
  // }
}

class YahooProduct {
  String janCode;
  String name;
  String imageUrl;

  YahooProduct({
    required this.janCode,
    required this.name,
    required this.imageUrl,
  });

  // //Firebaseからデータを取得する際の変換処理
  // YahooProduct.fromJson(Map<String, Object?> json)
  //     : this(
  //           userId: json['userId']! as String,
  //           productId: json['productId']! as String,
  //           name: json['name']! as String,
  //           code: json['code']! as String,
  //           lastBuyDate:
  //               (json['lastBuyDate']! as Timestamp).toDate() as DateTime,
  //           isStrictLimit: json['isStrictLimit']! as bool,
  //           createdAt: (json['createdAt']! as Timestamp).toDate() as DateTime,
  //           updatedAt: (json['updatedAt']! as Timestamp).toDate() as DateTime,
  //           deletedAt:
  //               (json['deletedAt'] as Timestamp?)?.toDate() as DateTime?);

  // // DartのオブジェクトからFirebaseへ渡す際の変換処理
  // Map<String, Object?> toJson() {
  //   Timestamp? deletedTimestamp;
  //   if (deletedAt != null) {
  //     deletedTimestamp = Timestamp.fromDate(deletedAt!);
  //   }
  //   return {
  //     'userId': userId,
  //     'productId': productId,
  //     'name': name,
  //     'code': code,
  //     'lastBuyDate': Timestamp.fromDate(lastBuyDate),
  //     'isStrictLimit': isStrictLimit,
  //     'createdAt': Timestamp.fromDate(createdAt),
  //     'updatedAt': Timestamp.fromDate(updatedAt),
  //     'deletedAt': deletedTimestamp,
  //   };
  // }

  // // 残り個数
  // int restNumber() {
  //   int restNum = 0;
  //   for (var i = 0; i < histories.length; i++) {
  //     if (histories[i].isUsed == false) {
  //       restNum++;
  //     }
  //   }
  //   return restNum;
  // }

  // // histriesから、isUsed==falseで最古のlimitdateを返す
  // DateTime nearestLimitDate() {
  //   DateTime oldestDate = DateTime.now();
  //   for (var i = 0; i < histories.length; i++) {
  //     if (!histories[i].isUsed) {
  //       if (oldestDate.isAfter(histories[i].limitDate)) {
  //         oldestDate = histories[i].limitDate;
  //       }
  //     }
  //   }
  //   return oldestDate;
  // }

  // int restDays() {
  //   int todaysDayNumber =
  //       DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  //   var restDays = dayNumber - todaysDayNumber;
  //   if (restDays < 0) {
  //     restDays = 365 + restDays;
  //   }
  //   return restDays;
  // }
}
