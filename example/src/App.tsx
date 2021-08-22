import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import ZendeskSdk from 'react-native-zendesk-sdk';

export default function App() {
  React.useEffect(() => {
    ZendeskSdk.initialize({
      appId: '',
      clientId: '',
      zendeskUrl: 'https://shobbak.zendesk.com',
      user: {
        userId: '1',
        locale: 'ar',
      },
    }).then((res) => console.log(res));
  }, []);

  return (
    <View style={styles.container}>
      <Button
        title={'Open Help Center'}
        onPress={() => {
          ZendeskSdk.showNativeHelpCenter({});
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
