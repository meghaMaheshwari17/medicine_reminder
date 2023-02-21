import 'package:flutter/material.dart';
import 'package:med_reminder/screens/home_screen.dart';
import 'package:med_reminder/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/feedback_model.dart';
import '../provider/auth_provider.dart';

class FeedbackByUser extends StatefulWidget {
  const FeedbackByUser({Key? key}) : super(key: key);

  @override
  State<FeedbackByUser> createState() => _FeedbackByUserState();
}

class _FeedbackByUserState extends State<FeedbackByUser> {

     final TextEditingController _controller = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey();

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here',
              filled: true,
            ),
            maxLines: 5,
            maxLength: 4096,
            textInputAction: TextInputAction.done,
            validator: (String? text) {
              if (text == null || text.isEmpty) {
                showSnackBar(context, "Please enter some text");
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel',style: TextStyle(color:Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Send',style: TextStyle(color:Colors.green),),
            onPressed: () async {
              /**
               * Here we will add the necessary code to
               * send the entered data to the Firebase Cloud Firestore.
               */
              final ap = Provider.of<AuthProvider>(context, listen: false);
              FeedbackModel feedback=new FeedbackModel(feedback: _controller.text, uid: '');
              await ap.saveFeedbackToFirebase(context: context, feedbackModel: feedback);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          )
        ],
      );
    }
  }