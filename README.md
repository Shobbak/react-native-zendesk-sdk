# react-native-zendesk-sdk

React Native ZndeskSDK Wrapper

## Installation

```sh
yarn install react-native-zendesk-sdk
```

## Usage

```js
import ZendeskSdk from "react-native-zendesk-sdk";

// ...

const result = await ZendeskSdk.initialize({
        appId: 'APP_ID',
        clientId: 'CLIENT_ID',
        zendeskUrl: 'YOUR_ZENDESK_DOMAIN',
        user: {
          userId: 9876789,
          locale: 'ar | en-us',
        },
      });
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
