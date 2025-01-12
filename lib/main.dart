import 'package:flutter/material.dart';
import 'package:finalyear/register.dart';
import 'package:finalyear/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform; // For platform checks
import 'package:network_info_plus/network_info_plus.dart'; // Supports multiple platforms

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  String? ssid = 'Unknown'; // Holds the Wi-Fi SSID or "Unknown"

  @override
  void initState() {
    super.initState();
    fetchWifiSSID(); // Fetch the SSID when the app initializes
  }

  // Fetch Wi-Fi SSID based on platform
  Future<void> fetchWifiSSID() async {
    try {
      final info = NetworkInfo();
      String? wifiName;

      if (Platform.isAndroid || Platform.isIOS || Platform.isLinux) {
        wifiName = await info.getWifiName(); // Works on Android/iOS
      } else if (Platform.isWindows || Platform.isMacOS) {
        wifiName = 'Not Supported on this Platform'; // Handle unsupported platforms
      } else {
        wifiName = 'Not Available'; // For other cases like web
      }

      setState(() {
        ssid = wifiName ?? 'Unknown';
      });
    } catch (e) {
      print('Error fetching Wi-Fi SSID: $e');
      setState(() {
        ssid = 'Error Fetching SSID';
      });
    }
  }

  // Send SSID to backend
  Future<void> sendSSIDToBackend() async {
    if (ssid == null || ssid == 'Unknown' || ssid == 'Not Supported on this Platform') {
      print("SSID not available or unsupported on this platform.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/validate_ssid'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ssid': ssid}),
      );

      if (response.statusCode == 200) {
        print('SSID validation successful: ${response.body}');
      } else {
        print('SSID validation failed: ${response.body}');
      }
    } catch (e) {
      print('Error sending SSID to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Zanzibar University',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Image.asset(
                        'asset/image.png', // Path to your logo image
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Connected Wi-Fi: $ssid',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    sendSSIDToBackend(); // Send SSID to backend on login
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 18),
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
