package com.example.cnpm24ct1.ui.cart;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.CartItem;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;

import java.util.List;

public class CartAdapter extends RecyclerView.Adapter<CartAdapter.CartViewHolder> {

    public interface OnCartItemChangeListener {
        void onCartItemChanged();
        void onItemDeleted(CartItem item);
    }

    private final Context context;
    private final List<CartItem> cartList;
    private final OnCartItemChangeListener listener;

    public CartAdapter(Context context, List<CartItem> cartList, OnCartItemChangeListener listener) {
        this.context = context;
        this.cartList = cartList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public CartViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_cart, parent, false);
        return new CartViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull CartViewHolder holder, int position) {
        CartItem item = cartList.get(position);
        holder.bind(item);
    }

    @Override
    public int getItemCount() {
        return cartList.size();
    }

    public class CartViewHolder extends RecyclerView.ViewHolder {
        private final CheckBox cbItemCheck;
        private final TextView tvShopName;
        private final ImageButton btnDelete;
        private final ImageView ivProductThumb;
        private final TextView tvProductName;
        private final TextView tvVariation;
        private final TextView tvStockNote;
        private final TextView tvPrice;
        private final ImageButton btnMinus;
        private final EditText etQuantity;
        private final ImageButton btnPlus;

        private TextWatcher quantityTextWatcher;

        public CartViewHolder(@NonNull View itemView) {
            super(itemView);
            cbItemCheck = itemView.findViewById(R.id.cbItemCheck);
            tvShopName = itemView.findViewById(R.id.tvShopName);
            btnDelete = itemView.findViewById(R.id.btnDelete);
            ivProductThumb = itemView.findViewById(R.id.ivProductThumb);
            tvProductName = itemView.findViewById(R.id.tvProductName);
            tvVariation = itemView.findViewById(R.id.tvVariation);
            tvStockNote = itemView.findViewById(R.id.tvStockNote);
            tvPrice = itemView.findViewById(R.id.tvPrice);
            btnMinus = itemView.findViewById(R.id.btnMinus);
            etQuantity = itemView.findViewById(R.id.etQuantity);
            btnPlus = itemView.findViewById(R.id.btnPlus);
        }

        public void bind(final CartItem item) {
            if (item.getProduct() != null) {
                tvProductName.setText(item.getProduct().getName());
                tvShopName.setText(item.getProduct().getShopName());
            }
            tvVariation.setText(item.getVariationDisplay());
            tvPrice.setText(FormatUtils.formatVND(item.getItemUnitPrice()));

            final int maxStock = item.getMaxStock();
            tvStockNote.setText("Còn " + maxStock + " sản phẩm trong kho");

            // Checkbox state
            cbItemCheck.setOnCheckedChangeListener(null);
            cbItemCheck.setChecked(item.isSelected());
            cbItemCheck.setOnCheckedChangeListener((buttonView, isChecked) -> {
                item.setSelected(isChecked);
                if (listener != null) {
                    listener.onCartItemChanged();
                }
            });

            // Quantity buttons state
            updateQuantityUI(item);

            // Remove existing text watcher to prevent infinite recursion
            if (quantityTextWatcher != null) {
                etQuantity.removeTextChangedListener(quantityTextWatcher);
            }

            etQuantity.setText(String.valueOf(item.getQuantity()));

            // Minus Button Click
            btnMinus.setOnClickListener(v -> {
                int currentQty = item.getQuantity();
                if (currentQty > 1) {
                    item.setQuantity(currentQty - 1);
                    updateQuantityUI(item);
                    if (listener != null) listener.onCartItemChanged();
                }
            });

            // Plus Button Click
            btnPlus.setOnClickListener(v -> {
                int currentQty = item.getQuantity();
                if (currentQty < maxStock) {
                    item.setQuantity(currentQty + 1);
                    updateQuantityUI(item);
                    if (listener != null) listener.onCartItemChanged();
                } else {
                    ViewUtils.showToast(context, "Số lượng đã đạt tồn kho tối đa (" + maxStock + ")");
                }
            });

            // EditText Focus & Input validation
            quantityTextWatcher = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {}
                @Override
                public void afterTextChanged(Editable s) {
                    String input = s.toString().trim();
                    if (input.isEmpty()) return;
                    try {
                        int typedQty = Integer.parseInt(input);
                        if (typedQty > maxStock) {
                            ViewUtils.showToast(context, "Số lượng vượt quá số hàng tồn kho (" + maxStock + ")");
                            item.setQuantity(maxStock);
                            etQuantity.removeTextChangedListener(this);
                            etQuantity.setText(String.valueOf(maxStock));
                            etQuantity.setSelection(etQuantity.getText().length());
                            etQuantity.addTextChangedListener(this);
                        } else if (typedQty < 1) {
                            item.setQuantity(1);
                            etQuantity.removeTextChangedListener(this);
                            etQuantity.setText("1");
                            etQuantity.setSelection(1);
                            etQuantity.addTextChangedListener(this);
                        } else {
                            item.setQuantity(typedQty);
                        }
                        updateButtonsOnly(item.getQuantity(), maxStock);
                        if (listener != null) listener.onCartItemChanged();
                    } catch (NumberFormatException ignored) {}
                }
            };
            etQuantity.addTextChangedListener(quantityTextWatcher);

            // Delete action
            btnDelete.setOnClickListener(v -> {
                new AlertDialog.Builder(context)
                        .setTitle("Xóa sản phẩm")
                        .setMessage("Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?")
                        .setPositiveButton("Xóa", (dialog, which) -> {
                            if (listener != null) {
                                listener.onItemDeleted(item);
                            }
                        })
                        .setNegativeButton("Hủy", null)
                        .show();
            });
        }

        private void updateQuantityUI(CartItem item) {
            int qty = item.getQuantity();
            int maxStock = item.getMaxStock();
            etQuantity.setText(String.valueOf(qty));
            updateButtonsOnly(qty, maxStock);
        }

        private void updateButtonsOnly(int qty, int maxStock) {
            // [-] button disabled/dimmed when quantity == 1
            if (qty <= 1) {
                btnMinus.setEnabled(false);
                btnMinus.setAlpha(0.35f);
            } else {
                btnMinus.setEnabled(true);
                btnMinus.setAlpha(1.0f);
            }

            // [+] button disabled if reached max stock
            if (qty >= maxStock) {
                btnPlus.setEnabled(false);
                btnPlus.setAlpha(0.35f);
            } else {
                btnPlus.setEnabled(true);
                btnPlus.setAlpha(1.0f);
            }
        }
    }
}
