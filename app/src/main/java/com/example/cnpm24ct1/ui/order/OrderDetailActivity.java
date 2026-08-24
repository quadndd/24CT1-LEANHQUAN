package com.example.cnpm24ct1.ui.order;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.data.model.Order;
import com.example.cnpm24ct1.data.model.OrderStatus;
import com.example.cnpm24ct1.data.model.TimelineNode;
import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.ui.checkout.CheckoutItemAdapter;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;
import com.google.android.material.appbar.MaterialToolbar;

import java.util.List;
import org.osmdroid.config.Configuration;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.Marker;
import android.os.Handler;

public class OrderDetailActivity extends AppCompatActivity {

    private MaterialToolbar toolbarDetail;
    private LinearLayout llStatusBanner;
    private TextView tvDetailStatusTitle;
    private TextView tvDetailOrderIdAndDate;

    // Refund Timeline
    private CardView cardRefundTimeline;
    private TextView tvRefundNote;
    private LinearLayout llRefundTimelineContainer;

    // Delivery Timeline
    private CardView cardDeliveryTimeline;
    private TextView tvCarrierName;
    private LinearLayout llTimelineContainer;

    // Shipper
    private CardView cardShipperInfo;
    private TextView tvShipperName;
    private TextView tvShipperPhone;
    private TextView tvShipperLicensePlate;
    private ImageButton btnCallShipper;
    private ImageButton btnSmsShipper;

    // Map & Tracking
    private CardView cardMapTracker;
    private MapView mapTracker;
    private TextView tvMapEta;
    private Handler mapHandler;
    private Runnable mapRunnable;
    private Marker shipperMarker;
    private int currentStep = 0;

    // Address & Shop & Items & Bill
    private TextView tvDetailRecipient;
    private TextView tvDetailAddressText;
    private TextView tvDetailShopName;
    private RecyclerView rvDetailItems;
    private TextView tvDetailPaymentMethod;
    private TextView tvDetailSubtotal;
    private TextView tvDetailShippingFee;
    private TextView tvDetailDiscount;
    private TextView tvDetailTotalAmount;

    // Actions
    private Button btnCancelOrder;
    private Button btnDetailReorder;

    // Demo status switchers
    private Button btnDemoPending, btnDemoPreparing, btnDemoShipping, btnDemoDelivered, btnDemoRefund;

    private DataRepository repository;
    private Order currentOrder;
    private String orderId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Configuration.getInstance().load(getApplicationContext(), getSharedPreferences("osmdroid", MODE_PRIVATE));
        Configuration.getInstance().setUserAgentValue(getPackageName());
        setContentView(R.layout.activity_order_detail);

        repository = DataRepository.getInstance();
        orderId = getIntent().getStringExtra("ORDER_ID");

        if (orderId != null) {
            currentOrder = repository.findOrderById(orderId);
        }

        if (currentOrder == null) {
            ViewUtils.showToast(this, "Không tìm thấy thông tin đơn hàng!");
            finish();
            return;
        }

