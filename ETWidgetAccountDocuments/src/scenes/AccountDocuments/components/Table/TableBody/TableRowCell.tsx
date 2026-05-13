import { Component } from "solid-js";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { TableColumn } from "app/scenes/AccountDocuments/types";
import styles from "./TableBody.css?inline";

type Props = {
  column: TableColumn;
  document: IAccountDocumentsDto;
};

export const TableRowCell: Component<Props> = (props) => {
  const cellData = props.document[props.column.key];

  const cellValue = props.column.renderer
    ? props.column.renderer({
      cellData,
      rowData: props.document,
    })
    : cellData;

  return (
    <>
      <style>{styles}</style>

      <td class="table-body__cell">
        {cellValue}
      </td>
    </>
  );
};
