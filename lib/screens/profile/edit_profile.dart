import 'package:reelriot/models/profile_image_list.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/screens/profile/delete_account.dart';
import 'package:reelriot/screens/profile/password_change.dart';
import 'package:reelriot/utils/globlal_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
  static const bgCanvasDark = Color(0xFF030712);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const textPrimDark = Color(0xFFFFFFFF);
  static const textSecDark = Color(0xB8FFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const iconBgDark = Color(0x14FFFFFF);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecLight = Color(0xFF64748B);
  static const borderLight = Color(0x140F172A);

  static const radiusMd = 16.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space6 = 24.0;
  static const screenPadH = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
}

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _auth = Supabase.instance.client.auth;
  final _supabase = Supabase.instance.client;
  String? uid;
  String? userEmail;
  bool? isVerified;
  String? name;
  String? provider;
  String? email;
  String? joinedAt;
  int? profileId;
  bool? userAnonymous;
  String? username;
  String? month;
  int? year;
  int? selectedProfile;
  String _fullName = '';
  String _userName = '';
  final ProfileImages profileImages = ProfileImages();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final GlobalMethods _globalMethods = GlobalMethods();

  void getData() async {
    final user = _auth.currentUser;
    uid = user?.id;

    if (user == null) {
      setState(() => userAnonymous = null);
      return;
    }

    if (user.isAnonymous) {
      setState(() {
        userAnonymous = true;
      });
    } else {
      final res =
          await _supabase.from('profiles').select().eq('id', uid!).limit(1);

      if (res.isNotEmpty) {
        final data = res[0];
        setState(() {
          userAnonymous = false;
          name = data['name'] as String?;
          email = data['email'] as String?;
          userEmail = data['email'] as String?;
          final joinedAtStr = data['joined_at'] as String?;
          if (joinedAtStr != null) {
            joinedAt = joinedAtStr;
            try {
              final dt = DateTime.parse(joinedAtStr);
              month = DateFormat('MMMM').format(DateTime(0, dt.month));
              year = dt.year;
            } catch (_) {}
          }
          isVerified = data['verified'] as bool?;
          profileId = data['profile_id'] as int?;
          username = data['username'] as String?;
        });
      } else {
        setState(() => userAnonymous = false);
      }
    }
  }

  Future<bool> checkIfDocExists(String username) async {
    final res = await _supabase
        .from('usernames')
        .select('username')
        .eq('username', username.trim().toLowerCase())
        .limit(1);
    return res.isNotEmpty;
  }

  void updateProfile() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid && uid != null) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        if (username == _userName) {
          await _supabase.from('profiles').update({
            'name': _fullName,
            'profile_id': profileId ?? 0,
          }).eq('id', uid!);
          if (mounted) Navigator.pop(context);
        } else if (username != _userName) {
          if (await checkIfDocExists(_userName)) {
            if (mounted) {
              GlobalMethods.showCustomScaffoldMessage(
                SnackBar(
                  content: Text(
                    tr("username_exists"),
                    maxLines: 3,
                  ),
                  duration: const Duration(seconds: 4),
                ),
                context,
              );
            }
            setState(() {
              _userName = username ?? '';
            });
            return;
          }
          if (username != null && username!.isNotEmpty) {
            await _supabase
                .from('usernames')
                .delete()
                .eq('username', username!.trim().toLowerCase());
          }
          await _supabase.from('usernames').insert({
            'username': _userName.trim().toLowerCase(),
            'user_id': uid!,
          });
          await _supabase.from('profiles').update({
            'name': _fullName,
            'username': _userName.trim().toLowerCase(),
            'profile_id': profileId ?? 0,
          }).eq('id', uid!);
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          _globalMethods.authErrorHandle(e.toString(), context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;
    final iconBg = isDark ? _Design.iconBgDark : _Design.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space2),
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            iconColor: textPrim,
            bgColor: iconBg,
          ),
        ),
        title: Text(
          tr("edit_profile"),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: userAnonymous == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: _Design.screenPadH,
                vertical: _Design.space4,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Profile picture section ─────────────────────────────
                    Text(
                      tr("profile_picture"),
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: _Design.space3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: _Design.space3,
                        horizontal: _Design.space2,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(_Design.radiusMd),
                        border: Border.all(color: border),
                        boxShadow: const [_Design.shadowCard],
                      ),
                      child: SizedBox(
                        height: 88,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              profileImages.profile().map((Profile profile) {
                            final selected = profileId == profile.index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _Design.space2,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      profileId = profile.index;
                                      selectedProfile = profile.index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selected ? _Design.primary : border,
                                        width: selected ? 3 : 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: Image.asset(
                                        'assets/images/profiles/${profile.index}.png',
                                        fit: BoxFit.cover,
                                        height: 64,
                                        width: 64,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: _Design.space6),

                    // ─── Form card ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(_Design.space4),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(_Design.radiusMd),
                        border: Border.all(color: border),
                        boxShadow: const [_Design.shadowCard],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EditField(
                            initialValue: name,
                            key: const ValueKey('name'),
                            label: tr("full_name"),
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("name_empty");
                              }
                              if (value.length > 40 || value.length < 2) {
                                return tr("name_short_long");
                              }
                              return null;
                            },
                            onSaved: (value) => _fullName = value ?? '',
                            onChanged: (value) => _fullName = value,
                            textPrim: textPrim,
                            textSec: textSec,
                            border: border,
                            surface: surface,
                          ),
                          const SizedBox(height: _Design.space4),
                          _EditField(
                            initialValue: username,
                            key: const ValueKey('username'),
                            label: tr("username"),
                            icon: Icons.alternate_email_rounded,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^[a-zA-Z0-9_]*'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return tr("username_empty");
                              }
                              if (value.length < 5 || value.length > 30) {
                                return tr("username_short_long");
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]*$').hasMatch(value)) {
                                return tr("invalid_username");
                              }
                              return null;
                            },
                            onSaved: (value) => _userName = value ?? '',
                            onChanged: (value) => _userName = value,
                            textPrim: textPrim,
                            textSec: textSec,
                            border: border,
                            surface: surface,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: _Design.space6),

                    // ─── Primary CTA ─────────────────────────────────────────
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(_Design.space4),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Material(
                        color: _Design.primary,
                        borderRadius: BorderRadius.circular(9999),
                        child: InkWell(
                          onTap: updateProfile,
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: Text(
                              tr("confirm"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: _Design.space6),

                    // ─── Secondary actions ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(_Design.space4),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(_Design.radiusMd),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          _ActionTile(
                            icon: Icons.lock_outline_rounded,
                            label: tr("change_password"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PasswordChangeScreen(),
                                ),
                              );
                            },
                            textPrim: textPrim,
                            textSec: textSec,
                          ),
                          const Divider(height: 1),
                          _ActionTile(
                            icon: Icons.email_outlined,
                            label: tr("change_email"),
                            onTap: () {},
                            textPrim: textPrim,
                            textSec: textSec,
                          ),
                          const Divider(height: 1),
                          _ActionTile(
                            icon: Icons.delete_outline_rounded,
                            label: tr("delete_account"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DeleteAccountScreen(),
                                ),
                              );
                            },
                            destructive: true,
                            textPrim: textPrim,
                            textSec: textSec,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: _Design.space6),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String? initialValue;
  final String label;
  final IconData icon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final Color textPrim;
  final Color textSec;
  final Color border;
  final Color surface;

  const _EditField({
    super.key,
    this.initialValue,
    required this.label,
    required this.icon,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onChanged,
    required this.textPrim,
    required this.textSec,
    required this.border,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      style: TextStyle(color: textPrim, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSec),
        prefixIcon: Icon(icon, size: 22, color: textSec),
        errorStyle: TextStyle(color: _Design.primary, fontSize: 12),
        errorMaxLines: 3,
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          borderSide: const BorderSide(color: _Design.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Design.radiusMd),
          borderSide: const BorderSide(color: _Design.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _Design.space4,
          vertical: _Design.space3 + 4,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Color textPrim;
  final Color textSec;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    required this.textPrim,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? _Design.primary : textPrim;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Design.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: _Design.space3,
            horizontal: _Design.space2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: color,
              ),
              const SizedBox(width: _Design.space3),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: destructive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: textSec,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
