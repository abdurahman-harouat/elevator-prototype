// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:scoped_model/scoped_model.dart';

// import 'background_collected_page.dart';
// import 'background_collecting_task.dart';
// import 'chat_page.dart';
// import 'discovery_page.dart';
// import 'select_bonded_device_page.dart';

// // import './helpers/LineChart.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   _MainPage createState() =>  _MainPage();
// }

// class _MainPage extends State<MainPage> {
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

//   String _address = "...";
//   String _name = "...";

//   Timer? _discoverableTimeoutTimer;
//   int _discoverableTimeoutSecondsLeft = 0;

//   BackgroundCollectingTask? _collectingTask;

//   bool _autoAcceptPairingRequests = false;

//   @override
//   void initState() {
//     super.initState();

//     // Get current state
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });

//     Future.doWhile(() async {
//       // Wait if adapter not enabled
//       if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
//         return false;
//       }
//       await Future.delayed(const Duration(milliseconds: 0xDD));
//       return true;
//     }).then((_) {
//       // Update the address field
//       FlutterBluetoothSerial.instance.address.then((address) {
//         setState(() {
//           _address = address!;
//         });
//       });
//     });

//     FlutterBluetoothSerial.instance.name.then((name) {
//       setState(() {
//         _name = name!;
//       });
//     });

//     // Listen for futher state changes
//     FlutterBluetoothSerial.instance
//         .onStateChanged()
//         .listen((BluetoothState state) {
//       setState(() {
//         _bluetoothState = state;

//         // Discoverable mode is disabled when Bluetooth gets disabled
//         _discoverableTimeoutTimer = null;
//         _discoverableTimeoutSecondsLeft = 0;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
//     _collectingTask?.dispose();
//     _discoverableTimeoutTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Bluetooth Serial'),
//       ),
//       body: Container(
//         child: ListView(
//           children: <Widget>[
//             const Divider(),
//             const ListTile(title: Text('General')),
//             SwitchListTile(
//               title: const Text('Enable Bluetooth'),
//               value: _bluetoothState.isEnabled,
//               onChanged: (bool value) {
//                 // Do the request and update with the true value then
//                 future() async {
//                   // async lambda seems to not working
//                   if (value) {
//                     await FlutterBluetoothSerial.instance.requestEnable();
//                   } else {
//                     await FlutterBluetoothSerial.instance.requestDisable();
//                   }
//                 }

//                 future().then((_) {
//                   setState(() {});
//                 });
//               },
//             ),
//             ListTile(
//               title: const Text('Bluetooth status'),
//               subtitle: Text(_bluetoothState.toString()),
//               trailing: ElevatedButton(
//                 child: const Text('Settings'),
//                 onPressed: () {
//                   FlutterBluetoothSerial.instance.openSettings();
//                 },
//               ),
//             ),
//             ListTile(
//               title: const Text('Local adapter address'),
//               subtitle: Text(_address),
//             ),
//             ListTile(
//               title: const Text('Local adapter name'),
//               subtitle: Text(_name),
//               onLongPress: null,
//             ),
//             ListTile(
//               title: _discoverableTimeoutSecondsLeft == 0
//                   ? const Text("Discoverable")
//                   : Text(
//                       "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
//               subtitle: const Text("PsychoX-Luna"),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Checkbox(
//                     value: _discoverableTimeoutSecondsLeft != 0,
//                     onChanged: null,
//                   ),
//                   const IconButton(
//                     icon: Icon(Icons.edit),
//                     onPressed: null,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.refresh),
//                     onPressed: () async {
//                       print('Discoverable requested');
//                       final int timeout = (await FlutterBluetoothSerial.instance
//                           .requestDiscoverable(60))!;
//                       if (timeout < 0) {
//                         print('Discoverable mode denied');
//                       } else {
//                         print(
//                             'Discoverable mode acquired for $timeout seconds');
//                       }
//                       setState(() {
//                         _discoverableTimeoutTimer?.cancel();
//                         _discoverableTimeoutSecondsLeft = timeout;
//                         _discoverableTimeoutTimer =
//                             Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//                           setState(() {
//                             if (_discoverableTimeoutSecondsLeft < 0) {
//                               FlutterBluetoothSerial.instance.isDiscoverable
//                                   .then((isDiscoverable) {
//                                 if (isDiscoverable ?? false) {
//                                   print(
//                                       "Discoverable after timeout... might be infinity timeout :F");
//                                   _discoverableTimeoutSecondsLeft += 1;
//                                 }
//                               });
//                               timer.cancel();
//                               _discoverableTimeoutSecondsLeft = 0;
//                             } else {
//                               _discoverableTimeoutSecondsLeft -= 1;
//                             }
//                           });
//                         });
//                       });
//                     },
//                   )
//                 ],
//               ),
//             ),
//             const Divider(),
//             const ListTile(title: Text('Devices discovery and connection')),
//             SwitchListTile(
//               title: const Text('Auto-try specific pin when pairing'),
//               subtitle: const Text('Pin 1234'),
//               value: _autoAcceptPairingRequests,
//               onChanged: (bool value) {
//                 setState(() {
//                   _autoAcceptPairingRequests = value;
//                 });
//                 if (value) {
//                   FlutterBluetoothSerial.instance.setPairingRequestHandler(
//                       (BluetoothPairingRequest request) {
//                     print("Trying to auto-pair with Pin 1234");
//                     if (request.pairingVariant == PairingVariant.Pin) {
//                       return Future.value("1234");
//                     }
//                     return Future.value(null);
//                   });
//                 } else {
//                   FlutterBluetoothSerial.instance
//                       .setPairingRequestHandler(null);
//                 }
//               },
//             ),
//             ListTile(
//               title: ElevatedButton(
//                   child: const Text('Explore discovered devices'),
//                   onPressed: () async {
//                     final BluetoothDevice? selectedDevice =
//                         await Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return const DiscoveryPage();
//                         },
//                       ),
//                     );

