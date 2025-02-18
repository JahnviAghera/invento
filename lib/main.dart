import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

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
      home: const AuthWrapper(),
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
            return InventoryDashboard();
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
            padding: EdgeInsets.only(top: 50,left: 32,right: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GestureDetector(
                //   child: Icon(Icons.arrow_back_ios),
                // ),
                const SizedBox(height: 100),
                Image.asset("assets/images/logo.png",height: 100,),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 26,fontWeight: FontWeight.bold,fontFamily: "Poppins",height: 1.5), // Default style
                    children: [
                      TextSpan(text: "Welcome Back 👋 \nto "),
                      TextSpan(text: "Invento", style: TextStyle(color: Color(0xFF7871F8))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text("Login to your account",style: TextStyle(fontSize: 16),),
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
                          borderSide: BorderSide(color: Colors.grey,width: 2), // Grey border
                          borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7871F8),width: 2), // Border color when focused
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
                        labelStyle: TextStyle(color: Colors.grey,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 2), // Grey border
                          borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: Icon(
                            _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF7871F8),width: 2), // Border color when focused
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: (){},
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
                        ),),
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
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                      width: 380,
                      height: 15,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 109.01,
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
                            width: 109.01,
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
                            onTap: (){

                            },
                            child:Image.asset("assets/images/google-color-svgrepo-com.png",height: 35)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegistrationScreen()));
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "New here? ",
                              style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w400,), // Add styling
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
            )
        ),
      )
    );
  }

  // Email/Password Login Function
  Future<bool> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      return true;
    }  on FirebaseAuthException catch (e) {
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
              padding: EdgeInsets.only(top: 50,left: 32,right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GestureDetector(
                  //   child: Icon(Icons.arrow_back_ios),
                  // ),
                  const SizedBox(height: 100),
                  Image.asset("assets/images/logo.png",height: 100,),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 26,fontWeight: FontWeight.bold,fontFamily: "Poppins",height: 1.5), // Default style
                      children: [
                        TextSpan(text: "Create an Account"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Sign up now and start exploring.",style: TextStyle(fontSize: 16),),
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
                            borderSide: BorderSide(color: Colors.grey,width: 2), // Grey border
                            borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7871F8),width: 2), // Border color when focused
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
                          labelStyle: TextStyle(color: Colors.grey,),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 2), // Grey border
                            borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            child: Icon(
                              _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7871F8),width: 2), // Border color when focused
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
                          labelStyle: TextStyle(color: Colors.grey,),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 2), // Grey border
                            borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7871F8),width: 2), // Border color when focused
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
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                        width: 380,
                        height: 15,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 109.01,
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
                              width: 109.01,
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
                              onTap: (){

                              },
                              child:Image.asset("assets/images/google-color-svgrepo-com.png",height: 35)
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Already have an Account? ",
                                style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.w400,), // Add styling
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
              )
          ),
        )
    );
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
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
// Inventory Dashboard Stateful Widget
class InventoryDashboard extends StatefulWidget {
  @override
  _InventoryDashboardState createState() => _InventoryDashboardState();
}

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _initializeInventory() async {
    QuerySnapshot snapshot = await _db.collection('inventory').get();
    if (snapshot.docs.isEmpty) {
      await _db.collection('inventory').add({'name': 'Sample Item', 'stock': 10});
    }
  }

  Future<List<Map<String, dynamic>>> fetchInventory() async {
    await _initializeInventory();  // Ensure initial data exists
    QuerySnapshot snapshot = await _db.collection('inventory').get();
    return snapshot.docs.map((doc) => {
      "id": doc.id,
      ...doc.data() as Map<String, dynamic>
    }).toList();
  }

  Future<void> addInventory(String name, int stock) async {
    await _db.collection('inventory').add({'name': name, 'stock': stock});
  }

  Future<void> updateInventory(String id, int stock) async {
    await _db.collection('inventory').doc(id).update({'stock': stock});
  }

  Future<void> deleteInventory(String id) async {
    await _db.collection('inventory').doc(id).delete();
  }
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  final InventoryService _inventoryService = InventoryService();
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    List<Map<String, dynamic>> data = await _inventoryService.fetchInventory();
    setState(() {
      _inventory = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInventory,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                  },
                  child: Text("Logout")),
                  Text("Total Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_inventory.length}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Icon(Icons.inventory, color: Colors.blue, size: 30),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _inventory.isEmpty
                  ? Center(child: Text("No items available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))
                  : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  var item = _inventory[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurpleAccent,
                        child: Icon(FontAwesomeIcons.boxOpen, color: Colors.white),
                      ),
                      title: Text(item["name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      subtitle: Text("Stock: ${item["stock"]}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _inventoryService.deleteInventory(item["id"]);
                          _loadInventory();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddInventoryPage())).then((_) => _loadInventory());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class AddInventoryPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Inventory")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: "Stock"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                int stock = int.parse(stockController.text);
                await _inventoryService.addInventory(name, stock);
                Navigator.pop(context);
              },
              child: Text("Add Item"),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(child: Text("Settings Page")),
    );
  }
}