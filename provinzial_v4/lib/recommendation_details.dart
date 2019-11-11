import 'package:flutter/material.dart';
import 'dart:io';
import 'assets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecommendationDetailsPage extends StatelessWidget {
  static final String path = "lib/src/pages/food/recipe_details.dart";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                Text(
                  "Hausratversicherung".toUpperCase(),
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                    "Eine Hausratversicherung hilft, wenn Ihre Besitztümer beschädigt oder gestohlen werden. Zum Beispiel bei Feuer, Einbruchdiebstahl oder extremen Wetterverhältnissen."),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  height: 30,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("59.32"),
                            SizedBox(width: 5.0),
                            Icon(Icons.euro_symbol),
                          ],
                        ),
                      ),
                      VerticalDivider(),
                      Expanded(
                        child: Text(
                          "Provinzial Rheinland",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      VerticalDivider(),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.home),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text("Eigentum")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                _buildStep(
                    leadingTitle: "01",
                    title: "Schritt".toUpperCase(),
                    content:
                        "Rufen Sie ihren Versicherungsberater an. Wir freuen uns auf Sie! Ob Möbel, Computer oder Kaffeemaschine: sicher besitzen Sie viele Dinge, die Ihnen wichtig sind. Und selbst wenn der materielle Wert einer einzelnen Sache gar nicht so groß ist - zusammengenommen kann eine erhebliche Summe zusammenkommen. Eine Hausratversicherung ist zu empfehlen, wenn Sie einen Schaden nicht auf eigene Rechnung tragen können oder wollen."),
                SizedBox(
                  height: 30.0,
                ),
                _buildStep(
                    leadingTitle: "02",
                    title: "Schritt".toUpperCase(),
                    content:
                        "Bestaunen Sie das umfangreiche Portfolio der Provinzial! Die Hausratversicherung greift, wenn diese Gegenstände durch ein versichertes Ereignis beschädigt oder abhandengekommen sind. Im Schadenfall übernimmt die Provinzial dann die Kosten für die Reparatur und Wiederbeschaffung - und das zum Neuwert. Wählen Sie die Versicherungssumme deshalb immer so, dass sie dem Wert Ihres gesamten Hausrates entspricht. "),
                SizedBox(
                  height: 30.0,
                ),
                _buildStep(
                    leadingTitle: "03",
                    title: "Schritt".toUpperCase(),
                    content:
                        "Schließen Sie die passende Versicherung zu Ihren Ansprüchen ab. Je nach Lage der versicherten Wohnung können die Risiken unterschiedlich sein. Wir unterstützen Sie bei der Beurteilung der individuellen Risiken und bei der Wertermittlung Ihres Hausrats. Im Ernstfall erhalten Sie so die finanzielle Hilfe, die Sie wirklich brauchen."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildBottomImage(String image) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
              image: CachedNetworkImageProvider(image), fit: BoxFit.cover)),
    );
  }

  Widget _buildStep({String leadingTitle, String title, String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: Color(0xff006646),
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Text(leadingTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0)),
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              SizedBox(
                height: 10.0,
              ),
              Text(content),
            ],
          ),
        )
      ],
    );
  }
}
