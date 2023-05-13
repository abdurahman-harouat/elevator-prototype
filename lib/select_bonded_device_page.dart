import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({Key? key, this.checkAvailability = true})
      : super(key: key);

  @override
  _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
}

enum _DeviceAvailability { maybe, yes }

class _DeviceWithAvailability {
  final BluetoothDevice device;
  final _DeviceAvailability availability;
  final int? rssi;

  _DeviceWithAvailability(this.device, this.availability, {this.rssi});
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = [];

  @override
  void initState() {
    super.initState();

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((bondedDevices) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(devices[index].device);
                  },
                  enabled: true,
                  title: Text(
                    '${devices[index].device.name}',
                    style: GoogleFonts.bebasNeue(fontSize: 22),
                  ),
                  subtitle: Text(
                    devices[index].device.address,
                    style: GoogleFonts.aBeeZee(),
                  ),
                  trailing: const Icon(Icons.link),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
