import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ledgu/utilties/colors.dart';
import 'package:ledgu/widgets/text.dart';
import 'package:ledgu/utilties/images.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatefulWidget {
  final String fullName;
  final String contact;
  final String city;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.contact,
    required this.city,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File file) async {
    if (_auth.currentUser == null) return;
    setState(() => _isUploading = true);

    try {
      final uid = _auth.currentUser!.uid;
      final ref = _storage.ref().child('profile_images/$uid.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // Save URL to Firestore
      await _firestore.collection('users').doc(uid).update({
        'profileImage': downloadUrl,
      });

      setState(() {
        _imageFile = file;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : AssetImage(MyImages.image) as ImageProvider,
                  child: _isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blue2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black1, width: 2),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        MyText(
          text: widget.fullName.isNotEmpty ? widget.fullName : 'Loading...',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.grey1,
        ),
        const SizedBox(height: 15),
        MyText(
          text: widget.contact.isNotEmpty && widget.city.isNotEmpty
              ? '${widget.contact} | ${widget.city}'
              : 'Loading...',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.grey1,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
