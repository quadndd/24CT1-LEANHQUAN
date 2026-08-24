package com.example.cnpm24ct1.data.repository;

import android.content.Context;
import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.Address;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.data.model.Order;
import com.example.cnpm24ct1.data.model.OrderStatus;
import com.example.cnpm24ct1.data.model.Product;
import com.example.cnpm24ct1.data.model.ProductVariation;
import com.example.cnpm24ct1.data.model.ShippingUnit;
import com.example.cnpm24ct1.data.model.TimelineNode;
import com.example.cnpm24ct1.data.model.Voucher;
import com.example.cnpm24ct1.utils.FormatUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

public class DataRepository {

    private static DataRepository instance;
    private final List<Product> products = new ArrayList<>();
    private final List<CartItem> cartItems = new ArrayList<>();
    private final List<Order> orders = new ArrayList<>();
    private final List<Address> addresses = new ArrayList<>();
    private final List<ShippingUnit> shippingUnits = new ArrayList<>();
    private final List<Voucher> vouchers = new ArrayList<>();

    private DataRepository() {
        initMockData();
    }

    public static synchronized DataRepository getInstance() {
        if (instance == null) {
            instance = new DataRepository();
        }
        return instance;
    }

    private void initMockData() {
        // 1. Initial Sample Products
        Product p1 = new Product("P101", "Áo Polo Nam Thể Thao Cao Cấp 24CT1", 
                "Chất liệu thun cá sấu cao cấp, co giãn 4 chiều, thấm hút mồ hôi cực tốt. Thiết kế trẻ trung, form chuẩn phong cách học phần CNPM.", 
                "Thời trang nam", 189000, 45, R.drawable.ic_box, "24CT1 Fashion Official");
        p1.setWeightGram(250);
        p1.setDimensions("25x20x3");
        p1.getVariations().add(new ProductVariation("V101_1", "Đen - Size M", 189000, 15, "AP-DEN-M"));
        p1.getVariations().add(new ProductVariation("V101_2", "Đen - Size L", 189000, 20, "AP-DEN-L"));
        p1.getVariations().add(new ProductVariation("V101_3", "Trắng - Size M", 189000, 10, "AP-TRA-M"));
        products.add(p1);

        Product p2 = new Product("P102", "Giày Sneaker Nam Nữ Thể Thao Streetwear", 
                "Đế đệm cao su êm ái, trợ lực di chuyển, chất liệu vải dệt thoáng khí không hôi chân.", 
                "Giày dép", 350000, 30, R.drawable.ic_box, "SportZone VietNam");
        p2.setWeightGram(800);
        p2.setDimensions("32x22x12");
        p2.getVariations().add(new ProductVariation("V102_1", "Trắng Xám - Size 40", 350000, 8, "SNK-40"));
        p2.getVariations().add(new ProductVariation("V102_2", "Trắng Xám - Size 41", 350000, 12, "SNK-41"));
        p2.getVariations().add(new ProductVariation("V102_3", "Đen Cam - Size 42", 350000, 10, "SNK-42"));
        products.add(p2);

        Product p3 = new Product("P103", "Tai Nghe Bluetooth True Wireless TWS-24", 
                "Chống ồn chủ động ANC, pin trâu 28 giờ liên tục, Bluetooth 5.3 kết nối siêu tốc không độ trễ.", 
                "Thiết bị điện tử", 299000, 25, R.drawable.ic_box, "TechPro Digital");
        p3.setWeightGram(120);
        p3.setDimensions("10x10x5");
        p3.getVariations().add(new ProductVariation("V103_1", "Màu Đen Nhám", 299000, 15, "TWS-BLACK"));
        p3.getVariations().add(new ProductVariation("V103_2", "Màu Trắng Ngọc", 299000, 10, "TWS-WHITE"));
        products.add(p3);

        Product p4 = new Product("P104", "Bàn Phím Cơ Không Dây 3 Chế Độ RGB", 
                "Gasket mount cao cấp, hotswap 5 pin, switch gõ siêu êm, keycap PBT Doubleshot bền màu.", 
                "Phụ kiện máy tính", 650000, 15, R.drawable.ic_box, "TechPro Digital");
        p4.setWeightGram(950);
        p4.setDimensions("35x15x6");
        p4.getVariations().add(new ProductVariation("V104_1", "Linear Switch - Xanh Pastel", 650000, 8, "KB-LIN-BLUE"));
        p4.getVariations().add(new ProductVariation("V104_2", "Tactile Switch - Tím Khói", 650000, 7, "KB-TAC-PUR"));
        products.add(p4);

        // 2. Initial Sample Cart Items
        cartItems.add(new CartItem("C101", p1, p1.getVariations().get(0), 1));
        cartItems.add(new CartItem("C102", p3, p3.getVariations().get(0), 2));

        // 3. Initial Sample Addresses
        Address defAddr = new Address("A1", "Lê Anh Quân (24CT1)", "0905123456", 
                "Ký túc xá Đại học / 254 Nguyễn Văn Linh, P. Thạc Gián, Q. Thanh Khê, TP. Đà Nẵng", true);
        addresses.add(defAddr);
        addresses.add(new Address("A2", "Nguyễn Thị Mai", "0912345678", 
                "Số 120 Hoàng Diệu, P. Hải Châu 2, Q. Hải Châu, TP. Đà Nẵng", false));

        // 4. Initial Shipping Units
        shippingUnits.add(new ShippingUnit("S1", "Shopee Xpress Nhanh", 16500, "Nhận hàng trong 1-2 ngày"));
        shippingUnits.add(new ShippingUnit("S2", "Giao Hàng Nhanh (GHN)", 22000, "Giao trước 18h ngày mai"));
        shippingUnits.add(new ShippingUnit("S3", "Viettel Post Đồng Giá", 25000, "Nhận hàng trong 2-3 ngày"));
        shippingUnits.add(new ShippingUnit("S4", "J&T Express Tiết Kiệm", 18000, "Nhận hàng trong 2-3 ngày"));

        // 5. Initial Vouchers
        vouchers.add(new Voucher("FREESHIP", "Miễn phí vận chuyển", 25000, 0, 100000));
        vouchers.add(new Voucher("CNPM24CT1", "Giảm 10% cho sinh viên 24CT1", 0, 0.10, 150000));
        vouchers.add(new Voucher("GIAM30K", "Giảm ngay 30.000₫", 30000, 0, 200000));

        // 6. Initial Sample Orders (demonstrating all statuses)
        createSampleOrders(defAddr, p1, p2, p3, p4);
    }

