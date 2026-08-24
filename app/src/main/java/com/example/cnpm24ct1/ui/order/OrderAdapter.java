package com.example.cnpm24ct1.ui.order;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.data.model.Order;
import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;

import java.util.List;

public class OrderAdapter extends RecyclerView.Adapter<OrderAdapter.OrderViewHolder> {

    public interface OnOrderActionListener {
        void onOrderChanged();
    }

    private final Context context;
    private final List<Order> orderList;
    private final OnOrderActionListener actionListener;

    public OrderAdapter(Context context, List<Order> orderList, OnOrderActionListener actionListener) {
        this.context = context;
        this.orderList = orderList;
        this.actionListener = actionListener;
    }

    @NonNull
    @Override
    public OrderViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_order_card, parent, false);
        return new OrderViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull OrderViewHolder holder, int position) {
        Order order = orderList.get(position);
        holder.bind(order);
    }

    @Override
    public int getItemCount() {
        return orderList.size();
    }

    public class OrderViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvOrderShopName;
        private final TextView tvOrderStatusBadge;
        private final TextView tvOrderIdAndDate;
        private final LinearLayout llOrderItemsPreview;
        private final TextView tvOrderProductCount;
        private final TextView tvOrderTotalAmount;
        private final Button btnContactSeller;
        private final Button btnReorder;

        public OrderViewHolder(@NonNull View itemView) {
            super(itemView);
            tvOrderShopName = itemView.findViewById(R.id.tvOrderShopName);
            tvOrderStatusBadge = itemView.findViewById(R.id.tvOrderStatusBadge);
            tvOrderIdAndDate = itemView.findViewById(R.id.tvOrderIdAndDate);
            llOrderItemsPreview = itemView.findViewById(R.id.llOrderItemsPreview);
            tvOrderProductCount = itemView.findViewById(R.id.tvOrderProductCount);
            tvOrderTotalAmount = itemView.findViewById(R.id.tvOrderTotalAmount);
            btnContactSeller = itemView.findViewById(R.id.btnContactSeller);
            btnReorder = itemView.findViewById(R.id.btnReorder);
        }

        public void bind(final Order order) {
            tvOrderShopName.setText(order.getShopName());
            tvOrderStatusBadge.setText(order.getStatus().getDisplayName());
            tvOrderStatusBadge.setTextColor(ViewUtils.getStatusColor(context, order.getStatus()));

            tvOrderIdAndDate.setText("Mã đơn: #" + order.getId() + " • " + order.getOrderDate());
            tvOrderProductCount.setText(order.getTotalProductCount() + " sản phẩm");
            tvOrderTotalAmount.setText(FormatUtils.formatVND(order.getTotalAmount()));

            // Populate items preview
            llOrderItemsPreview.removeAllViews();
            LayoutInflater inflater = LayoutInflater.from(context);
            for (CartItem item : order.getItems()) {
                View itemView = inflater.inflate(R.layout.item_checkout_summary, llOrderItemsPreview, false);
                TextView tvName = itemView.findViewById(R.id.tvName);
                TextView tvVariation = itemView.findViewById(R.id.tvVariation);
                TextView tvPrice = itemView.findViewById(R.id.tvPrice);
                TextView tvQty = itemView.findViewById(R.id.tvQty);

                if (item.getProduct() != null) {
                    tvName.setText(item.getProduct().getName());
                }
                tvVariation.setText(item.getVariationDisplay());
                tvPrice.setText(FormatUtils.formatVND(item.getItemUnitPrice()));
                tvQty.setText("x" + item.getQuantity());

                llOrderItemsPreview.addView(itemView);
            }

            // Click entire Card -> Open Order Detail & Tracking
            itemView.setOnClickListener(v -> {
                Intent intent = new Intent(context, OrderDetailActivity.class);
                intent.putExtra("ORDER_ID", order.getId());
                context.startActivity(intent);
            });

            // Quick Button: Mua lại (Reorder)
            btnReorder.setOnClickListener(v -> {
                DataRepository repo = DataRepository.getInstance();
                for (CartItem item : order.getItems()) {
                    repo.addToCart(item.getProduct(), item.getVariation(), item.getQuantity());
                }
                ViewUtils.showToast(context, "Đã thêm các sản phẩm trong đơn #" + order.getId() + " vào giỏ hàng!");
            });

            // Quick Button: Liên hệ người bán
            btnContactSeller.setOnClickListener(v -> {
                new AlertDialog.Builder(context)
                        .setTitle("Liên hệ: " + order.getShopName())
                        .setMessage("Bạn có thể liên hệ trực tiếp với Shop qua tổng đài hỗ trợ:\n\n📞 Hotline Shop: 0905.888.999\n💬 Chat trực tuyến: Đang hoạt động")
                        .setPositiveButton("Đóng", null)
                        .show();
            });
        }
    }
}
