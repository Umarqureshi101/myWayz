import 'package:flutter/material.dart';  // Import the material design package for Flutter.
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Authentication to handle user login.
import 'package:mywayz/pages/widgets/sign_in.dart';  // Import the SignIn widget (login form).
import 'package:mywayz/pages/widgets/sign_up.dart';  // Import the SignUp widget (signup form).
import 'package:mywayz/theme.dart';  // Import custom theme for styling.
import 'package:mywayz/utils/bubble_indicator_painter.dart';  // Import custom painter for the indicator.
import 'geopify_map.dart';  // Import the HomePage widget which is shown after successful login/signup.
import 'geopify_map_2.0.dart';
import 'map_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;  // Declare PageController to manage page view transitions.

  Color left = Colors.black;  // Initially set the 'Existing' button color to black.
  Color right = Colors.white;  // Initially set the 'New' button color to white.

  @override
  void dispose() {
    _pageController.dispose();  // Dispose of the PageController when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();  // Initialize the PageController.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());  // Dismiss the keyboard when tapping outside the text fields.
              },
              child: Container(
                width: MediaQuery.of(context).size.width,  // Set container width to the device's width.
                height: MediaQuery.of(context).size.height,  // Set container height to the device's height.
                decoration: const BoxDecoration(
                  gradient: LinearGradient(  // Apply a gradient background to the screen.
                    colors: <Color>[
                      CustomTheme.loginGradientStart,  // Start color of the gradient.
                      CustomTheme.loginGradientEnd,  // End color of the gradient.
                    ],
                    begin: FractionalOffset(0.0, 0.0),  // Start point of the gradient.
                    end: FractionalOffset(1.0, 1.0),  // End point of the gradient.
                    stops: <double>[0.0, 1.0],  // Define the stopping points of the gradient.
                    tileMode: TileMode.clamp,  // Make sure the gradient doesn't repeat.
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 75.0),  // Add top padding for the logo.
                      child: Image(
                        height: MediaQuery.of(context).size.height > 800 ? 191.0 : 150,  // Set logo height based on screen size.
                        fit: BoxFit.fill,  // Make sure the image fits correctly.
                        image: const AssetImage('assets/img/login_logo.png'),  // Specify the logo image.
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),  // Add padding above the menu bar.
                      child: _buildMenuBar(context),  // Build the menu bar (buttons for "Existing" and "New").
                    ),
                    Expanded(
                      flex: 2,  // The PageView widget takes up most of the screen space.
                      child: PageView(
                        controller: _pageController,  // Assign the PageController to manage page transitions.
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (int i) {
                          FocusScope.of(context).requestFocus(FocusNode());  // Dismiss keyboard when page changes.
                          setState(() {
                            if (i == 0) {
                              right = Colors.white;  // Change button colors for "Existing" page.
                              left = Colors.black;
                            } else {
                              right = Colors.black;  // Change button colors for "New" page.
                              left = Colors.white;
                            }
                          });
                        },
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: const BoxConstraints.expand(),  // Expand to fill the available space.
                            child: SignIn(onLoginSuccess: _onLoginSuccess),  // Display the SignIn widget for login.
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints.expand(),  // Expand to fill the available space.
                            child: SignUp(onSignUpSuccess: _onLoginSuccess),  // Display the SignUp widget for registration.
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,  // Position the Skip button at the top of the screen.
            right: 20,  // Align the button to the right.
            child: TextButton(
              onPressed: _skipLogin,  // Navigate to the main screen when tapped.
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,  // Set the menu bar width.
      height: 50.0,  // Set the menu bar height.
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),  // Set the background color for the menu bar.
        borderRadius: BorderRadius.all(Radius.circular(25.0)),  // Apply rounded corners.
      ),
      child: CustomPaint(
        painter: BubbleIndicatorPainter(pageController: _pageController),  // Custom painter for the bubble indicator.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Space out the buttons evenly.
          children: <Widget>[
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),  // Remove overlay color on press.
                ),
                onPressed: _onSignInButtonPress,  // Navigate to the SignIn page when pressed.
                child: Text(
                  'Existing',
                  style: TextStyle(
                      color: left,  // Set text color for "Existing" button.
                      fontSize: 16.0,
                      fontFamily: 'WorkSansSemiBold'),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),  // Remove overlay color on press.
                ),
                onPressed: _onSignUpButtonPress,  // Navigate to the SignUp page when pressed.
                child: Text(
                  'New',
                  style: TextStyle(
                      color: right,  // Set text color for "New" button.
                      fontSize: 16.0,
                      fontFamily: 'WorkSansSemiBold'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(  // Animate to the first page (SignIn).
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,  // Smooth deceleration curve for the animation.
    );
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(  // Animate to the second page (SignUp).
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,  // Smooth deceleration curve for the animation.
    );
  }

  void _onLoginSuccess(User? user) {
    if (user != null) {
      // If login or sign-up is successful, navigate to the HomePage and remove the LoginPage from the stack.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TruckRoutingApp()),
            (Route<dynamic> route) => false, // Remove all previous routes, including the login page.
      );
    }
  }

  void _skipLogin() {
    // Navigate to the main screen directly (skip login/signup).
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TruckRoutingApp()),
    );
  }
}
