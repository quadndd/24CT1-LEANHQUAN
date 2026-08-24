package com.example.cnpm24ct1.ui.cart;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.MainActivity;
import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.ui.checkout.CheckoutActivity;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;

import java.util.List;

public class CartFragment extends Fragment implements CartAdapter.OnCartItemChangeListener {

    private RecyclerView rvCartItems;
    private CartAdapter adapter;
    private CheckBox cbSelectAll;
    private TextView tvCartTotalPrice;
    private TextView tvCartItemCount;
    private Button btnCheckout;
    private LinearLayout llEmptyCart;
    private LinearLayout llCartBottomBar;
    private Button btnShopNow;

    private DataRepository repository;
    private boolean isUpdatingSelectAll = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_cart, container, false);
        repository = DataRepository.getInstance();

        initViews(view);
        setupRecyclerView();
        setupEvents();
        updateSummary();

        return view;
    }

    private void initViews(View view) {
        rvCartItems = view.findViewById(R.id.rvCartItems);
        cbSelectAll = view.findViewById(R.id.cbSelectAll);
        tvCartTotalPrice = view.findViewById(R.id.tvCartTotalPrice);
        tvCartItemCount = view.findViewById(R.id.tvCartItemCount);
        btnCheckout = view.findViewById(R.id.btnCheckout);
        llEmptyCart = view.findViewById(R.id.llEmptyCart);
        llCartBottomBar = view.findViewById(R.id.llCartBottomBar);
        btnShopNow = view.findViewById(R.id.btnShopNow);
    }

    private void setupRecyclerView() {
        rvCartItems.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new CartAdapter(getContext(), repository.getCartItems(), this);
        rvCartItems.setAdapter(adapter);
    }

    private void setupEvents() {
        cbSelectAll.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isUpdatingSelectAll) return;
            repository.setSelectAll(isChecked);
            adapter.notifyDataSetChanged();
            updateSummary();
        });

        btnCheckout.setOnClickListener(v -> {
            List<CartItem> selected = repository.getSelectedCartItems();
            if (selected.isEmpty()) {
                ViewUtils.showToast(getContext(), "Vui lòng chọn ít nhất một sản phẩm để thanh toán!");
                return;
            }
            Intent intent = new Intent(getContext(), CheckoutActivity.class);
            startActivity(intent);
        });

        btnShopNow.setOnClickListener(v -> {
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).switchToHomeTab();
            }
        });
    }

    public void updateSummary() {
        List<CartItem> cartItems = repository.getCartItems();
        if (cartItems.isEmpty()) {
            llEmptyCart.setVisibility(View.VISIBLE);
            rvCartItems.setVisibility(View.GONE);
            llCartBottomBar.setVisibility(View.GONE);
            tvCartItemCount.setText("0 sản phẩm");
            return;
        }

        llEmptyCart.setVisibility(View.GONE);
        rvCartItems.setVisibility(View.VISIBLE);
        llCartBottomBar.setVisibility(View.VISIBLE);

        int totalCount = cartItems.size();
        tvCartItemCount.setText(totalCount + " sản phẩm");

        double subtotal = repository.calculateSelectedSubtotal();
        tvCartTotalPrice.setText(FormatUtils.formatVND(subtotal));

        List<CartItem> selected = repository.getSelectedCartItems();
        int selectedCount = 0;
        for (CartItem item : selected) {
            selectedCount += item.getQuantity();
        }
        btnCheckout.setText("Thanh toán (" + selectedCount + ")");

        // Update Select All Checkbox state without triggering listener loop
        isUpdatingSelectAll = true;
        cbSelectAll.setChecked(repository.isAllSelected());
        isUpdatingSelectAll = false;
    }

    @Override
    public void onCartItemChanged() {
        updateSummary();
    }

    @Override
    public void onItemDeleted(CartItem item) {
        repository.removeFromCart(item.getId());
        adapter.notifyDataSetChanged();
        updateSummary();
        ViewUtils.showToast(getContext(), "Đã xóa sản phẩm khỏi giỏ hàng");
    }

    @Override
    public void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
        updateSummary();
    }
}
