import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReditChoosenWidget extends StatelessWidget {
  const ReditChoosenWidget({
    required this.title,
    required this.text,
    required this.imagenNetwork,
    required this.accountName,
    super.key,
  });

  final String? imagenNetwork;
  final String title;
  final String text;
  final String? accountName;

  String _truncateText(String text, [int maxLength = 80]) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context,) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 250,
              height: double.infinity,
              child: imagenNetwork == null || imagenNetwork!.isEmpty
                  ? Image.asset(
                      'assets/images/miniredit.png',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imagenNetwork!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/images/miniredit.png'),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Expanded(
                      child: Text(
                        _truncateText(text),
                        style: GoogleFonts.arapey(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (accountName != null && accountName!.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '@$accountName',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
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
}
