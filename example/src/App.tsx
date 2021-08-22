import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import ZendeskSdk from 'react-native-zendesk-sdk';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    ZendeskSdk.multiply(3, 7).then(setResult);
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
      <Button
        title={'Open Help Center'}
        onPress={() => {
          // ZendeskSdk.showNativeHelpCenter();
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
