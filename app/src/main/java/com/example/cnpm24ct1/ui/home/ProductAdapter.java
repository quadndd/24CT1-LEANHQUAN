package com.example.cnpm24ct1.ui.home;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.Product;
import com.example.cnpm24ct1.utils.FormatUtils;

import java.util.List;

public class ProductAdapter extends RecyclerView.Adapter<ProductAdapter.ProductViewHolder> {

    public interface OnProductClickListener {
        void onProductClicked(Product product);
        void onQuickAddToCart(Product product);
    }

    private final Context context;
    private final List<Product> productList;
    private final OnProductClickListener listener;

    public ProductAdapter(Context context, List<Product> productList, OnProductClickListener listener) {
        this.context = context;
        this.productList = productList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ProductViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_product_card, parent, false);
        return new ProductViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ProductViewHolder holder, int position) {
        Product product = productList.get(position);
        holder.tvProductName.setText(product.getName());
        holder.tvProductCategory.setText(product.getCategory());
        holder.tvProductPrice.setText(FormatUtils.formatVND(product.getPrice()));

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onProductClicked(product);
        });

        holder.btnQuickAddToCart.setOnClickListener(v -> {
            if (listener != null) listener.onQuickAddToCart(product);
        });
    }

    @Override
    public int getItemCount() {
        return productList.size();
    }

    public static class ProductViewHolder extends RecyclerView.ViewHolder {
        TextView tvProductName;
        TextView tvProductCategory;
        TextView tvProductPrice;
        ImageButton btnQuickAddToCart;

        public ProductViewHolder(@NonNull View itemView) {
            super(itemView);
            tvProductName = itemView.findViewById(R.id.tvHomeProductName);
            tvProductCategory = itemView.findViewById(R.id.tvHomeProductCategory);
            tvProductPrice = itemView.findViewById(R.id.tvHomeProductPrice);
            btnQuickAddToCart = itemView.findViewById(R.id.btnQuickAddToCart);
        }
    }
}
