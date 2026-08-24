package com.example.cnpm24ct1;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.ui.cart.CartFragment;
import com.example.cnpm24ct1.ui.home.HomeFragment;
import com.example.cnpm24ct1.ui.order.OrderManagementFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {

    private TextView tvToolbarTitle;
    private ImageView ivHeaderCart;
    private TextView tvCartBadge;
    private BottomNavigationView bottomNavigationView;

    private final HomeFragment homeFragment = new HomeFragment();
    private final CartFragment cartFragment = new CartFragment();
    private final OrderManagementFragment orderFragment = new OrderManagementFragment();

    private DataRepository repository;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        repository = DataRepository.getInstance();

        initViews();
        setupNavigation();
        updateCartBadge();

        // Default tab
        loadFragment(homeFragment, "CNPM 24CT1 Shop");
    }

    private void initViews() {
        tvToolbarTitle = findViewById(R.id.tvToolbarTitle);
        ivHeaderCart = findViewById(R.id.ivHeaderCart);
        tvCartBadge = findViewById(R.id.tvCartBadge);
        bottomNavigationView = findViewById(R.id.bottomNavigationView);

        ivHeaderCart.setOnClickListener(v -> {
            bottomNavigationView.setSelectedItemId(R.id.nav_cart);
        });
    }

    private void setupNavigation() {
        bottomNavigationView.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.nav_home) {
                loadFragment(homeFragment, "CNPM 24CT1 Shop");
                return true;
            } else if (itemId == R.id.nav_cart) {
                loadFragment(cartFragment, "Giỏ hàng của bạn");
                return true;
            } else if (itemId == R.id.nav_orders) {
                loadFragment(orderFragment, "Quản lý đơn hàng");
                return true;
            }
            return false;
        });
    }

    private void loadFragment(Fragment fragment, String title) {
        tvToolbarTitle.setText(title);
        FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();
        ft.replace(R.id.fragmentContainer, fragment);
        ft.commit();
        updateCartBadge();
    }

    public void updateCartBadge() {
        int cartCount = repository.getCartItems().size();
        if (cartCount > 0) {
            tvCartBadge.setVisibility(View.VISIBLE);
            tvCartBadge.setText(String.valueOf(cartCount));
        } else {
            tvCartBadge.setVisibility(View.GONE);
        }
    }

    public void switchToHomeTab() {
        bottomNavigationView.setSelectedItemId(R.id.nav_home);
    }

    public void switchToCartTab() {
        bottomNavigationView.setSelectedItemId(R.id.nav_cart);
    }

    public void switchToOrdersTab() {
        bottomNavigationView.setSelectedItemId(R.id.nav_orders);
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateCartBadge();
    }
}
