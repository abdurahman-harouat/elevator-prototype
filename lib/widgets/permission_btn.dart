import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionBtn extends StatefulWidget {
  final String title;
  final Permission permission;
  const PermissionBtn(
      {required this.title, required this.permission, super.key});

  @override
  State<PermissionBtn> createState() => _PermissionBtnState();
}

class _PermissionBtnState extends State<PermissionBtn> {
  // Future<void> requestPermission() async {
  //   await widget.permission.request();
  // }

  Future<PermissionStatus> status() async {
    PermissionStatus status = await widget.permission.request();
    status == PermissionStatus.granted;
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            color: Color.fromARGB(255, 219, 216, 216)),
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: ListTile(
            title: Text(widget.title),
            onTap:
                //  () async {
                //   PermissionStatus bluetoothconnectStatus =
                //       await Permission.widgetpermission.request();
                //   if (bluetoothconnectStatus == PermissionStatus.granted) {
                //     print('bluetoothconnect activated');
                //   } else if (bluetoothconnectStatus == PermissionStatus.denied) {
                //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //         content: Text('this permission is recommended')));
                //   } else if (bluetoothconnectStatus ==
                //       PermissionStatus.permanentlyDenied) {
                //     openAppSettings(); //take me to app settings
                //   }
                // }
                () async {
              PermissionStatus status = await widget.permission.request();
              if (status == PermissionStatus.granted) {
                print('${widget.permission} activated');
              } else if (status == PermissionStatus.denied) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('this permission is recommended')));
              } else if (status == PermissionStatus.permanentlyDenied) {
                openAppSettings(); //take me to app settings
              }
            },
            leading:
                //  const CircleAvatar(
                //     backgroundColor: Colors.grey,
                //     child: Icon(
                //       Icons.bluetooth,
                //       color: Color.fromARGB(246, 33, 33, 33),
                //     ))
                FutureBuilder<PermissionStatus>(
              future: status(),
              builder: (BuildContext context,
                  AsyncSnapshot<PermissionStatus> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Use the snapshot data to set the CircleAvatar background color
                  return const CircleAvatar(
                    // backgroundColor: snapshot.data == PermissionStatus.granted
                    //     ? Colors.green
                    //     : Colors.grey,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.bluetooth,color: Colors.white,),
                  );
                } else {
                  // Show a loading indicator while the permission check is in progress
                  return const CircleAvatar(
                    // backgroundColor: snapshot.data == PermissionStatus.granted
                    //     ? Colors.green
                    //     : Colors.grey,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.bluetooth_disabled,color: Colors.white,),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
