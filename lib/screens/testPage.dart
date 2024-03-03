import 'package:flutter/material.dart';
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
                  if (code != '') {
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