    private void createSampleOrders(Address addr, Product p1, Product p2, Product p3, Product p4) {
        // Sample Order 1: Đang giao (Shipping)
        Order ord1 = new Order("DH24CT1001", "24CT1 Fashion Official",
                Arrays.asList(new CartItem("SC1", p1, p1.getVariations().get(0), 1)),
                addr, shippingUnits.get(0), "COD", vouchers.get(0),
                189000, 16500, 16500, 189000,
                OrderStatus.DANG_GIAO, FormatUtils.getTimeAgoString(14, 30), false);
        
        ord1.getDeliveryTimeline().add(new TimelineNode("Đã đặt đơn", "Đơn hàng #DH24CT1001 đã được đặt thành công", FormatUtils.getTimeAgoString(14, 30), true, false));
        ord1.getDeliveryTimeline().add(new TimelineNode("Đã đóng gói", "Người bán đang chuẩn bị kiện hàng cẩn thận", FormatUtils.getTimeAgoString(10, 15), true, false));
        ord1.getDeliveryTimeline().add(new TimelineNode("Đã giao cho ĐVVC", "Shopee Xpress đã tiếp nhận kiện hàng", FormatUtils.getTimeAgoString(6, 45), true, false));
        ord1.getDeliveryTimeline().add(new TimelineNode("Đang luân chuyển", "Kiện hàng đã đến Kho trung chuyển Đà Nẵng SOC", FormatUtils.getTimeAgoString(3, 20), true, false));
        ord1.getDeliveryTimeline().add(new TimelineNode("Đang giao đến bạn", "Shipper Nguyễn Văn Giao đang trên đường phát hàng", FormatUtils.getTimeAgoString(0, 45), false, true));
        ord1.getDeliveryTimeline().add(new TimelineNode("Giao thành công", "Khách hàng đã kiểm tra và nhận hàng", "Dự kiến hôm nay", false, false));
        orders.add(ord1);

        // Sample Order 2: Chờ xác nhận (Pending Confirmation - can be cancelled!)
        Order ord2 = new Order("DH24CT1002", "TechPro Digital",
                Arrays.asList(new CartItem("SC2", p3, p3.getVariations().get(0), 1)),
                addr, shippingUnits.get(1), "Ví MoMo", vouchers.get(1),
                299000, 22000, 29900, 291100,
                OrderStatus.CHO_XAC_NHAN, FormatUtils.getTimeAgoString(1, 10), true);
        
        ord2.getDeliveryTimeline().add(new TimelineNode("Đã đặt đơn", "Đơn hàng đã thanh toán qua Ví MoMo", FormatUtils.getTimeAgoString(1, 10), false, true));
        ord2.getDeliveryTimeline().add(new TimelineNode("Đã đóng gói", "Người bán đang chuẩn bị kiện hàng", "Chờ người bán", false, false));
        ord2.getDeliveryTimeline().add(new TimelineNode("Đã giao cho ĐVVC", "Chờ ĐVVC lấy hàng", "Chờ xử lý", false, false));
        orders.add(ord2);

        // Sample Order 3: Đã giao (Delivered)
        Order ord3 = new Order("DH24CT1003", "SportZone VietNam",
                Arrays.asList(new CartItem("SC3", p2, p2.getVariations().get(1), 1)),
                addr, shippingUnits.get(0), "Thẻ tín dụng / Visa", null,
                350000, 16500, 0, 366500,
                OrderStatus.DA_GIAO, FormatUtils.getTimeAgoString(48, 0), true);
        
        ord3.getDeliveryTimeline().add(new TimelineNode("Đã đặt đơn", "Đơn hàng đặt thành công", FormatUtils.getTimeAgoString(48, 0), true, false));
        ord3.getDeliveryTimeline().add(new TimelineNode("Đã đóng gói", "Người bán đóng gói kiện hàng", FormatUtils.getTimeAgoString(42, 0), true, false));
        ord3.getDeliveryTimeline().add(new TimelineNode("Đã giao cho ĐVVC", "ĐVVC tiếp nhận hàng", FormatUtils.getTimeAgoString(36, 0), true, false));
        ord3.getDeliveryTimeline().add(new TimelineNode("Đang luân chuyển", "Hàng qua kho phân loại", FormatUtils.getTimeAgoString(24, 0), true, false));
        ord3.getDeliveryTimeline().add(new TimelineNode("Đang giao đến bạn", "Shipper đi phát", FormatUtils.getTimeAgoString(18, 0), true, false));
        ord3.getDeliveryTimeline().add(new TimelineNode("Giao thành công", "Người nhận đã ký nhận kiện hàng", FormatUtils.getTimeAgoString(16, 30), true, true));
        orders.add(ord3);

        // Sample Order 4: Hoàn tiền (Refund)
        Order ord4 = new Order("DH24CT1004", "TechPro Digital",
                Arrays.asList(new CartItem("SC4", p4, p4.getVariations().get(0), 1)),
                addr, shippingUnits.get(0), "Chuyển khoản ngân hàng", null,
                650000, 16500, 0, 666500,
                OrderStatus.HOAN_TIEN, FormatUtils.getTimeAgoString(20, 0), true);
        ord4.setCancelReason("Đổi ý không muốn mua nữa");
        ord4.getRefundTimeline().add(new TimelineNode("Yêu cầu hoàn tiền", "Khách hàng gửi yêu cầu hoàn tiền lý do: Đổi ý không muốn mua nữa", FormatUtils.getTimeAgoString(18, 0), true, false));
        ord4.getRefundTimeline().add(new TimelineNode("Hệ thống xử lý", "Kế toán đang tiến hành đối soát và hoàn khoản thanh toán", FormatUtils.getTimeAgoString(12, 0), false, true));
        ord4.getRefundTimeline().add(new TimelineNode("Đã hoàn tiền", "Tiền sẽ hoàn về tài khoản ngân hàng trong 1-3 ngày làm việc", "Dự kiến 1-3 ngày", false, false));
        orders.add(ord4);
    }

