package com.example.cnpm24ct1.ui.checkout;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.Address;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.data.model.Order;
import com.example.cnpm24ct1.data.model.ShippingUnit;
import com.example.cnpm24ct1.data.model.Voucher;
import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;
import com.google.android.material.appbar.MaterialToolbar;

import java.util.List;

public class CheckoutActivity extends AppCompatActivity {

    private MaterialToolbar toolbarCheckout;
    private TextView tvRecipientInfo;
    private TextView tvDetailAddress;
    private TextView btnChangeAddress;
    private TextView tvShopNameCheckout;
    private RecyclerView rvCheckoutItems;
    private RadioGroup rgShippingOptions;
    private RadioButton rbShipping1, rbShipping2, rbShipping3;
    private EditText etVoucherCode;
    private Button btnApplyVoucher;
    private TextView tvVoucherResult;
    private RadioGroup rgPaymentMethods;
    private RadioButton rbCOD, rbCreditCard, rbBankTransfer, rbEWallet;
    private TextView tvSummarySubtotal, tvSummaryShippingFee, tvSummaryDiscount, tvSummaryFinalTotal;
    private TextView tvBottomFinalTotal;
    private Button btnPlaceOrder;

    private DataRepository repository;
    private List<CartItem> selectedItems;
    private Address currentAddress;
    private ShippingUnit currentShipping;
    private Voucher appliedVoucher;
    private String currentPaymentMethod = "COD";

