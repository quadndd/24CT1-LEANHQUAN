<?php
header("Content-Type: application/json");
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $fullname = $_POST['fullname'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $password = $_POST['password'] ?? '';
    $role = $_POST['role'] ?? 'customer'; // customer or driver

    if (empty($fullname) || empty($phone) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Vui lòng điền đầy đủ thông tin"]);
        exit;
    }

    // Check if phone already exists
    $check_stmt = $conn->prepare("SELECT id FROM users WHERE phone = ?");
    $check_stmt->bind_param("s", $phone);
    $check_stmt->execute();
    $result = $check_stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Số điện thoại đã được đăng ký"]);
        exit;
    }

    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $conn->prepare("INSERT INTO users (fullname, phone, password, role) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $fullname, $phone, $hashed_password, $role);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Đăng ký thành công!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi: " . $stmt->error]);
    }
}
?>
