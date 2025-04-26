
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect after build frame to avoid build context issues
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData) {
            print("has data");
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            print("no data");
            Navigator.pushReplacementNamed(context, '/splash');
          }
        });

        return const SizedBox.shrink(); // Empty widget while redirecting
      },
    );
  }
}


// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData) {
//           print("has data");
//           Navigator.pushReplacementNamed(context, '/main');
//         } else {
//           print("no data");
//           Navigator.pushReplacementNamed(context, '/splash');
//         }
//       },
//     );
//   }
// }
