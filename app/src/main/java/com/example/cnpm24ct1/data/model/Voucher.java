package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class Voucher implements Serializable {
    private String code;
    private String title;
    private double discountAmount;
    private double discountPercent; // e.g. 0.10 for 10%
    private double minSpend;

    public Voucher() {
    }

    public Voucher(String code, String title, double discountAmount, double discountPercent, double minSpend) {
        this.code = code;
        this.title = title;
        this.discountAmount = discountAmount;
        this.discountPercent = discountPercent;
        this.minSpend = minSpend;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public double getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(double discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getMinSpend() {
        return minSpend;
    }

    public void setMinSpend(double minSpend) {
        this.minSpend = minSpend;
    }

    public double calculateDiscount(double subtotal) {
        if (subtotal < minSpend) {
            return 0.0;
        }
        if (discountAmount > 0) {
            return discountAmount;
        }
        if (discountPercent > 0) {
            return subtotal * discountPercent;
        }
        return 0.0;
    }
}
