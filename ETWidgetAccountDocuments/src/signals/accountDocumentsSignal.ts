import { createResource, createSignal, Resource, Accessor } from "solid-js";
import { QueryParams, SortOrder, mapDocumentTypesToCheckboxes } from "app/scenes/AccountDocuments/types";
import { AccountDocumentType, IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { getDateInPast } from "app/utils/date";
import { useApi } from "app/contexts/apiContext";

type Props = {
  accountId: number;
  isAscOrder?: boolean;
  availableDocumentTypes?: AccountDocumentType[] | null;
};

type Return = {
  refetch: () => void;
  documents: Resource<IAccountDocumentsDto[]>;
  queryParams: Accessor<QueryParams>;
  onFiltersChange: (name: keyof QueryParams, value: QueryParams[keyof QueryParams]) => void;
  onLoadMore: () => void;
  onSortOrderChange: (params: SortOrder) => void;
};

export function accountDocumentsSignal(props: Props): Return {
  const { appApi } = useApi();
  const availableCheckboxes = new Set(mapDocumentTypesToCheckboxes(props.availableDocumentTypes) ?? []);
  const showAllCheckboxes = availableCheckboxes.size === 0 && !props.availableDocumentTypes;

  const [queryParams, setQueryParams] = createSignal<QueryParams>({
    startDate: getDateInPast(new Date()),
    endDate: new Date().toISOString(),
    sortBy: "Date",
    isAsc: typeof props.isAscOrder === 'boolean' ? props.isAscOrder : true,
    includeAccountStatements: showAllCheckboxes || availableCheckboxes.has("includeAccountStatements"),
    includeTaxForms: showAllCheckboxes || availableCheckboxes.has("includeTaxForms"),
    includeTradeConfirmations: showAllCheckboxes || availableCheckboxes.has("includeTradeConfirmations"),
    includeConfirmationLetter: showAllCheckboxes || availableCheckboxes.has("includeConfirmationLetter"),
  });

  const [documents, { refetch }] = createResource(
    () => ({
      queryParamsPayload: queryParams(),
      accountId: props.accountId,
    }),
    async ({ queryParamsPayload, accountId }) => {
      try {
        return await appApi.getDocuments(
          queryParamsPayload,
          accountId,
        );
      } catch (error) {
        throw (error);
      }
  });

  const handleQueryParamsChange = (name: keyof QueryParams, value: QueryParams[keyof QueryParams]): void => {
    setQueryParams((filters) => ({
      ...filters,
      [name]: value,
    }));
  };

  const handleSortOrderQueryParamsChange = (params: SortOrder): void => {
    setQueryParams((filters) => ({
      ...filters,
      ...params
    }));
  };

  const handleLoadMore = (): void => {
    const reducedDate = new Date(queryParams().startDate);
    const newDate = getDateInPast(reducedDate);

    handleQueryParamsChange("startDate", newDate);
  };

  return {
    refetch,
    documents,
    queryParams,
    onFiltersChange: handleQueryParamsChange,
    onLoadMore: handleLoadMore,
    onSortOrderChange: handleSortOrderQueryParamsChange
  };
}