//                     if (selectedDevice != null) {
//                       print('Discovery -> selected ${selectedDevice.address}');
//                     } else {
//                       print('Discovery -> no device selected');
//                     }
//                   }),
//             ),
//             ListTile(
//               title: ElevatedButton(
//                 child: const Text('Connect to paired device to chat'),
//                 onPressed: () async {
//                   final BluetoothDevice? selectedDevice =
//                       await Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return const SelectBondedDevicePage(checkAvailability: false);
//                       },
//                     ),
//                   );

//                   if (selectedDevice != null) {
//                     print('Connect -> selected ${selectedDevice.address}');
//                     _startChat(context, selectedDevice);
//                   } else {
//                     print('Connect -> no device selected');
//                   }
//                 },
//               ),
//             ),
//             const Divider(),
//             const ListTile(title: Text('Multiple connections example')),
//             ListTile(
//               title: ElevatedButton(
//                 child: ((_collectingTask?.inProgress ?? false)
//                     ? const Text('Disconnect and stop background collecting')
//                     : const Text('Connect to start background collecting')),
//                 onPressed: () async {
//                   if (_collectingTask?.inProgress ?? false) {
//                     await _collectingTask!.cancel();
//                     setState(() {
//                       /* Update for `_collectingTask.inProgress` */
//                     });
//                   } else {
//                     final BluetoothDevice? selectedDevice =
//                         await Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return const SelectBondedDevicePage(
//                               checkAvailability: false);
//                         },
//                       ),
//                     );

//                     if (selectedDevice != null) {
//                       await _startBackgroundTask(context, selectedDevice);
//                       setState(() {
//                         /* Update for `_collectingTask.inProgress` */
//                       });
//                     }
//                   }
//                 },
//               ),
//             ),
//             ListTile(
//               title: ElevatedButton(
//                 onPressed: (_collectingTask != null)
//                     ? () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return ScopedModel<BackgroundCollectingTask>(
//                                 model: _collectingTask!,
//                                 child: BackgroundCollectedPage(),
//                               );
//                             },
//                           ),
//                         );
//                       }
//                     : null,
//                 child: const Text('View background collected data'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _startChat(BuildContext context, BluetoothDevice server) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) {
//           return ChatPage(server: server);
//         },
//       ),
//     );
//   }

//   Future<void> _startBackgroundTask(
//     BuildContext context,
//     BluetoothDevice server,
//   ) async {
//     try {
//       _collectingTask = await BackgroundCollectingTask.connect(server);
//       await _collectingTask!.start();
//     } catch (ex) {
//       _collectingTask?.cancel();
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error occured while connecting'),
//             content: Text(ex.toString()),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("Close"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }

// ---------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:lite_rolling_switch/lite_rolling_switch.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'dart:async';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
  
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

//   @override
//   void initState() {
//     super.initState();

