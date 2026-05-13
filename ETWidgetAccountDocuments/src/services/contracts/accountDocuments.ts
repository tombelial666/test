export interface IAccountDocumentsDto {
  Date: string;
  Type: AccountDocumentType;
  Code: string;
  Url: string;
  DocumentId?: string;
  Inserts: string[];
}

export type AccountDocumentType = "AccountStatement" | "TaxForm" | "TradeConfirmation" | "ConfirmationLetter";
