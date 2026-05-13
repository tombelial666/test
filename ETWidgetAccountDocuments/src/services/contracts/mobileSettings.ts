import { SiebertProviderData } from "app/scenes/SiebertDocuments/types";

export type IMobileSettingsDto = {
  Settings: Settings;
}

type Settings = {
  documentsDataProviders: string;
}

export type DocumentsDataProviders = {
  Siebert: SiebertProviderData;
}
