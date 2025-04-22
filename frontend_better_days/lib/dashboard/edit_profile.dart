import 'package:better_days/common/responsive_widget.dart';
import 'package:better_days/models/user.dart';
import 'package:better_days/services/api_service.dart';
import 'package:better_days/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:provider/provider.dart';
import 'package:snacknload/snacknload.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final DateTime currentDob;
  final double? currentHeight;
  final double? currentWeight;
  final String? currentProfileImage;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentDob,
    required this.currentHeight,
    required this.currentWeight,
    this.currentProfileImage,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late DateTime _dob;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  XFile? _profileImage;
  bool _isLoading = false;

  late final AuthService authService;

  late String? profileImage;

  bool uploadingImage = false;

  @override
  void initState() {
    super.initState();
    authService = context.read<AuthService>();
    _emailController = TextEditingController(text: widget.currentEmail);
    _nameController = TextEditingController(text: widget.currentName);
    _dob = widget.currentDob;
    _heightController = TextEditingController(
      text: widget.currentHeight.toString(),
    );
    _weightController = TextEditingController(
      text: widget.currentWeight.toString(),
    );
    profileImage = widget.currentProfileImage;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
        uploadingImage = true;
      });
      final fileBytes = await _profileImage!.readAsBytes();
      var uploadRes = await ApiService.instance.uploadFile(
        fileName: path.basename(pickedFile.path),
        fileByte: fileBytes,
        otherParams: {"unique_id": authService.user!.id},
      );

      if (uploadRes.success) {
        setState(() {
          profileImage = uploadRes.data['download_url'];
          _profileImage = null;
          uploadingImage = false;
        });
        await authService.fetchUser();
      } else {
        uploadingImage = false;
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User updateUser = User(
        id: authService.user!.id,
        email: _emailController.text,
        name: _nameController.text,
        dob: _dob,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        profileImage: profileImage,
      );

      var mapData = updateUser.toMap();

      mapData.remove("id");

      var response = await ApiService.instance.patch(
        "/api/auth/users/${authService.user?.id}/update",
        mapData,
      );

      setState(() {
        _isLoading = false;
      });
      if (response.success) {
        SnackNLoad.showSnackBar(
          "Profile updated successfully",
          type: Type.success,
        );
        authService.fetchUser();
      }
      // Close the screen after saving
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formView = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 44),
          child: ListTile(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new),
              padding: EdgeInsets.zero,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            title: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            // trailing: TextButton(
            //   onPressed: _saveProfile,
            //   child: Text(
            //     'Save',
            //     style: theme.textTheme.bodyLarge?.copyWith(
            //       color: theme.colorScheme.primary,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                          _profileImage != null
                              ? FutureBuilder(
                              future: _profileImage!.readAsBytes(),
                              builder: (context,snapshot) {
                                if(snapshot.data!=null){
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }else{
                                  return SizedBox();
                                }
                              }
                          )
                              : profileImage != null
                              ? Image.network(
                            profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (
                                context,
                                error,
                                stackTrace,
                                ) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[500],
                              );
                            },
                          )
                              : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      if (uploadingImage)
                        Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        controller: TextEditingController(
                          text: '${_dob.day}/${_dob.month}/${_dob.year}',
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: const Icon(Icons.height),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: const Icon(Icons.monitor_weight),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        'Save Changes',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.primary.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: ResponsiveWidget(
          mobView: formView,
          deskView: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
              Expanded(
                flex: 6,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: formView,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
            ],
          ),
      ),
    );
  }
}
