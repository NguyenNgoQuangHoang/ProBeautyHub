import 'dart:convert';
import 'package:booking_app/services/promotion_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePromotionScreen extends StatefulWidget {
  const CreatePromotionScreen({super.key});

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxUsageController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final PromotionApiService _promotionApiService = PromotionApiService();

  bool _isLoading = false;
  List<dynamic> _services = [];
  String? _selectedServiceId;
  String? _selectedServiceName;
  int _discountType = 0; // 0: percentage, 1: amount
  final int _voucherType = 1;
  final int _discountStype = 1;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final result = await _promotionApiService.getServices();
    if (result['success'] && result['data'] != null) {
      final data = result['data'];
      if (data is Map<String, dynamic> && data.containsKey('serviceDTOs')) {
        setState(() {
          _services = data['serviceDTOs'] ?? [];
        });
      } else if (data is Map<String, dynamic> && data.containsKey('services')) {
        setState(() {
          _services = data['services'] ?? [];
        });
      } else if (data is List) {
        setState(() {
          _services = data;
        });
      }
    }
  }

  Future<void> _createVoucher() async {
    // Validate form
    if (_codeController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng nhập mã voucher');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng nhập mô tả');
      return;
    }

    if (_discountController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng nhập giá trị giảm giá');
      return;
    }

    if (_startDateController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng chọn ngày bắt đầu');
      return;
    }

    if (_endDateController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng chọn ngày kết thúc');
      return;
    }

    if (_selectedServiceId == null) {
      _showErrorDialog('Vui lòng chọn dịch vụ áp dụng');
      return;
    }

    final discountValue = int.tryParse(_discountController.text.trim());
    if (discountValue == null || discountValue <= 0) {
      _showErrorDialog('Giá trị giảm giá phải lớn hơn 0');
      return;
    }

    // Validate discount value based on type
    if (_discountType == 0 && discountValue > 100) {
      _showErrorDialog('Phần trăm giảm giá không được vượt quá 100%');
      return;
    }

    final minAmount = int.tryParse(_minAmountController.text.trim()) ?? 0;
    final maxUsage = int.tryParse(_maxUsageController.text.trim()) ?? 100;
    final minQuantity = int.tryParse(_minQuantityController.text.trim()) ?? 1;

    try {
      setState(() {
        _isLoading = true;
      });

      final startDate = _dateFormat.parse(_startDateController.text);
      final endDate = _dateFormat.parse(_endDateController.text);

      if (endDate.isBefore(startDate)) {
        _showErrorDialog('Ngày kết thúc phải sau ngày bắt đầu');
        return;
      }

      final creatorId = await _getCreatorId();

      final result = await _promotionApiService.createVoucher(
        serviceOptionId: _selectedServiceId!,
        voucherType: _voucherType,
        currentUsage: 0,
        endDate: endDate,
        minTotalAmount: minAmount,
        discountStype: _discountStype,
        code: _codeController.text.trim(),
        discountValue: discountValue,
        startDate: startDate,
        creatorId: creatorId,
        discountType: _discountType,
        description: _descriptionController.text.trim(),
        minQuantity: minQuantity,
        maxUsage: maxUsage,
      );

      if (result['success']) {
        _showSuccessDialog('Tạo voucher thành công!');
      } else {
        _showErrorDialog(result['message'] ?? 'Có lỗi xảy ra khi tạo voucher');
      }
    } catch (e) {
      _showErrorDialog('Có lỗi xảy ra: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(
                  context, true); // Return to previous screen with result
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectService() async {
    if (_services.isEmpty) {
      _showErrorDialog('Không có dịch vụ nào để chọn');
      return;
    }

    final selected = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn dịch vụ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _services.map((service) {
              final id = service['id']?.toString() ?? '';
              final name = service['name']?.toString() ??
                  service['serviceName']?.toString() ??
                  'Dịch vụ không có tên';

              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.pop(context, {'id': id, 'name': name});
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedServiceId = selected['id'];
        _selectedServiceName = selected['name'];
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _dateFormat.format(picked);
    }
  }

  Future<String> _getCreatorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        // Decode JWT token to get creator ID
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Add padding if needed
          String normalizedPayload = payload;
          switch (payload.length % 4) {
            case 2:
              normalizedPayload += '==';
              break;
            case 3:
              normalizedPayload += '=';
              break;
          }

          final decoded = utf8.decode(base64Url.decode(normalizedPayload));
          final Map<String, dynamic> payloadMap = json.decode(decoded);

          // Try different possible fields for user ID
          return payloadMap['sub']?.toString() ??
              payloadMap['nameid']?.toString() ??
              payloadMap[
                      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
                  ?.toString() ??
              'unknown';
        }
      }
      return 'unknown';
    } catch (e) {
      print('Error getting creator ID: $e');
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Tạo voucher mới',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField('Mã voucher', _codeController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildInputField('Mô tả', _descriptionController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildDiscountTypeSelector(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildInputField(
                _discountType == 0 ? 'Giảm giá (%)' : 'Giảm giá (VNĐ)',
                _discountController,
                isNumber: true,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildInputField('Số tiền tối thiểu (VNĐ)', _minAmountController,
                  isNumber: true),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildInputField('Số lượng tối thiểu', _minQuantityController,
                  isNumber: true),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildInputField('Số lần sử dụng tối đa', _maxUsageController,
                  isNumber: true),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildDateField('Thời gian bắt đầu', _startDateController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildDateField('Thời gian kết thúc', _endDateController),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildServiceSelector(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createVoucher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    minimumSize: Size(236, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Tạo voucher',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "JacquesFrancois",
                              fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F2F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
              fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F2F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
              fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13),
          border: InputBorder.none,
          suffixIcon:
              Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildServiceSelector(BuildContext context) {
    return GestureDetector(
      onTap: _selectService,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F2F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedServiceName ?? 'Dịch vụ áp dụng',
                style: TextStyle(
                    fontFamily: "JacquesFrancois",
                    color: _selectedServiceName != null
                        ? Colors.black
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F2F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loại giảm giá',
            style: TextStyle(
              fontFamily: "JacquesFrancois",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Phần trăm (%)',
                      style: TextStyle(fontSize: 12)),
                  value: 0,
                  groupValue: _discountType,
                  onChanged: (value) {
                    setState(() {
                      _discountType = value!;
                      _discountController.clear();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Số tiền (VNĐ)',
                      style: TextStyle(fontSize: 12)),
                  value: 1,
                  groupValue: _discountType,
                  onChanged: (value) {
                    setState(() {
                      _discountType = value!;
                      _discountController.clear();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
