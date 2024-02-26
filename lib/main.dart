import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.red),
      home: EmailSender(),
    );
  }
}

class EmailSender extends StatefulWidget {
  const EmailSender({Key? key}) : super(key: key);

  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  List<String> attachments = [];
  bool isHTML = false;
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  Future<void> sendEmail() async {
    if (attachments.isEmpty) {
      // Generate the PDF if no attachments are present
      await generateAndPreviewPdf();
    }

    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Error sending email: $error');
      // Handle the error gracefully
    }
  }

  Future<void> generateAndPreviewPdf() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            'Recipient: ${_recipientController.text}\n'
            'Subject: ${_subjectController.text}\n'
            'Body: ${_bodyController.text}',
          ),
        ),
      ),
    );

    // Get the temporary directory
    final output =
        await File('${Directory.systemTemp.path}/example.pdf').create();

    // Save the PDF to a file
    await output.writeAsBytes(await pdf.save());

    // Add the PDF file to the attachments list
    setState(() {
      attachments.add(output.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Sender App'),
        actions: <Widget>[
          IconButton(
            onPressed: sendEmail,
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient',
              ),
            ),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
              ),
            ),
            TextField(
              controller: _bodyController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Body',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openImagePicker,
              child: Text('Attach Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateAndPreviewPdf,
              child: Text('Generate and Preview PDF'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(attachments[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => _removeAttachment(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        attachments.add(pickedFile.path);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }
}
