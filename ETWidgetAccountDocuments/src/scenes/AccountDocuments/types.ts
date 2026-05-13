import { JSX } from "solid-js";
import { AccountDocumentType, IAccountDocumentsDto } from "app/services/contracts/accountDocuments";

export enum CheckboxTitles {
  includeAccountStatements = "Statements",
  includeTaxForms = "Tax Forms",
  includeTradeConfirmations = "Trade Confirmations",
  includeConfirmationLetter = "Confirmation Letter"
}

export type FilterCheckboxes = Record<keyof typeof CheckboxTitles, boolean>
export type FilterCheckbox = keyof typeof CheckboxTitles;

export type SortOrder = {
  sortBy: string;
  isAsc: boolean;
};

export type QueryParams = FilterCheckboxes & SortOrder & {
  startDate: string;
  endDate: string;
};

export type TableCellRendererType<T> = {
  cellData: T[keyof T];
  rowData: T;
}

export type TableColumn<T = IAccountDocumentsDto> = {
  key: string;
  label: string;
  sortable: boolean,
  renderer?: ({cellData, rowData}: TableCellRendererType<T>) => JSX.Element;
}

export const allFilterCheckboxes = Object.keys(CheckboxTitles) as FilterCheckbox[];

export const documentTypeToCheckbox: Record<AccountDocumentType, FilterCheckbox> = {
  AccountStatement: "includeAccountStatements",
  TaxForm: "includeTaxForms",
  TradeConfirmation: "includeTradeConfirmations",
  ConfirmationLetter: "includeConfirmationLetter",
};

export const mapDocumentTypesToCheckboxes = (
  documentTypes?: AccountDocumentType[] | null,
): FilterCheckbox[] | null => {
  if (!documentTypes) {
    return null;
  }

  return documentTypes.map((documentType) => documentTypeToCheckbox[documentType]);
};

export enum DocumentType {
  None = "None",
  AccountStatement = "AccountStatement",
  TaxForm = "TaxForm",
  TradeConfirmation = "TradeConfirmation",
  ConfirmationLetter = "ConfirmationLetter"
}
