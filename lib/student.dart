import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:baraka/login.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final String studentName = "John Doe";
  final String department = "Computer Science";

  // Sample data for attendance (from January till now)
  final List<FlSpot> attendanceData = [
    FlSpot(0, 3),  // January
    FlSpot(1, 4),  // February
    FlSpot(2, 3),  // March
    FlSpot(3, 5),  // April
    FlSpot(4, 4),  // May
    FlSpot(5, 6),  // June
    FlSpot(6, 4),  // July
    FlSpot(7, 5),  // August
    FlSpot(8, 6),  // September
    FlSpot(9, 7),  // October
    FlSpot(10, 8), // November (current month)
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Student Dashboard"),
        centerTitle: true,
        leading: null,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()), // Navigate to Login on logout
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Student Name and Department
            Text(
              "Name: $studentName",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Department: $department",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),

            // Attendance Graph
            Text(
              "Attendance (January - Now)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: height * 0.3,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: attendanceData,
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      getTitles: (value) {
                        // Mapping month index to month name
                        switch (value.toInt()) {
                          case 0:
                            return 'Jan';
                          case 1:
                            return 'Feb';
                          case 2:
                            return 'Mar';
                          case 3:
                            return 'Apr';
                          case 4:
                            return 'May';
                          case 5:
                            return 'Jun';
                          case 6:
                            return 'Jul';
                          case 7:
                            return 'Aug';
                          case 8:
                            return 'Sep';
                          case 9:
                            return 'Oct';
                          case 10:
                            return 'Nov';
                          default:
                            return '';
                        }
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // QR Code Scanner Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRViewExample()),
                );
              },
              icon: Icon(Icons.qr_code),
              label: Text("Scan QR Code"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QR Code Scanner Page
class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Scan QR Code"),
        centerTitle: true,
      ),
      body: Center(
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR code result here
      print("QR Code Result: ${scanData.code}");
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
