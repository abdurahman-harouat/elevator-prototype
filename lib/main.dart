import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

// other pages
import './select_bonded_device_page.dart';
import 'package:elevator_app/widgets/permission_btn.dart';
import 'chat_page.dart';
import 'discovery_page.dart';

// third-party pluggins
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as premium;
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

void main() async {
  // fixing the app to be in portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // getting permissions status
  Future bluetoothPermissionsStatus() async {
    PermissionStatus bluetooth = await Permission.bluetooth.status;
    PermissionStatus bluetoothConnect =
        await Permission.bluetoothConnect.status;
    PermissionStatus bluetoothScan = await Permission.bluetoothScan.status;
  }

  Future bluetoothPermissionActivate() async {
	  PermissionStatus bluetoothPermission = await Permission.bluetooth.request();
      PermissionStatus bluetoothConnectPermission = await Permission.bluetoothConnect.request();
      PermissionStatus bluetoothScanPermission = await Permission.bluetoothScan.request();

  }

  // flutter_blue_plus things
  final premium.FlutterBluePlus _flutterBlue = premium.FlutterBluePlus.instance;
  // bluetooth state
  bool _isBluetoothOn = false;


  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    bluetoothPermissionActivate();
  }

  // getting bluetooth status from flutter_blue_plus
  void _checkBluetoothStatus() async {
    if (await Permission.bluetooth.request().isGranted) {
      _flutterBlue.state.listen((state) {
        if (state == premium.BluetoothState.on) {
          setState(() => _isBluetoothOn = true);
        } else {
          setState(() => _isBluetoothOn = false);
        }
      });
    }
  }

  void _toggleBluetooth(bool value) async {
    if (value) {
      FlutterBluetoothSerial.instance.requestEnable();
      await _flutterBlue.turnOn();
    } else {
      // disabling bluetooth is not working write now
      premium.FlutterBluePlus.instance.turnOff();
      // await _flutterBlue.turnOff();
    }
  }

  List devicePage = [
    ["إتصال", Icons.link],
    ["أول مرة؟", Icons.device_unknown],
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Lottie.asset(
                'assets/lottie/867-bluetooth.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
              ),
              SizedBox(
                // width: MediaQuery.of(context).size.width * 0.5,
                child: FittedBox(
                  child: Text(
                    'تفعيل البلوتوت',
                    style: TextStyle(fontSize: 30, fontFamily: 'CairoPlayBold'),
                ),
              ),),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Text(
                    'يجب تفعيل جميع الأذونات الخاصة بالبلوتوث حتى يعمل التطبيق بدون مشاكل',
                    style: GoogleFonts.cairoPlay(
                      fontSize: 18.0,
                    ),
                    // style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[200]),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CupertinoSwitch(
                            value: _isBluetoothOn,
                            onChanged: (value) {
                              _toggleBluetooth(value);
                            }),
                        Text(
                          _isBluetoothOn ? 'مفعل' : 'غير مفعل',
                          style: GoogleFonts.cairoPlay(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              // devices box
              // TODO: this should be added inside futureBuilder

              // Expanded(
              //   child: GestureDetector(
              //     onTap: () async {
              //       await Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) {
              //             return const SelectBondedDevicePage(
              //                 checkAvailability: false);
              //           },
              //         ),
              //       );
              //     },
              //     child: GridView.builder(
              //       itemCount: devicePage.length,
              //       gridDelegate:
              //           const SliverGridDelegateWithFixedCrossAxisCount(
              //               crossAxisCount: 2, childAspectRatio: 1.2 / 1),
              //       itemBuilder: (context, index) => Padding(
              //         padding: const EdgeInsets.all(20.0),
              //         child: Container(
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(20),
              //               color: Colors.grey[200]),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.all(12.0),
              //                 child: Icon(devicePage[index][1],
              //                     color: _isBluetoothOn
              //                         ? Colors.black
              //                         : Colors.grey[400]),
              //               ),
              //               Padding(
              //                 padding: const EdgeInsets.all(12.0),
              //                 child: Text(
              //                   devicePage[index][0],
              //                   style: GoogleFonts.tajawal(
              //                       fontSize: 20,
              //                       fontWeight: FontWeight.bold,
              //                       color: _isBluetoothOn
              //                           ? Colors.black
              //                           : Colors.grey[400]),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 50,
              )

              // ListTile(
              //   title: const Text('البلوتوث'),
              //   onTap: () async {
              //     PermissionStatus bluetoothPermissionStatus =
              //         await Permission.bluetooth.request();
              //     if (bluetoothPermissionStatus == PermissionStatus.granted) {
              //       print('bluetooth activated');
              //     } else if (bluetoothPermissionStatus == PermissionStatus.denied) {
              //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //           content: Text('this permission is recommended')));
              //     } else if (bluetoothPermissionStatus ==
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

              // replacing this with only one cuppertino radio button
              // const PermissionBtn(
              //     title: 'تفعيل البلوتوت', permission: Permission.bluetooth),
              // const SizedBox(
              //   height: 15,
              // ),
              // const PermissionBtn(
              //   title: 'فحص البلوتوت',
              //   permission: Permission.bluetoothScan,
              // ),
              // const SizedBox(
              //   height: 15,
              // ),
              // const PermissionBtn(
              //   title: 'إتصال البلوتوت',
              //   permission: Permission.bluetoothConnect,
              // ),
              // const SizedBox(
              //   height: 20.0,
              // ),
              ,
              FutureBuilder(
                future: bluetoothPermissionsStatus(),
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
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[200]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(Icons.link,
                                          color: _isBluetoothOn
                                              ? Colors.black
                                              : Colors.grey[400]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "إتصال",
                                        style: GoogleFonts.tajawal(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _isBluetoothOn
                                                ? Colors.black
                                                : Colors.grey[400]),
                                      ),
                                    ),
                                  ],
                                ),
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