    private double subtotal = 0;
    private double shippingFee = 16500;
    private double discount = 0;
    private double finalTotal = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checkout);

        repository = DataRepository.getInstance();
        selectedItems = repository.getSelectedCartItems();

        if (selectedItems.isEmpty()) {
            ViewUtils.showToast(this, "Không có sản phẩm nào được chọn!");
            finish();
            return;
        }

        initViews();
        setupData();
        setupEvents();
        recalculateBill();
    }

    private void initViews() {
        toolbarCheckout = findViewById(R.id.toolbarCheckout);
        tvRecipientInfo = findViewById(R.id.tvRecipientInfo);
        tvDetailAddress = findViewById(R.id.tvDetailAddress);
        btnChangeAddress = findViewById(R.id.btnChangeAddress);
        tvShopNameCheckout = findViewById(R.id.tvShopNameCheckout);
        rvCheckoutItems = findViewById(R.id.rvCheckoutItems);
        rgShippingOptions = findViewById(R.id.rgShippingOptions);
        rbShipping1 = findViewById(R.id.rbShipping1);
        rbShipping2 = findViewById(R.id.rbShipping2);
        rbShipping3 = findViewById(R.id.rbShipping3);
        etVoucherCode = findViewById(R.id.etVoucherCode);
        btnApplyVoucher = findViewById(R.id.btnApplyVoucher);
        tvVoucherResult = findViewById(R.id.tvVoucherResult);
        rgPaymentMethods = findViewById(R.id.rgPaymentMethods);
        rbCOD = findViewById(R.id.rbCOD);
        rbCreditCard = findViewById(R.id.rbCreditCard);
        rbBankTransfer = findViewById(R.id.rbBankTransfer);
        rbEWallet = findViewById(R.id.rbEWallet);
        tvSummarySubtotal = findViewById(R.id.tvSummarySubtotal);
        tvSummaryShippingFee = findViewById(R.id.tvSummaryShippingFee);
        tvSummaryDiscount = findViewById(R.id.tvSummaryDiscount);
        tvSummaryFinalTotal = findViewById(R.id.tvSummaryFinalTotal);
        tvBottomFinalTotal = findViewById(R.id.tvBottomFinalTotal);
        btnPlaceOrder = findViewById(R.id.btnPlaceOrder);

        toolbarCheckout.setNavigationOnClickListener(v -> finish());
    }

    private void setupData() {
        // Address
        currentAddress = repository.getDefaultAddress();
        updateAddressUI();

        // Shop Name & Products
        if (!selectedItems.isEmpty() && selectedItems.get(0).getProduct() != null) {
            tvShopNameCheckout.setText(selectedItems.get(0).getProduct().getShopName());
        }

        rvCheckoutItems.setLayoutManager(new LinearLayoutManager(this));
        CheckoutItemAdapter adapter = new CheckoutItemAdapter(this, selectedItems);
        rvCheckoutItems.setAdapter(adapter);

        // Shipping unit
        List<ShippingUnit> units = repository.getShippingUnits();
        if (!units.isEmpty()) {
            currentShipping = units.get(0);
            shippingFee = currentShipping.getFee();
        }
    }

    private void setupEvents() {
        // Address dialog
        View.OnClickListener addressClickListener = v -> showAddressDialog();
        btnChangeAddress.setOnClickListener(addressClickListener);
        findViewById(R.id.llAddressBlock).setOnClickListener(addressClickListener);

        // Shipping selection
        rgShippingOptions.setOnCheckedChangeListener((group, checkedId) -> {
            List<ShippingUnit> units = repository.getShippingUnits();
            if (checkedId == R.id.rbShipping1 && !units.isEmpty()) {
                currentShipping = units.get(0);
            } else if (checkedId == R.id.rbShipping2 && units.size() > 1) {
                currentShipping = units.get(1);
            } else if (checkedId == R.id.rbShipping3 && units.size() > 2) {
                currentShipping = units.get(2);
            }
            if (currentShipping != null) {
                shippingFee = currentShipping.getFee();
            }
            recalculateBill();
        });

        // Payment method selection
        rgPaymentMethods.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == R.id.rbCOD) {
                currentPaymentMethod = "COD";
            } else if (checkedId == R.id.rbCreditCard) {
                currentPaymentMethod = "Thẻ tín dụng / Visa";
            } else if (checkedId == R.id.rbBankTransfer) {
                currentPaymentMethod = "Chuyển khoản ngân hàng";
            } else if (checkedId == R.id.rbEWallet) {
                currentPaymentMethod = "Ví điện tử (MoMo)";
            }
            validateOrderConditions();
        });

        // Voucher apply
        btnApplyVoucher.setOnClickListener(v -> {
            String code = etVoucherCode.getText().toString().trim();
            if (TextUtils.isEmpty(code)) {
                ViewUtils.showToast(this, "Vui lòng nhập mã Voucher!");
                return;
            }
            Voucher voucher = repository.findVoucherByCode(code);
            if (voucher != null) {
                if (subtotal >= voucher.getMinSpend()) {
                    appliedVoucher = voucher;
                    tvVoucherResult.setText("Đã áp dụng thành công: " + voucher.getTitle());
                    tvVoucherResult.setTextColor(getColor(R.color.accent));
                    ViewUtils.showToast(this, "Áp dụng Voucher thành công!");
                } else {
                    appliedVoucher = null;
                    tvVoucherResult.setText("Đơn hàng chưa đạt mức tối thiểu " + FormatUtils.formatVND(voucher.getMinSpend()));
                    tvVoucherResult.setTextColor(getColor(R.color.status_cancelled));
                }
            } else {
                appliedVoucher = null;
                tvVoucherResult.setText("Mã Voucher không hợp lệ hoặc đã hết hạn!");
                tvVoucherResult.setTextColor(getColor(R.color.status_cancelled));
            }
            recalculateBill();
        });

        // Place Order button
        btnPlaceOrder.setOnClickListener(v -> {
            if (currentAddress == null || TextUtils.isEmpty(currentAddress.getDetailAddress())) {
                ViewUtils.showToast(this, "Vui lòng cung cấp đầy đủ thông tin Địa chỉ nhận hàng!");
                return;
            }
            if (TextUtils.isEmpty(currentPaymentMethod)) {
                ViewUtils.showToast(this, "Vui lòng chọn Phương thức thanh toán!");
                return;
            }

            // Create Order in Repository
            Order newOrder = repository.createOrder(selectedItems, currentAddress, currentShipping, currentPaymentMethod, appliedVoucher);

            new AlertDialog.Builder(this)
                    .setTitle("🎉 Đặt hàng thành công!")
                    .setMessage("Mã đơn hàng của bạn: #" + newOrder.getId() + "\n"
                            + "Phương thức: " + newOrder.getPaymentMethod() + "\n"
                            + "Tổng thanh toán: " + FormatUtils.formatVND(newOrder.getTotalAmount()) + "\n\n"
                            + "Đơn hàng đang được người bán chuẩn bị.")
                    .setCancelable(false)
                    .setPositiveButton("Xem đơn hàng", (dialog, which) -> {
                        finish();
                    })
                    .show();
        });
    }

    private void updateAddressUI() {
        if (currentAddress != null) {
            tvRecipientInfo.setText(currentAddress.getRecipientName() + " | " + currentAddress.getPhoneNumber());
            tvDetailAddress.setText(currentAddress.getDetailAddress());
        } else {
            tvRecipientInfo.setText("Chưa có địa chỉ nhận hàng");
            tvDetailAddress.setText("Vui lòng nhấn để thêm địa chỉ nhận hàng");
        }
        validateOrderConditions();
    }

    private void recalculateBill() {
        subtotal = 0;
        for (CartItem item : selectedItems) {
            subtotal += item.getTotalPrice();
        }

        if (appliedVoucher != null) {
            discount = appliedVoucher.calculateDiscount(subtotal);
        } else {
            discount = 0;
        }

        finalTotal = Math.max(0, subtotal + shippingFee - discount);

        tvSummarySubtotal.setText(FormatUtils.formatVND(subtotal));
        tvSummaryShippingFee.setText(FormatUtils.formatVND(shippingFee));
        tvSummaryDiscount.setText("-" + FormatUtils.formatVND(discount));
        tvSummaryFinalTotal.setText(FormatUtils.formatVND(finalTotal));
        tvBottomFinalTotal.setText(FormatUtils.formatVND(finalTotal));

        validateOrderConditions();
    }

    private void validateOrderConditions() {
        boolean hasAddress = (currentAddress != null && !TextUtils.isEmpty(currentAddress.getDetailAddress()));
        boolean hasPayment = !TextUtils.isEmpty(currentPaymentMethod);
        boolean isValid = hasAddress && hasPayment;

        btnPlaceOrder.setEnabled(isValid);
        btnPlaceOrder.setAlpha(isValid ? 1.0f : 0.5f);
    }

    private void showAddressDialog() {
        List<Address> addresses = repository.getAddresses();
        String[] items = new String[addresses.size()];
        for (int i = 0; i < addresses.size(); i++) {
            Address a = addresses.get(i);
            items[i] = a.getRecipientName() + " (" + a.getPhoneNumber() + ")\n" + a.getDetailAddress();
        }

        new AlertDialog.Builder(this)
                .setTitle("Chọn địa chỉ nhận hàng")
                .setItems(items, (dialog, which) -> {
                    currentAddress = addresses.get(which);
                    updateAddressUI();
                })
                .setNeutralButton("Hủy", null)
                .show();
    }
}
