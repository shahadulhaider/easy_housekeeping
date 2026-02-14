import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provides sharing capabilities — PDF files, WhatsApp messages, and email.
class ShareService {
  /// Saves [pdfBytes] to a temporary file and shares it via the system share
  /// sheet.
  Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Opens WhatsApp with a pre-filled [message] using the `whatsapp://` URI
  /// scheme.
  Future<void> shareViaWhatsApp(String message) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('whatsapp://send?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Shares content via the system share sheet with an email-friendly subject.
  ///
  /// If [attachment] bytes and [attachmentName] are provided, the PDF is
  /// written to a temp file and included as an attachment.
  Future<void> shareViaEmail({
    required String subject,
    required String body,
    Uint8List? attachment,
    String? attachmentName,
  }) async {
    if (attachment != null && attachmentName != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$attachmentName');
      await file.writeAsBytes(attachment);

      await Share.shareXFiles([XFile(file.path)], subject: subject, text: body);
    } else {
      await Share.share(body, subject: subject);
    }
  }
}
