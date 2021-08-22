package com.reactnativezendesksdk;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;

import zendesk.core.Identity;
import zendesk.core.JwtIdentity;
import zendesk.core.Zendesk;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;

@ReactModule(name = ZendeskSdkModule.NAME)
public class ZendeskSdkModule extends ReactContextBaseJavaModule {
    public static final String NAME = "ZendeskSdk";

    private ReactContext appContext;

    public ZendeskSdkModule(ReactApplicationContext reactContext) {

      super(reactContext);
      appContext = reactContext;
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

        if (options.hasKey("user")) {
          ReadableMap user = options.getMap("user");
          String userId = user.getString("userId");
          String locale = user.getString("locale");

          Identity identity = new JwtIdentity(userId);

          Zendesk.INSTANCE.setIdentity(identity);

          registerDevice(userId);
        }

        promise.resolve("Zendesk SDK Initiated");
    }

    @ReactMethod
    public void setUserIdentity(ReadableMap options) {
    }

  @ReactMethod
  public void showNativeHelpCenter(ReadableMap options) {
    Activity activity = getCurrentActivity();
    HelpCenterActivity.builder().show(activity);
  }

    private boolean registerDevice(String identifier){
      final Boolean[] registrationResult = {false};
      Zendesk.INSTANCE.provider().pushRegistrationProvider().registerWithDeviceIdentifier(identifier, new ZendeskCallback<String>() {
        @Override
        public void onSuccess(String result) {
          registrationResult[0] = true;
        }
        @Override
        public void onError(ErrorResponse errorResponse) {
        }
      });
      return registrationResult[0];
    }

}
