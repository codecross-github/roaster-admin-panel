import 'package:flutter/material.dart';
import '../core/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebarBg,
        title: Row(
          children: [
            Image.asset(
              AppConstants.logoPath,
              height: 32,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            const Text(
              'Roster Radar Pro',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Last updated: April 10, 2026',
                  style: TextStyle(color: AppColors.gray, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _section(
                  '1. Introduction',
                  'Welcome to Roster Radar Pro ("we", "our", or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application Roster Radar Pro (the "App").\n\nPlease read this policy carefully. If you disagree with its terms, please discontinue use of the App.',
                ),
                _section(
                  '2. Information We Collect',
                  'We collect information that you provide directly to us when you:\n\n• Register for an account (name, email address, phone number)\n• Upload a profile photo\n• Submit scouting report requests\n• Save or favorite player profiles\n• Configure notification preferences and alert criteria\n\nWe also automatically collect certain information when you use the App:\n\n• Device information (device type, operating system, unique device identifiers)\n• Usage data (features accessed, search queries, report views)\n• Firebase Cloud Messaging (FCM) token for push notification delivery\n• Log data (IP address, app crashes, activity timestamps)',
                ),
                _section(
                  '3. How We Use Your Information',
                  'We use the information we collect to:\n\n• Create and manage your account\n• Deliver the core features of the App including player search, profile views, and scouting reports\n• Process and fulfill scouting report requests you submit\n• Send push notifications about report status updates, new free agents matching your alert criteria, and player status changes\n• Track your saved players and personalized alert settings\n• Monitor and improve App performance and user experience\n• Respond to your support inquiries\n• Enforce our Terms of Service\n• Comply with applicable legal obligations',
                ),
                _section(
                  '4. Sharing of Your Information',
                  'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following limited circumstances:\n\n• Service Providers: We use Firebase (Google LLC) for authentication, database storage, file storage, and push notifications. Google\'s privacy policy governs their handling of data.\n• Legal Requirements: We may disclose your information if required by law, court order, or governmental authority.\n• Business Transfers: In the event of a merger, acquisition, or sale of assets, your information may be transferred as part of that transaction.\n• Safety: We may share information to protect the rights, property, or safety of Roster Radar Pro, our users, or others.',
                ),
                _section(
                  '5. Data Storage & Security',
                  'Your data is stored in Google Firebase\'s Cloud Firestore and Firebase Storage infrastructure, protected by Google\'s enterprise-grade security.\n\nWe implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These include:\n\n• Encrypted data transmission (HTTPS/TLS)\n• Firebase Security Rules restricting data access\n• Authentication-gated access to all user-specific data\n\nHowever, no method of transmission over the internet or electronic storage is 100% secure. We cannot guarantee absolute security.',
                ),
                _section(
                  '6. Data Retention',
                  'We retain your personal information for as long as your account is active or as needed to provide you services. If you request deletion of your account, we will delete your personal data within 30 days, except where we are legally required to retain it.',
                ),
                _section(
                  '7. Third-Party Services',
                  'The App integrates with the following third-party services:\n\n• Google Firebase (Authentication, Firestore, Storage, Cloud Messaging) — https://firebase.google.com/support/privacy\n• MiLB.com (Official Minor League Baseball website, accessed via in-app WebView restricted to the milb.com domain)\n\nThese third parties have their own privacy policies, and we encourage you to review them. We are not responsible for the privacy practices of these services.',
                ),
                _section(
                  '8. Push Notifications',
                  'With your permission, we send push notifications to your device via Firebase Cloud Messaging (FCM). Notifications may include:\n\n• Scouting report delivery confirmations\n• New free agent alerts matching your saved criteria\n• Report request status updates\n• Player status changes\n\nYou can disable push notifications at any time through your device\'s notification settings or within the App\'s notification preferences.',
                ),
                _section(
                  '9. Children\'s Privacy',
                  'Roster Radar Pro is intended for use by baseball professionals and is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will delete that information immediately.',
                ),
                _section(
                  '10. Your Rights',
                  'Depending on your location, you may have the following rights regarding your personal data:\n\n• Access: Request a copy of the personal data we hold about you.\n• Correction: Request that we correct inaccurate or incomplete data.\n• Deletion: Request deletion of your personal data.\n• Portability: Request transfer of your data in a machine-readable format.\n• Opt-out: Opt out of certain data uses such as push notifications.\n\nTo exercise any of these rights, contact us at privacy@rosterradarpro.com.',
                ),
                _section(
                  '11. California Privacy Rights (CCPA)',
                  'If you are a California resident, you have the right to:\n\n• Know what personal information we collect, use, disclose, and sell.\n• Request deletion of your personal information.\n• Opt out of the sale of personal information (we do not sell personal information).\n• Non-discrimination for exercising your privacy rights.\n\nTo submit a CCPA request, contact us at privacy@rosterradarpro.com.',
                ),
                _section(
                  '12. International Users',
                  'Roster Radar Pro is operated from the United States. If you access the App from outside the United States, your information may be transferred to, stored, and processed in the United States where our servers are located. By using the App, you consent to this transfer.',
                ),
                _section(
                  '13. Changes to This Privacy Policy',
                  'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy within the App and updating the "Last updated" date at the top of this page. Your continued use of the App after changes are posted constitutes your acceptance of the revised policy.',
                ),
                _section(
                  '14. Contact Us',
                  'If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:\n\nRoster Radar Pro\nEmail: privacy@rosterradarpro.com\nWebsite: https://rosterradarpro.com',
                ),
                const SizedBox(height: 48),
                const Divider(color: AppColors.inputBorder),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '© 2026 Roster Radar Pro. All rights reserved.',
                    style: TextStyle(color: AppColors.gray, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 15,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}
