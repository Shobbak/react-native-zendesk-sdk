import { NativeModules } from 'react-native';

type User = {
  userId?: string;
  email?: string;
  name?: string;
};

type SDKConfig = {
  appId: string;
  clientId: string;
  zendeskUrl: string;
  user?: {
    userId: string;
    locale?: string;
  };
};

// type Request = {
//     title: string,
//     body: string,
//     tags: string[],
//     customFields: CustomField[]
// }
// type CustomField = {
//   fieldId: string;
//   value: string;
// };

type HelpCenterOptions = {
  locale?: string;
  groupIds?: string[];
  groupType?: 'category' | 'section';
  labels?: string[];
  articleId?: string;
  hideContactSupport?: boolean;
};

type ZendeskSdkType = {
  initialize(config: SDKConfig): Promise<string>;
  setAnonymous(name: string, email: string): Promise<string>;
  setIdentity(user: User): Promise<string>;
  showNativeHelpCenter(options?: HelpCenterOptions): () => void;
  // @TODO
  // createTicket(Request): () => void;
};

const { ZendeskSdk } = NativeModules;

export default ZendeskSdk as ZendeskSdkType;
