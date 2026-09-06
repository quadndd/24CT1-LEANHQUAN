<?php
header("Content-Type: application/json");
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $phone = $_POST['phone'] ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($phone) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Vui lòng nhập số điện thoại và mật khẩu"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT id, fullname, phone, password, role FROM users WHERE phone = ?");
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        if (password_verify($password, $user['password'])) {
            echo json_encode([
                "status" => "success", 
                "message" => "Đăng nhập thành công!",
                "data" => [
                    "id" => $user['id'],
                    "fullname" => $user['fullname'],
                    "phone" => $user['phone'],
                    "role" => $user['role']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Sai mật khẩu"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Số điện thoại không tồn tại"]);
    }
}
?>
