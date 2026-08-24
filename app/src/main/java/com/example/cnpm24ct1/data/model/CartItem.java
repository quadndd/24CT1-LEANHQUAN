package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class CartItem implements Serializable {
    private String id;
    private Product product;
    private ProductVariation variation;
    private int quantity;
    private boolean isSelected;

    public CartItem() {
        this.quantity = 1;
        this.isSelected = true;
    }

    public CartItem(String id, Product product, ProductVariation variation, int quantity) {
        this.id = id;
        this.product = product;
        this.variation = variation;
        this.quantity = quantity;
        this.isSelected = true;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public ProductVariation getVariation() {
        return variation;
    }

    public void setVariation(ProductVariation variation) {
        this.variation = variation;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public double getItemUnitPrice() {
        if (variation != null && variation.getPrice() > 0) {
            return variation.getPrice();
        }
        return product != null ? product.getPrice() : 0.0;
    }

    public double getTotalPrice() {
        return getItemUnitPrice() * quantity;
    }

    public int getMaxStock() {
        if (variation != null && variation.getStock() > 0) {
            return variation.getStock();
        }
        return product != null ? product.getStock() : 99;
    }

    public String getVariationDisplay() {
        if (variation != null && variation.getName() != null && !variation.getName().isEmpty()) {
            return "Phân loại: " + variation.getName();
        }
        return "Phân loại: Mặc định";
    }
}
