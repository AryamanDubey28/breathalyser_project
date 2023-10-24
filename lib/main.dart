import 'dart:html';
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
  bool showPdfButton =
      false; // To control the visibility of "Show as PDF" button
  int pdfPage = 0; // Page number for PDF viewer

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
                  fontSize: 24),
            )
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
              maxLines: null, // Allow multiple lines for pasting
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                  labelText: 'Enter names (one per line)'),
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
              child: ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(names[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                selectRandomNames();
                setState(() {
                  showPdfButton = true; // Show the "Show as PDF" button
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
              child: ListView.builder(
                itemCount: selectedNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(selectedNames[index]),
                  );
                },
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
          // Remove '*' and '/' characters using regex
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
    int numberOfSelectedNames =
        (totalNames * 0.10).ceil(); // Select 10% of names

    // Use the random package to shuffle and select names randomly
    List<String> shuffledNames = List.from(names)..shuffle(random);
    selectedNames = shuffledNames.take(numberOfSelectedNames).toList();

    setState(() {});
  }

  void generateAndOpenPDF() async {
    // Create a text content for the text file
    String textContent = 'Name of the ATCOs (Sh./Ms.):\n';
    textContent += names.join('\n');
    textContent += '\n\nSelected ATCO and Timestamp:\n';
    textContent +=
        selectedNames.join(', ') + ' - ${DateTime.now().toLocal().toString()}';

    // Create a text blob
    final textBlob = Blob([textContent]);

    // Create a URL for the text blob
    final textFileUrl = Url.createObjectUrlFromBlob(textBlob);

    // Create an anchor element to trigger the download of the text file
    final anchor = AnchorElement(href: textFileUrl)
      ..setAttribute('download', 'selected_names.txt')
      ..setAttribute('target', 'blank') // Open in a new tab/window
      ..setAttribute('rel', 'noopener noreferrer') // Security attributes
      ..click();

    // Create the PDF as before
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

    final pdfBytes = pdf.save();
    final pdfBlob = Blob([pdfBytes]);

    // Create a URL for the PDF blob
    final pdfUrl = Url.createObjectUrlFromBlob(pdfBlob);

    // Open the PDF in a new tab
    AnchorElement(href: pdfUrl)
      ..setAttribute('target', 'blank')
      ..click();
  }
}