    // Product methods
    public List<Product> getProducts() {
        return products;
    }

    public void addProduct(Product product) {
        if (product.getId() == null || product.getId().isEmpty()) {
            product.setId("P" + (System.currentTimeMillis() % 10000));
        }
        products.add(0, product);
    }

    public Product findProductById(String id) {
        for (Product p : products) {
            if (p.getId().equals(id)) return p;
        }
        return null;
    }

    // Cart methods
    public List<CartItem> getCartItems() {
        return cartItems;
    }

    public void addToCart(Product product, ProductVariation variation, int quantity) {
        for (CartItem item : cartItems) {
            boolean sameProduct = item.getProduct().getId().equals(product.getId());
            boolean sameVariation = (item.getVariation() == null && variation == null) ||
                    (item.getVariation() != null && variation != null && item.getVariation().getId().equals(variation.getId()));
            if (sameProduct && sameVariation) {
                int newQty = item.getQuantity() + quantity;
                int maxStock = item.getMaxStock();
                item.setQuantity(Math.min(newQty, maxStock));
                return;
            }
        }
        String id = "CART_" + UUID.randomUUID().toString().substring(0, 8);
        cartItems.add(0, new CartItem(id, product, variation, quantity));
    }

    public void removeFromCart(String cartItemId) {
        for (int i = 0; i < cartItems.size(); i++) {
            if (cartItems.get(i).getId().equals(cartItemId)) {
                cartItems.remove(i);
                break;
            }
        }
    }

