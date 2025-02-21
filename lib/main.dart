import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invento/export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as ex;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } else {
            return const UserSelectionScreen(); // Redirect here
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Select an Option")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Get Started with Your Store",
            style: TextStyle(
              color:Colors.black,
              fontSize: 24
            ),),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFF7871F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)), // Removes border radius
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateStoreScreen()),
                    );
                  },
                  child: Text('Create a New Store',style: TextStyle(color: Colors.white),),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFF7871F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)), // Removes border radius
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaffAccessScreen()),
                    );
                  },
                  child: Text('Access an Existing Store',style: TextStyle(color: Colors.white),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
class StaffAccessScreen extends StatefulWidget {
  @override
  _StaffAccessScreenState createState() => _StaffAccessScreenState();
}
class _StaffAccessScreenState extends State<StaffAccessScreen> {
  final TextEditingController _qrCodeController = TextEditingController();
  String? storedStoreId;

  @override
  void initState() {
    super.initState();
    // _loadStoredStore(); //  Load store ID from SharedPreferences
  }

  // //  Load Store ID from SharedPreferences
  // Future<void> _loadStoredStore() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     storedStoreId = prefs.getString('storeId');
  //   });
  //
  //   if (storedStoreId != null) {
  //     //  Auto-login if Store ID exists
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => InventoryDashboard(storeId: storedStoreId!)),
  //     );
  //   }
  // }

  //  Save Store ID in SharedPreferences
  Future<void> _saveStoreId(String storeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeId', storeId);
  }

  //  Logout and clear Store ID
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('storeId'); // Clear store ID
    await FirebaseAuth.instance.signOut(); // Sign out user
    await prefs.clear(); // Deletes all stored preferences
    // Redirect to login screen (or StaffAccessScreen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StaffAccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staff Access")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _qrCodeController,
              decoration: InputDecoration(labelText: 'Enter Store QR Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String storeId = _qrCodeController.text.trim();
                if (storeId.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('stores')
                        .doc(storeId)
                        .collection('staff')
                        .doc(user.uid)
                        .set({
                      'name': user.displayName ?? 'Staff Member',
                      'role': 'staff',
                    });

                    await _saveStoreId(storeId); //  Save store ID

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => InventoryDashboard(storeId: storeId)),
                    );
                  }
                }
              },
              child: Text('Access Store'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                String scannedCode = await FlutterBarcodeScanner.scanBarcode(
                  '#ff6666', 'Cancel', true, ScanMode.QR,
                );

                if (scannedCode != "-1") {
                  _qrCodeController.text = scannedCode;
                }
              },
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Scan QR Code'),
            ),
            SizedBox(height: 20),
            storedStoreId != null
                ? ElevatedButton(
              onPressed: _logout, //  Logout button to clear store session
              child: Text("Logout"),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
class CreateStoreScreen extends StatelessWidget {
  final TextEditingController _storeNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Setup Your Store",
              style: TextStyle(
                  color:Colors.black,
                  fontSize: 24
              ),),
            const SizedBox(height: 100,),
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                  labelText: 'Store Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey, width: 2), // Grey border
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF7871F8),
                      width: 2), // Border color when focused
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Color(0xFF7871F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)), // Removes border radius
                ),
              ),
              onPressed: () async {
                String storeName = _storeNameController.text;
                if (storeName.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    String storeId = FirebaseFirestore.instance.collection('stores').doc().id;
                    await FirebaseFirestore.instance.collection('stores').doc(storeId).set({
                      'name': storeName,
                      'owner': user.uid,
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreQRCodeScreen(storeId: storeId),
                      ),
                    );
                  }
                }
              },
              child: Text('Create Store',style:TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
class StoreQRCodeScreen extends StatefulWidget {
  final String storeId;

  StoreQRCodeScreen({required this.storeId});

  @override
  _StoreQRCodeScreenState createState() => _StoreQRCodeScreenState();
}

class _StoreQRCodeScreenState extends State<StoreQRCodeScreen> {
  final GlobalKey _qrKey = GlobalKey();

  Future<Uint8List?> _captureQRCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);

      // Create a white background
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = Colors.white;

      // Draw white background
      canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), paint);

      // Draw QR code image on top
      canvas.drawImage(image, Offset.zero, Paint());

      // Convert to bytes
      final img = await recorder.endRecording().toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("❌ Error capturing QR Code: $e");
      return null;
    }
  }


  /// 📌 Save QR Code to Gallery
  Future<void> saveQRCode() async {
    Uint8List? pngBytes = await _captureQRCode();
    if (pngBytes == null) return;

    final result = await ImageGallerySaver.saveImage(pngBytes, name: "store_qr");
    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(" QR Code saved to gallery!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to save QR Code!")));
    }
  }

  /// 📌 Share QR Code
  Future<void> shareQRCode() async {
    Uint8List? pngBytes = await _captureQRCode();
    if (pngBytes == null) return;

    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/store_qr.png';
    File file = File(filePath);
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(file.path)], text: "📌 Store QR Code");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Store QR Code")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: QrImageView(
                data: widget.storeId,
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xff7871F8),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            )
          ),
          // RepaintBoundary(
          //   key: _qrKey,
          //   child: Container(
          //     color: Colors.white,  // Ensures a white background
          //     padding: EdgeInsets.all(10),  // Adds spacing to prevent cropping
          //     child: QrImageView(
          //       data: widget.storeId,
          //       version: QrVersions.auto,
          //       eyeStyle: const QrEyeStyle(
          //         eyeShape: QrEyeShape.square,
          //         color: Color(0xff7871F8),
          //       ),
          //       dataModuleStyle: const QrDataModuleStyle(
          //         dataModuleShape: QrDataModuleShape.square,
          //         color: Colors.black,
          //       ),
          //       size: 200.0,
          //       backgroundColor: Colors.white,  // Ensures QR code does not blend into the background
          //     ),
          //   ),
          // ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color(0xFF7871F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)), // Removes border radius
                  ),
                ),
                icon: Icon(Icons.save,color: Colors.white,),
                label: Text("Save QR",style: TextStyle(color: Colors.white),),
                onPressed: saveQRCode,
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color(0xFF7871F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)), // Removes border radius
                  ),
                ),
                icon: Icon(Icons.share,color:Colors.white),
                label: Text("Share QR",style: TextStyle(color: Colors.white),),
                onPressed: shareQRCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(top: 50, left: 32, right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GestureDetector(
                  //   child: Icon(Icons.arrow_back_ios),
                  // ),
                  const SizedBox(height: 100),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          height: 1.5), // Default style
                      children: [
                        TextSpan(text: "Welcome Back 👋 \nto "),
                        TextSpan(
                            text: "Invento",
                            style: TextStyle(color: Color(0xFF7871F8))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2), // Grey border
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF7871F8),
                                width: 2), // Border color when focused
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2), // Grey border
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Rounded corners
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            child: Icon(
                              _passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF7871F8),
                                width: 2), // Border color when focused
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          width: 380,
                          child: Text(
                            'Forgot Password?',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Color(0xFF7871F8),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          login();
                        },
                        child: Container(
                          width: 400,
                          height: 50,
                          alignment: Alignment.center, // Center the text
                          decoration: BoxDecoration(
                            color: Color(0xFF7871F8),
                            borderRadius:
                            BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white, // Make text readable
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 15,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              height: 1,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFF9DA6AF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Color(0xFF9DA6AF),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              height: 1,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFF9DA6AF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                googleSignIn();
                              },
                              child: Image.asset(
                                  "assets/images/google-color-svgrepo-com.png",
                                  height: 35)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationScreen()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "New here? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ), // Add styling
                              ),
                              TextSpan(
                                text: "Create an Account.",
                                style: TextStyle(
                                  color: Color(0xFF7871F8),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }

  // Email/Password Login Function
  Future<bool> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StaffAccessScreen()));
      return true;
    } on FirebaseAuthException catch (e) {
      print("Error Code: ${e.code}");
      print("Error Message: ${e.message}");
      print("Email: ${_emailController.text.trim()}");
      print("Password: ${_passwordController.text.trim()}");

      showError(e.message ?? "Login failed. Please try again.");
      return false;
    }
  }

  // Google Sign-In Function
  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      showError("Google sign-in failed.");
      return false;
    }
  }

  // Show Error Message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(top: 50, left: 32, right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GestureDetector(
                  //   child: Icon(Icons.arrow_back_ios),
                  // ),
                  const SizedBox(height: 100),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          height: 1.5), // Default style
                      children: [
                        TextSpan(text: "Create an Account"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Sign up now and start exploring.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2), // Grey border
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF7871F8),
                                width: 2), // Border color when focused
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2), // Grey border
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Rounded corners
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            child: Icon(
                              _passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF7871F8),
                                width: 2), // Border color when focused
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2), // Grey border
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF7871F8),
                                width: 2), // Border color when focused
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _register();
                        },
                        child: Container(
                          width: 400,
                          height: 50,
                          alignment: Alignment.center, // Center the text
                          decoration: BoxDecoration(
                            color: Color(0xFF7871F8),
                            borderRadius:
                            BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white, // Make text readable
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 15,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              height: 1,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFF9DA6AF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Color(0xFF9DA6AF),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: MediaQuery.of(context).size.width*0.25,
                              height: 1,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFF9DA6AF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {googleSignIn();},
                              child: Image.asset(
                                  "assets/images/google-color-svgrepo-com.png",
                                  height: 35)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Already have an Account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ), // Add styling
                              ),
                              TextSpan(
                                text: "Login.",
                                style: TextStyle(
                                  color: Color(0xFF7871F8),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }

  Future<void> _register() async {
    // if (_formKey.currentState!.validate()) {
    //   setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Registration failed. Try again.");
    } finally {
      setState(() => _isLoading = false);
    }
    // }
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      showError("Google sign-up failed.");
      return false;
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
    );
  }
}

