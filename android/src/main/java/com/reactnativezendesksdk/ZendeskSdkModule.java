package com.reactnativezendesksdk;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = ZendeskSdkModule.NAME)
public class ZendeskSdkModule extends ReactContextBaseJavaModule {
    public static final String NAME = "ZendeskSdk";

    public ZendeskSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void initialize(ReadableMap options, Promise promise) {
        String appId = options.getString("appId");
        String clientId = options.getString("clientId");
        String url = options.getString("url");
        Context context = appContext;
        Zendesk.INSTANCE.init(context, url, appId, clientId);
        Support.INSTANCE.init(Zendesk.INSTANCE);
    }

    @ReactMethod
    public void setUserIdentity(ReadableMap options) {
//         if (options.hasKey("token")) {
//           Identity identity = new JwtIdentity(options.getString("token"));
//           Zendesk.INSTANCE.setIdentity(identity);
//         } else {
//           String name = options.getString("name");
//           String email = options.getString("email");
//           Identity identity = new AnonymousIdentity.Builder()
//                   .withNameIdentifier(name).withEmailIdentifier(email).build();
//           Zendesk.INSTANCE.setIdentity(identity);
//         }
    }

    public static native int nativeMultiply(int a, int b);
}
