package com.clickio.clickioapp;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class CustomWebViewDialog extends DialogFragment {

    private final String controllerId;
    private final String url;
    private final int width;
    private final int height;
    private final int gravity;
    private final String bgColor;

    private final ClickioSDKModule module;

    private WebView webView;

    public CustomWebViewDialog(String controllerId, String url, int width, int height, int gravity, String bgColor, ClickioSDKModule module) {
        this.controllerId = controllerId;
        this.url = url;
        this.width = width;
        this.height = height;
        this.gravity = gravity;
         this.bgColor = bgColor;
        this.module = module;
    }

 @Nullable
@Override
public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                         @Nullable Bundle savedInstanceState) {

    webView = new WebView(getContext());
    webView.setWebViewClient(new WebViewClient() {
        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            module.sendWebViewEvent("loaded", controllerId, url);
        }
    });
    webView.getSettings().setJavaScriptEnabled(true);
    webView.loadUrl(url);

    int colorInt = parseColorSafe(bgColor);
    webView.setBackgroundColor(colorInt);

    return webView;
}


    int parseColorSafe(String color) {
        if (color == null) return Color.TRANSPARENT;
        try {
            if (color.equalsIgnoreCase("transparent")) {
                return Color.TRANSPARENT;
            }
            if (color.startsWith("0x")) {
                // Handle numeric ARGB like 0xFF0000FF
                return (int) Long.parseLong(color.substring(2), 16);
            }
            return Color.parseColor(color);
        } catch (Exception e) {
            return Color.TRANSPARENT;
        }
    }

@Override
public void onStart() {
    super.onStart();

    if (getDialog() != null && getDialog().getWindow() != null) {
        android.view.Window window = getDialog().getWindow();

        //Make width full by default
        int finalWidth = (width > 0) ? width : ViewGroup.LayoutParams.MATCH_PARENT;

        int finalHeight;
        if (height > 0) {
            finalHeight = height;
        } else {
            DisplayMetrics dm = new DisplayMetrics();
            requireActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);
            finalHeight = (int) (dm.heightPixels * 0.7); // 70% screen height
        }

        window.setLayout(finalWidth, finalHeight);

        // Apply gravity
        android.view.WindowManager.LayoutParams params = window.getAttributes();
        params.gravity = gravity;
        window.setAttributes(params);

        //Background color
        int colorInt = parseColorSafe(bgColor);
        webView.setBackgroundColor(colorInt);
        window.setBackgroundDrawable(new ColorDrawable(colorInt));
    }
}




}
