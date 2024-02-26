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
  int pdfCount = 0;

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
    // Increment the PDF count for each generation
    pdfCount++;

    // Generate invoice number
    final String currentDate = DateTime.now().day.toString().padLeft(2, '0');
    final String currentMonth = DateTime.now().month.toString().padLeft(2, '0');
    final String currentYear = DateTime.now().year.toString();
    final String invoiceNumber =
        'DPLC/$currentDate/$currentMonth/$currentYear/S-$pdfCount';

    // Create a new PDF document
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice Number: $invoiceNumber',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Recipient: _recipientController.text}\n'
              'Subject: _subjectController.text}\n'
              'Body: _bodyController.text}',
            ),
          ],
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
