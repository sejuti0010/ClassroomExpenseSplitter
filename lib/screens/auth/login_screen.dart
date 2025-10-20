
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../home/group_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  final auth = FirebaseAuth.instance;

  Future<void> _login() async {
    setState(() => _loading = true);
    final email = _emailCtl.text.trim();
    final pass = _passCtl.text.trim();
    debugPrint('Attempt login -> $email');

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email and password')));
      setState(() => _loading = false);
      return;
    }

    try {
      final cred = await auth.signInWithEmailAndPassword(email: email, password: pass);
      final user = cred.user;
      debugPrint('signInWithEmail: user=${user?.uid} email=${user?.email}');

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed: no user returned')));
        setState(() => _loading = false);
        return;
      }


      final current = FirebaseAuth.instance.currentUser;
      debugPrint('FirebaseAuth.currentUser after signIn: ${current?.uid}');


      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => GroupListScreen(currentUserId: user.uid)),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: code=${e.code} message=${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth error')));
    } catch (e, st) {
      debugPrint('Unknown login error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CLASS ROOM')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Text('Login'),
            ),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create account')),
          ],
        ),
      ),
    );
  }
}