class InventoryDashboard extends StatefulWidget {
  final String storeId; //  Accept storeId parameter

  InventoryDashboard({required this.storeId}); //  Constructor

  @override
  _InventoryDashboardState createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _lowStockThreshold = 10;

  @override
  void initState() {
    super.initState();
    // _initializeInventory();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF6F7F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF6F7F8),
        // title: Text('Invento - Store: ${widget.storeId}'), //  Show Store ID
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(onPressed: _refreshInventory, icon: Icon(Icons.refresh)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => UserInfoScreen()));
            },
            child: CircleAvatar(
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreName(widget.storeId,_firestore),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildStockOverview(),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('inventory').snapshots(), //  Fetch from 'inventory' collection directly
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); //  Show while loading
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error loading inventory")); //  Handle Firestore errors
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No inventory data available")); //  Handle empty case
                }

                final inventoryDocs = snapshot.data!.docs;

                final totalItems = inventoryDocs.length;
                final lowStockCount = inventoryDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?; //  Ensure it's a map
                  final stock = data?['stock'] ?? 0; //  Default to 0 if missing
                  return stock < _lowStockThreshold;
                }).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStockCard(
                        'Total Items', '$totalItems', Icons.inventory, Colors.black87, "All items in stock"),
                    _buildStockCard(
                        'Low Stock', '$lowStockCount', Icons.warning, Colors.red, "Low stock alerts"),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildLowStockAlerts(),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AllProductsScreen()));
              },
              child: Text("See all products"),
            )
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Future<void> _refreshInventory() async {
    setState(() {}); // Refresh UI
  }
  Widget _buildStoreName(String storeId, FirebaseFirestore firestore) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('stores').doc(storeId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Store Not Found"));
        }

        final storeName = snapshot.data!.get('name') ?? "Unnamed Store"; //  Fetch Store Name
        return Text(
          "Welcome $storeName",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      },
    );
  }



  Widget _buildLowStockAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Low Stock Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('inventory')
              .where('stock', isLessThan: _lowStockThreshold)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            return SizedBox(
              height: 250, // Fixed height to allow scrolling within the parent
              child: ListView.builder(
                shrinkWrap: true, // Important to prevent rendering issues
                physics:
                NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return _buildLowStockItem(
                      doc['name'], doc['sku'], '${doc['stock']} left');
                },
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildSearchBar(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search inventory...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0x5CDEDEDE)), // Apply grey border
        ),
      ),
      onSubmitted: (query) {
        if (query.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsPage(query: query),
            ),
          );
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.qr_code_scanner, 'Scan'),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddProductPage()));
          },
          child: _buildActionButton(Icons.add, 'Add'),
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ExportDataScreen()));
          },
          child: _buildActionButton(Icons.import_export, 'Export'),
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => InsightsPage()));
          },
          child: _buildActionButton(Icons.bar_chart, 'Insigh'),
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BillScreen(storeId: widget.storeId,)));
          },
          child: _buildActionButton(Icons.monetization_on, 'Bill'),
        )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  Widget _buildStockOverview() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 215,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.94, 0.33),
          end: Alignment(-0.94, -0.33),
          colors: [Color(0xFFD6A5FD), Color(0xFF7871F8)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(107),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
        ),
      ),
      child: Stack(
        children: [
          //  Background Circles
          Positioned(
            left: 258,
            top: -22,
            child: Container(
              width: 130,
              height: 130,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.38),
                shape: OvalBorder(),
              ),
            ),
          ),
          Positioned(
            left: 241,
            top: -39,
            child: Container(
              width: 164,
              height: 164,
              decoration: ShapeDecoration(
                shape: OvalBorder(
                  side: BorderSide(
                    width: 4,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Colors.white.withOpacity(0.38),
                  ),
                ),
              ),
            ),
          ),
          //  Fetch Inventory Data & Display
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inventory') //  Adjusted Firestore path
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No inventory data available"));
                }

                //  Process Inventory Data
                final inventoryDocs = snapshot.data!.docs;
                int totalItems = inventoryDocs.length;
                int totalQty = 0;
                int lowStockCount = 0;

                for (var doc in inventoryDocs) {
                  final data = doc.data() as Map<String, dynamic>?; // Ensure valid map
                  int quantity = (data?['stock'] ?? 0) as int;
                  totalQty += quantity;
                  if (quantity < 10) lowStockCount++; // Low stock if less than 10
                }

                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTopCard('Total Items', '$totalItems'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTopCard('Total Qty', '$totalQty items'),
                          SizedBox(height: 8),
                          _buildTopCard('Low Stock', '$lowStockCount'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTopCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent, // No background color
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Line
          Container(
            width: 2, // Thin vertical line
            height: 55, // Line height
            color: Colors.white, // White line color
          ),
          const SizedBox(width: 20), // Spacing between line and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white, // White text
                  fontSize: 14, // Slightly smaller font size
                  fontWeight: FontWeight.w600, // Medium-bold weight
                ),
              ),
              const SizedBox(height: 6), // Adjust spacing between text
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white, // White text
                  fontSize: 22, // Bigger font size for number
                  fontWeight: FontWeight.bold, // Bold weight for emphasis
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
      String title, String count, IconData icon, Color iconColor, String str) {
    return Container(
      width: 150, // Fixed width for consistency
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1), // Soft shadow
        //     blurRadius: 8,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: iconColor), // Icon on top
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$str", // Static subtitle like in the reference image
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$count items", // Adding "items" for clarity
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLowStockAlerts() {
  //   return Expanded(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('Low Stock Alerts',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         const SizedBox(height: 10),
  //         Expanded(
  //           child: StreamBuilder<QuerySnapshot>(
  //             stream: _firestore.collection('inventory')
  //                 .where('stock', isLessThan: _lowStockThreshold)
  //                 .snapshots(),
  //             builder: (context, snapshot) {
  //               if (!snapshot.hasData) return const CircularProgressIndicator();
  //
  //               return ListView.builder(
  //                 itemCount: snapshot.data!.docs.length,
  //                 itemBuilder: (context, index) {
  //                   final doc = snapshot.data!.docs[index];
  //                   return _buildLowStockItem(
  //                       doc['name'],
  //                       doc['sku'],
  //                       '${doc['stock']} left'
  //                   );
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildLowStockItem(String name, String sku, String stock) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: Colors.white, // Ensuring background stays white
      child: ListTile(
        title: Text(name),
        subtitle: Text('SKU: $sku'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stock, style: const TextStyle(color: Colors.red)),
            const Text('Reorder', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.inventory), label: 'Inventory'),
        BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final String query;

  SearchResultsPage({required this.query});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inventory')
            .where('name', isGreaterThanOrEqualTo: widget.query)
            .where('name',
            isLessThan: widget.query + 'z') // For case-insensitive search
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var results = snapshot.data!.docs;

          if (results.isEmpty) {
            return Center(child: Text("No products found"));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              var doc = results[index];
              var data = doc.data() as Map<String, dynamic>;

              // Extracting product data
              String productId = doc.id; // Get Firestore document ID
              String name = data['name'] ?? 'No Name';
              String sku = data['sku'] ?? 'N/A';
              int quantity = data['quantity'] ?? 0;
              double price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
              double cost = (data['cost'] is num) ? (data['cost'] as num).toDouble() : 0.0;

              return Dismissible(
                key: Key(productId),
                direction: DismissDirection.startToEnd, // Swipe right to edit
                background: Container(
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductScreen(
                        productId: productId,
                        name: name,
                        sku: sku,
                        quantity: quantity,
                        price: price,
                        cost: cost,
                      ),
                    ),
                  );
                  return false; // Prevent automatic dismissal after swipe
                },
                child: GestureDetector(
                  onLongPress: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Delete Product"),
                        content: Text("Are you sure you want to delete $name?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('inventory').doc(productId).delete();
                              Navigator.pop(context, true);
                            },
                            child: Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$name deleted successfully")),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text("Qty: $quantity | Price: \$$price | Cost: \$$cost"),
                    leading: Icon(Icons.inventory),
                  ),
                ),
              );
            },
          );

        },
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _costController = TextEditingController(); // NEW Cost Field
  String _scannedBarcode = "Not Scanned";

  // 📌 Function to scan barcode
  Future<void> _scanBarcode() async {
    String barcodeScanResult;
    try {
      barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Scanner color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Only barcode scanning
      );
    } catch (e) {
      barcodeScanResult = "Failed to scan";
    }

    if (!mounted) return;

    setState(() {
      _scannedBarcode =
      barcodeScanResult != "-1" ? barcodeScanResult : "Not Scanned";
    });
  }
  Future<void> _saveProduct() async {
    String name = _nameController.text.trim();
    String stockText = _stockController.text.trim();
    String costText = _costController.text.trim();

    int stock = int.tryParse(stockText) ?? 0;
    double cost = double.tryParse(costText) ?? 0.0;

    if (_scannedBarcode == "Not Scanned" || name.isEmpty || stock <= 0 || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details and scan a barcode")),
      );
      return;
    }

    try {
      await _firestore.collection('inventory').add({
        "name": name,
        "sku": _scannedBarcode,
        "stock": stock,
        "cost": cost, // NEW: Save Cost
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product added successfully!")),
      );

      setState(() {
        _scannedBarcode = "Not Scanned";
      });
      _nameController.clear();
      _stockController.clear();
      _costController.clear(); // Clear cost field
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding product: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.qr_code_scanner),
                label: Text("Scan Barcode"),
                onPressed: _scanBarcode,
              ),
              SizedBox(height: 10),
              Text("Scanned Barcode: $_scannedBarcode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Product Name", border: OutlineInputBorder()),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Stock Quantity", border: OutlineInputBorder()),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _costController, // NEW Cost Field
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cost Price", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                onPressed: _saveProduct,
                child: Text("Save Product"),
              ),
            ],
          ),
        ),
      )
    );
  }
}


