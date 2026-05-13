import { DocumentsDataProviders, IMobileSettingsDto } from "app/services/contracts/mobileSettings";
import { SiebertProviderData } from "app/scenes/SiebertDocuments/types";

export const mobileSettingsMapper = (dto: IMobileSettingsDto): SiebertProviderData => {
  const parsedData: DocumentsDataProviders = JSON.parse(dto.Settings.documentsDataProviders);

  return {
    url: parsedData.Siebert.url,
    secretSalt: parsedData.Siebert.secretSalt,
    clientId: parsedData.Siebert.clientId,
  }
}
