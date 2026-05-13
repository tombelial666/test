import { Component, For } from "solid-js";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { TableColumn } from "app/scenes/AccountDocuments/types";
import { TableRowCell } from "app/scenes/AccountDocuments/components/Table/TableBody/TableRowCell";
import styles from "./TableBody.css?inline";

type Props = {
  document: IAccountDocumentsDto;
  columns: TableColumn[];
};

export const TableRow: Component<Props> = (props) => {
  return (
    <>
      <style>{styles}</style>

      <tr class="table-body__row">
        <For each={props.columns}>
          {(column) => (
            <TableRowCell
              document={props.document}
              column={column}
            />
          )}
        </For>
      </tr>
    </>
  );
};
