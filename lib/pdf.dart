import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPDF extends StatelessWidget {
  final String date;
  final List<String> selectedStaff;
  final List<String> allStaff;
  const MyPDF({
    Key? key,
    required this.date,
    required this.selectedStaff,
    required this.allStaff,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double tableHeight = 0.75 * screenHeight; // 80% of the screen height

    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(date));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/AIRPORT_LOGO.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(width: 5),
            Text(
              'Airports Authority of India, C.C.S.I Airport, Lucknow',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                "Randomiser for Breath Analyser Examination (Ref: DGCA CAR SECTION 5 - AIR SAFETY SERIES F PART IV)",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Shift:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text(
                  "Duty: Morning/ Afternoon/ Night/ General",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text("Date: $formattedDate",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            // Display 'allStaff' and 'selectedStaff' tables side by side
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: tableHeight, // Set height dynamically
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Name of the ATCOs (Sh./Ms.)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Staff Name')),
                            ],
                            rows: allStaff
                                .map((staff) => DataRow(cells: [
                                      DataCell(Text(staff)),
                                    ]))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Add some space between tables
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: tableHeight, // Set height dynamically
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'The ATCOs to be undertaking the Breath Analyser Examination:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Staff Name')),
                            ],
                            rows: selectedStaff
                                .map((staff) => DataRow(cells: [
                                      DataCell(Text(staff)),
                                    ]))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              "Signature: _____________________________\nATS IN-CHARGE/ W.S.O.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
