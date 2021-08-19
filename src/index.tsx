import { NativeModules } from 'react-native';

type ZendeskSdkType = {
  multiply(a: number, b: number): Promise<number>;
};

const { ZendeskSdk } = NativeModules;

export default ZendeskSdk as ZendeskSdkType;
