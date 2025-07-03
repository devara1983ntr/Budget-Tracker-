import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/theme_provider.dart';
import '../../viewmodel/security_provider.dart';
import '../../utils/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'Security'),
          _buildSecuritySection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'Appearance'),
          _buildAppearanceSection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'Data & Backup'),
          _buildDataSection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationsSection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'Currency & Format'),
          _buildCurrencySection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'Help & Support'),
          _buildHelpSection(context),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'About'),
          _buildAboutSection(context),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Consumer<SecurityProvider>(
            builder: (context, securityProvider, child) {
              return ListTile(
                leading: const Icon(Icons.pin),
                title: const Text('PIN Protection'),
                subtitle: Text(
                  securityProvider.isPinEnabled ? 'Enabled' : 'Disabled',
                ),
                trailing: Switch(
                  value: securityProvider.isPinEnabled,
                  onChanged: (value) {
                    if (value) {
                      context.push('/security-setup');
                    } else {
                      _showDisablePinDialog(context);
                    }
                  },
                ),
                onTap: () {
                  if (securityProvider.isPinEnabled) {
                    context.push('/change-pin');
                  } else {
                    context.push('/security-setup');
                  }
                },
              );
            },
          ),
          
          const Divider(height: 1),
          
          Consumer<SecurityProvider>(
            builder: (context, securityProvider, child) {
              return ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: Text(
                  securityProvider.isBiometricEnabled ? 'Enabled' : 'Disabled',
                ),
                trailing: Switch(
                  value: securityProvider.isBiometricEnabled,
                  onChanged: securityProvider.isPinEnabled
                      ? (value) {
                          _toggleBiometrics(context, value);
                        }
                      : null,
                ),
                enabled: securityProvider.isPinEnabled,
              );
            },
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('Auto-Lock Timer'),
            subtitle: const Text('Lock app after inactivity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAutoLockDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.dark_mode 
                      : Icons.light_mode,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Dark' : 'Light',
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              );
            },
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('App Color'),
            subtitle: const Text('Customize app accent color'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showColorPicker(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: const Text('Adjust text size'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import from backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestoreDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sync Settings'),
            subtitle: const Text('Sync data across devices'),
            trailing: Switch(
              value: false, // TODO: Implement sync functionality
              onChanged: null, // Disabled for now
            ),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all transactions and settings'),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive app notifications'),
            trailing: Switch(
              value: true, // TODO: Implement notification settings
              onChanged: (value) {
                // TODO: Handle notification toggle
              },
            ),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Budget Reminders'),
            subtitle: const Text('Weekly spending reminders'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Handle budget reminder toggle
              },
            ),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Bill Reminders'),
            subtitle: const Text('Upcoming bill notifications'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Handle bill reminder toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: const Text('USD (\$)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date Format'),
            subtitle: const Text('MM/DD/YYYY'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDateFormatDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: const Text('Number Format'),
            subtitle: const Text('1,234.56'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNumberFormatDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & FAQ'),
            subtitle: const Text('Get help and answers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            subtitle: const Text('Share your thoughts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFeedbackDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on the store'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRateAppDialog(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report Bug'),
            subtitle: const Text('Report issues or bugs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBugReportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we protect your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            subtitle: const Text('Terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTermsOfService(context),
          ),
          
          const Divider(height: 1),
          
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source Licenses'),
            subtitle: const Text('Third-party licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLicenses(context),
          ),
        ],
      ),
    );
  }

  // Dialog and action methods
  void _showDisablePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable PIN Protection'),
        content: const Text(
          'Are you sure you want to disable PIN protection? This will remove security from your app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SecurityProvider>().disablePin();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _toggleBiometrics(BuildContext context, bool enable) async {
    final securityProvider = context.read<SecurityProvider>();
    
    if (enable) {
      final success = await securityProvider.enableBiometrics();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enable biometric authentication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      securityProvider.disableBiometrics();
    }
  }

  void _showAutoLockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Lock Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Immediately'),
              leading: Radio<int>(
                value: 0,
                groupValue: 5, // Default 5 minutes
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('1 minute'),
              leading: Radio<int>(
                value: 1,
                groupValue: 5,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('5 minutes'),
              leading: Radio<int>(
                value: 5,
                groupValue: 5,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('15 minutes'),
              leading: Radio<int>(
                value: 15,
                groupValue: 5,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Never'),
              leading: Radio<int>(
                value: -1,
                groupValue: 5,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose App Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your preferred accent color:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorOption(Colors.green, context),
                _buildColorOption(Colors.blue, context),
                _buildColorOption(Colors.purple, context),
                _buildColorOption(Colors.orange, context),
                _buildColorOption(Colors.red, context),
                _buildColorOption(Colors.teal, context),
                _buildColorOption(Colors.indigo, context),
                _buildColorOption(Colors.pink, context),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement color change
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Small'),
              leading: Radio<String>(
                value: 'small',
                groupValue: 'medium',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<String>(
                value: 'medium',
                groupValue: 'medium',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Large'),
              leading: Radio<String>(
                value: 'large',
                groupValue: 'medium',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'Export your transactions and settings to a backup file. This file can be used to restore your data later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement backup functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'Import data from a backup file. This will replace your current data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement restore functionality
            },
            child: const Text('Select Backup File'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions, categories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear data functionality
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('US Dollar (USD)'),
                subtitle: const Text('\$'),
                leading: Radio<String>(
                  value: 'USD',
                  groupValue: 'USD',
                  onChanged: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Euro (EUR)'),
                subtitle: const Text('€'),
                leading: Radio<String>(
                  value: 'EUR',
                  groupValue: 'USD',
                  onChanged: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('British Pound (GBP)'),
                subtitle: const Text('£'),
                leading: Radio<String>(
                  value: 'GBP',
                  groupValue: 'USD',
                  onChanged: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Add more currencies as needed
            ],
          ),
        ),
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('MM/DD/YYYY'),
              leading: Radio<String>(
                value: 'MM/DD/YYYY',
                groupValue: 'MM/DD/YYYY',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('DD/MM/YYYY'),
              leading: Radio<String>(
                value: 'DD/MM/YYYY',
                groupValue: 'MM/DD/YYYY',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('YYYY-MM-DD'),
              leading: Radio<String>(
                value: 'YYYY-MM-DD',
                groupValue: 'MM/DD/YYYY',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1,234.56'),
              subtitle: const Text('US Format'),
              leading: Radio<String>(
                value: 'US',
                groupValue: 'US',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('1.234,56'),
              subtitle: const Text('European Format'),
              leading: Radio<String>(
                value: 'EU',
                groupValue: 'US',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    context.push('/help');
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Your feedback',
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Budget Tracker'),
        content: const Text(
          'If you enjoy using Budget Tracker, please take a moment to rate us on the app store. Your rating helps us improve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open app store rating
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Bug'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Bug description',
                hintText: 'Describe the issue you encountered...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Budget Tracker respects your privacy. All your financial data is stored locally on your device and is never transmitted to external servers without your explicit consent.\n\n'
            'We do not collect, store, or share any personal financial information.\n\n'
            'For the full privacy policy, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using Budget Tracker, you agree to use the app responsibly for personal financial tracking purposes.\n\n'
            'The app is provided "as is" without warranties. Users are responsible for backing up their data.\n\n'
            'For complete terms of service, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
    );
  }
}