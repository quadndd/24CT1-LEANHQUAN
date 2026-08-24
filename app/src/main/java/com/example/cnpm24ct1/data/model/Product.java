package com.example.cnpm24ct1.data.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Product implements Serializable {
    private String id;
    private String name;
    private String description;
    private String category;
    private double price;
    private int stock;
    private int imageResId;
    private List<String> mediaUris;
    private int coverImageIndex;
    private String videoUri;
    private List<ProductVariation> variations;
    private int weightGram;
    private String dimensions;
    private String shopName;
    private boolean isDraft;

    public Product() {
        this.mediaUris = new ArrayList<>();
        this.variations = new ArrayList<>();
        this.coverImageIndex = 0;
        this.shopName = "CNPM 24CT1 Official Store";
    }

    public Product(String id, String name, String description, String category, double price, int stock, int imageResId, String shopName) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.stock = stock;
        this.imageResId = imageResId;
        this.shopName = shopName != null ? shopName : "CNPM 24CT1 Official Store";
        this.mediaUris = new ArrayList<>();
        this.variations = new ArrayList<>();
        this.coverImageIndex = 0;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
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

    public int getImageResId() {
        return imageResId;
    }

    public void setImageResId(int imageResId) {
        this.imageResId = imageResId;
    }

    public List<String> getMediaUris() {
        return mediaUris;
    }

    public void setMediaUris(List<String> mediaUris) {
        this.mediaUris = mediaUris;
    }

    public int getCoverImageIndex() {
        return coverImageIndex;
    }

    public void setCoverImageIndex(int coverImageIndex) {
        this.coverImageIndex = coverImageIndex;
    }

    public String getVideoUri() {
        return videoUri;
    }

    public void setVideoUri(String videoUri) {
        this.videoUri = videoUri;
    }

    public List<ProductVariation> getVariations() {
        return variations;
    }

    public void setVariations(List<ProductVariation> variations) {
        this.variations = variations;
    }

    public int getWeightGram() {
        return weightGram;
    }

    public void setWeightGram(int weightGram) {
        this.weightGram = weightGram;
    }

    public String getDimensions() {
        return dimensions;
    }

    public void setDimensions(String dimensions) {
        this.dimensions = dimensions;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public boolean isDraft() {
        return isDraft;
    }

    public void setDraft(boolean draft) {
        isDraft = draft;
    }
}
