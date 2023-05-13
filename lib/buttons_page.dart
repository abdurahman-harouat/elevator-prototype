import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

//plugins
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:lottie/lottie.dart';

class ButtonsPage extends StatefulWidget {
  final BluetoothDevice server;

  const ButtonsPage({required this.server});

  @override
  _ButtonsPage createState() => _ButtonsPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ButtonsPage extends State<ButtonsPage> {
  
  // elevators data
  List elevators = [
    ['6'],
    ['5'],
    ['4'],
    ['3'],
    ['2'],
    ['1'],
  ];

  static final clientID = 0;
  
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);

  bool isConnecting = true;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      setState(() {
        isConnecting = false;
      });
    }).catchError((error) {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: 
        isConnecting
            ? Center(
                child: Lottie.asset(
                  'assets/lottie/99851-loading-device.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              )
            : 
            Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: FittedBox(
                          child: Text(
                            "إضغط على الأزرار للتحكم في المصعد",
                            style: GoogleFonts.cairoPlay(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Divider(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Expanded(
                        child: GridView.builder(
                      itemCount: elevators.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () => _floor(elevators[index][0]),
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                color: Colors.white),
                            child: Center(
                                child: Text(
                              elevators[index][0],
                              style: GoogleFonts.cairoPlay(
                                  fontSize: 35, color: Colors.grey[800]),
                            )),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _floor(String floor) async {
    try {
      connection!.output.add(Uint8List.fromList(utf8.encode(floor + "\r\n")));
      await connection!.output.allSent;

      setState(() {
        messages.add(_Message(clientID, floor));
      });
    } catch (e) {
      // Ignore error, but notify state
      setState(() {});
    }
  }
}
