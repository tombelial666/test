import { Component, For, createSignal } from "solid-js";
import { TableColumn, SortOrder } from "app/scenes/AccountDocuments/types";
import styles from "./TableHead.css?inline";

type Props = {
  columns: TableColumn[];
  onSortOrderChange: (params: SortOrder) => void;
}

type OrderParams = {
  field: string;
  order: "asc" | "desc";
}

export const TableHead: Component<Props> = (props) => {
  const [orderParams, setOrderParams] = createSignal<OrderParams>({
    field: "Date",
    order: "asc"
  })

  const handleSort = (field: string) => {
    const { field: currentField, order: currentOrder } = orderParams();

    const isSameField = currentField === field;
    const order = isSameField && currentOrder === "asc" ? "desc" : "asc";

    setOrderParams({ field, order } as OrderParams);
    props.onSortOrderChange({ sortBy: field, isAsc: order === 'asc' });
  };

  return (
    <>
      <style>{styles}</style>

      <thead class="table-head">
        <tr class="table-head__row">
          <For each={props.columns}>
            {(column) => (
              <th
                class="table-head__cell"
                classList={{'table-head__cell--pointer': column.sortable}}
                scope="col"
                onClick={() => column.sortable ? handleSort(column.key) : null}
              >
                <span class="table-head__label">{column.label}</span>
                {column.key === orderParams().field && (
                  <i class={`table-head__arrow table-head__arrow--${orderParams().order}`}></i>
                )}
              </th>
            )}
          </For>
        </tr>
      </thead>
    </>
  );
};