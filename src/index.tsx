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

type CustomField = {
  fieldId: number;
  value: any;
};

type HelpCenterOptions = {
  locale?: string;
  groupIds?: number[];
  groupType?: 'category' | 'section';
  labels?: string[];
  articleId?: string;
  hideContactSupport?: boolean;
};

type ZendeskSdkType = {
  multiply(a: number, b: number): Promise<number>;
  initialize(config: SDKConfig): Promise<string>;
  setAnonymous(name: string, email: string): Promise<string>;
  setIdentity(user: User): Promise<string>;
  showNativeHelpCenter(options?: HelpCenterOptions): () => void;
  createTicket(
    title: string,
    body: string,
    tags: string[],
    customFields: CustomField[]
  ): () => void;
};

const { ZendeskSdk } = NativeModules;

export default ZendeskSdk as ZendeskSdkType;
