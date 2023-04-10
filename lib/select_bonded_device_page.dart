import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({super.key, this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;
  bool enabled = true;

  // _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    // start discovering
    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  // function that discovers devices
  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var device = i.current;
          if (device.device == r.device) {
            device.availability = _DeviceAvailability.yes;
            device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<BluetoothDeviceListEntry> list = devices
    //     .map((device) => BluetoothDeviceListEntry(
    //           device: device.device,
    //           rssi: device.rssi,
    //           enabled: device.availability == _DeviceAvailability.yes,
    //           onTap: () {
    //             Navigator.of(context).pop(device.device);
    //           },
    //         ))
    //     .toList();
    return Scaffold(
      // appBar: AppBar(
      //   actions: <Widget>[
      //     _isDiscovering
      //         ? FittedBox(
      //             child: Container(
      //               margin: new EdgeInsets.all(16.0),
      //               child: CircularProgressIndicator(
      //                 valueColor: AlwaysStoppedAnimation<Color>(
      //                   Colors.white,
      //                 ),
      //               ),
      //             ),
      //           )
      //         : IconButton(
      //             icon: Icon(Icons.replay),
      //             onPressed: _restartDiscovery,
      //           )
      //   ],
      // ),
      // body: Column(
      //   children: [
      //     const SizedBox(
      //       height: 20,
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(20.0),
      //       child: Directionality(
      //           textDirection: TextDirection.rtl,
      //           child: FractionallySizedBox(
      //               widthFactor: 1,
      //               child: Container(
      //                   child: const Text(
      //                 'الأجهزة المقترنة',
      //                 style: TextStyle(fontSize: 35),
      //               )))),
      //     ),
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: devices.length,
      //         itemBuilder: (context, index) {
      //           return ListTile(
      //             onTap: () {
      //           Navigator.of(context).pop(devices[index].device);
      //             },
      //             enabled: enabled,
      //             title: Text('${devices[index].device.name}'),
      //             subtitle: Text(devices[index].device.address),
      //             trailing: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 devices[index].device.address != null
      //                     ? Container(
      //                         margin: const EdgeInsets.all(8.0),
      //                       )
      //                     : const SizedBox(width: 0, height: 0),
      //                 devices[index].device.isConnected
      //                     ? const Icon(Icons.import_export)
      //                     : const SizedBox(width: 0, height: 0),
      //                 devices[index].device.isBonded
      //                     ? const Icon(Icons.link)
      //                     : const SizedBox(width: 0, height: 0),
      //               ],
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Directionality(
                textDirection: TextDirection.rtl,
                child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Container(
                        child: Text(
                      'الأجهزة المقترنة',
                      style: GoogleFonts.cairoPlay(fontSize: 30),
                    )))),
          ),
          // Expanded(child: ListView(children: list)),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(devices[index].device);
                  },
                  enabled: enabled,
                  title: Text('${devices[index].device.name}', style: GoogleFonts.bebasNeue(fontSize: 22),),
                  subtitle: Text(devices[index].device.address, style: GoogleFonts.aBeeZee(),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      devices[index].device.address != null
                          ? Container(
                              margin: const EdgeInsets.all(8.0),
                            )
                          : const SizedBox(width: 0, height: 0),
                      devices[index].device.isConnected
                          ? const Icon(Icons.import_export)
                          : const SizedBox(width: 0, height: 0),
                      devices[index].device.isBonded
                          ? const Icon(Icons.link)
                          : const SizedBox(width: 0, height: 0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
