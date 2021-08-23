package com.reactnativezendesksdk;

import android.app.Activity;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;

import zendesk.core.Identity;
import zendesk.core.JwtIdentity;
import zendesk.core.Zendesk;
import zendesk.support.CreateRequest;
import zendesk.support.CustomField;
import zendesk.support.Request;
import zendesk.support.RequestProvider;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.guide.HelpCenterConfiguration;

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

    try {
      String appId = options.getString("appId");
      String clientId = options.getString("clientId");
      String url = options.getString("zendeskUrl");
      if (appId.isEmpty() || clientId.isEmpty() || url.isEmpty()) {
        promise.reject("100", "Invalid parameters shared");
      }

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

    } catch (Exception exception) {
      promise.reject("100", exception.getMessage());
    }


  }

  @ReactMethod
  public void setUserIdentity(ReadableMap options) {
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  @ReactMethod
  public void showNativeHelpCenter(ReadableMap options) {

    try {
      Support.INSTANCE.setHelpCenterLocaleOverride(Locale.US);
      if (options.hasKey("locale")) {

        String locale = options.getString("locale");

        Support.INSTANCE.setHelpCenterLocaleOverride(new Locale(locale));

      }
    } catch (Exception exception) {
      System.out.println("Error: " + exception.getMessage());
    }

    try {
      Activity activity = getCurrentActivity();

      HelpCenterConfiguration.Builder activityBuilder = new HelpCenterConfiguration.Builder();

      if (options.hasKey("groupType") && options.hasKey("groupIds")) {
        List<Long> filterGroup = options.getArray("groupIds")
          .toArrayList()
          .stream()
          .map(object -> new Long((String) object))
          .collect(Collectors.toList());

        if (!filterGroup.isEmpty()) {
          switch (options.getString("groupType")) {
            case "category":
              activityBuilder = activityBuilder.withArticlesForCategoryIds(filterGroup);
              break;
            case "section":
              activityBuilder = activityBuilder.withArticlesForSectionIds(filterGroup);
              break;
            default:
              break;
          }
        }
      }

      if (options.hasKey("labels")) {
        activityBuilder = activityBuilder.withLabelNames(String.valueOf(options.getArray("labels").toArrayList()));
      }

      if (options.hasKey("hideContactSupport")) {
        activityBuilder = activityBuilder.withContactUsButtonVisible(!options.getBoolean("hideContactSupport"));
      }

      activityBuilder.show(activity);

    } catch (Exception exception) {

      System.out.println("Error: " + exception.getMessage());
    }

  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  @ReactMethod
  public void createTicket(String title, String body, ReadableArray tags, ReadableArray customFields, Promise promise) {
    CreateRequest request = new CreateRequest();

    request.setSubject(title);

    request.setDescription(body);

    request.setTags((List<String>) tags);

    // @TODO: Implement Custom Field
//    if (customFields != null) {
//      List<CustomField> parsedCustomFields = null;
//      customFields
//        .toArrayList()
//        .stream()
//        .map(fieldObject -> new CustomField(new Long(fieldObject.getString("fieldId")), fieldObject.getString("value")))
//        .forEach(parsedCustomFields::add);
//
//      if (parsedCustomFields != null) request.setCustomFields(parsedCustomFields);
//
//    }

    RequestProvider provider = Support.INSTANCE.provider().requestProvider();
    provider.createRequest(request, new ZendeskCallback<Request>() {
      @Override
      public void onSuccess(Request request) {
        promise.resolve(request);
      }

      @Override
      public void onError(ErrorResponse errorResponse) {
        promise.reject(errorResponse.getReason());
      }
    });

  }
  private boolean registerDevice(String identifier) {
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
