import 'package:flutter/material.dart';
import 'package:finalyear/register.dart';
import 'package:finalyear/login.dart';
import 'dart:io' show Platform;
import 'package:network_info_plus/network_info_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  String? ssid = 'Unknown';
  final String allowedSSID = "ENG_NET";
  
  @override
  void initState() {
    super.initState();
    fetchWifiSSID();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
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
                      height: 200,
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
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                    if (ssid == allowedSSID) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Access Denied"),
                          content: const Text("Please connect to the Required Wi-Fi to proceed."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                //   },
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                //   child: const Text(
                //     "Login",
                //     style: TextStyle(fontSize: 18),
                //   ),
                // ),
                ElevatedButton(
                  onPressed: () {
                    if (ssid == allowedSSID) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Access Denied"),
                          content: const Text("Please connect to the Required Wi-Fi to proceed."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
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
