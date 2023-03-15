import './select_bonded_device_page.dart';
import 'package:elevator_app/widgets/permission_btn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './chat_page.dart';

void main() => runApp(const PermissionHandlerWidget());

class PermissionHandlerWidget extends StatefulWidget {
  const PermissionHandlerWidget({super.key});

  @override
  State<PermissionHandlerWidget> createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  Future bluetoothStatus() async {
    PermissionStatus bluetooth = await Permission.bluetooth.status;
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.status;
    PermissionStatus bluetoothScan = await Permission.bluetoothScan.status;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Lottie.asset(
              'assets/lottie/867-bluetooth.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            const Text(
              'فعل الأذونات',
              style: TextStyle(fontSize: 38.0, fontWeight: FontWeight.bold),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Center(
                        child: Text(
                      'يجب تفعيل جميع الأذونات الخاصة بالبلوتوث حتى يعمل التطبيق بدون مشاكل',
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            // ListTile(
            //   title: const Text('البلوتوث'),
            //   onTap: () async {
            //     PermissionStatus bluetoothStatus =
            //         await Permission.bluetooth.request();
            //     if (bluetoothStatus == PermissionStatus.granted) {
            //       print('bluetooth activated');
            //     } else if (bluetoothStatus == PermissionStatus.denied) {
            //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //           content: Text('this permission is recommended')));
            //     } else if (bluetoothStatus ==
            //         PermissionStatus.permanentlyDenied) {
            //       openAppSettings(); //take me to app settings
            //     }
            //   },
            //   leading: const CircleAvatar(
            //     backgroundColor: Colors.redAccent,
            //     child: Icon(Icons.bluetooth),
            //   ),
            // ),

            // ListTile(
            //   title: const Text('فحص البلوتوث'),
            //   onTap: () async {
            //     PermissionStatus bluetoothScanStatus =
            //         await Permission.bluetoothScan.request();
            //     if (bluetoothScanStatus == PermissionStatus.granted) {
            //       print('bluetoothScan activated');
            //     } else if (bluetoothScanStatus == PermissionStatus.denied) {
            //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //           content: Text('this permission is recommended')));
            //     } else if (bluetoothScanStatus ==
            //         PermissionStatus.permanentlyDenied) {
            //       openAppSettings(); //take me to app settings
            //     }
            //   },
            //   leading: const CircleAvatar(
            //     backgroundColor: Colors.amber,
            //     child: Icon(Icons.bluetooth),
            //   ),
            // ),
            const PermissionBtn(
                title: 'تفعيل البلوتوت', permission: Permission.bluetooth),
            const SizedBox(
              height: 15,
            ),
            const PermissionBtn(
              title: 'فحص البلوتوت',
              permission: Permission.bluetoothScan,
            ),
            const SizedBox(
              height: 15,
            ),
            const PermissionBtn(
              title: 'إتصال البلوتوت',
              permission: Permission.bluetoothConnect,
            ),
            const SizedBox(
              height: 20.0,
            ),
            FutureBuilder(
              future: bluetoothStatus(),
              builder: (BuildContext context, future) {
                if (future.connectionState == ConnectionState.done) {
                  // FlutterBluetoothSerial.instance.requestEnable();
                  return Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: Color.fromARGB(255, 238, 237, 237)),
                          child: TextButton(
                            onPressed: () async {
                              FlutterBluetoothSerial.instance.requestEnable();
                              final BluetoothDevice? selectedDevice =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const SelectBondedDevicePage(
                                        checkAvailability: false);
                                  },
                                ),
                              );

                              if (selectedDevice != null) {
                                print(
                                    'Connect -> selected ${selectedDevice.address}');
                                _startChat(context, selectedDevice);
                              } else {
                                print('Connect -> no device selected');
                              }
                            },
                            child: const Text(
                              'إبدأ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )),
                    ],
                  );
                } else {
                  return const SizedBox(
                    height: 0.0,
                    width: 0.0,
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}

void _startChat(BuildContext context, BluetoothDevice server) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return ChatPage(server: server);
      },
    ),
  );
}
