package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class ShippingUnit implements Serializable {
    private String id;
    private String name;
    private double fee;
    private String estimatedTime;

    public ShippingUnit() {
    }

    public ShippingUnit(String id, String name, double fee, String estimatedTime) {
        this.id = id;
        this.name = name;
        this.fee = fee;
        this.estimatedTime = estimatedTime;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getFee() {
        return fee;
    }

    public void setFee(double fee) {
        this.fee = fee;
    }

    public String getEstimatedTime() {
        return estimatedTime;
    }

    public void setEstimatedTime(String estimatedTime) {
        this.estimatedTime = estimatedTime;
    }
}
