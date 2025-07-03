# Ví dụ minh họa Logic 2FA mới

## Kịch bản 1: User lần đầu đăng nhập với 2FA

```json
// Response từ API login:
{
  "token": null,
  "requiresTwoFactor": true,
  "name": "John Doe",
  "email": "john@example.com",
  "isSuccess": true
}
```

**→ Kết quả:** Chuyển sang màn hình nhập mã 2FA

---

## Kịch bản 2: User đã từng xác thực 2FA thành công

```json
// Response từ API login:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "requiresTwoFactor": true,
  "name": "John Doe",
  "email": "john@example.com",
  "isSuccess": true
}
```

**→ Kết quả:** Đăng nhập thành công luôn, vào app

---

## Kịch bản 3: User không có 2FA

```json
// Response từ API login:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "requiresTwoFactor": false,
  "name": "Jane Doe",
  "email": "jane@example.com",
  "isSuccess": true
}
```

**→ Kết quả:** Đăng nhập thành công luôn, vào app

---

## Lợi ích của logic mới:

✅ **User experience tốt hơn:** User không phải nhập mã 2FA mỗi lần đăng nhập

✅ **Bảo mật vẫn đảm bảo:** Token chỉ được cấp sau khi xác thực 2FA thành công

✅ **Linh hoạt:** Hệ thống có thể thu hồi token để bắt user xác thực lại nếu cần

---

## Code logic:

```dart
// Trong LoginScreen._login()
if (user.requiresTwoFactor && (user.token == null || user.token!.isEmpty)) {
  // Case 1: Cần 2FA và chưa có token → nhập mã
  Navigator.push(context, TwoFactorScreen(email: email));
} else {
  // Case 2 & 3: Đã có token hoặc không cần 2FA → vào app
  await UserStorage.saveUser(user);
  showSuccessDialog(); // Chuyển vào MainLayout
}
```
