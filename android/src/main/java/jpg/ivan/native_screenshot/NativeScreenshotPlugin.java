package jpg.ivan.native_screenshot;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.ByteArrayOutputStream;
import java.util.Date;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

/**
 * NativeScreenshotPlugin
 */
public class NativeScreenshotPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
    private static final String TAG = "NativeScreenshotPlugin";

    private Context context;
    private MethodChannel channel;
    private Activity activity;
    private Object renderer;

    private boolean ssError = false;

    // Default constructor for old registrar
    public NativeScreenshotPlugin() {
    } // NativeScreenshotPlugin()

    // Condensed logic to initialize the plugin
    private void initPlugin(Context context, BinaryMessenger messenger, Activity activity, Object renderer) {
        this.context = context;
        this.activity = activity;
        this.renderer = renderer;

        this.channel = new MethodChannel(messenger, "native_screenshot");
        this.channel.setMethodCallHandler(this);
    } // initPlugin()

    // New v2 listener methods
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.channel.setMethodCallHandler(null);
        this.channel = null;
        this.context = null;
    } // onDetachedFromEngine()

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.println(Log.INFO, TAG, "Using *NEW* registrar method!");

        initPlugin(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger(), null,
                flutterPluginBinding.getFlutterEngine().getRenderer()); // initPlugin()
    } // onAttachedToEngine()

    // Old v1 register method
    // FIX: Make instance variables set with the old method
    public static void registerWith(Registrar registrar) {
        Log.println(Log.INFO, TAG, "Using *OLD* registrar method!");

        NativeScreenshotPlugin instance = new NativeScreenshotPlugin();

        instance.initPlugin(registrar.context(), registrar.messenger(), registrar.activity(), registrar.view()); // initPlugin()
    } // registerWith()

    // Activity condensed methods
    private void attachActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    } // attachActivity()

    private void detachActivity() {
        this.activity = null;
    } // attachActivity()

    // Activity listener methods
    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        attachActivity(binding);
    } // onAttachedToActivity()

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        detachActivity();
    } // onDetachedFromActivityForConfigChanges()

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        attachActivity(binding);
    } // onReattachedToActivityForConfigChanges()

    @Override
    public void onDetachedFromActivity() {
        detachActivity();
    } // onDetachedFromActivity()

    // MethodCall, manage stuff coming from Dart
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!call.method.equals("takeScreenshot")) {
            Log.println(Log.INFO, TAG, "Method not implemented!");
            result.notImplemented();
            return;
        } // if not implemented

        int quality = call.argument("quality");
        byte[] bytes = takeScreenshot(quality);
        result.success(bytes);

    } // onMethodCall()

    private byte[] takeScreenshot(int quality) {
        Log.println(Log.INFO, TAG, "Taking screenshot");

        try {
            View view = this.activity.getWindow().getDecorView().getRootView();

            view.setDrawingCacheEnabled(true);

            Bitmap bitmap = null;
            if (this.renderer.getClass() == FlutterView.class) {
                bitmap = ((FlutterView) this.renderer).getBitmap();
            } else if (this.renderer.getClass() == FlutterRenderer.class) {
                bitmap = ((FlutterRenderer) this.renderer).getBitmap();
            }

            view.setDrawingCacheEnabled(false);

            if (bitmap == null) {
                Log.println(Log.INFO, TAG, "The bitmap cannot be created :(");
                return null;
            }

            ByteArrayOutputStream stream = new ByteArrayOutputStream();

            // int dstWidth = (int) (bitmap.getWidth() * quality / 100);
            // int dstHeight = (int) (bitmap.getHeight() * quality / 100);
            // Bitmap dstBitmap = Bitmap.createScaledBitmap(bitmap, dstWidth, dstHeight,
            // false);
            bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream);
            byte[] byteArray = stream.toByteArray();
            bitmap.recycle();

            return byteArray;

        } catch (Exception ex) {
            Log.println(Log.INFO, TAG, "Error taking screenshot: " + ex.getMessage());
        }
        return null;
    }
}
