package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class Address implements Serializable {
    private String id;
    private String recipientName;
    private String phoneNumber;
    private String detailAddress;
    private boolean isDefault;

    public Address() {
    }

    public Address(String id, String recipientName, String phoneNumber, String detailAddress, boolean isDefault) {
        this.id = id;
        this.recipientName = recipientName;
        this.phoneNumber = phoneNumber;
        this.detailAddress = detailAddress;
        this.isDefault = isDefault;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getDetailAddress() {
        return detailAddress;
    }

    public void setDetailAddress(String detailAddress) {
        this.detailAddress = detailAddress;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean aDefault) {
        isDefault = aDefault;
    }

    public String getFormattedAddress() {
        return recipientName + " | " + phoneNumber + "\n" + detailAddress;
    }
}
