import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:html' as html;

void main() {
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
  String textContent = ''; // Global variable to store text content

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Name Selector'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Randomiser for Breath Analyser Examination",
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
                    appendToTextFile();
                  },
                  child: const Text('Append to Text File'),
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
                      'Timestamp: $timestamp',
                    ),
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

    // Updates the timestamp when randomized
    timestamp = DateTime.now().toLocal().toString();

    // Update the text content to append the new data
    textContent += '\n\nName of the ATCOs (Sh./Ms.):\n';
    textContent += names.join('\n');
    textContent += '\n\nSelected ATCO and Timestamp:\n';
    textContent += selectedNames.join(', ') + ' - $timestamp';

    setState(() {});
  }

  void appendToTextFile() {
    final textBlob = html.Blob([textContent], 'text/plain');
    final textFileUrl = html.Url.createObjectUrlFromBlob(textBlob);

    final anchor = html.AnchorElement(href: textFileUrl)
      ..setAttribute('download', 'selected_names.txt')
      ..setAttribute('target', 'blank')
      ..setAttribute('rel', 'noopener noreferrer')
      ..click();
  }
}
