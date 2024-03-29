import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_apps/device_apps.dart';
import 'package:launch_review/launch_review.dart';

import 'live.dart';
import 'messages.dart';
import 'web.dart';
import 'constants.dart';

 // TODO: Cambiar paquete

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: PRIMARY_COLOR,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = APP_TITLE;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _messaging = FirebaseMessaging();

  int _currentIndex = 0;
  bool notifications = false;

  List<Widget> _children = [
    WebTab(),
//    LiveTab(),
    MessagesTab()
  ];

  void onTapTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1) notifications = false;
    });
  }

  var badge = Icon(
    Icons.brightness_1,
    size: 12.0,
    color: Colors.red,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: ACCENT_COLOR,
        type: BottomNavigationBarType.fixed,
        onTap: onTapTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.web),
              title: Text('Inicio')
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.fiber_manual_record),
            title: Text('En vivo'),
          ),*/
          BottomNavigationBarItem(
            icon: Stack(children: <Widget>[
              Icon(Icons.mail),
              Positioned(
                  top: -1.0,
                  right: -1.0,
                  child: Stack(
                    children: <Widget>[
                      (notifications) ? badge : Container()
                    ],
                  ))
            ],),
            title: Text('Mensajes'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    /*DeviceApps.isAppInstalled(APP_TO_LAUNCH).then((result) {
      if (result) {
        DeviceApps.openApp(APP_TO_LAUNCH); 
        print('Installed');
      } else {
        // TODO: Añadir el ID de la app en App Store
        LaunchReview.launch(androidAppId: APP_TO_LAUNCH, iOSAppId: AR_APP_ID_IOS);
        print('GetApp');
      }
    });*/

    _messaging.requestNotificationPermissions();
    _messaging.subscribeToTopic('informe');
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print(message['notification']);
        print('on message $message');
        setState(() {
          if (_currentIndex != 2)
            notifications = true;
          else
            _currentIndex = 2;
        });
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _messaging.getToken().then((token) {
      print("token: "+token);
    });
  }
}
