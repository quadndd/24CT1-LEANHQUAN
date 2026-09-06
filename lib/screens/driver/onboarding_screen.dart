import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool _isLoading = false;

  // Controllers
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _cccdController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  // Images (Base64)
  String? _cccdFrontBase64;
  String? _cccdBackBase64;
  String? _licenseFrontBase64;
  String? _licenseBackBase64;
  String? _faceBase64;

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(
      source: type == 'face' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50, // Compress to save DB space
      maxWidth: 800,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = "data:image/jpeg;base64,${base64Encode(bytes)}";
      
      setState(() {
        if (type == 'cccd_front') _cccdFrontBase64 = base64String;
        else if (type == 'cccd_back') _cccdBackBase64 = base64String;
        else if (type == 'license_front') _licenseFrontBase64 = base64String;
        else if (type == 'license_back') _licenseBackBase64 = base64String;
        else if (type == 'face') _faceBase64 = base64String;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_cccdFrontBase64 == null || _cccdBackBase64 == null || 
        _licenseFrontBase64 == null || _licenseBackBase64 == null || 
        _faceBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cung cấp đủ 5 ảnh yêu cầu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id');

      await Supabase.instance.client.from('driver_profiles').insert({
        'user_id': userId,
        'dob': _dobController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'license_plate': _licensePlateController.text,
        'cccd_number': _cccdController.text,
        'license_number': _licenseNumberController.text,
        'cccd_image': _cccdFrontBase64,
        'cccd_back_image': _cccdBackBase64,
        'license_image': _licenseFrontBase64,
        'license_back_image': _licenseBackBase64,
        'face_image': _faceBase64,
        'is_approved': false,
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/driver/pending');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cập nhật hồ sơ Tài xế', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF006E2E)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin cá nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTextField(_dobController, 'Ngày tháng năm sinh (DD/MM/YYYY)', Icons.calendar_today),
                  const SizedBox(height: 12),
                  _buildTextField(_addressController, 'Địa chỉ thường trú', Icons.location_on),
                  const SizedBox(height: 12),
                  _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                  
                  const SizedBox(height: 24),
                  const Text('Thông tin phương tiện & Giấy tờ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTextField(_licensePlateController, 'Biển số xe (VD: 29A-123.45)', Icons.directions_car),
                  const SizedBox(height: 12),
                  _buildTextField(_cccdController, 'Số CCCD/CMND', Icons.badge),
                  const SizedBox(height: 12),
                  _buildTextField(_licenseNumberController, 'Số Bằng lái xe', Icons.card_membership),

                  const SizedBox(height: 24),
                  const Text('Hình ảnh xác thực', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(child: _buildImagePicker('cccd_front', 'CCCD (Mặt trước)', _cccdFrontBase64, isGallery: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildImagePicker('cccd_back', 'CCCD (Mặt sau)', _cccdBackBase64, isGallery: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildImagePicker('license_front', 'Bằng lái (Mặt trước)', _licenseFrontBase64, isGallery: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildImagePicker('license_back', 'Bằng lái (Mặt sau)', _licenseBackBase64, isGallery: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildImagePicker('face', 'Chụp ảnh chân dung (Camera)', _faceBase64, isGallery: false),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006E2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Gửi hồ sơ xét duyệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF006E2E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập thông tin này';
        return null;
      },
    );
  }

  Widget _buildImagePicker(String type, String label, String? base64Data, {required bool isGallery}) {
    return InkWell(
      onTap: () => _pickImage(type),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: base64Data != null ? const Color(0xFF00B14F) : Colors.grey.shade300, width: 2),
        ),
        child: base64Data != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(base64Data.split(',')[1]),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isGallery ? Icons.photo_library : Icons.camera_alt, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
      ),
    );
  }
}
