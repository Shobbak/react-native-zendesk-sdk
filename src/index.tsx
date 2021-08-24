import { NativeModules } from 'react-native';
type CustomField = {
  fieldId: string;
  value: any;
};

type TicketRequestOptions = {
  ticketTitle?: string;
  ticketTags?: string[];
  ticketCustomFields?: CustomField[];
};
type User = {
  userToken?: string;
  email?: string;
  name?: string;
};

type Device = {
  deviceId: string;
  locale?: string;
};

export type SDKConfig = {
  appId: string;
  clientId: string;
  zendeskUrl: string;
  user?: {
    userToken: string;
  };
  device?: Device;
};

type HelpCenterOptions = {
  locale?: string;
  groupIds?: string[];
  groupType?: 'category' | 'section';
  labels?: string[];
  articleId?: string;
  hideContactSupport?: boolean;
  ticketRequest?: TicketRequestOptions;
};

type ZendeskSdkType = {
  initialize(config: SDKConfig): Promise<string>;
  setAnonymous(name: string, email: string): Promise<string>;
  setIdentity(user: User): Promise<string>;
  showNativeHelpCenter(options?: HelpCenterOptions): () => void;
  showTicketList(options?: {
    ticketRequest?: TicketRequestOptions;
  }): () => void;
  showTicket(ticketId: string): () => void;
  showNewTicketRequest(options?: {
    ticketRequest?: TicketRequestOptions;
  }): () => void;
};

const { ZendeskSdk } = NativeModules;

export default ZendeskSdk as ZendeskSdkType;
