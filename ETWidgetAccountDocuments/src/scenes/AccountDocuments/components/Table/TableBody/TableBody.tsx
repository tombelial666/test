import { Component, For } from "solid-js";
import { TableColumn } from "app/scenes/AccountDocuments/types";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { TableRow } from "app/scenes/AccountDocuments/components/Table/TableBody/TableRow";
import styles from "./TableBody.css?inline";

type Props = {
  documents: IAccountDocumentsDto[];
  columns: TableColumn[];
};

export const TableBody: Component<Props> = (props) => {
  return (
    <>
      <style>{styles}</style>

      <tbody class="table-body">
        <For each={props.documents}>
          {(document) => (
            <TableRow
              document={document}
              columns={props.columns}
            />
          )}
        </For>
      </tbody>
    </>
  );
};