//     // Get current state
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });

//     Future.doWhile(() async {
//       // Wait if adapter not enabled
//       if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
//         return false;
//       }
//       await Future.delayed(const Duration(milliseconds: 0xDD));
//       return true;
//     });

//     // Listen for futher state changes
//     FlutterBluetoothSerial.instance
//         .onStateChanged()
//         .listen((BluetoothState state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[200],
//         body: Column(
//           children: [
//             const Center(
//                 child: Text(
//               'مرحبا بكم',
//               style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
//             )),
//             const Center(
//                 child: Text(
//               'جرب المصعد الإلكتروني',
//               style: TextStyle(fontSize: 15),
//             )),
//             Center(
//               child: Container(
//                 margin: const EdgeInsets.all(10.0),
//                 color: Colors.amber[600],
//                 width: 48.0,
//                 height: 300.0,
//               ),
//             ),
//             const SizedBox(
//               height: 20.0,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                         color: Colors.white),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         children: const [
//                           Center(child: Icon(Icons.devices)),
//                           SizedBox(
//                             height: 20.0,
//                           ),
//                           Center(child: Text('الجهاز'))
//                         ],
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                         color: Colors.white),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         children: const [
//                           Center(child: Icon(Icons.devices)),
//                           SizedBox(
//                             height: 20.0,
//                           ),
//                           Center(child: Text('الجهاز'))
//                         ],
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                         color: Colors.white),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         children: const [
//                           Center(child: Icon(Icons.devices)),
//                           SizedBox(
//                             height: 20.0,
//                           ),
//                           Center(child: Text('الجهاز'))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Container(
//                 child: Row(
//                   children: [
//                     Flexible(
//                       flex: 1,
//                       child: Container(
//                           color: Colors.redAccent[600],
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor: Colors.redAccent,
//                                       child: TextButton(
//                                           onPressed: () {},
//                                           child: const Text(
//                                             '1',
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           )),
//                                     ),
//                                     CircleAvatar(
//                                       backgroundColor: Colors.redAccent,
//                                       child: TextButton(
//                                           onPressed: () {},
//                                           child: const Text(
//                                             '2',
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           )),
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor: Colors.redAccent,
//                                       child: TextButton(
//                                           onPressed: () {},
//                                           child: const Text(
//                                             '3',
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           )),
//                                     ),
//                                     CircleAvatar(
//                                       backgroundColor: Colors.redAccent,
//                                       child: TextButton(
//                                           onPressed: () {},
//                                           child: const Text(
//                                             '4',
//                                             style:
//                                                 TextStyle(color: Colors.white),
//                                           )),
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )),
//                     ),
//                     Flexible(
//                       flex: 1,
//                       child: Container(
//                         decoration: const BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(20.0)),
//                             color: Color.fromARGB(255, 97, 56, 180)),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 60.0),
//                                 child: LiteRollingSwitch(
//                                   //initial value
//                                   value: _bluetoothState.isEnabled,
//                                   textOn: '',
//                                   textOff: '',
//                                   width: 50,
//                                   colorOn: Colors.greenAccent,
//                                   colorOff:
//                                       const Color.fromARGB(255, 120, 82, 185),
//                                   iconOn: Icons.done,
//                                   iconOff: Icons.remove_circle_outline,
//                                   textSize: 0.0,
//                                   onChanged: (bool value) {
//                                     // Do the request and update with the true value then
//                                     future() async {
//                                       // async lambda seems to not working
//                                       if (value) {
//                                         await FlutterBluetoothSerial.instance
//                                             .requestEnable();
//                                       } else {
//                                         await FlutterBluetoothSerial.instance
//                                             .requestDisable();
//                                       }
//                                     }

//                                     future().then((_) {
//                                       setState(() {});
//                                     });
//                                   },
//                                   onDoubleTap: () {},
//                                   onSwipe: () {},
//                                   onTap: () {

//                                   },
//                                 ),
//                               ),
//                               Column(
//                                 children: [
//                                   const Text(
//                                     'البلوتوث',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 20),
//                                   ),
//                                   const SizedBox(
//                                     height: 20,
//                                   ),
//                                   Text(
//                                     _bluetoothState.isEnabled == true
//                                         ? 'مفعل'
//                                         : 'غير مفعل',
//                                     style: const TextStyle(
//                                         fontSize: 20,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w700),
//                                   )
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
