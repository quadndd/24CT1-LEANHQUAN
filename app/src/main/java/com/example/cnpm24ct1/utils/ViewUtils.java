package com.example.cnpm24ct1.utils;

import android.content.Context;
import android.widget.Toast;
import androidx.core.content.ContextCompat;
import com.example.cnpm24ct1.R;
import com.example.cnpm24ct1.data.model.OrderStatus;

public class ViewUtils {

    public static void showToast(Context context, String message) {
        if (context != null) {
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
        }
    }

    public static int getStatusColor(Context context, OrderStatus status) {
        if (status == null) return ContextCompat.getColor(context, R.color.text_secondary);
        switch (status) {
            case CHO_THANH_TOAN:
                return ContextCompat.getColor(context, R.color.status_pending);
            case CHO_XAC_NHAN:
                return ContextCompat.getColor(context, R.color.status_confirm);
            case DANG_CHUAN_BI:
                return ContextCompat.getColor(context, R.color.status_processing);
            case DANG_GIAO:
                return ContextCompat.getColor(context, R.color.status_shipping);
            case DA_GIAO:
                return ContextCompat.getColor(context, R.color.status_delivered);
            case DA_HUY:
                return ContextCompat.getColor(context, R.color.status_cancelled);
            case HOAN_TIEN:
                return ContextCompat.getColor(context, R.color.status_refund);
            default:
                return ContextCompat.getColor(context, R.color.text_secondary);
        }
    }
}
