import 'package:reelriot/provider/sign_in_provider.dart';
import 'package:reelriot/screens/auth_screens/welcome.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:reelriot/utils/theme/textStyle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  DeleteAccountScreenState createState() => DeleteAccountScreenState();
}

class DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String confirmationText = '';
  User? user;
  final _formKey = GlobalKey<FormState>();
  final _auth = Supabase.instance.client.auth;
  final _supabase = Supabase.instance.client;
  final GlobalMethods _globalMethods = GlobalMethods();
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? uid;
  String? username;
  final FocusNode deleteFN = FocusNode();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    user = _auth.currentUser;
    uid = user?.id;
    if (uid == null) {
      setState(() => _isDataLoaded = true);
      return;
    }

    final res = await _supabase
        .from('profiles')
        .select('username')
        .eq('id', uid!)
        .limit(1);

    setState(() {
      username = res.isNotEmpty ? res[0]['username'] as String? : null;
      _isDataLoaded = true;
    });
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid && uid != null) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        await _supabase.from('usernames').delete().eq('user_id', uid!);
        await _supabase.from('bookmarks').delete().eq('user_id', uid!);
        await _supabase.from('watch_history').delete().eq('user_id', uid!);
        await _supabase.from('profiles').delete().eq('id', uid!);

        await Provider.of<SignInProvider>(context, listen: false).userSignOut();

        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()));
          GlobalMethods.showCustomScaffoldMessage(
              SnackBar(
                content: Text(
                  tr("account_deleted_successfully"),
                  maxLines: 3,
                  style: kTextSmallBodyStyle,
                ),
                duration: const Duration(seconds: 4),
              ),
              context);
        }
      } on AuthException catch (e) {
        if (mounted) {
          final msg = e.message.toLowerCase();
          if (msg.contains('mismatch')) {
            _globalMethods.authErrorHandle(tr("user_mismatch"), context);
          } else if (msg.contains('not found')) {
            _globalMethods.authErrorHandle(tr("user_not_found"), context);
          } else if (msg.contains('invalid') && msg.contains('credential')) {
            _globalMethods.authErrorHandle(tr("invalid_credential"), context);
          } else if (msg.contains('invalid') && msg.contains('email')) {
            _globalMethods.authErrorHandle(tr("invalid_email"), context);
          } else if (msg.contains('wrong') && msg.contains('password')) {
            _globalMethods.authErrorHandle(tr("wrong_password"), context);
          } else if (msg.contains('weak')) {
            _globalMethods.authErrorHandle(tr("weak_password"), context);
          } else if (msg.contains('recent') && msg.contains('login')) {
            _globalMethods.authErrorHandle(
                tr("requires_recent_login"), context);
          } else {
            _globalMethods.authErrorHandle(e.message, context);
          }
        }
      } catch (e) {
        if (mounted) {
          _globalMethods.authErrorHandle(e.toString(), context);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tr("delete_account"))),
        body: !_isDataLoaded
            ? const Center(child: CircularProgressIndicator())
            : uid == null
                ? Center(child: Text(tr("user_not_found")))
                : Center(
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            tr("delete_account"),
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          tr("delete_notice"),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextFormField(
                                    key: const ValueKey('confirmation'),
                                    validator: (value) {
                                      if (value != 'CONFIRM') {
                                        return tr("del_input_err");
                                      }
                                      return null;
                                    },
                                    focusNode: deleteFN,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        errorMaxLines: 3,
                                        border: const UnderlineInputBorder(),
                                        filled: true,
                                        prefixIcon: const Icon(
                                            Icons.text_fields_rounded),
                                        labelText: tr("type_confirm"),
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .surface),
                                    onSaved: (value) {
                                      setState(() {
                                        confirmationText = value!;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        confirmationText = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  const WidgetStatePropertyAll(
                                                      Colors.red),
                                              minimumSize:
                                                  const WidgetStatePropertyAll(
                                                      Size(200, 50)),
                                              shape: WidgetStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              )),
                                          onPressed: () {
                                            _submitForm();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                tr("delete_account"),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Icon(
                                                FontAwesomeIcons.trash,
                                                size: 18,
                                              )
                                            ],
                                          )),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]))));
  }
}
