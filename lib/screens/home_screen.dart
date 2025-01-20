import 'package:flutter/material.dart';
import 'package:lg_connection/components/connection_flag.dart';
//Import connections/ssh.dart
import 'package:lg_connection/connections/ssh.dart';

import '../components/reusable_card.dart';

bool connectionStatus = false;
//17: Initialize const String searchPlace

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize SSH instance just like you did in the settings_page.dart, just uncomment the lines below, this time use the same instance for each of the tasks
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  Future<void> _relaunchLG() async {
    await ssh.relaunchLG();
  }

  Future<void> _sendKml1() async {
    await ssh.sendKML1();
    await ssh.flyToKml1();
  }

  Future<void> _sendKml2() async {
    await ssh.sendKML2();
    await ssh.flyToKml2();
  }

  Future<void> _clearKml() async {
    await ssh.clearKml();
  }

  Future<void> _showLogo() async {
    await ssh.showLogo();
  }

  Future<void> _clearLogo() async {
    await ssh.clearLogo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Connection'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: ConnectionFlag(
                status: connectionStatus,
              )),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      await _relaunchLG();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Relaunch LG',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      await _showLogo();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Add Logo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      // TODO 15: Implement selectKML1() as async task
                      await _sendKml1();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Select KML 1',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      //: Implement selectKML2() as async task and test
                      await _sendKml2();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Select KML 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      //  : Implement clearKML() as async task and test
                      await _clearKml();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Clear KML',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ReusableCard(
                    colour: Colors.purple,
                    onPress: () async {
                      await _clearLogo();
                    },
                    cardChild: const Center(
                      child: Text(
                        'Clear Logo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
