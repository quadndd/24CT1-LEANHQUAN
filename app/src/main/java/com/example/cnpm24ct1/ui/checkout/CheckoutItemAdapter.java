package com.example.cnpm24ct1.ui.checkout;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.utils.FormatUtils;

import java.util.List;

public class CheckoutItemAdapter extends RecyclerView.Adapter<CheckoutItemAdapter.ViewHolder> {

    private final Context context;
    private final List<CartItem> items;

    public CheckoutItemAdapter(Context context, List<CartItem> items) {
        this.context = context;
        this.items = items;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_checkout_summary, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        CartItem item = items.get(position);
        if (item.getProduct() != null) {
            holder.tvName.setText(item.getProduct().getName());
        }
        holder.tvVariation.setText(item.getVariationDisplay());
        holder.tvPrice.setText(FormatUtils.formatVND(item.getItemUnitPrice()));
        holder.tvQty.setText("x" + item.getQuantity());
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivThumb;
        TextView tvName;
        TextView tvVariation;
        TextView tvPrice;
        TextView tvQty;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivThumb = itemView.findViewById(R.id.ivThumb);
            tvName = itemView.findViewById(R.id.tvName);
            tvVariation = itemView.findViewById(R.id.tvVariation);
            tvPrice = itemView.findViewById(R.id.tvPrice);
            tvQty = itemView.findViewById(R.id.tvQty);
        }
    }
}
