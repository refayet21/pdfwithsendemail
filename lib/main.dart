import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
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
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  Uint8List? pdfBytes;

  Future<void> sendEmail(List<String> recipients, String subject, String body,
      List<String>? attachmentPaths) async {
    if (attachments.isEmpty) {
      await generatePdf();
    }

    final Email email = Email(
        recipients: recipients,
        subject: subject,
        body: body,
        attachmentPaths: attachmentPaths);

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  Future<void> generatePdf() async {
    // Create a new PDF document
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

    final Uint8List bytes = await pdf.save();

    setState(() {
      pdfBytes = bytes;
    });

    final tempDir = await getTemporaryDirectory();
    final pdfFile = File('${tempDir.path}/example.pdf');
    await pdfFile.writeAsBytes(bytes);

    setState(() {
      attachments.add(pdfFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Sender App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: generatePdf,
              child: Text('Generate PDF'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: pdfBytes != null
                  ? PdfPreview(
                      build: (PdfPageFormat format) => pdfBytes!,
                      initialPageFormat: PdfPageFormat.a4,
                      allowPrinting: false,
                      onPrinted: (_) {},
                    )
                  : Container(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendEmail(
                    ['refayet21@gmail.com'], 'subject', 'body', attachments);
              },
              child: Text('Send Email with PDF Attachment'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:printing/printing.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(primaryColor: Colors.red),
//       home: EmailSender(),
//     );
//   }
// }

// class EmailSender extends StatefulWidget {
//   const EmailSender({Key? key}) : super(key: key);

//   @override
//   _EmailSenderState createState() => _EmailSenderState();
// }

// class _EmailSenderState extends State<EmailSender> {
//   List<String> attachments = [];
//   final _recipientController = TextEditingController();
//   final _subjectController = TextEditingController();
//   final _bodyController = TextEditingController();

//   Uint8List? pdfBytes;

//   Future<void> sendEmail() async {
//     // Generate the PDF if it hasn't been generated yet
//     if (pdfBytes == null) {
//       await generatePdf();
//     }

//     // Add the generated PDF to attachments
//     if (pdfBytes != null) {
//       final tempDir = await getTemporaryDirectory();
//       final pdfFile = File('${tempDir.path}/example.pdf');
//       await pdfFile.writeAsBytes(pdfBytes!);
//       setState(() {
//         attachments.add(pdfFile.path);
//       });
//     }

//     // Send the email
//     final Email email = Email(
//       body: _bodyController.text,
//       subject: _subjectController.text,
//       recipients: [_recipientController.text],
//       attachmentPaths: attachments,
//     );

//     try {
//       await FlutterEmailSender.send(email);
//     } catch (error) {
//       print('Error sending email: $error');
//       // Handle the error gracefully
//     }
//   }

//   Future<void> generatePdf() async {
//     // Create a new PDF document
//     final pdf = pw.Document();

//     // Add content to the PDF
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Center(
//           child: pw.Text(
//             'Recipient: ${_recipientController.text}\n'
//             'Subject: ${_subjectController.text}\n'
//             'Body: ${_bodyController.text}',
//           ),
//         ),
//       ),
//     );

//     // Convert the PDF document to a Uint8List
//     final Uint8List bytes = await pdf.save();

//     // Set the generated PDF bytes to the state
//     setState(() {
//       pdfBytes = bytes;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Email Sender App'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: _recipientController,
//               decoration: InputDecoration(
//                 labelText: 'Recipient',
//               ),
//             ),
//             TextField(
//               controller: _subjectController,
//               decoration: InputDecoration(
//                 labelText: 'Subject',
//               ),
//             ),
//             TextField(
//               controller: _bodyController,
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 labelText: 'Body',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: sendEmail,
//               child: Text('Send Email with PDF Attachment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
