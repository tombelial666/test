import { AccountDocumentType } from "app/services/contracts/accountDocuments";

const availableDocumentTypesKey = "AccountDocuments.AvailableDocumentTypes";
const supportedDocumentTypes: AccountDocumentType[] = [
  "AccountStatement",
  "TaxForm",
  "TradeConfirmation",
  "ConfirmationLetter",
];

export const providerSettingsMapper = (
  settings?: Record<string, string> | null,
): AccountDocumentType[] | null => {
  const rawValue = settings?.[availableDocumentTypesKey];

  if (!rawValue) {
    return null;
  }

  try {
    const parsedValue = JSON.parse(rawValue);

    if (!Array.isArray(parsedValue)) {
      return null;
    }

    const availableDocumentTypes = parsedValue.filter((value): value is AccountDocumentType =>
      supportedDocumentTypes.includes(value as AccountDocumentType)
    );

    if (parsedValue.length > 0 && availableDocumentTypes.length === 0) {
      return null;
    }

    return availableDocumentTypes;
  } catch {
    return null;
  }
};
