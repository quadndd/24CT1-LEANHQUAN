package com.example.cnpm24ct1.ui.order;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import androidx.viewpager2.widget.ViewPager2;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.OrderStatus;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;

public class OrderManagementFragment extends Fragment {

    private TabLayout tabLayoutOrders;
    private ViewPager2 viewPagerOrders;

    private final OrderStatus[] statuses = {
            OrderStatus.TAT_CA,
            OrderStatus.CHO_THANH_TOAN,
            OrderStatus.CHO_XAC_NHAN,
            OrderStatus.DANG_CHUAN_BI,
            OrderStatus.DANG_GIAO,
            OrderStatus.DA_GIAO,
            OrderStatus.DA_HUY,
            OrderStatus.HOAN_TIEN
    };

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_order_management, container, false);

        tabLayoutOrders = view.findViewById(R.id.tabLayoutOrders);
        viewPagerOrders = view.findViewById(R.id.viewPagerOrders);

        setupViewPager();

        return view;
    }

    private void setupViewPager() {
        OrderPagerAdapter pagerAdapter = new OrderPagerAdapter(this);
        viewPagerOrders.setAdapter(pagerAdapter);

        new TabLayoutMediator(tabLayoutOrders, viewPagerOrders, (tab, position) -> {
            tab.setText(statuses[position].getDisplayName());
        }).attach();
    }

    private class OrderPagerAdapter extends FragmentStateAdapter {

        public OrderPagerAdapter(@NonNull Fragment fragment) {
            super(fragment);
        }

        @NonNull
        @Override
        public Fragment createFragment(int position) {
            return OrderListFragment.newInstance(statuses[position]);
        }

        @Override
        public int getItemCount() {
            return statuses.length;
        }
    }
}
