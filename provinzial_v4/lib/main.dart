import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provinzial_v4/recommendation_details.dart';
import 'package:url_launcher/url_launcher.dart';

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  //
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  final Color iconColor = Color(0xffFFC107);
  final Color color1 = Color(0xff006646); // #006646
  final Color color2 = Color(0xff006646);
  final Color color3 = Color(0xff69A82F);

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  void _launchInsuranceURL() async {
    const url = 'https://transactiongenerator.azurewebsites.net/r/ird/ha';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
          height: double.infinity,
          child: Stack(children: <Widget>[
            Positioned(
              top: 350,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color2, color3],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
              ),
            ),
            Positioned(
                top: 350,
                left: 0,
                right: 150,
                bottom: 80,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50.0),
                    ),
                  ),
                )),
            Positioned(
              top: 350,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 40.0),
                    Text(
                      "Hausratversicherung".toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      "Basierend auf deinem Einkauf bei IKEA \nschlagen wir Dir eine Hausratversicherung vor.",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                    SizedBox(height: 50.0),
                    SizedBox(
                      height: 30.0,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Text(
                            "59.32",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                          SizedBox(width: 5.0),
                          Icon(Icons.euro_symbol, color: Colors.white),
                          Spacer(),
                          VerticalDivider(color: Colors.white),
                          Spacer(),
                          Text(
                            "Provinzial Rheinland",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                          Spacer(),
                          VerticalDivider(color: Colors.white),
                          Spacer(),
                          Icon(Icons.home, color: Colors.white),
                          SizedBox(width: 5.0),
                          Text(
                            "Eigentum",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('JETZT BUCHEN'),
                          textColor: color1,
                          color: iconColor,
                          onPressed: _launchInsuranceURL,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 380,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: Colors.black38, blurRadius: 30.0)
              ]),
              child: SizedBox(
                height: 350,
                child: Image.asset(
                  'assets/images/kinderterror.jpg',
                  fit: BoxFit.cover,
                ),
                // PNetworkImage(
                //   recommendationUnfall,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            Positioned(
              top: 325,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: IconButton(
                  color: color1,
                  onPressed: () {},
                  icon: Icon(
                    Icons.home,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 325,
              right: 20,
              child: RaisedButton(
                child: Text("Mehr lesen".toUpperCase()),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RecommendationDetailsPage()));
                },
              ),
            ),
            Container(
                height: 70.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )),
          ]),
        ),
      ),
    );
  }
}

class PushMessagingExample extends StatefulWidget {
  @override
  _PushMessagingExampleState createState() => _PushMessagingExampleState();
}

class _PushMessagingExampleState extends State<PushMessagingExample> {
  String _homeScreenText = "Waiting for token...";
  Map<String, String> _message = {
    'url': 'https://transactiongenerator.azurewebsites.net/r/ird/ha',
    'category': 'Kategorie...',
    'creditor': 'Grund',
    'company': 'Firma',
    'versicherung': 'Hausrat?'
  };
  bool _topicButtonsDisabled = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _topicController =
      TextEditingController(text: 'topic');

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
    printToken();
    configureFirebaseMessage();
  }

  void printToken() async {
    var token = await _firebaseMessaging.getToken();
    print("Instance ID: " + token);
    var url =
        'http://transactiongenerator.azurewebsites.net/rest/update_device_token/$token';
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void configureFirebaseMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      titlePadding: EdgeInsets.all(16.0),
      content: Text("Es gibt eine Empfehlung für Dich!"),
      actions: <Widget>[
        FlatButton(
          child: const Text('Weg damit!'),
          textColor: Color(0xff006646),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        RaisedButton(
          child: const Text('Zeig her!'),
          color: Color(0xff006646),
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  void _launchURL() async {
    const url = 'https://www.provinzial.com/hackathon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // For testing -- simulate a message being received
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(<String, dynamic>{
          "data": <String, String>{
            "id": "2",
            "status": "out of stock",
          },
        }),
        tooltip: 'Simulate Message',
        child: const Icon(Icons.message),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
            ),
            new RaisedButton(
              onPressed: _launchURL,
              child: new Text('Gehe zur Website'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearTopicText() {
    setState(() {
      _topicController.text = "";
      _topicButtonsDisabled = true;
    });
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Provinzial Recommender',
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xff006646),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: PushMessagingExample(),
    ),
  );
}