class EditProductScreen extends StatefulWidget {
  final String productId;
  final String name;
  final String sku;
  final int quantity;
  final double price;
  final double cost; // NEW: Cost Field

  EditProductScreen({
    required this.productId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.cost, // NEW: Cost Field
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _costController; // NEW: Cost Field

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _skuController = TextEditingController(text: widget.sku);
    _quantityController = TextEditingController(text: widget.quantity.toString());
    _priceController = TextEditingController(text: widget.price.toString());
    _costController = TextEditingController(text: widget.cost.toString()); // NEW: Cost Field
  }

  Future<void> _updateProduct() async {
    await _firestore.collection('inventory').doc(widget.productId).update({
      'name': _nameController.text,
      'sku': _skuController.text,
      'quantity': int.tryParse(_quantityController.text) ?? widget.quantity,
      'price': double.tryParse(_priceController.text) ?? widget.price,
      'cost': double.tryParse(_costController.text) ?? widget.cost, // NEW: Update Cost
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product Updated Successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _skuController,
              decoration: InputDecoration(labelText: 'SKU'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _costController, // NEW Cost Field
              decoration: InputDecoration(labelText: 'Cost Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String scannedCode = "Not Scanned";

  Future<void> _scanQR() async {
    String code = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );

    if (!mounted) return;

    setState(() {
      scannedCode = code != "-1" ? code : "Not Scanned";
    });

    if (scannedCode != "Not Scanned") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailsScreen(sku: scannedCode)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Scanned Code: $scannedCode"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _scanQR,
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
class ProductDetailsScreen extends StatelessWidget {
  final String sku;

  ProductDetailsScreen({required this.sku});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Details")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').where('sku', isEqualTo: sku).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;
          if (products.isEmpty) {
            return Center(child: Text("No product found with SKU: $sku"));
          }

          var product = products.first;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${product['name']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("SKU: ${product['sku']}"),
                Text("Quantity: ${product['quantity']}"),
                Text("Price: \$${product['price']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${user?.displayName ?? 'N/A'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'UID: ${user?.uid ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
class AllProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Products")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(child: Text("No products found"));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var data = product.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(
                    "Qty: ${data['stock'] ?? 0} | SKU: ${data['sku'] ?? 'N/A'}"),
                leading: Icon(Icons.inventory),
              );
            },
          );
        },
      ),
    );
  }
}

// class _BillScreenState extends State<BillScreen> {
//   List<BillItem> selectedProducts = [];
//   String storeName = "Loading...";
//
//   @override
//   void initState() {
//     super.initState();
//     fetchStoreName();
//   }
//
//   Future<void> fetchStoreName() async {
//     DocumentSnapshot storeDoc = await FirebaseFirestore.instance
//         .collection('stores')
//         .doc(widget.storeId)
//         .get();
//
//     setState(() {
//       storeName = storeDoc.exists ? storeDoc['name'] : "Unnamed Store";
//     });
//   }
//
//   /// 📌 Scan Barcode and Add Product
//   Future<void> scanBarcode() async {
//     String barcode = await FlutterBarcodeScanner.scanBarcode(
//         "#ff6666", "Cancel", true, ScanMode.BARCODE);
//
//     if (barcode == "-1") return; // If user cancels scanning
//
//     print("📌 Scanned Barcode: $barcode");
//
//     var querySnapshot = await FirebaseFirestore.instance
//         .collection('stores')
//         .doc(widget.storeId)
//         .collection('inventory')
//         .where('sku', isEqualTo: barcode)
//         .get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       var data = querySnapshot.docs.first.data();
//       addToBill(data);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("⚠️ Product not found in inventory!")),
//       );
//     }
//   }
//
//   /// 📌 Add Product to Bill (Auto Increment Quantity)
//   void addToBill(Map<String, dynamic> data) {
//     int index = selectedProducts.indexWhere((item) => item.sku == data['sku']);
//
//     if (index != -1) {
//       // Product already exists, increment quantity
//       setState(() {
//         selectedProducts[index].quantity++;
//       });
//     } else {
//       // Add new product
//       setState(() {
//         selectedProducts.add(BillItem(
//           name: data['name'],
//           sku: data['sku'],
//           quantity: 1,
//           price: (data['price'] as num).toDouble(),
//           discount: data.containsKey('discount') ? (data['discount'] as num).toDouble() : 0.0,
//         ));
//       });
//     }
//   }
//
//   /// 📌 Generate PDF Bill
//   Future<void> generateBillPDF() async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Column(
//           children: [
//             pw.Text(storeName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//             pw.Text("Invoice", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//             pw.Divider(),
//             pw.Table.fromTextArray(
//               headers: ["Product", "SKU", "Qty", "Price", "Discount", "Total"],
//               data: selectedProducts.map((item) => [
//                 item.name,
//                 item.sku,
//                 item.quantity.toString(),
//                 "\$${item.price}",
//                 "\$${item.discount}",
//                 "\$${item.totalPrice}"
//               ]).toList(),
//             ),
//             pw.Divider(),
//             pw.Text(
//               "Total: \$${selectedProducts.fold(0.0, (double sum, item) => sum + item.totalPrice).toStringAsFixed(2)}",
//               style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//
//     Directory? directory = await getExternalStorageDirectory();
//     String filePath = "${directory?.path}/invoice.pdf";
//     File file = File(filePath);
//     await file.writeAsBytes(await pdf.save());
//
//     print(" Bill PDF saved at: $filePath");
//     shareBill(filePath);
//   }
//
//   /// 📌 Share Bill via SMS or WhatsApp
//   Future<void> shareBill(String filePath) async {
//     await Share.shareFiles([filePath], text: "📜 Here is your invoice from $storeName.");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Create Bill - $storeName")),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(Icons.qr_code_scanner),
//                 label: Text("Scan Product"),
//                 onPressed: scanBarcode,
//               ),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.list),
//                 label: Text("Manual Add"),
//                 onPressed: _showProductSelection, // Implement manual add if needed
//               ),
//             ],
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: selectedProducts.length,
//               itemBuilder: (context, index) {
//                 var item = selectedProducts[index];
//
//                 return ListTile(
//                   title: Text(item.name),
//                   subtitle: Text("Qty: ${item.quantity} | Price: \$${item.price}"),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () {
//                       setState(() {
//                         selectedProducts.removeAt(index);
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           ElevatedButton(
//             onPressed: generateBillPDF,
//             child: Text("Generate & Share Bill"),
//           ),
//         ],
//       ),
//     );
//   }
//   Future<void> _showProductSelection() async {
//     TextEditingController searchController = TextEditingController();
//     List<DocumentSnapshot> allProducts = [];
//     List<DocumentSnapshot> filteredProducts = [];
//
//     //  Fetch products from Firestore `inventory`
//     QuerySnapshot productSnapshot = await FirebaseFirestore.instance
//         .collection('inventory') // 🔹 Direct access to inventory collection
//         .get();
//
//     allProducts = productSnapshot.docs;
//     filteredProducts = List.from(allProducts);
//
//     if (allProducts.isEmpty) {
//       print("❌ No products found in inventory.");
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // 📌 Search Bar
//                     TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         labelText: "Search Product",
//                         prefixIcon: Icon(Icons.search),
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (query) {
//                         setState(() {
//                           filteredProducts = query.isEmpty
//                               ? List.from(allProducts)
//                               : allProducts.where((doc) {
//                             var data = doc.data() as Map<String, dynamic>;
//                             return data['name']
//                                 .toLowerCase()
//                                 .contains(query.toLowerCase());
//                           }).toList();
//                         });
//                       },
//                     ),
//                     SizedBox(height: 10),
//                     Expanded(
//                       child: filteredProducts.isEmpty
//                           ? Center(child: Text("No products found"))
//                           : ListView.builder(
//                         itemCount: filteredProducts.length,
//                         itemBuilder: (context, index) {
//                           var doc = filteredProducts[index];
//                           var data = doc.data() as Map<String, dynamic>;
//
//                           return GestureDetector(
//                             onTap: () {
//                               var cost = data['cost'] ?? 0.0; //  Set default if null
//                               var stock = data['stock'] ?? 0; //  Set default if null
//
//                               addToBill({
//                                 'name': data['name'] ?? "Unnamed Product",
//                                 'cost': cost,
//                                 'stock': stock,
//                               });
//
//                               Navigator.pop(context);
//                             },
//
//                             child: Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: ListTile(
//                                 title: Text(data['name'] ?? "Unnamed Product"),
//                                 subtitle: Text(
//                                   "₹${data['cost'] ?? 0} | Stock: ${data['stock'] ?? 0}",
//                                 ),
//                                 trailing: Icon(Icons.add_shopping_cart),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//
// }
class BillScreen extends StatefulWidget {
  final String storeId;

  BillScreen({required this.storeId});

  @override
  _BillScreenState createState() => _BillScreenState();
}

class BillItem {
  final String name;
  final String sku;
  int quantity;
  double price;
  double discount;

  BillItem({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
  });

  double get totalPrice => (price * quantity) - discount;
}


class _BillScreenState extends State<BillScreen> {
  List<Map<String, dynamic>> selectedProducts = [];
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    fetchAllProducts();
  }

  void _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchAllProducts() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      // Query Firestore to find the store where the owner matches the current user ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("inventory")
          .doc("stores")
          .collection("stores") // Adjust if needed
          .where("owner", isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first["name"]; // Return store name
      } else {
      }
    } catch (e) {
      print("Error fetching store name: $e");
    }
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('inventory').get();

    List<Map<String, dynamic>> allProducts = querySnapshot.docs.map((doc) {
      return {'sku': doc.id, ...doc.data() as Map<String, dynamic>};
    }).toList();

    setState(() {
      selectedProducts.addAll(
        allProducts.where((newItem) =>
        !selectedProducts.any((existingItem) => existingItem['sku'] == newItem['sku'])),
      );
    });
  }

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      String barcode = result.rawContent;
      if (barcode.isNotEmpty) {
        addProductBySKU(barcode);
      }
    } catch (e) {
      print("Barcode scan error: $e");
    }
  }

  Future<void> addProductBySKU(String sku) async {
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection('inventory').doc(sku).get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Product not found in inventory!")),
      );
      return;
    }

    Map<String, dynamic> productData = {'sku': sku, ...doc.data() as Map<String, dynamic>};
    setState(() {
      selectedProducts.add(productData);
    });
  }
  Future<void> generateBillPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    String storeName="";

    final fileName = "Invoice_${now.millisecondsSinceEpoch}.pdf";
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      // Query Firestore to find the store where the owner matches the current user ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("inventory")
          .doc("stores")
          .collection("stores") // Adjust if needed
          .where("owner", isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        storeName= querySnapshot.docs.first["name"]; // Return store name
      } else {
      }
    } catch (e) {
      print("Error fetching store name: $e");
    }
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(storeName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Product', 'SKU', 'Price'],
                data: selectedProducts.map((item) => [item['name'], item['sku'], "₹${item['price']}"]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    // Share.shareFiles([file.path], text: "Here is your invoice from $storeName.");
    if (file.path != null) {
      Share.shareXFiles([XFile(file.path!)], text: "Here is your invoice from $storeName.");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ No file to share. Please export first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Billing System")),
      body: Column(
        children: [
          ElevatedButton(onPressed: scanBarcode, child: Text("Scan Barcode")),
          Expanded(
            child: ListView.builder(
              itemCount: selectedProducts.length,
              itemBuilder: (context, index) {
                final product = selectedProducts[index];
                return ListTile(
                  title: Text(product['name'] ?? 'Unknown'),
                  subtitle: Text("SKU: ${product['sku']} - ₹${product['price']}"),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: generateBillPDF, child: Text("Generate PDF")),
        ],
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  Future<Map<String, dynamic>> getInsights() async {
    QuerySnapshot inventorySnapshot =
    await FirebaseFirestore.instance.collection('inventory').get();
    QuerySnapshot billsSnapshot =
    await FirebaseFirestore.instance.collection('bills').get();

    double totalInventoryValue = 0;
    int lowStockCount = 0;
    Map<String, int> topSellingProducts = {};

    for (var doc in inventorySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double price = (data['price'] as num).toDouble();
      int quantity = (data['quantity'] as num).toInt();
      totalInventoryValue += price * quantity;
      if (quantity < 5) lowStockCount++; // Items with stock < 5 are low stock
    }

    for (var doc in billsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String productName = data['name'];
      int quantitySold = data['quantity'];

      if (topSellingProducts.containsKey(productName)) {
        topSellingProducts[productName] =
            topSellingProducts[productName]! + quantitySold;
      } else {
        topSellingProducts[productName] = quantitySold;
      }
    }

    return {
      'totalInventoryValue': totalInventoryValue,
      'lowStockCount': lowStockCount,
      'topSellingProducts': topSellingProducts,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Business Insights")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getInsights(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var data = snapshot.data!;
          var topProducts = data['topSellingProducts'] as Map<String, int>;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text("📊 Total Inventory Value: \$${data['totalInventoryValue']}", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("⚠ Low Stock Items: ${data['lowStockCount']}", style: TextStyle(fontSize: 18, color: Colors.red)),
                SizedBox(height: 20),
                Text("🔥 Top Selling Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...topProducts.entries.map((e) => Text("${e.key}: ${e.value} sold")),
              ],
            ),
          );
        },
      ),
    );
  }
}