import 'dart:html';
import 'dart:html' as html;
import 'package:breathalyser/pdf.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io' as dart_io;
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Name Selector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  List<String> names = [];
  List<String> selectedNames = [];
  bool showPdfButton = false;
  int pdfPage = 0;
  String timestamp = '';
  String textContent = ''; // Maintain the content here
  late Blob textBlob;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(width: 10),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Randomiser for Breath Analyser Examination (Ref: DGCA CAR SECTION 5 - AIR SAFETY SERIES F PART IV)",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: nameController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Enter names (one per line)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addNamesFromTextField();
              },
              child: const Text('Add Names'),
            ),
            const SizedBox(height: 16),
            const Text('All Inputted Names:'),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black),
                ),
                child: ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(names[index]),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                selectRandomNames();
                setState(() {
                  showPdfButton = true;
                });
              },
              child: const Text('Randomise'),
            ),
            if (showPdfButton)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    generateAndOpenPDF();
                  },
                  child: const Text('Show as PDF'),
                ),
              ),
            const SizedBox(height: 16),
            const Text('Randomly Selected Names:'),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(selectedNames[index]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                        'Timestamp: $timestamp'), // Displays the timestamp when randomised
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addNamesFromTextField() {
    String text = nameController.text.trim();
    if (text.isNotEmpty) {
      List<String> enteredNames = text.split('\n');
      for (String name in enteredNames) {
        name = name.trim();
        if (name.isNotEmpty) {
          name = name.replaceAll(RegExp(r'[*\/]'), '');
          setState(() {
            names.add(name);
          });
        }
      }
      nameController.clear();
    }
  }

  void selectRandomNames() {
    Random random = Random();
    int totalNames = names.length;
    int numberOfSelectedNames = (totalNames * 0.10).ceil();

    List<String> shuffledNames = List.from(names)..shuffle(random);
    selectedNames = shuffledNames.take(numberOfSelectedNames).toList();

    // Updates the timestamp when randomised
    timestamp = DateTime.now().toLocal().toString();

    setState(() {});
  }

  void generateAndOpenPDF() {
    // Create a PDF document as before
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: selectedNames
                  .map(
                    (name) => pw.Text(name),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );

    DateTime now = DateTime.now();
    String generatedDate = now.toLocal().toString();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyPDF(
                date: generatedDate,
                selectedStaff: selectedNames,
                allStaff: names,
              )),
    );
  }
}

// void generateAndOpenPDF() async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Column(
//               children: selectedNames
//                   .map(
//                     (name) => pw.Text(name),
//                   )
//                   .toList(),
//             ),
//           );
//         },
//       ),
//     );

//     final pdfBytes = pdf.save();
//     final blob = Blob([pdfBytes]);
//     final url = Url.createObjectUrlFromBlob(blob);
//     DateTime now = DateTime.now();
//     String generatedDate = now.toLocal().toString();

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => MyPDF(
    //             date: generatedDate,
    //             selectedStaff: selectedNames,
    //             allStaff: names,
    //           )),
    // );
//   }