    public void updateCartItemQuantity(String cartItemId, int newQty) {
        for (CartItem item : cartItems) {
            if (item.getId().equals(cartItemId)) {
                item.setQuantity(newQty);
                break;
            }
        }
    }

    public void setCartItemSelected(String cartItemId, boolean isSelected) {
        for (CartItem item : cartItems) {
            if (item.getId().equals(cartItemId)) {
                item.setSelected(isSelected);
                break;
            }
        }
    }

    public void setSelectAll(boolean isSelected) {
        for (CartItem item : cartItems) {
            item.setSelected(isSelected);
        }
    }

    public boolean isAllSelected() {
        if (cartItems.isEmpty()) return false;
        for (CartItem item : cartItems) {
            if (!item.isSelected()) return false;
        }
        return true;
    }

    public List<CartItem> getSelectedCartItems() {
        List<CartItem> selected = new ArrayList<>();
        for (CartItem item : cartItems) {
            if (item.isSelected()) {
                selected.add(item);
            }
        }
        return selected;
    }

    public double calculateSelectedSubtotal() {
        double total = 0;
        for (CartItem item : cartItems) {
            if (item.isSelected()) {
                total += item.getTotalPrice();
            }
        }
        return total;
    }

    public void removeSelectedCartItems() {
        List<CartItem> toRemove = new ArrayList<>();
        for (CartItem item : cartItems) {
            if (item.isSelected()) {
                toRemove.add(item);
            }
        }
        cartItems.removeAll(toRemove);
    }

    // Order methods
    public List<Order> getOrders() {
        return orders;
    }

    public List<Order> getOrdersByStatus(OrderStatus status) {
        if (status == OrderStatus.TAT_CA) {
            return orders;
        }
        List<Order> filtered = new ArrayList<>();
        for (Order o : orders) {
            if (o.getStatus() == status) {
                filtered.add(o);
            }
        }
        return filtered;
    }

    public Order findOrderById(String orderId) {
        for (Order o : orders) {
            if (o.getId().equals(orderId)) return o;
        }
        return null;
    }

