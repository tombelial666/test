import { Component, Switch, Match, Show, For, createSignal } from "solid-js";
import { useLocalization } from "@etna-widget/localization";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { ClearingFirm } from "app/types/common";
import styles from "./DocumentCellByType.css?inline";

type Props = {
  document: IAccountDocumentsDto;
  clearingFirm: ClearingFirm;
  onLoadFile: (document: IAccountDocumentsDto) => void;
};

export const DocumentCellByType: Component<Props> = (props) => {
  const { t } = useLocalization();
  const [loading, setLoading] = createSignal<boolean>(false);

  const handleDocumentLinkClick = async (document: IAccountDocumentsDto) => {
    if (props.clearingFirm === 'InteliClear') {
      setLoading(true);

      try {
        await props.onLoadFile(document);
      } finally {
        setLoading(false);
      }

      return;
    }

    // Url takes priority over DocumentId.
    // DocumentId is only used when Url is absent (server sends one or the other, not both).
    if (!document.Url && document.DocumentId) {
      setLoading(true);

      try {
        await props.onLoadFile(document);
      } finally {
        setLoading(false);
      }

      return;
    }

    window.open(document.Url, "_blank");
  }

  return (
    <div class="document-cell">
      <style>{styles}</style>

      <Show
        when={!loading()}
        fallback={(<documents-spinner size="s" />)}
      >
        <a
          class="document-cell__link"
          onClick={() => handleDocumentLinkClick(props.document)}
        >
          <Switch>
            <Match when={props.document.Type === "TaxForm"}>
              {t('taxForm')} {props.document.Code}
            </Match>
            <Match when={props.document.Type === "TradeConfirmation"}>
              {t('tradeConfirmation')}
            </Match>
            <Match when={props.document.Type === "AccountStatement"}>
              {t('accountStatement')}
            </Match>
            <Match when={props.document.Type === "ConfirmationLetter"}>
              {t('confirmationLetter')}
            </Match>
          </Switch>
        </a>

        <Show when={props.document.Inserts.length > 0}>
          <div class="document-cell__insert">
            {t('inserts')}:

            <For each={props.document.Inserts}>
              {(insert, index) => (
                <a
                  class="document-cell__link document-cell__link--indent"
                  href={insert}
                  target="_blank"
                >
                  {index() + 1}
                </a>
              )}
            </For>
          </div>
        </Show>
      </Show>
    </div>
  );
};
