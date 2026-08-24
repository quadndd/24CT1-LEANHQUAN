package com.example.cnpm24ct1.ui.order;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.Order;
import com.example.cnpm24ct1.data.model.OrderStatus;
import com.example.cnpm24ct1.data.repository.DataRepository;

import java.util.List;

public class OrderListFragment extends Fragment implements OrderAdapter.OnOrderActionListener {

    private static final String ARG_STATUS = "arg_order_status";
    private OrderStatus currentStatus = OrderStatus.TAT_CA;

    private RecyclerView rvOrderList;
    private LinearLayout llEmptyOrders;
    private OrderAdapter adapter;

    public static OrderListFragment newInstance(OrderStatus status) {
        OrderListFragment fragment = new OrderListFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_STATUS, status);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_order_list, container, false);

        if (getArguments() != null) {
            currentStatus = (OrderStatus) getArguments().getSerializable(ARG_STATUS);
        }

        rvOrderList = view.findViewById(R.id.rvOrderList);
        llEmptyOrders = view.findViewById(R.id.llEmptyOrders);

        setupRecyclerView();
        loadOrders();

        return view;
    }

    private void setupRecyclerView() {
        rvOrderList.setLayoutManager(new LinearLayoutManager(getContext()));
    }

    private void loadOrders() {
        DataRepository repo = DataRepository.getInstance();
        List<Order> orders = repo.getOrdersByStatus(currentStatus);

        if (orders.isEmpty()) {
            llEmptyOrders.setVisibility(View.VISIBLE);
            rvOrderList.setVisibility(View.GONE);
        } else {
            llEmptyOrders.setVisibility(View.GONE);
            rvOrderList.setVisibility(View.VISIBLE);
            adapter = new OrderAdapter(getContext(), orders, this);
            rvOrderList.setAdapter(adapter);
        }
    }

    @Override
    public void onOrderChanged() {
        loadOrders();
    }

    @Override
    public void onResume() {
        super.onResume();
        loadOrders();
    }
}
