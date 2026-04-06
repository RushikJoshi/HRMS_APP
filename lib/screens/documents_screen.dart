import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../models/api/profile_response.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_constants.dart';

class DocumentsScreen extends StatelessWidget {
  final ProfileData? profileData;
  const DocumentsScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    if (profileData == null || profileData!.documents == null) {
       return Scaffold(
        appBar: AppBar(title: const Text('Documents'), elevation: 0),
        backgroundColor: AppColors.backgroundPrimary,
        body: const Center(child: Text('No documents found')),
      );
    }

    final docs = <Widget>[];

    // Helper to add document items
    void addDoc(String label, String? url) {
      if (url != null && url.isNotEmpty) {
        docs.add(_buildDocumentTile(context, label, url));
      }
    }

    addDoc('Aadhar Front', profileData!.documents!.aadharFront);
    addDoc('Aadhar Back', profileData!.documents!.aadharBack);
    addDoc('PAN Card', profileData!.documents!.panCard);
    
    // Safety check just in case education docs are mixed in or other miscellaneous
    addDoc('Class 10 Marksheet', profileData!.education?.class10Marksheet);
    addDoc('Diploma Certificate', profileData!.education?.diplomaCertificate);
    addDoc('Bachelor Degree', profileData!.education?.bachelorDegree);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: docs.isEmpty
          ? const Center(child: Text('No documents uploaded'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(3.w),
              child: _buildSection(
                context,
                title: 'Uploaded Documents',
                children: docs,
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.5.w,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.w),
           Wrap(
            spacing: 3.w,
            runSpacing: 3.w,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, String label, String url) {
     return Container(
       width: 50.w - 8.5.w,
       padding: EdgeInsets.all(3.w),
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade200),
         borderRadius: BorderRadius.circular(8),
         color: Colors.grey.shade50,
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Center(
              child: Icon(Icons.picture_as_pdf_outlined, color: Colors.deepOrange, size: 25.sp),
            ),
            SizedBox(height: 2.w),
           Text(
             label,
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp, 
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 3.w),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(
                 child: InkWell(
                   onTap: () => _launchURL(context, url, false),
                   child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.remove_red_eye, size: 14.sp, color: AppColors.primary),
                    ),
                 ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                 child: InkWell(
                   onTap: () => _launchURL(context, url, true),
                   child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.download_rounded, size: 14.sp, color: Colors.green),
                    ),
                 ),
               ),
             ],
           )
         ],
       ),
     );
  }

  Future<void> _launchURL(BuildContext context, String urlString, bool forceDownload) async {
    try {
      String finalUrl = urlString;
      
      // Handle relative paths
      if (!urlString.startsWith('http')) {
        // Base URL is typically 'http://...:5000/api'
        // Uploads are typically at 'http://...:5000/uploads/...'
        // So we need to remove '/api' if it's there
        String base = ApiConstants.baseUrl;
        if (base.endsWith('/api')) {
          base = base.substring(0, base.length - 4);
        }
        if (base.endsWith('/')) {
           base = base.substring(0, base.length - 1);
        }
        
        if (!urlString.startsWith('/')) {
          finalUrl = '$base/$urlString';
        } else {
           finalUrl = '$base$urlString';
        }
      }

      final Uri uri = Uri.parse(finalUrl);
      final mode = forceDownload 
          ? LaunchMode.externalApplication 
          : LaunchMode.platformDefault;

      if (!await launchUrl(uri, mode: mode)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $finalUrl')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
