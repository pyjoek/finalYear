import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsPage({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(student['name']),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle avatar with initials
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColorLight,
                    child: Text(
                      student['name'] != null && student['name'].length > 1
                          ? student['name'].substring(0, 2).toUpperCase()
                          : 'NA',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColorDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildInfoRow(Icons.person, 'Name', student['name']),
                SizedBox(height: 16),
                _buildInfoRow(Icons.badge, 'RegNo', student['regno']),
                SizedBox(height: 16),
                _buildInfoRow(Icons.email, 'Email', student['email']),
                SizedBox(height: 16),
                _buildInfoRow(Icons.school, 'Department', student['department']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueGrey),
        SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value ?? 'N/A'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