    public Order createOrder(List<CartItem> selectedItems, Address address,
                             ShippingUnit shippingUnit, String paymentMethod, Voucher voucher) {
        String orderId = "DH24CT1" + String.format("%03d", (orders.size() + 1));
        double subtotal = 0;
        for (CartItem item : selectedItems) {
            subtotal += item.getTotalPrice();
        }
        double shippingFee = shippingUnit != null ? shippingUnit.getFee() : 20000;
        double discount = voucher != null ? voucher.calculateDiscount(subtotal) : 0;
        double totalAmount = Math.max(0, subtotal + shippingFee - discount);

        boolean isPrepaid = !paymentMethod.equalsIgnoreCase("COD");
        OrderStatus initialStatus = isPrepaid ? OrderStatus.CHO_XAC_NHAN : OrderStatus.CHO_XAC_NHAN;

        String shopName = (selectedItems != null && !selectedItems.isEmpty() && selectedItems.get(0).getProduct() != null)
                ? selectedItems.get(0).getProduct().getShopName() : "24CT1 Official Store";

        Order newOrder = new Order(orderId, shopName, new ArrayList<>(selectedItems),
                address, shippingUnit, paymentMethod, voucher,
                subtotal, shippingFee, discount, totalAmount,
                initialStatus, FormatUtils.getCurrentDateTimeString(), isPrepaid);

        // Build default timeline
        newOrder.getDeliveryTimeline().add(new TimelineNode("Đã đặt đơn", "Đơn hàng #" + orderId + " đặt thành công", FormatUtils.getCurrentDateTimeString(), true, true));
        newOrder.getDeliveryTimeline().add(new TimelineNode("Đã đóng gói", "Người bán đang chuẩn bị kiện hàng", "Chờ xử lý", false, false));
        newOrder.getDeliveryTimeline().add(new TimelineNode("Đã giao cho ĐVVC", (shippingUnit != null ? shippingUnit.getName() : "ĐVVC") + " chờ lấy hàng", "Chờ xử lý", false, false));
        newOrder.getDeliveryTimeline().add(new TimelineNode("Đang luân chuyển", "Đang chuyển đến kho giao hàng", "Chờ xử lý", false, false));
        newOrder.getDeliveryTimeline().add(new TimelineNode("Đang giao đến bạn", "Shipper sẽ giao hàng sớm nhất", "Chờ xử lý", false, false));
        newOrder.getDeliveryTimeline().add(new TimelineNode("Giao thành công", "Kiểm tra và nhận hàng", "Chờ xử lý", false, false));

        orders.add(0, newOrder);
        removeSelectedCartItems();
        return newOrder;
    }

    public void cancelOrder(String orderId, String reason) {
        Order order = findOrderById(orderId);
        if (order != null) {
            order.setCancelReason(reason);
            if (order.isPrepaid()) {
                // If prepaid, move to Refund state
                order.setStatus(OrderStatus.HOAN_TIEN);
                order.getRefundTimeline().clear();
                order.getRefundTimeline().add(new TimelineNode("Yêu cầu hoàn tiền", "Đã tiếp nhận yêu cầu hủy & hoàn tiền: " + reason, FormatUtils.getCurrentDateTimeString(), true, false));
                order.getRefundTimeline().add(new TimelineNode("Hệ thống xử lý", "Kế toán đang tiến hành đối soát và hoàn tiền", FormatUtils.getCurrentDateTimeString(), false, true));
                order.getRefundTimeline().add(new TimelineNode("Đã hoàn tiền", "Tiền sẽ hoàn về tài khoản/ví trong 1-3 ngày làm việc", "Dự kiến 1-3 ngày", false, false));
            } else {
                // COD -> direct Cancelled
                order.setStatus(OrderStatus.DA_HUY);
            }
        }
    }

    public void updateOrderStatus(String orderId, OrderStatus newStatus) {
        Order order = findOrderById(orderId);
        if (order != null) {
            order.setStatus(newStatus);
        }
    }

    // Address methods
    public List<Address> getAddresses() {
        return addresses;
    }

    public Address getDefaultAddress() {
        for (Address a : addresses) {
            if (a.isDefault()) return a;
        }
        return !addresses.isEmpty() ? addresses.get(0) : null;
    }

    public void addAddress(Address address) {
        if (address.isDefault()) {
            for (Address a : addresses) a.setDefault(false);
        }
        addresses.add(0, address);
    }

    // Shipping units
    public List<ShippingUnit> getShippingUnits() {
        return shippingUnits;
    }

    // Vouchers
    public List<Voucher> getVouchers() {
        return vouchers;
    }

    public Voucher findVoucherByCode(String code) {
        if (code == null) return null;
        for (Voucher v : vouchers) {
            if (v.getCode().equalsIgnoreCase(code.trim())) return v;
        }
        return null;
    }
}
