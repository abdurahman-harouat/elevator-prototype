import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

//plugins
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  // elevators data
  List elevators = [
    ['6', true],
    ['5', false],
    ['4', false],
    ['3', false],
    ['2', false],
    ['1', false],
  ];

  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      backgroundColor: Colors.grey[300],
      // appBar: AppBar(
      //     title: (isConnecting
      //         ? Text('Connecting chat to ' + serverName + '...')
      //         : isConnected
      //             ? Text('Live chat with ' + serverName)
      //             : Text('Chat log with ' + serverName))),
      body: SafeArea(
        child: isConnecting
            ? Center(
                child: Lottie.asset(
                  'assets/lottie/99851-loading-device.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              )
            : Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    // Flexible(
                    //   child: ListView(
                    //       padding: const EdgeInsets.all(12.0),
                    //       controller: listScrollController,
                    //       children: list),
                    // ),
                    // Row(
                    //   children: <Widget>[
                    //     Flexible(
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(20.0),
                    //         child: Container(
                    //           margin: const EdgeInsets.only(left: 16.0),
                    //           child: TextField(
                    //             style: const TextStyle(fontSize: 15.0),
                    //             controller: textEditingController,
                    //             decoration: InputDecoration.collapsed(
                    //               hintText: isConnecting
                    //                   ? 'يتم الإتصال بالجهاز'
                    //                   : isConnected
                    //                       ? 'أكتب رقم المصعد...'
                    //                       : 'تم فصل الإتصال',
                    //               hintStyle: const TextStyle(color: Colors.grey),
                    //             ),
                    //             enabled: isConnected,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       margin: const EdgeInsets.all(8.0),
                    //       child: IconButton(
                    //           icon: const Icon(Icons.send),
                    //           onPressed: isConnected
                    //               ? () => _sendMessage(textEditingController.text)
                    //               : null),
                    //     ),
                    //   ],
                    // )
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: FittedBox(
                          child: Text(
                            "إضغط ليصل إليك المصعد",
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
                            decoration: BoxDecoration(
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
                    // Flexible(
                    //   flex: 1,
                    //   child: Row(
                    //     children: [
                    //       Flexible(
                    //           flex: 1,
                    //           child: Center(
                    //             child: FractionallySizedBox(
                    //               widthFactor: 0.9,
                    //               child: Container(
                    //                   decoration: const BoxDecoration(
                    //                       // borderRadius: BorderRadius.all(Radius.circular(20)),
                    //                       color: Color.fromARGB(8, 22, 130, 219),
                    //                       border: Border(
                    //                         top: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         bottom: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         right: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         left: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                       )),
                    //                   child: TextButton(
                    //                       onPressed: () => _floor('6'),
                    //                       child: const Center(
                    //                         child: Text(
                    //                           '6',
                    //                           style: TextStyle(
                    //                               color: Colors.tealAccent,
                    //                               fontSize: 25),
                    //                         ),
                    //                       ))),
                    //             ),
                    //           )),
                    //       Flexible(
                    //           flex: 1,
                    //           child: Center(
                    //             child: FractionallySizedBox(
                    //               widthFactor: 0.9,
                    //               child: Container(
                    //                   decoration: const BoxDecoration(
                    //                       // borderRadius: BorderRadius.all(Radius.circular(20)),
                    //                       color: Color.fromARGB(8, 22, 130, 219),
                    //                       border: Border(
                    //                         top: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         bottom: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         right: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                         left: BorderSide(
                    //                             color: Colors.tealAccent),
                    //                       )),
                    //                   child: TextButton(
                    //                       onPressed: () => _floor('5'),
                    //                       child: const Center(
                    //                         child: Text(
                    //                           '5',
                    //                           style: TextStyle(
                    //                               color: Colors.tealAccent,
                    //                               fontSize: 25),
                    //                         ),
                    //                       ))),
                    //             ),
                    //           )),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Flexible(
                    //   flex: 1,
                    //   child: Row(
                    //     children: [
                    //       // forth floor
                    //       Flexible(
                    //         flex: 1,
                    //         child: Center(
                    //           child: FractionallySizedBox(
                    //             widthFactor: 0.9,
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                   border:
                    //                       Border.all(color: Colors.tealAccent)),
                    //               child: Column(
                    //                 children: [
                    //                   //elevator head "numerote"
                    //                   Flexible(
                    //                     flex: 1,
                    //                     child: FractionallySizedBox(
                    //                       child: Container(
                    //                         decoration: BoxDecoration(
                    //                             border: Border.all(
                    //                                 color: Colors.tealAccent)),
                    //                         child: Center(
                    //                             child: OutlinedButton(
                    //                           onPressed: () => _floor('4'),
                    //                           child: const Text(
                    //                             '4',
                    //                             style: TextStyle(
                    //                                 fontSize: 18,
                    //                                 color: Colors.white,
                    //                                 fontWeight: FontWeight.bold),
                    //                           ),
                    //                         )),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   // elevator door in this row
                    //                   Flexible(
                    //                     flex: 3,
                    //                     child: Row(
                    //                       children: [
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         ),
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       //third floor
                    //       Flexible(
                    //         flex: 1,
                    //         child: Center(
                    //           child: FractionallySizedBox(
                    //             widthFactor: 0.9,
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                   border:
                    //                       Border.all(color: Colors.tealAccent)),
                    //               child: Column(
                    //                 children: [
                    //                   //elevator head "numerote"
                    //                   Flexible(
                    //                     flex: 1,
                    //                     child: FractionallySizedBox(
                    //                       child: Container(
                    //                         decoration: BoxDecoration(
                    //                             border: Border.all(
                    //                                 color: Colors.tealAccent)),
                    //                         child: Center(
                    //                             child: OutlinedButton(
                    //                           onPressed: () => _floor('3'),
                    //                           child: const Text(
                    //                             '3',
                    //                             style: TextStyle(
                    //                                 fontSize: 18,
                    //                                 color: Colors.white,
                    //                                 fontWeight: FontWeight.bold),
                    //                           ),
                    //                         )),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   // elevator door in this row
                    //                   Flexible(
                    //                     flex: 3,
                    //                     child: Row(
                    //                       children: [
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         ),
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Flexible(
                    //   flex: 1,
                    //   child: Row(
                    //     children: [
                    //       // second floor
                    //       Flexible(
                    //         flex: 1,
                    //         child: Center(
                    //           child: FractionallySizedBox(
                    //             widthFactor: 0.9,
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                   border:
                    //                       Border.all(color: Colors.tealAccent)),
                    //               child: Column(
                    //                 children: [
                    //                   //elevator head "numerote"
                    //                   Flexible(
                    //                     flex: 1,
                    //                     child: FractionallySizedBox(
                    //                       child: Container(
                    //                         decoration: BoxDecoration(
                    //                             border: Border.all(
                    //                                 color: Colors.tealAccent)),
                    //                         child: Center(
                    //                             child: OutlinedButton(
                    //                           onPressed: () => _floor('2'),
                    //                           child: const Text(
                    //                             '2',
                    //                             style: TextStyle(
                    //                                 fontSize: 18,
                    //                                 color: Colors.white,
                    //                                 fontWeight: FontWeight.bold),
                    //                           ),
                    //                         )),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   // elevator door in this row
                    //                   Flexible(
                    //                     flex: 3,
                    //                     child: Row(
                    //                       children: [
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         ),
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       // Flexible(
                    //       //     flex: 1,
                    //       //     child: Center(
                    //       //       child: FractionallySizedBox(
                    //       //         widthFactor: 0.9,
                    //       //         heightFactor: 1,
                    //       //         child: Container(
                    //       //             decoration: const BoxDecoration(
                    //       //                 // borderRadius: BorderRadius.all(Radius.circular(20)),
                    //       //                 color: Color.fromARGB(8, 22, 130, 219),
                    //       //                 border: Border(
                    //       //                   top: BorderSide(
                    //       //                       color: Colors.tealAccent),
                    //       //                   bottom: BorderSide(
                    //       //                       color: Colors.tealAccent),
                    //       //                   right: BorderSide(
                    //       //                       color: Colors.tealAccent),
                    //       //                   left: BorderSide(
                    //       //                       color: Colors.tealAccent),
                    //       //                 )),
                    //       //             child: Column(
                    //       //               children: [
                    //       //                 FractionallySizedBox(
                    //       //                   widthFactor: 0.9,
                    //       //                   heightFactor: 0.2,
                    //       //                   child: Container(
                    //       //                     decoration: BoxDecoration(
                    //       //                         border: Border(
                    //       //                             bottom: BorderSide(
                    //       //                                 color: Colors.teal),
                    //       //                             left: BorderSide(
                    //       //                                 color:
                    //       //                                     Colors.tealAccent),
                    //       //                             right: BorderSide(
                    //       //                                 color: Colors
                    //       //                                     .tealAccent))),
                    //       //                     child: TextButton(
                    //       //                         onPressed: () => _floor('1'),
                    //       //                         child: const Text(
                    //       //                           '1',
                    //       //                           style: TextStyle(
                    //       //                               color: Colors.tealAccent,
                    //       //                               fontSize: 25),
                    //       //                         )),
                    //       //                   ),
                    //       //                 ),
                    //       //                 Expanded(
                    //       //                   child: Container(
                    //       //                     decoration: BoxDecoration(
                    //       //                         border: Border(
                    //       //                             bottom: BorderSide(
                    //       //                                 color: Colors.teal),
                    //       //                             left: BorderSide(
                    //       //                                 color:
                    //       //                                     Colors.tealAccent),
                    //       //                             right: BorderSide(
                    //       //                                 color: Colors
                    //       //                                     .tealAccent))),
                    //       //                   ),
                    //       //                 )
                    //       //               ],
                    //       //             )),
                    //       //       ),
                    //       //     )),
                    //       // first floor
                    //       Flexible(
                    //         flex: 1,
                    //         child: Center(
                    //           child: FractionallySizedBox(
                    //             widthFactor: 0.9,
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                   border:
                    //                       Border.all(color: Colors.tealAccent)),
                    //               child: Column(
                    //                 children: [
                    //                   //elevator head "numerote"
                    //                   Flexible(
                    //                     flex: 1,
                    //                     child: FractionallySizedBox(
                    //                       child: Container(
                    //                         decoration: BoxDecoration(
                    //                             border: Border.all(
                    //                                 color: Colors.tealAccent)),
                    //                         child: Center(
                    //                             child: OutlinedButton(
                    //                           onPressed: () => _floor('1'),
                    //                           child: const Text(
                    //                             '1',
                    //                             style: TextStyle(
                    //                                 fontSize: 18,
                    //                                 color: Colors.white,
                    //                                 fontWeight: FontWeight.bold),
                    //                           ),
                    //                         )),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   // elevator door in this row
                    //                   Flexible(
                    //                     flex: 3,
                    //                     child: Row(
                    //                       children: [
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         ),
                    //                         Expanded(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                                 border: Border.all(
                    //                                     color:
                    //                                         Colors.tealAccent)),
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  // void _sendMessage(String text) async {
  //   text = text.trim();
  //   textEditingController.clear();

  //   if (text.length > 0) {
  //     try {
  //       connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
  //       await connection!.output.allSent;

  //       setState(() {
  //         messages.add(_Message(clientID, text));
  //       });

  //       Future.delayed(Duration(milliseconds: 333)).then((_) {
  //         listScrollController.animateTo(
  //             listScrollController.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 333),
  //             curve: Curves.easeOut);
  //       });
  //     } catch (e) {
  //       // Ignore error, but notify state
  //       setState(() {});
  //     }
  //   }
  // }

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
