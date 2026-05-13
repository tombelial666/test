import { Component, createMemo, Show, splitProps } from "solid-js";
import { useLocalization } from "@etna-widget/localization";
import { accountDocumentsSignal } from "app/signals/accountDocumentsSignal";
import {
  Table,
} from "app/scenes/AccountDocuments/components/Table/Table";
import { Filters } from "app/scenes/AccountDocuments/components/Filters/Filters";
import { ErrorMessage } from "app/components/ErrorMessage/ErrorMessage";
import { Button } from "app/components/Button/Button";
import { AccountNumber, ClearingFirm } from "app/types/common";
import { AccountDocumentType } from "app/services/contracts/accountDocuments";
import { mapDocumentTypesToCheckboxes } from "app/scenes/AccountDocuments/types";
import styles from "./AccountDocuments.css?inline";

type Props = AccountNumber & {
  accountId: number;
  clearingFirm: ClearingFirm;
  availableDocumentTypes?: AccountDocumentType[] | null;
  isAscOrder?: boolean;
}

export const AccountDocuments: Component<Props> = (props) => {
  const { t } = useLocalization();
  const [localProps, otherProps] = splitProps(props, ["accountNumber"]);
  const availableCheckboxes = createMemo(() => mapDocumentTypesToCheckboxes(otherProps.availableDocumentTypes));

  const {
    refetch,
    documents,
    queryParams,
    onFiltersChange,
    onLoadMore,
    onSortOrderChange
  } = accountDocumentsSignal(otherProps);

  const isReady = createMemo(() => documents.state === "ready");

  return (
    <div class="account-documents">
      <style>{styles}</style>

      <Filters
        queryParams={queryParams}
        availableCheckboxes={availableCheckboxes()}
        onFiltersChange={onFiltersChange}
      />

      <Table
        documents={documents()}
        accountNumber={localProps.accountNumber}
        showDocuments={isReady() || !documents.error}
        clearingFirm={otherProps.clearingFirm}
        accountId={otherProps.accountId}
        onSortOrderChange={onSortOrderChange}
      />

      <Show when={documents.loading}>
        <div class="account-documents__position-wrapper">
          <documents-spinner/>
        </div>
      </Show>

      <Show when={documents.error && !documents.loading}>
        <ErrorMessage refetch={refetch}/>
      </Show>

      <Show when={isReady()}>
        <div class="account-documents__position-wrapper">
          <Button
            text={t('loadMore')}
            onClick={onLoadMore}
          />
        </div>
      </Show>
    </div>
  );
};
