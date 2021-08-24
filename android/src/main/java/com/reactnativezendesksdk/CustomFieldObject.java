package com.reactnativezendesksdk;

import java.util.HashMap;

import zendesk.support.CustomField;

public class CustomFieldObject {

  public Object value;

  public CustomFieldObject(HashMap<String, Object> object) {
    setFieldId(Long.parseLong((String) object.get("fieldId")));
    setValue(object.get("value"));
  }

  public void setFieldId(Long fieldId) {
    this.fieldId = fieldId;
  }

  public void setValue(Object value) {
    this.value = value;
  }

  public Long fieldId;

  public Long getFieldId() {
    return fieldId;
  }

  public Object getValue() {
    return value;
  }


  public CustomField toZendeskCustomField() {
    return new CustomField(this.fieldId, this.value);
  }
}
