import 'dart:io';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/services/post_api_service.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  // API services
  final PostApiService _postApiService = PostApiService();
  final ApiService _apiService = ApiService();

  // Image handling
  dynamic _imageFile; // Can be File or XFile

  // Service options
  List<Map<String, dynamic>> _serviceOptions = [];
  String? _selectedServiceOptionId;
  bool _isLoadingServices = false;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServiceOptions();
  }

  Future<void> _loadServiceOptions() async {
    setState(() {
      _isLoadingServices = true;
    });

    try {
      final result = await _apiService.getServiceOptions();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        List<Map<String, dynamic>> serviceOptions = [];

        if (data is List) {
          serviceOptions = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          if (data['serviceOption'] != null) {
            serviceOptions =
                List<Map<String, dynamic>>.from(data['serviceOption']);
          } else if (data['serviceOptions'] != null) {
            serviceOptions =
                List<Map<String, dynamic>>.from(data['serviceOptions']);
          } else if (data['data'] != null) {
            serviceOptions = List<Map<String, dynamic>>.from(data['data']);
          }
        }

        setState(() {
          _serviceOptions = serviceOptions;
        });

        print('Loaded ${_serviceOptions.length} service options');
        for (var option in _serviceOptions) {
          print('Service: ${option['name']} - ID: ${option['id']}');
        }
      }
    } catch (e) {
      print('Error loading service options: $e');
    } finally {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
            child: Text('Tạo bài đăng mới',
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

              // Title field
              buildInputField(
                'Tiêu đề bài đăng',
                controller: _titleController,
                isRequired: true,
              ),

              // Content field
              buildInputField(
                'Nội dung bài đăng',
                controller: _contentController,
                maxLines: 5,
                isRequired: true,
              ),

              // Tags field
              buildInputField(
                'Tags (phân cách bằng dấu phẩy)',
                controller: _tagsController,
                isRequired: true,
              ),

              // Service option dropdown
              _buildServiceOptionDropdown(),

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
                          'Đăng bài',
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
      bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: mySecondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: "JacquesFrancois"),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Trường này là bắt buộc';
                }
                return null;
              }
            : null,
      ),
    );
  }

  // Build image section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh bài đăng:',
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
            height: 300,
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
                        'Thêm ảnh hoặc video',
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

  // Build service option dropdown
  Widget _buildServiceOptionDropdown() {
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
                  value: _selectedServiceOptionId,
                  hint: const Text(
                    'Chọn dịch vụ liên quan (tùy chọn)',
                    style: TextStyle(fontFamily: "JacquesFrancois"),
                  ),
                  isExpanded: true,
                  items: _serviceOptions.isEmpty
                      ? null
                      : _serviceOptions
                          .map<DropdownMenuItem<String>>((serviceOption) {
                          final id = serviceOption['id']?.toString();
                          final name = serviceOption['name']?.toString() ??
                              'Không có tên';
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(
                              name,
                              style: const TextStyle(
                                  fontFamily: "JacquesFrancois"),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    print('Dropdown changed to: $newValue');
                    setState(() {
                      _selectedServiceOptionId = newValue;
                    });
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
        const SnackBar(content: Text('Vui lòng chọn hình ảnh cho bài đăng')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to correct format for API
      XFile? imageFile;
      if (_imageFile is File) {
        imageFile = XFile(_imageFile.path);
      } else if (_imageFile is XFile) {
        imageFile = _imageFile;
      }

      final result = await _postApiService.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _tagsController.text.trim(),
        serviceOptionId: _selectedServiceOptionId,
        imageFile: imageFile,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo bài đăng thành công!')),
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