        initViews();
        setupData();
        setupEvents();
    }

    private void initViews() {
        toolbarDetail = findViewById(R.id.toolbarDetail);
        llStatusBanner = findViewById(R.id.llStatusBanner);
        tvDetailStatusTitle = findViewById(R.id.tvDetailStatusTitle);
        tvDetailOrderIdAndDate = findViewById(R.id.tvDetailOrderIdAndDate);

        cardRefundTimeline = findViewById(R.id.cardRefundTimeline);
        tvRefundNote = findViewById(R.id.tvRefundNote);
        llRefundTimelineContainer = findViewById(R.id.llRefundTimelineContainer);

        cardDeliveryTimeline = findViewById(R.id.cardDeliveryTimeline);
        tvCarrierName = findViewById(R.id.tvCarrierName);
        llTimelineContainer = findViewById(R.id.llTimelineContainer);

        cardShipperInfo = findViewById(R.id.cardShipperInfo);
        tvShipperName = findViewById(R.id.tvShipperName);
        tvShipperPhone = findViewById(R.id.tvShipperPhone);
        tvShipperLicensePlate = findViewById(R.id.tvShipperLicensePlate);
        btnCallShipper = findViewById(R.id.btnCallShipper);
        btnSmsShipper = findViewById(R.id.btnSmsShipper);

        cardMapTracker = findViewById(R.id.cardMapTracker);
        mapTracker = findViewById(R.id.mapTracker);
        tvMapEta = findViewById(R.id.tvMapEta);

        tvDetailRecipient = findViewById(R.id.tvDetailRecipient);
        tvDetailAddressText = findViewById(R.id.tvDetailAddressText);
        tvDetailShopName = findViewById(R.id.tvDetailShopName);
        rvDetailItems = findViewById(R.id.rvDetailItems);

        tvDetailPaymentMethod = findViewById(R.id.tvDetailPaymentMethod);
        tvDetailSubtotal = findViewById(R.id.tvDetailSubtotal);
        tvDetailShippingFee = findViewById(R.id.tvDetailShippingFee);
        tvDetailDiscount = findViewById(R.id.tvDetailDiscount);
        tvDetailTotalAmount = findViewById(R.id.tvDetailTotalAmount);

        btnCancelOrder = findViewById(R.id.btnCancelOrder);
        btnDetailReorder = findViewById(R.id.btnDetailReorder);

        btnDemoPending = findViewById(R.id.btnDemoPending);
        btnDemoPreparing = findViewById(R.id.btnDemoPreparing);
        btnDemoShipping = findViewById(R.id.btnDemoShipping);
        btnDemoDelivered = findViewById(R.id.btnDemoDelivered);
        btnDemoRefund = findViewById(R.id.btnDemoRefund);

        toolbarDetail.setNavigationOnClickListener(v -> finish());
    }

    private void setupData() {
        // Status Banner
        tvDetailStatusTitle.setText("Trạng thái: " + currentOrder.getStatus().getDisplayName());
        tvDetailOrderIdAndDate.setText("Mã đơn: #" + currentOrder.getId() + " • Đặt lúc: " + currentOrder.getOrderDate());
        llStatusBanner.setBackgroundColor(ViewUtils.getStatusColor(this, currentOrder.getStatus()));

        // Address
        if (currentOrder.getAddress() != null) {
            tvDetailRecipient.setText(currentOrder.getAddress().getRecipientName() + " | " + currentOrder.getAddress().getPhoneNumber());
            tvDetailAddressText.setText(currentOrder.getAddress().getDetailAddress());
        }

        // Shop & Items
        tvDetailShopName.setText(currentOrder.getShopName());
        rvDetailItems.setLayoutManager(new LinearLayoutManager(this));
        CheckoutItemAdapter adapter = new CheckoutItemAdapter(this, currentOrder.getItems());
        rvDetailItems.setAdapter(adapter);

        // Bill info
        tvDetailPaymentMethod.setText(currentOrder.getPaymentMethod());
        tvDetailSubtotal.setText(FormatUtils.formatVND(currentOrder.getSubtotal()));
        tvDetailShippingFee.setText(FormatUtils.formatVND(currentOrder.getShippingFee()));
        tvDetailDiscount.setText("-" + FormatUtils.formatVND(currentOrder.getDiscount()));
        tvDetailTotalAmount.setText(FormatUtils.formatVND(currentOrder.getTotalAmount()));

        // Carrier & Shipper
        if (currentOrder.getShippingUnit() != null) {
            tvCarrierName.setText(currentOrder.getShippingUnit().getName() + " • Mã vận đơn: SPX24CT1" + currentOrder.getId());
        }
        tvShipperName.setText(currentOrder.getShipperName());
        tvShipperPhone.setText("SĐT: " + currentOrder.getShipperPhone());

        // Render Timelines
        renderDeliveryTimeline();
        renderRefundTimeline();

        // Control Cancel Order Button Visibility (Feature 5: Only visible in Pending & Preparing states)
        updateCancelButtonVisibility();

        // Feature 8: Live Map Tracking for DANG_GIAO status
        OrderStatus status = currentOrder.getStatus();
        if (status == OrderStatus.DANG_GIAO) {
            cardShipperInfo.setVisibility(View.VISIBLE);
            cardMapTracker.setVisibility(View.VISIBLE);
            cardDeliveryTimeline.setVisibility(View.GONE);
            setupLiveMapTracking();
        } else {
            if (status == OrderStatus.CHO_XAC_NHAN || status == OrderStatus.DANG_CHUAN_BI || status == OrderStatus.CHO_THANH_TOAN) {
                cardShipperInfo.setVisibility(View.GONE);
            } else {
                cardShipperInfo.setVisibility(View.VISIBLE);
            }
            cardMapTracker.setVisibility(View.GONE);
            cardDeliveryTimeline.setVisibility(View.VISIBLE);
            stopLiveMapTracking();
        }
    }

    private void renderDeliveryTimeline() {
        llTimelineContainer.removeAllViews();
        List<TimelineNode> nodes = currentOrder.getDeliveryTimeline();
        LayoutInflater inflater = LayoutInflater.from(this);

        for (int i = 0; i < nodes.size(); i++) {
            TimelineNode node = nodes.get(i);
            View nodeView = inflater.inflate(R.layout.item_timeline_node, llTimelineContainer, false);

            View viewTopLine = nodeView.findViewById(R.id.viewTopLine);
            View viewNodeDot = nodeView.findViewById(R.id.viewNodeDot);
            View viewBottomLine = nodeView.findViewById(R.id.viewBottomLine);
            TextView tvTitle = nodeView.findViewById(R.id.tvTimelineTitle);
            TextView tvTime = nodeView.findViewById(R.id.tvTimelineTime);
            TextView tvDesc = nodeView.findViewById(R.id.tvTimelineDesc);

            tvTitle.setText(node.getTitle());
            tvDesc.setText(node.getDescription());
            tvTime.setText(node.getTimestamp());

            // First & Last line handling
            if (i == 0) viewTopLine.setVisibility(View.INVISIBLE);
            if (i == nodes.size() - 1) viewBottomLine.setVisibility(View.INVISIBLE);

            // Node dot styling: Active vs Done vs Inactive
            if (node.isCurrent()) {
                viewNodeDot.setBackgroundResource(R.drawable.bg_circle_active);
                tvTitle.setTextColor(getColor(R.color.primary));
                tvTitle.setText(node.getTitle() + " (Hiện tại)");
            } else if (node.isCompleted()) {
                viewNodeDot.setBackgroundResource(R.drawable.bg_circle_done);
                tvTitle.setTextColor(getColor(R.color.text_primary));
            } else {
                viewNodeDot.setBackgroundResource(R.drawable.bg_circle_inactive);
                tvTitle.setTextColor(getColor(R.color.text_hint));
                tvDesc.setTextColor(getColor(R.color.text_hint));
            }

            llTimelineContainer.addView(nodeView);
        }
    }

    private void renderRefundTimeline() {
        if (currentOrder.getStatus() == OrderStatus.HOAN_TIEN) {
            cardRefundTimeline.setVisibility(View.VISIBLE);
            llRefundTimelineContainer.removeAllViews();
            LayoutInflater inflater = LayoutInflater.from(this);
            List<TimelineNode> refundNodes = currentOrder.getRefundTimeline();

            for (int i = 0; i < refundNodes.size(); i++) {
                TimelineNode node = refundNodes.get(i);
                View nodeView = inflater.inflate(R.layout.item_timeline_node, llRefundTimelineContainer, false);

                View viewTopLine = nodeView.findViewById(R.id.viewTopLine);
                View viewNodeDot = nodeView.findViewById(R.id.viewNodeDot);
                View viewBottomLine = nodeView.findViewById(R.id.viewBottomLine);
                TextView tvTitle = nodeView.findViewById(R.id.tvTimelineTitle);
                TextView tvTime = nodeView.findViewById(R.id.tvTimelineTime);
                TextView tvDesc = nodeView.findViewById(R.id.tvTimelineDesc);

                tvTitle.setText(node.getTitle());
                tvDesc.setText(node.getDescription());
                tvTime.setText(node.getTimestamp());

                if (i == 0) viewTopLine.setVisibility(View.INVISIBLE);
                if (i == refundNodes.size() - 1) viewBottomLine.setVisibility(View.INVISIBLE);

                if (node.isCurrent()) {
                    viewNodeDot.setBackgroundResource(R.drawable.bg_circle_active);
                    tvTitle.setTextColor(getColor(R.color.status_refund));
                } else if (node.isCompleted()) {
                    viewNodeDot.setBackgroundResource(R.drawable.bg_circle_done);
                } else {
                    viewNodeDot.setBackgroundResource(R.drawable.bg_circle_inactive);
                }

                llRefundTimelineContainer.addView(nodeView);
            }
        } else {
            cardRefundTimeline.setVisibility(View.GONE);
        }
    }

    private void updateCancelButtonVisibility() {
        OrderStatus st = currentOrder.getStatus();
        // Visible only in: Chờ thanh toán, Chờ xác nhận, Đang chuẩn bị
        if (st == OrderStatus.CHO_THANH_TOAN || st == OrderStatus.CHO_XAC_NHAN || st == OrderStatus.DANG_CHUAN_BI) {
            btnCancelOrder.setVisibility(View.VISIBLE);
        } else {
            // Hidden when handed over to shipper or completed or cancelled
            btnCancelOrder.setVisibility(View.GONE);
        }
    }

    private void setupEvents() {
        // Call Shipper
        btnCallShipper.setOnClickListener(v -> {
            String phone = currentOrder.getShipperPhone();
            Intent dialIntent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + phone));
            try {
                startActivity(dialIntent);
            } catch (Exception e) {
                ViewUtils.showToast(this, "Không thể mở ứng dụng gọi điện!");
            }
        });

        // Message Shipper
        btnSmsShipper.setOnClickListener(v -> {
            String phone = currentOrder.getShipperPhone();
            Intent smsIntent = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:" + phone));
            smsIntent.putExtra("sms_body", "Chào bạn, mình là người nhận đơn hàng #" + currentOrder.getId());
            try {
                startActivity(smsIntent);
            } catch (Exception e) {
                ViewUtils.showToast(this, "Không thể mở ứng dụng tin nhắn!");
            }
        });

        // Cancel Order Click (Feature 5)
        btnCancelOrder.setOnClickListener(v -> showCancelOrderDialog());

        // Reorder Click
        btnDetailReorder.setOnClickListener(v -> {
            for (CartItem item : currentOrder.getItems()) {
                repository.addToCart(item.getProduct(), item.getVariation(), item.getQuantity());
            }
            ViewUtils.showToast(this, "Đã thêm các sản phẩm trong đơn vào giỏ hàng!");
        });

        // Demo Status Switchers
        btnDemoPending.setOnClickListener(v -> changeStatusDemo(OrderStatus.CHO_XAC_NHAN));
        btnDemoPreparing.setOnClickListener(v -> changeStatusDemo(OrderStatus.DANG_CHUAN_BI));
        btnDemoShipping.setOnClickListener(v -> changeStatusDemo(OrderStatus.DANG_GIAO));
        btnDemoDelivered.setOnClickListener(v -> changeStatusDemo(OrderStatus.DA_GIAO));
        btnDemoRefund.setOnClickListener(v -> changeStatusDemo(OrderStatus.HOAN_TIEN));
    }

    private void showCancelOrderDialog() {
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_cancel_order, null);
        RadioGroup rgCancelReasons = dialogView.findViewById(R.id.rgCancelReasons);
        RadioButton rbReasonOther = dialogView.findViewById(R.id.rbReasonOther);
        EditText etOtherReason = dialogView.findViewById(R.id.etOtherReason);

        rgCancelReasons.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rbReasonOther) {
                etOtherReason.setVisibility(View.VISIBLE);
            } else {
                etOtherReason.setVisibility(View.GONE);
            }
        });

        new AlertDialog.Builder(this)
                .setView(dialogView)
                .setPositiveButton("Xác nhận hủy đơn", (dialog, which) -> {
                    int checkedId = rgCancelReasons.getCheckedRadioButtonId();
                    String reason = "Đổi ý không muốn mua nữa";
                    if (checkedId == R.id.rbReason2) reason = "Tìm được nơi khác bán giá rẻ hơn";
                    else if (checkedId == R.id.rbReason3) reason = "Muốn thay đổi địa chỉ nhận hàng";
                    else if (checkedId == R.id.rbReason4) reason = "Muốn thay đổi phân loại sản phẩm";
                    else if (checkedId == R.id.rbReasonOther) {
                        String custom = etOtherReason.getText().toString().trim();
                        reason = !custom.isEmpty() ? custom : "Lý do khác";
                    }

                    // Execute Cancel & Refund Logic (Feature 5)
                    repository.cancelOrder(currentOrder.getId(), reason);

                    String msg = currentOrder.isPrepaid()
                            ? "Đơn hàng đã được yêu cầu hủy. Do bạn đã thanh toán trước (" + currentOrder.getPaymentMethod() + "), hệ thống đang tiến hành hoàn tiền trong 1-3 ngày làm việc."
                            : "Đơn hàng (COD) đã được hủy thành công.";

                    new AlertDialog.Builder(this)
                            .setTitle("Thông báo")
                            .setMessage(msg)
                            .setPositiveButton("Đồng ý", (d, w) -> {
                                setupData();
                            })
                            .show();
                })
                .setNegativeButton("Đóng", null)
                .show();
    }

    private void changeStatusDemo(OrderStatus status) {
        currentOrder.setStatus(status);
        if (status == OrderStatus.HOAN_TIEN && currentOrder.getRefundTimeline().isEmpty()) {
            currentOrder.getRefundTimeline().add(new TimelineNode("Yêu cầu hoàn tiền", "Khách hàng yêu cầu hoàn tiền", FormatUtils.getCurrentDateTimeString(), true, false));
            currentOrder.getRefundTimeline().add(new TimelineNode("Hệ thống xử lý", "Kế toán đang tiến hành đối soát", FormatUtils.getCurrentDateTimeString(), false, true));
            currentOrder.getRefundTimeline().add(new TimelineNode("Đã hoàn tiền", "Tiền sẽ hoàn về trong 1-3 ngày làm việc", "Dự kiến 1-3 ngày", false, false));
        }
        setupData();
        ViewUtils.showToast(this, "Đã chuyển sang trạng thái: " + status.getDisplayName());
    }

    private void setupLiveMapTracking() {
        if (mapTracker == null) return;

        mapTracker.setMultiTouchControls(true);
        mapTracker.getController().setZoom(15.0);

        // Destination Point (e.g. User's address)
        GeoPoint destPoint = new GeoPoint(16.0669, 108.2140); 
        mapTracker.getController().setCenter(destPoint);

        // Add Destination Marker
        mapTracker.getOverlays().clear();
        Marker destMarker = new Marker(mapTracker);
        destMarker.setPosition(destPoint);
        destMarker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM);
        destMarker.setTitle("Điểm giao hàng: " + currentOrder.getAddress().getDetailAddress());
        mapTracker.getOverlays().add(destMarker);

        // Shipper Marker Start Point
        GeoPoint startPoint = new GeoPoint(16.0500, 108.2000); // Somewhere nearby
        shipperMarker = new Marker(mapTracker);
        shipperMarker.setPosition(startPoint);
        shipperMarker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_CENTER);
        shipperMarker.setIcon(getDrawable(R.drawable.ic_motorcycle));
        shipperMarker.setTitle("Tài xế: " + tvShipperName.getText());
        mapTracker.getOverlays().add(shipperMarker);

        startMockShipperMovement(startPoint, destPoint);
    }

    private void startMockShipperMovement(GeoPoint start, GeoPoint dest) {
        stopLiveMapTracking();
        mapHandler = new Handler();
        currentStep = 0;
        int totalSteps = 100; // 10 seconds (100ms per step)

        mapRunnable = new Runnable() {
            @Override
            public void run() {
                currentStep++;
                double fraction = (double) currentStep / totalSteps;
                double currentLat = start.getLatitude() + (dest.getLatitude() - start.getLatitude()) * fraction;
                double currentLon = start.getLongitude() + (dest.getLongitude() - start.getLongitude()) * fraction;

                GeoPoint currentPos = new GeoPoint(currentLat, currentLon);
                shipperMarker.setPosition(currentPos);
                mapTracker.invalidate();

                int remainingSeconds = (totalSteps - currentStep) / 10;
                tvMapEta.setText("Tài xế đang đến, dự kiến " + Math.max(1, remainingSeconds) + " phút nữa");

                if (currentStep < totalSteps) {
                    mapHandler.postDelayed(this, 100);
                } else {
                    // Arrived
                    tvMapEta.setText("Tài xế đã đến nơi!");
                    showRatingPopup();
                }
            }
        };
        mapHandler.postDelayed(mapRunnable, 1000);
    }

    private void stopLiveMapTracking() {
        if (mapHandler != null && mapRunnable != null) {
            mapHandler.removeCallbacks(mapRunnable);
        }
    }

    private void showRatingPopup() {
        new AlertDialog.Builder(this)
            .setTitle("Đơn hàng đã giao thành công!")
            .setMessage("Bạn có muốn đánh giá chất lượng sản phẩm & tài xế không?")
            .setPositiveButton("Đánh giá ngay", (dialog, which) -> {
                // Change status to Delivered
                currentOrder.setStatus(OrderStatus.DA_GIAO);
                setupData();
                ViewUtils.showToast(this, "Cảm ơn bạn đã đánh giá!");
            })
            .setNegativeButton("Để sau", (dialog, which) -> {
                currentOrder.setStatus(OrderStatus.DA_GIAO);
                setupData();
            })
            .setCancelable(false)
            .show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mapTracker != null) {
            mapTracker.onResume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mapTracker != null) {
            mapTracker.onPause();
        }
        stopLiveMapTracking();
    }
}
