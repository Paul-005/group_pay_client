import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupCodePage extends StatefulWidget {
  const GroupCodePage({super.key});

  @override
  State<GroupCodePage> createState() => _GroupCodePageState();
}

class _GroupCodePageState extends State<GroupCodePage> {
  List<String> groupCode = List.filled(6, '');
  bool isLoading = false;

  void _onCodeChanged(String value, int index) {
    setState(() {
      groupCode[index] = value;
    });

    // Auto move to next field
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    }
  }

  void _validateAndJoinGroup() {
    // Check if all code fields are filled
    if (groupCode.every((code) => code.isNotEmpty)) {
      setState(() {
        isLoading = true;
      });

      // TODO: Implement group joining logic
      // You would typically call a backend service here to validate the group code
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
        // Navigate to group or show success message
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please enter the complete group code'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),
            _codeInputField(context),
            _actionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Join a Group",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const Text("Enter the 6-digit group code provided by admin"),
        const SizedBox(height: 20),
        if (isLoading)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.deepPurple.withOpacity(0.7)),
          ),
      ],
    );
  }

  Widget _codeInputField(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.deepPurple.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
            ),
            onChanged: (value) => _onCodeChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _actionButton(BuildContext context) {
    return Container(
      width: double.infinity, // Make the button full width
      margin: const EdgeInsets.symmetric(
          horizontal: 16), // Add some horizontal margin
      child: ElevatedButton(
        onPressed: isLoading ? null : _validateAndJoinGroup,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Increased border radius
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize:
              const Size(double.infinity, 56), // Increased minimum size
          backgroundColor: Colors.deepPurple,
          disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
        ),
        child: Text(
          isLoading ? "Joining..." : "Join Group",
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
