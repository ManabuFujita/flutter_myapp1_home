import 'dart:io';
import 'dart:typed_data';

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
import 'package:mobile_scanner/mobile_scanner.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
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
          children: <Widget>[
            SizedBox(
              height: 400,
              width: 200,
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
                    setState(() {
                      scannedValue = code;
                    });
                    debugPrint(code);
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
}
