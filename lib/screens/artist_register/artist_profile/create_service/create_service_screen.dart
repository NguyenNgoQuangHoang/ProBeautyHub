import 'dart:io';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  _CreateServiceScreenState createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Image handling
  dynamic _imageFile; // Can be File or XFile

  // Selected service ID and artist ID
  String? _selectedServiceId;
  String? _artistId;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingServices = false;

  // Services from API
  List<Map<String, dynamic>> _services = [];

  // API service
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadArtistId();
  }

  // Load services from API
  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final result = await _apiService.getServices();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // Handle new format: data contains serviceDTOs directly
        if (data is Map && data['serviceDTOs'] != null) {
          setState(() {
            _services = List<Map<String, dynamic>>.from(data['serviceDTOs']);
          });
        } else if (data is List) {
          // Fallback if data is directly a list
          setState(() {
            _services = List<Map<String, dynamic>>.from(data);
          });
        }

        print('Loaded ${_services.length} services');
      }
    } catch (e) {
      print('Error loading services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách dịch vụ: $e')),
      );
    } finally {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  // Load artist ID from token
  Future<void> _loadArtistId() async {
    try {
      final userId = await _apiService.getUserIdFromToken();
      setState(() {
        _artistId = userId;
      });
    } catch (e) {
      print('Error loading artist ID: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
            child: Text('Tạo dịch vụ mới',
                style: TextStyle(
                    color: Colors.black, fontFamily: "JacquesFrancois"))),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image upload section
              _buildImageSection(),
              const SizedBox(height: 20),

              // Service name field
              buildInputField(
                'Tên dịch vụ',
                controller: _nameController,
                isRequired: true,
              ),

              // Description field
              buildInputField(
                'Mô tả chi tiết',
                controller: _descriptionController,
                maxLines: 5,
                isRequired: true,
              ),

              // Price field
              buildInputField(
                'Giá dịch vụ (VNĐ)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá dịch vụ';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Giá dịch vụ phải là số dương';
                  }
                  return null;
                },
              ),

              // Service selection dropdown
              _buildServiceDropdown(),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Tạo dịch vụ',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "JacquesFrancois",
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String hint,
      {TextEditingController? controller,
      int maxLines = 1,
      bool isRequired = false,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mySecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: "JacquesFrancois"),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Trường này là bắt buộc';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  // Build image section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh dịch vụ:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "JacquesFrancois",
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWidget(_imageFile!),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Chọn hình ảnh dịch vụ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "JacquesFrancois",
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Build image widget compatible with web and mobile
  Widget _buildImageWidget(dynamic imageSource) {
    if (kIsWeb) {
      if (imageSource is XFile) {
        return FutureBuilder<Uint8List>(
          future: imageSource.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      }
    } else {
      if (imageSource is File) {
        return Image.file(
          imageSource,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else if (imageSource is XFile) {
        return Image.file(
          File(imageSource.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }
    return const Center(
      child: Icon(Icons.image, size: 48, color: Colors.grey),
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _imageFile = pickedFile;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  // Build service dropdown
  Widget _buildServiceDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mySecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: _isLoadingServices
            ? const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Đang tải dịch vụ...',
                      style: TextStyle(fontFamily: "JacquesFrancois")),
                ],
              )
            : DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedServiceId,
                  hint: const Text(
                    'Chọn loại dịch vụ',
                    style: TextStyle(fontFamily: "JacquesFrancois"),
                  ),
                  isExpanded: true,
                  itemHeight: 80, // Increase height for better display
                  items: _services.map<DropdownMenuItem<String>>((service) {
                    return DropdownMenuItem<String>(
                      value: service['id']?.toString(),
                      child: Row(
                        children: [
                          // Service image if available
                          if (service['imageUrl'] != null &&
                              service['imageUrl'].toString().isNotEmpty)
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(service['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          // Service info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  service['name']?.toString() ?? 'Không có tên',
                                  style: const TextStyle(
                                    fontFamily: "JacquesFrancois",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (service['description'] != null &&
                                    service['description']
                                        .toString()
                                        .isNotEmpty &&
                                    service['description'].toString() !=
                                        'string')
                                  Text(
                                    service['description'].toString(),
                                    style: const TextStyle(
                                      fontFamily: "JacquesFrancois",
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedServiceId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại dịch vụ';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
      ),
    );
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hình ảnh dịch vụ')),
      );
      return;
    }

    if (_artistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xác định thông tin nghệ sĩ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert XFile to correct format for API
      XFile? imageFile;
      if (_imageFile is File) {
        imageFile = XFile(_imageFile.path);
      } else if (_imageFile is XFile) {
        imageFile = _imageFile;
      }

      final result = await _apiService.createServiceOption(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        serviceId: _selectedServiceId!,
        imageFile: imageFile,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo dịch vụ thành công!')),
        );

        // Navigate back with success result
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: ${result['message'] ?? 'Không xác định'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
