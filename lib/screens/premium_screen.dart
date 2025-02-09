import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:what_car_flutter/utils/utilities.dart'; // For formatting

class PremiumScreen extends ConsumerStatefulWidget {
  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _reminderEnabled = false;
  String _selectedPlan = 'free';

  void _navigateBack() {
    context.pop();
  }

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Design Your Trial'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors. /*violet*/ purple[100],
                borderRadius: BorderRadius.circular(64),
              ),
              child: Center(
                child: Icon(
                  Icons.directions_car,
                  size: 64,
                  color: Colors. /*violet*/ purple[500],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Title
            Text(
              'Design Your Trial',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Features List
            Column(
              children: [
                Text(
                  'Enjoy your first 7 days, it\'s free',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  'Cancel from the app or your iCloud account',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  'Unlimited car identification',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  'Access to premium car details & specs',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Pricing Options
            Column(
              children: [
                _buildPricingOption('Free', '7 days', 'free'),
                _buildPricingOption('Weekly', '\$1.99/week', 'weekly'),
                _buildPricingOption('Monthly', '\$0.99/month', 'monthly'),
              ],
            ),
            SizedBox(height: 16),
            // Price Info
            Text(
              _selectedPlan == 'free'
                  ? '7 days free, then just \$29.99/yr (~\$2.50/mo)'
                  : _selectedPlan == 'weekly'
                      ? 'Billed weekly at \$1.99/week'
                      : 'Billed monthly at \$0.99/month',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            // Continue Button
            ElevatedButton(
              onPressed: () {
                // Handle subscription logic here
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Subscription logic will be implemented soon')));
              },
              child: Text(
                _selectedPlan == 'free' ? 'Start Free Trial' : 'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            // Reminder Toggle
            SwitchListTile(
              title: Text('Remind me before the trial ends'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
              activeTrackColor: Colors.purple[100],
              activeColor: Colors.purple[500],
              inactiveTrackColor: Colors.grey[300],
              inactiveThumbColor: Colors.grey[600],
            ),
            SizedBox(height: 16),
            // Footer Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterLink('Terms of Use'),
                _buildFooterLink('Privacy Policy'),
                _buildFooterLink('Subscription Terms'),
                _buildFooterLink('Restore'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingOption(String title, String price, String plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => _selectPlan(plan),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title + (plan == 'free' ? ' Trial' : ' Plan'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedPlan == plan
                    ? Colors.purple[500]
                    : Colors.grey[900],
              ),
            ),
            if (_selectedPlan == plan)
              Icon(
                MdiIcons.checkCircle,
                size: 20,
                color: Colors.purple[500],
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor:
              _selectedPlan == plan ? Colors.purple[100] : Colors.grey[50],
          foregroundColor:
              _selectedPlan == plan ? Colors.purple[500] : Colors.grey[900],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          // Handle link press
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$text link pressed')));
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
