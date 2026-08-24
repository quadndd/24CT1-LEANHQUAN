package com.example.cnpm24ct1.ui.home;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.cnpm24ct1.MainActivity;
import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.Product;
import com.example.cnpm24ct1.data.model.ProductVariation;
import com.example.cnpm24ct1.data.repository.DataRepository;
import com.example.cnpm24ct1.utils.FormatUtils;
import com.example.cnpm24ct1.utils.ViewUtils;

import java.util.ArrayList;
import java.util.List;

public class HomeFragment extends Fragment implements ProductAdapter.OnProductClickListener {

    private RecyclerView rvHomeProducts;
    private TextView tvProductTotalCount;
    private ProductAdapter adapter;
    private DataRepository repository;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);
        repository = DataRepository.getInstance();

        rvHomeProducts = view.findViewById(R.id.rvHomeProducts);
        tvProductTotalCount = view.findViewById(R.id.tvProductTotalCount);

        setupRecyclerView();
        loadProducts();

        return view;
    }

    private void setupRecyclerView() {
        rvHomeProducts.setLayoutManager(new GridLayoutManager(getContext(), 2));
    }

    private void loadProducts() {
        List<Product> products = repository.getProducts();
        tvProductTotalCount.setText(products.size() + " sản phẩm");
        adapter = new ProductAdapter(getContext(), products, this);
        rvHomeProducts.setAdapter(adapter);
    }

    @Override
    public void onProductClicked(Product product) {
        showProductDetailDialog(product);
    }

    @Override
    public void onQuickAddToCart(Product product) {
        ProductVariation v = (!product.getVariations().isEmpty()) ? product.getVariations().get(0) : null;
        repository.addToCart(product, v, 1);
        ViewUtils.showToast(getContext(), "Đã thêm \"" + product.getName() + "\" vào giỏ hàng!");
        if (getActivity() instanceof MainActivity) {
            ((MainActivity) getActivity()).updateCartBadge();
        }
    }

    private void showProductDetailDialog(Product product) {
        View dialogView = LayoutInflater.from(getContext()).inflate(R.layout.dialog_product_detail, null);

        TextView tvName = dialogView.findViewById(R.id.tvDialogProductName);
        TextView tvPrice = dialogView.findViewById(R.id.tvDialogPrice);
        TextView tvDesc = dialogView.findViewById(R.id.tvDialogDescription);
        Spinner spinnerVariations = dialogView.findViewById(R.id.spinnerDialogVariations);
        ImageButton btnMinus = dialogView.findViewById(R.id.btnDialogMinus);
        TextView tvQty = dialogView.findViewById(R.id.tvDialogQuantity);
        ImageButton btnPlus = dialogView.findViewById(R.id.btnDialogPlus);

        tvName.setText(product.getName());
        tvPrice.setText(FormatUtils.formatVND(product.getPrice()));
        tvDesc.setText(product.getDescription());

        final int[] quantity = {1};

        // Populate variations spinner
        List<String> variationNames = new ArrayList<>();
        if (!product.getVariations().isEmpty()) {
            for (ProductVariation v : product.getVariations()) {
                variationNames.add(v.getName() + " - " + FormatUtils.formatVND(v.getPrice()) + " (Kho: " + v.getStock() + ")");
            }
        } else {
            variationNames.add("Mặc định - " + FormatUtils.formatVND(product.getPrice()));
        }

        ArrayAdapter<String> varAdapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_spinner_dropdown_item, variationNames);
        spinnerVariations.setAdapter(varAdapter);

        btnMinus.setOnClickListener(v -> {
            if (quantity[0] > 1) {
                quantity[0]--;
                tvQty.setText(String.valueOf(quantity[0]));
            }
        });

        btnPlus.setOnClickListener(v -> {
            quantity[0]++;
            tvQty.setText(String.valueOf(quantity[0]));
        });

        new AlertDialog.Builder(getContext())
                .setView(dialogView)
                .setPositiveButton("Thêm vào giỏ", (dialog, which) -> {
                    int selectedIndex = spinnerVariations.getSelectedItemPosition();
                    ProductVariation selectedVar = (!product.getVariations().isEmpty() && selectedIndex < product.getVariations().size())
                            ? product.getVariations().get(selectedIndex) : null;
                    repository.addToCart(product, selectedVar, quantity[0]);
                    ViewUtils.showToast(getContext(), "Đã thêm " + quantity[0] + " sản phẩm vào giỏ hàng!");
                    if (getActivity() instanceof MainActivity) {
                        ((MainActivity) getActivity()).updateCartBadge();
                    }
                })
                .setNegativeButton("Đóng", null)
                .show();
    }

    @Override
    public void onResume() {
        super.onResume();
        loadProducts();
    }
}
