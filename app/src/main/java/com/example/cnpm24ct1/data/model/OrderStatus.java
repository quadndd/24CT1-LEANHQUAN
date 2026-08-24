package com.example.cnpm24ct1.data.model;

public enum OrderStatus {
    TAT_CA("Tất cả"),
    CHO_THANH_TOAN("Chờ thanh toán"),
    CHO_XAC_NHAN("Chờ xác nhận"),
    DANG_CHUAN_BI("Đang chuẩn bị"),
    DANG_GIAO("Đang giao"),
    DA_GIAO("Đã giao"),
    DA_HUY("Đã hủy"),
    HOAN_TIEN("Trả hàng/Hoàn tiền");

    private final String displayName;

    OrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
