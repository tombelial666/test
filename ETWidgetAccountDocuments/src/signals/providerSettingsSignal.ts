import { createResource, Accessor, Resource } from "solid-js";
import { AccountDocumentType } from "app/services/contracts/accountDocuments";
import { providerSettingsMapper } from "app/utils/mappers/providerSettingsMapper";
import { useApi } from "app/contexts/apiContext";

type Return = {
  availableDocumentTypes: Resource<AccountDocumentType[] | null>;
};

export function providerSettingsSignal(providerName: Accessor<string | undefined>): Return {
  const { appApi } = useApi();

  const [availableDocumentTypes] = createResource(
    providerName,
    async (currentProviderName) => {
      if (!currentProviderName) {
        return null;
      }

      try {
        const settings = await appApi.getProviderSettings(currentProviderName);
        return providerSettingsMapper(settings);
      } catch {
        return null;
      }
    },
  );

  return {
    availableDocumentTypes,
  };
}
