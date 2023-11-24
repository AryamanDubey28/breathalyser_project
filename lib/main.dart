import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:breathalyser/pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:pdf/widgets.dart' as pw;

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

// Function to save content to a file
  void saveToFile(String content) async {
    final directory = await getDownloadsDirectory();
    final file = File('${directory!.path}/Randomised_ATCOs.txt');

    // Write to the file
    await file.writeAsString(content);
  }

//   // Function to save content to a file
//   void saveToFile(String content) async {
//     final path = await getFilePath();
//     final file = File('$path/Randomised_ATCOs.txt');

//     // Write to the file
//     await file.writeAsString(content);
//   }

// Function to get the file path
  Future<String> getFilePath() async {
    final directory = await getDownloadsDirectory();
    return directory!.path; // Note the non-null assertion operator (!)
  }

// Function to write content to a file
  Future<void> writeToTextFile(String content) async {
    final path = await getFilePath();
    final file = File('$path/Randomised_ATCOs.txt');

    // Write to the file
    await file.writeAsString(content);
  }

// Function to read content from a file
  Future<String> readFromTextFile() async {
    final path = await getFilePath();
    final file = File('$path/Randomised_ATCOs.txt');

    // Read from the file
    if (await file.exists()) {
      return await file.readAsString();
    } else {
      return 'File not found';
    }
  }

  // Function to add names from the text field to the list
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

  // Function to randomly select names
  void selectRandomNames() {
    Random random = Random();
    int totalNames = names.length;
    int numberOfSelectedNames = (totalNames * 0.10).ceil();

    List<String> shuffledNames = List.from(names)..shuffle(random);
    selectedNames = shuffledNames.take(numberOfSelectedNames).toList();

    // Updates the timestamp when randomised
    timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal());

    setState(() {});
  }

  // Function to update the text file with selected names
  void updateTextFile() async {
    // Appends the selected names to the existing content
    textContent +=
        '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal())}';
    textContent += '\nName of the ATCOs (Sh./Ms.):\n\n';
    textContent += names.join('\n');
    textContent +=
        '\n\nSelected ATCO - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal())}:\n';
    textContent += selectedNames.join(', ') + '\n';
    textContent +=
        "-------------------------------------------------\n"; //Divider between each randomization

    // Get the file path
    final path = await getFilePath();

    // Open the file for appending
    final file = File('$path/Randomised_ATCOs.txt');

    try {
      // Append the updated content to the file
      await file.writeAsString(textContent, mode: FileMode.append);
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  // Function to navigate to the PDF page
  void routeToMyPDF(String formattedDate) {
    // Opens the PDF page with the information
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyPDF(
                date: formattedDate,
                selectedStaff: selectedNames,
                allStaff: names,
              )),
    );
  }

  // Function to generate and open a PDF
  void generateAndOpenPDF() async {
    // Update the text file with new information
    updateTextFile();
    // Save the content to a file
    saveToFile(textContent);

    // Download the text file
    await downloadTextFile();

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

    // Gets the dates and information for the timestamps
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now.toLocal());

    // Open the PDF page with the information
    routeToMyPDF(formattedDate);
  }

  Future<void> downloadTextFile() async {
    try {
      final path = await getFilePath();
      final file = File('$path/randomized_names.txt');

      if (await file.exists()) {
        // Trigger download by opening the file in an external app
        await OpenFile.open(file.path);
      } else {
        print('File not found');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
}

// Future appendNamesToFile() async {
//     // Open history.txt and append names to it then close file
//     print("in method at start");
//     dart_io.File file = dart_io.File('/history.txt');
//     print("made file object");
//     // Open the file for appending
//     IOSink? sink;
//     print("made sink");
//     try {
//       print("in try");
//       sink = file.openWrite(mode: FileMode.append);
//       print("opened file in append mode");
//       // Append each name from the list to the file
//       sink.writeln("\nName of the ATCOs (Sh./Ms.):\n\n");
//       for (String name in names) {
//         sink.writeln(name);
//       }
//       sink.writeln(
//           DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal()));
//       sink.writeln("-----------------------------------------------------");
//       print("wrote to file");
//     } finally {
//       // Close the file
//       sink?.close();
//       print("closed file");
//     }
//     // Should be async?
// }
