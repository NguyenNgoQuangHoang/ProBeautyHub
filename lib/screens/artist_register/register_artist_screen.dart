import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:booking_app/screens/artist_register/register_succes_artist_screen.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:booking_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_text_field_artist.dart';

class RegisterArtistScreen extends StatefulWidget {
  const RegisterArtistScreen({super.key});

  @override
  State<RegisterArtistScreen> createState() => _RegisterArtistScreenState();
}

class _RegisterArtistScreenState extends State<RegisterArtistScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each input field
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  // Dropdown selections
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedDistrictId; // Store district ID for API calls

  // Boolean selections
  bool _termsAccepted = false;
  bool _acceptUrgentBooking = false;
  bool _commonCosmetics = false;

  // Service IDs (multi-select)
  final List<String> _interestedServiceIds = [];

  // Images
  dynamic _cccdFrontImage; // Can be File or XFile
  dynamic _cccdBackImage; // Can be File or XFile
  final List<dynamic> _portfolioImages = []; // Can contain File or XFile

  // Track whether form is valid
  bool _isFormValid = false;

  // API service
  final ApiService _apiService = ApiService();

  // Data from API
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _services = [];
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingServices = false;

  // Validate form and update button state
  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final priceValid = _minPriceController.text.isNotEmpty &&
        _maxPriceController.text.isNotEmpty;
    final cityValid = _selectedCity != null && _selectedDistrict != null;
    final termsValid = _termsAccepted;
    final experienceValid = _yearsOfExperienceController.text.isNotEmpty;
    final imagesValid = _cccdFrontImage != null &&
        _cccdBackImage != null &&
        _portfolioImages.isNotEmpty;

    final allValid = isValid &&
        priceValid &&
        cityValid &&
        termsValid &&
        experienceValid &&
        imagesValid;

    if (_isFormValid != allValid) {
      setState(() => _isFormValid = allValid);
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen for changes in required fields to check form validity
    _minPriceController.addListener(_validateForm);
    _maxPriceController.addListener(_validateForm);
    _yearsOfExperienceController.addListener(_validateForm);

    // Load data when screen initializes
    _loadCities();
    _loadServices();
  }

  // Load cities from API
  Future<void> _loadCities() async {
    setState(() {
      _isLoadingCities = true;
    });

    try {
      final result = await _apiService.getCities();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // Kiểm tra format API response
        if (data['isSuccess'] == true && data['cityList'] != null) {
          // Convert cityList từ string array thành Map array cho dropdown
          final cityNames = List<String>.from(data['cityList']);
          setState(() {
            _cities = cityNames
                .map((cityName) => {
                      'id': cityName, // Sử dụng name làm id
                      'name': cityName,
                    })
                .toList();
          });
          print('Cities loaded: ${_cities.length} cities');
        } else {
          print('API response format error: $data');
        }
      } else {
        print('Failed to load cities: ${result['error']}');
        // Hiển thị thông báo lỗi nếu cần
        if (result['error']?.toString().contains('token') == true) {
          _showTokenErrorDialog();
        }
      }
    } catch (e) {
      print('Error loading cities: $e');
    } finally {
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  // Load districts by city name
  Future<void> _loadDistricts(String cityName) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
      _selectedDistrictId = null;
    });

    try {
      final result = await _apiService.getDistricts(cityName);
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // Kiểm tra format API response cho districts
        if (data is List) {
          // Nếu data là array trực tiếp
          setState(() {
            _districts = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map) {
          // Nếu data là object, kiểm tra các key có thể
          if (data['districtList'] != null) {
            final districtNames = List<String>.from(data['districtList']);
            setState(() {
              _districts = districtNames
                  .map((districtName) => {
                        'id': districtName,
                        'name': districtName,
                      })
                  .toList();
            });
          } else if (data['isSuccess'] == true && data['districts'] != null) {
            setState(() {
              _districts = List<Map<String, dynamic>>.from(data['districts']);
            });
          } else {
            print('Unknown districts API format: $data');
          }
        }
        print('Districts loaded: ${_districts.length} districts for $cityName');
      } else {
        print('Failed to load districts: ${result['error']}');
      }
    } catch (e) {
      print('Error loading districts: $e');
    } finally {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
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

        // Kiểm tra format API response cho services
        if (data is List) {
          // Nếu data là array trực tiếp
          setState(() {
            _services = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map) {
          // Nếu data là object, kiểm tra các key có thể
          if (data['isSuccess'] == true && data['serviceDTOs'] != null) {
            // Format mới: serviceDTOs array
            setState(() {
              _services = List<Map<String, dynamic>>.from(data['serviceDTOs']);
            });
          } else if (data['serviceList'] != null) {
            setState(() {
              _services = List<Map<String, dynamic>>.from(data['serviceList']);
            });
          } else if (data['isSuccess'] == true && data['services'] != null) {
            setState(() {
              _services = List<Map<String, dynamic>>.from(data['services']);
            });
          } else {
            print('Unknown services API format: $data');
            // Fallback: thử convert trực tiếp
            setState(() {
              _services = [
                data as Map<String, dynamic>
              ]; // Wrap single object in array
            });
          }
        }
        print('Services loaded: ${_services.length} services');
      } else {
        print('Failed to load services: ${result['error']}');
      }
    } catch (e) {
      print('Error loading services: $e');
    } finally {
      setState(() {
        _isLoadingServices = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to free memory
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 30),

                // City selection
                _buildApiDropdown(
                  value: _selectedCity,
                  items: _cities,
                  hint: 'Chọn thành phố',
                  isLoading: _isLoadingCities,
                  onChanged: (Map<String, dynamic>? selectedCity) {
                    setState(() {
                      _selectedCity = selectedCity?['name'];
                      _selectedDistrict = null;
                      _selectedDistrictId = null;
                    });
                    if (_selectedCity != null) {
                      _loadDistricts(_selectedCity!);
                    }
                    _validateForm();
                  },
                ),
                const SizedBox(height: 15),

                // District selection
                _buildApiDropdown(
                  value: _selectedDistrict,
                  items: _districts,
                  hint: 'Chọn quận/huyện',
                  isLoading: _isLoadingDistricts,
                  onChanged: (Map<String, dynamic>? selectedDistrict) {
                    setState(() {
                      _selectedDistrict = selectedDistrict?['name'];
                      _selectedDistrictId = selectedDistrict?['id'];
                    });
                    _validateForm();
                  },
                ),
                const SizedBox(height: 15),

                // Price range
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormFieldArtist(
                        hintText: 'Giá tối thiểu',
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập giá tối thiểu';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextFormFieldArtist(
                        hintText: 'Giá tối đa',
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập giá tối đa';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Years of experience
                CustomTextFormFieldArtist(
                  hintText: 'Số năm kinh nghiệm',
                  controller: _yearsOfExperienceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số năm kinh nghiệm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Terms accepted checkbox
                _buildCheckbox(
                  value: _termsAccepted,
                  title: 'Tôi đồng ý với các điều khoản',
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                    _validateForm();
                  },
                ),

                // Accept urgent booking checkbox
                _buildCheckbox(
                  value: _acceptUrgentBooking,
                  title: 'Chấp nhận đặt lịch gấp',
                  onChanged: (value) {
                    setState(() {
                      _acceptUrgentBooking = value ?? false;
                    });
                  },
                ),

                // Common cosmetics checkbox
                _buildCheckbox(
                  value: _commonCosmetics,
                  title: 'Có mỹ phẩm thông dụng',
                  onChanged: (value) {
                    setState(() {
                      _commonCosmetics = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Interested services
                _buildServiceSelection(),

                const SizedBox(height: 20),

                // CCCD Images
                _buildImageSection('CCCD Mặt trước', _cccdFrontImage, (file) {
                  setState(() {
                    _cccdFrontImage = file;
                  });
                  _validateForm();
                }),

                const SizedBox(height: 15),

                _buildImageSection('CCCD Mặt sau', _cccdBackImage, (file) {
                  setState(() {
                    _cccdBackImage = file;
                  });
                  _validateForm();
                }),

                const SizedBox(height: 15),

                // Portfolio Images
                _buildPortfolioSection(),

                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              // Lấy userId từ JWT token
                              final userId =
                                  await _apiService.getUserIdFromToken();
                              if (userId == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Lỗi'),
                                    content: const Text(
                                        'Không thể lấy thông tin người dùng. Vui lòng đăng nhập lại.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              // Lấy dữ liệu từ form
                              final certificateJson =
                                  _generateCertificatesJson();
                              final areaId = _selectedDistrictId ?? '';
                              final minPrice = _minPriceController.text;
                              final maxPrice = _maxPriceController.text;
                              final termsAccepted = _termsAccepted;
                              final yearsOfExperience =
                                  _yearsOfExperienceController.text;
                              final acceptUrgentBooking = _acceptUrgentBooking;
                              final commonCosmetics =
                                  _commonCosmetics.toString();
                              final interestedServiceIds =
                                  _interestedServiceIds;
                              final cccdFrontImage = _cccdFrontImage;
                              final cccdBackImage = _cccdBackImage;
                              final portfolioImages = _portfolioImages;

                              // Gọi API
                              final result = await _apiService.registerArtist(
                                userId: userId,
                                certificateJson: certificateJson,
                                areaId: areaId,
                                minPrice: int.tryParse(minPrice) ?? 0,
                                maxPrice: int.tryParse(maxPrice) ?? 0,
                                termsAccepted: termsAccepted,
                                yearsOfExperience:
                                    int.tryParse(yearsOfExperience) ?? 0,
                                acceptUrgentBooking: acceptUrgentBooking,
                                commonCosmetics: commonCosmetics,
                                interestedServiceIds: interestedServiceIds,
                                cccdFrontImage: cccdFrontImage,
                                cccdBackImage: cccdBackImage,
                                portfolioImages: portfolioImages,
                              );

                              if (result['success'] == true) {
                                // Thành công
                                loadingScreen(context,
                                    () => const RegisterSuccesArtistScreen());
                              } else {
                                // Thất bại
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Đăng ký thất bại'),
                                    content: Text(result['error']?.toString() ??
                                        'Lỗi không xác định'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE93D8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(236, 46),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tiếp tục'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // App logo made of 2 texts and an image
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _shadowedText("FLAW"),
        const SizedBox(width: 8),
        Image.asset("assets/images/entypo_flower.png", width: 24, height: 24),
        const SizedBox(width: 8),
        _shadowedText("ESS"),
      ],
    );
  }

  // Logo text with shadow styling
  Widget _shadowedText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(5.0, 5.0),
          ),
        ],
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // API Dropdown builder
  Widget _buildApiDropdown({
    required String? value,
    required List<Map<String, dynamic>> items,
    required String hint,
    required bool isLoading,
    required Function(Map<String, dynamic>?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Đang tải...', style: TextStyle(color: Colors.grey)),
              ],
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: items.isNotEmpty && value != null
                    ? items.cast<Map<String, dynamic>?>().firstWhere(
                          (item) => item?['name'] == value,
                          orElse: () => null,
                        )
                    : null,
                hint: Text(hint, style: const TextStyle(color: Colors.grey)),
                isExpanded: true,
                items: items.map((Map<String, dynamic> item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(item['name']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
    );
  }

  // Checkbox builder
  Widget _buildCheckbox({
    required bool value,
    required String title,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFCE93D8),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // Service selection builder
  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ quan tâm:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _isLoadingServices
            ? const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Đang tải dịch vụ...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _services.map((service) {
                  final serviceId = service['id']?.toString() ?? '';
                  final serviceName = service['name']?.toString() ?? '';
                  final isSelected = _interestedServiceIds.contains(serviceId);

                  return FilterChip(
                    label: Text(serviceName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _interestedServiceIds.add(serviceId);
                        } else {
                          _interestedServiceIds.remove(serviceId);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFCE93D8),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey.shade100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // Image selection builder
  Widget _buildImageSection(
      String title, dynamic image, Function(dynamic) onImageSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? pickedFile =
                await picker.pickImage(source: ImageSource.gallery);

            if (pickedFile != null) {
              if (kIsWeb) {
                onImageSelected(pickedFile);
              } else {
                onImageSelected(File(pickedFile.path));
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(image),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Chọn ảnh', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Helper method to build image widget compatible with web and mobile
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
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      }
      return const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      );
    } else {
      // Mobile platform
      if (imageSource is File) {
        return Image.file(
          imageSource,
          fit: BoxFit.cover,
        );
      } else if (imageSource is XFile) {
        return Image.file(
          File(imageSource.path),
          fit: BoxFit.cover,
        );
      }
      return const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      );
    }
  }

  // Portfolio images builder
  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh Portfolio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          child: _portfolioImages.isEmpty
              ? GestureDetector(
                  onTap: _pickPortfolioImages,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Chọn ảnh Portfolio',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _portfolioImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _portfolioImages.length) {
                      return GestureDetector(
                        onTap: _pickPortfolioImages,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              size: 32, color: Colors.grey),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: _buildImageWidget(_portfolioImages[index]),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _portfolioImages.removeAt(index);
                              });
                              _validateForm();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Pick portfolio images
  Future<void> _pickPortfolioImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        if (kIsWeb) {
          _portfolioImages.addAll(pickedFiles);
        } else {
          _portfolioImages.addAll(pickedFiles.map((file) => File(file.path)));
        }
      });
      _validateForm();
    }
  }

  // Helper method to generate certificates JSON
  String _generateCertificatesJson() {
    // Gửi dữ liệu cố định
    final sampleCertificates = [
      {
        "ImageUrl": "https://link-den-anh-bang-cap.com/certificate1.jpg",
        "Name": "Chứng chỉ Makeup chuyên nghiệp",
        "Institution": "Trường Đào tạo Thẩm mỹ ABC",
        "Description": "Hoàn thành khóa học makeup chuyên nghiệp năm 2022"
      },
      {
        "ImageUrl": "https://link-den-anh-bang-cap.com/certificate2.jpg",
        "Name": "Chứng chỉ Nail Art",
        "Institution": "Viện Đào tạo Nghệ thuật XYZ",
        "Description": "Đạt chứng nhận về nghệ thuật nail"
      }
    ];

    return jsonEncode(sampleCertificates);
  }

  // Show token error dialog
  void _showTokenErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi xác thực'),
        content: const Text(
            'Token đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Có thể chuyển về màn hình đăng nhập
              // Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
