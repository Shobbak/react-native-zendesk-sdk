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
        appId: '',
        clientId: '',
        zendeskUrl: 'https://shobbak.zendesk.com',
        user: {
          userId: user.id,
          locale: 'ar',
        },
      });
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
