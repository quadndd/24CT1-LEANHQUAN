package com.example.cnpm24ct1.data.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Order implements Serializable {
    private String id;
    private String shopName;
    private List<CartItem> items;
    private Address address;
    private ShippingUnit shippingUnit;
    private String paymentMethod;
    private Voucher voucher;
    private double subtotal;
    private double shippingFee;
    private double discount;
    private double totalAmount;
    private OrderStatus status;
    private String orderDate;
    private String cancelReason;
    private boolean isPrepaid;
    private List<TimelineNode> deliveryTimeline;
    private List<TimelineNode> refundTimeline;
    private String shipperName;
    private String shipperPhone;

    public Order() {
        this.items = new ArrayList<>();
        this.deliveryTimeline = new ArrayList<>();
        this.refundTimeline = new ArrayList<>();
    }

    public Order(String id, String shopName, List<CartItem> items, Address address,
                 ShippingUnit shippingUnit, String paymentMethod, Voucher voucher,
                 double subtotal, double shippingFee, double discount, double totalAmount,
                 OrderStatus status, String orderDate, boolean isPrepaid) {
        this.id = id;
        this.shopName = shopName != null ? shopName : "CNPM 24CT1 Official Store";
        this.items = items != null ? items : new ArrayList<>();
        this.address = address;
        this.shippingUnit = shippingUnit;
        this.paymentMethod = paymentMethod;
        this.voucher = voucher;
        this.subtotal = subtotal;
        this.shippingFee = shippingFee;
        this.discount = discount;
        this.totalAmount = totalAmount;
        this.status = status;
        this.orderDate = orderDate;
        this.isPrepaid = isPrepaid;
        this.deliveryTimeline = new ArrayList<>();
        this.refundTimeline = new ArrayList<>();
        this.shipperName = "Nguyễn Văn Giao (Shopee Express)";
        this.shipperPhone = "0987654321";
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public Address getAddress() {
        return address;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    public ShippingUnit getShippingUnit() {
        return shippingUnit;
    }

    public void setShippingUnit(ShippingUnit shippingUnit) {
        this.shippingUnit = shippingUnit;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Voucher getVoucher() {
        return voucher;
    }

    public void setVoucher(Voucher voucher) {
        this.voucher = voucher;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public double getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(double shippingFee) {
        this.shippingFee = shippingFee;
    }

    public double getDiscount() {
        return discount;
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

    public String getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(String orderDate) {
        this.orderDate = orderDate;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public boolean isPrepaid() {
        return isPrepaid;
    }

    public void setPrepaid(boolean prepaid) {
        isPrepaid = prepaid;
    }

    public List<TimelineNode> getDeliveryTimeline() {
        return deliveryTimeline;
    }

    public void setDeliveryTimeline(List<TimelineNode> deliveryTimeline) {
        this.deliveryTimeline = deliveryTimeline;
    }

    public List<TimelineNode> getRefundTimeline() {
        return refundTimeline;
    }

    public void setRefundTimeline(List<TimelineNode> refundTimeline) {
        this.refundTimeline = refundTimeline;
    }

    public String getShipperName() {
        return shipperName;
    }

    public void setShipperName(String shipperName) {
        this.shipperName = shipperName;
    }

    public String getShipperPhone() {
        return shipperPhone;
    }

    public void setShipperPhone(String shipperPhone) {
        this.shipperPhone = shipperPhone;
    }

    public int getTotalProductCount() {
        int count = 0;
        if (items != null) {
            for (CartItem item : items) {
                count += item.getQuantity();
            }
        }
        return count;
    }
}
