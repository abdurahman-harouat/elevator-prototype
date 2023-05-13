import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// other pages
import 'select_bonded_device_page.dart';
import 'buttons_page.dart';

// third-party pluggins
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as premium;
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';

void main() async {
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
  final premium.FlutterBluePlus _flutterBlue = premium.FlutterBluePlus.instance;
  bool _isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    bluetoothPermissionActivate();
  }

  Future bluetoothPermissionActivate() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
  }

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
      premium.FlutterBluePlus.instance.turnOff();
    }
  }

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
                    const SizedBox(height: 50),
                    Lottie.asset('assets/lottie/867-bluetooth.json',
                        width: 200, height: 200, fit: BoxFit.fill),
                    const SizedBox(
                        child: FittedBox(
                            child: Text('تفعيل البلوتوت',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'CairoPlayBold')))),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Text(
                          'يجب تفعيل جميع الأذونات الخاصة بالبلوتوث حتى يعمل التطبيق بدون مشاكل',
                          style: GoogleFonts.cairoPlay(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey[200]),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 12.0, bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Switch(
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
                    const SizedBox(height: 80),
                    const SizedBox(height: 50),
                    FutureBuilder(
                      future: Permission.bluetooth.status,
                      builder: (BuildContext context,
                          AsyncSnapshot<PermissionStatus> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: Color.fromARGB(255, 238, 237, 237)),
                                child: TextButton(
                                    onPressed: () async {
                                      if (_isBluetoothOn) {
                                        FlutterBluetoothSerial.instance
                                            .requestEnable();
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
                                          _goToButtonsPage(context, selectedDevice);
                                        }
                                      } else {
                                        return null;
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.grey[200]),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            child: Text("إتصال",
                                                style: GoogleFonts.tajawal(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: _isBluetoothOn
                                                        ? Colors.black
                                                        : Colors.grey[400])),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
              )),
        ));
  }
}

void _goToButtonsPage(BuildContext context, BluetoothDevice server) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ButtonsPage(server: server)));
}
