package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class ProductVariation implements Serializable {
    private String id;
    private String name; // e.g. "Đỏ, M" or "Đen, XL"
    private double price;
    private int stock;
    private String sku;

    public ProductVariation() {
    }

    public ProductVariation(String id, String name, double price, int stock, String sku) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.stock = stock;
        this.sku = sku;
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

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }
}
