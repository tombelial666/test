import { Component, Show } from "solid-js";
import { useLocalization } from "@etna-widget/localization";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { TableHead } from "app/scenes/AccountDocuments/components/Table/TableHead/TableHead";
import { TableColumn, SortOrder, DocumentType } from "app/scenes/AccountDocuments/types";
import { TableBody } from "app/scenes/AccountDocuments/components/Table/TableBody/TableBody";
import { getLocalizedTypeNames } from "./constants";
import {
  DocumentCellByType,
} from "app/scenes/AccountDocuments/components/Table/cells/DocumentCellByType/DocumentCellByType";
import { AccountNumber, ClearingFirm } from "app/types/common";
import { useApi } from "app/contexts/apiContext";
import styles from "./Table.css?inline";

type Props = AccountNumber & {
  accountId: number;
  showDocuments: boolean;
  documents?: IAccountDocumentsDto[];
  clearingFirm: ClearingFirm;
  onSortOrderChange: (params: SortOrder) => void;
};

export const Table: Component<Props> = (props) => {
  const { t } = useLocalization();
  const { appApi } = useApi();
  const localizedTypeNames = getLocalizedTypeNames(t);

  const handleFileLoad = async (doc: IAccountDocumentsDto) => {
    try {
      // InteliClear passes docId via the Url field (legacy behavior), so DocumentId may be absent.
      const response = await appApi.getDocumentById(props.accountId, doc.DocumentId ?? doc.Url);

      const url = window.URL.createObjectURL(response);
      const a = document.createElement('a');
      a.style.display = 'none';
      a.href = url;

      const date = new Date(doc.Date as string);

      let formattedDate: string;

      if (doc.Type === "TaxForm") {
          formattedDate = date.getUTCFullYear().toString();
      } else {
          const dateFormat: Intl.DateTimeFormatOptions = {
              year: "numeric",
              month: "long",
              ...(doc.Type === "TradeConfirmation" && { day: "numeric" }),
              timeZone: "UTC",
          };
          formattedDate = date.toLocaleDateString("en-US", dateFormat);
      }

      const prefix = localizedTypeNames[doc.Type] ?? doc.Type;

      a.download = `${prefix} ${formattedDate}.pdf`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      throw (error)
    }
  }

  const columns: TableColumn[] = [
    {
      key: "Date",
      label: t('date'),
      sortable: true,
      renderer: ({ cellData, rowData }) => {
        const date = new Date(cellData as string);

        if (rowData.Type === DocumentType.TaxForm) {
            return date.getUTCFullYear();
        }

        const statementsOptions: Intl.DateTimeFormatOptions =
          {
            year: 'numeric',
            month: 'short',
            timeZone: 'UTC',
          };

          const options: Intl.DateTimeFormatOptions =
          {
            weekday: 'short',
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            timeZone: 'UTC',
          };

        return date.toLocaleDateString('en-US', rowData.Type == DocumentType.AccountStatement ? statementsOptions : options);
      },
    },
    {
      key: "account",
      label: t('account'),
      sortable: true,
      renderer: () => props.accountNumber,
    },
    {
      key: "Type",
      label: t('document'),
      sortable: false,
      renderer: ({ rowData }) =>
        <DocumentCellByType
          document={rowData}
          clearingFirm={props.clearingFirm}
          onLoadFile={handleFileLoad}
        />,
    },
  ];

  return (
    <div class="table">
      <style>{styles}</style>

      <table class="table__documents">
        <TableHead
          columns={columns}
          onSortOrderChange={props.onSortOrderChange}
        />

        <Show when={props.showDocuments}>
          <TableBody
            documents={props.documents!}
            columns={columns}
          />
        </Show>
      </table>
    </div>
  );
};
