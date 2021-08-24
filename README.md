# react-native-zendesk-sdk

React Native ZendeskSDK Wrapper

## Installation

```sh
yarn add @shobbak/react-native-zendesk-sdk
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
          userToken: 'USER_TOKEN',
        },
        device:{
            devicId: 'DEVICE_IDENTIFIER',
            locale: 'ar',
        }
      });
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
