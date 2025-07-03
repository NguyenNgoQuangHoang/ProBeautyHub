# Tích hợp Two-Factor Authentication (2FA)

## Luồng đăng nhập mới với 2FA

### 1. **API Login** (`/user-account/login`)

- Người dùng nhập email/password
- API trả về response với `requiresTwoFactor: true/false`
- Nếu `requiresTwoFactor = false`: Đăng nhập thành công, chuyển vào app
- Nếu `requiresTwoFactor = true`: Chuyển sang màn hình nhập mã 2FA

### 2. **Màn hình Two-Factor (login_twoface.dart)**

- Hiển thị email đã đăng nhập (readonly)
- Thông báo mã đã được gửi tới email
- Input field để nhập mã 6 số
- Nút "VERIFY" để xác thực mã

### 3. **API Verify 2FA** (`/user-account/verify-twofactor-code`)

- Gửi email và mã xác thực
- API trả về token thực sự nếu mã đúng
- Lưu thông tin user (có token) vào local storage
- Chuyển vào app

## Các file đã được cập nhật:

### 📁 `lib/services/api_service.dart`

```dart
Future<Map<String, dynamic>> verifyTwoFactorCode({
  required String email,
  required String twoFactorCode,
}) async {
  // Gọi API verify-twofactor-code
  // Trả về UserModel với token
}
```

### 📁 `lib/screens/auth/login_screen.dart`

```dart
if (result['success']) {
  UserModel user = result['data'];

  if (user.requiresTwoFactor) {
    // Chuyển sang màn hình 2FA
    Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        TwoFactorScreen(email: email)));
  } else {
    // Đăng nhập thành công, vào app
    await UserStorage.saveUser(user);
    // ... chuyển vào MainLayout
  }
}
```

### 📁 `lib/screens/auth/login_twoface.dart`

- Nhận email parameter từ LoginScreen
- Hiển thị email readonly
- Input cho mã 6 số
- Gọi API verifyTwoFactorCode khi verify
- Xử lý thành công/thất bại với popup

## ⚠️ **Logic mới - Kiểm tra token đã tồn tại:**

### Điều kiện yêu cầu 2FA:

```dart
if (user.requiresTwoFactor && (user.token == null || user.token!.isEmpty)) {
  // Chỉ yêu cầu 2FA nếu chưa có token
  Navigator.push(context, TwoFactorScreen(email: email));
} else {
  // Đăng nhập thành công luôn nếu:
  // 1. Không cần 2FA (requiresTwoFactor = false)
  // 2. Hoặc đã có token từ lần xác thực trước
  await UserStorage.saveUser(user);
  // Chuyển vào app
}
```

### Các trường hợp:

1. **User lần đầu có 2FA**: `requiresTwoFactor = true, token = null` → **Cần nhập mã**
2. **User đã xác thực 2FA trước đó**: `requiresTwoFactor = true, token = "abc123"` → **Vào app luôn**
3. **User không có 2FA**: `requiresTwoFactor = false` → **Vào app luôn**

---

## Cách test:

1. **Đăng nhập với tài khoản có 2FA enabled**

   - Nhập email/password
   - Nếu server trả về `requiresTwoFactor: true`
   - Sẽ chuyển sang màn hình nhập mã

2. **Nhập mã 2FA**

   - Email sẽ hiển thị readonly
   - Nhập mã 6 số nhận được từ email
   - Nhấn VERIFY

3. **Kết quả**
   - Nếu mã đúng: Nhận token, lưu user, vào app
   - Nếu mã sai: Hiển thị lỗi, cho phép thử lại

## Lưu ý:

- Token chỉ được trả về sau khi verify 2FA thành công
- User data được lưu vào local storage chỉ khi có token
- Màn hình 2FA có nút "Gửi lại mã" (chưa implement API)
- Validation: Mã phải đúng 6 số

## API Endpoints sử dụng:

1. `POST /user-account/login` - Đăng nhập ban đầu
2. `POST /user-account/verify-twofactor-code` - Xác thực mã 2FA
