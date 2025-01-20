// Import 'dartssh2' package
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/services.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      // Connect to Liquid Galaxy system
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print('$_host,  $_passwordOrKey,  $_username,  $_port, $_numberOfRigs');
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');

      return false;
    }
  }

  Future<SSHSession?> execute(command) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      // Execute a demo command: echo "search=Lleida" >/tmp/query.txt

      final result = await _client?.run(command);
      print("Done");
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
    return null;
  }

//   11: Make functions for each of the tasks in the home screen
  Future<SSHSession?> relaunchLG() async {
    final relaunchCmd = """
        RELAUNCH_CMD="\\
        if [ -f /etc/init/lxdm.conf ]; then
          export SERVICE=lxdm
        elif [ -f /etc/init/lightdm.conf ]; then
          export SERVICE=lightdm
        else
          exit 1
        fi

        if [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
          echo $_passwordOrKey | sudo -S service \\\${SERVICE} start
        else
          echo $_passwordOrKey | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p $_passwordOrKey ssh -x -t lg@lg1 "\$RELAUNCH_CMD\"""";

    return await execute(
      relaunchCmd,
    );
  }

  Future<SSHSession?> sendKML1() async {
    const kml = 'kml1';
    final localPath = await _copyAssetToLocal('assets/kmls/kml1.kml');
    await kmlFileUpload(File(localPath), kml);
    await runKml(kml);
    return null;
  }

  Future<SSHSession?> flyToKml1() async {
    final orbit_command =
        'echo "flytoview=<gx:duration>1</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>5</longitude><latitude>52</latitude><range>100000</range><altitude>1000000</altitude><tilt>0</tilt><heading>0</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt';
    await execute(orbit_command);
  }

  Future<SSHSession?> sendKML2() async {
    const kml = 'kml2';
    final localPath = await _copyAssetToLocal('assets/kmls/kml2.kml');
    await kmlFileUpload(File(localPath), kml);
    await runKml(kml);
    return null;
  }

  Future<SSHSession?> flyToKml2() async {
    final orbit_command =
        'echo "flytoview=<gx:duration>1</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>17</longitude><latitude>26</latitude><range>100000</range><altitude>4000000</altitude><tilt>0</tilt><heading>0</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt';
    await execute(orbit_command);
  }

  Future<SSHSession?> clearKml() async {
    await _client?.run('echo "" > /tmp/query.txt');
    await _client?.run("echo '' > /var/www/html/kmls.txt");
    print('KMLs cleared');
    return null;
  }

  Future<SSHSession?> kmlFileUpload(File inputFile, String kmlName) async {
    final sftp = await _client?.sftp();
    final file = await sftp?.open('/var/www/html/$kmlName.kml',
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write);

    var fileSize = await inputFile.length();
    await file?.write(inputFile.openRead().cast(), onProgress: (progress) {
      print('Progress: ${progress / fileSize * 100}%');
    });
    return null;
  }

  Future<SSHSession?> runKml(String kmlName) async {
    await _client
        ?.run("echo 'http://lg1:81/$kmlName.kml' >> /var/www/html/kmls.txt");
    return null;
  }

  Future<String> _copyAssetToLocal(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final directory = Directory.systemTemp.createTempSync();
    final file = File('${directory.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }

  Future<SSHSession?> showLogo() async {
    final kmlContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>Logo</name>
    <open>1</open>
    <Folder>
          <ScreenOverlay>
      <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png</href>
      </Icon>
    </ScreenOverlay>
    </Folder>
  </Document>
</kml>
  ''';
    final result =
        await execute("echo '$kmlContent' > /var/www/html/kml/slave_3.kml");
    return result;
  }

  Future<SSHSession?> clearLogo() async {
    final kml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="slave_3">
  </Document>
</kml>
''';
    try {
      await execute("echo '$kml' > /var/www/html/kml/slave_3.kml");
      print("Slave deleted");
    } catch (e) {
      print(e);
    }
  }
}
