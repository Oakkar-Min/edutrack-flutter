import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for logo
              SvgPicture.asset(
                'lib/assets/images/EDU-2.svg',
                width: 250,
                height: 250,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 0),

              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB388F5).withOpacity(0.69),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    ),
                    elevation: 10, // adds shadow
                      
                    
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginPage()));
                  },
                  child: const Text('Log in',
                  style: TextStyle(
                    color: Colors.white,fontSize: 15, fontWeight: FontWeight.bold
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 250,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFB388F5),
                    side: const BorderSide(color: Color(0xFFB388F5)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    ),
                    elevation: 8, // adds shadow
                    shadowColor: Color(0xFFB388F5).withOpacity(0.2),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()));
                  },
                  child: const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
