import {Component, Match, Show, splitProps, Switch, createMemo} from "solid-js";
import { AccountDocuments } from "app/scenes/AccountDocuments/AccountDocuments";
import { ErrorMessage } from "app/components/ErrorMessage/ErrorMessage";
import { SiebertDocuments } from "app/scenes/SiebertDocuments/SiebertDocuments";
import { providerDataSignal } from "app/signals/providerDataSignal";
import { providerSettingsSignal } from "app/signals/providerSettingsSignal";
import { AccountNumber } from "app/types/common";
import styles from "./Provider.css?inline";

type Props = AccountNumber & {
  isAscOrder?: boolean;
}

export const Provider: Component<Props> = (props) => {
  const [localProps, otherProps] = splitProps(props, ["isAscOrder"]);

  const {
    account,
    refetch,
  } = providerDataSignal(otherProps);
  const currentProvider = createMemo(() => account()?.clearingFirm);
  const isSiebertProvider = createMemo(() => currentProvider() === "Siebert");
  const { availableDocumentTypes } = providerSettingsSignal(currentProvider);
  const isLoading = createMemo(() =>
    account.loading || (account.state === "ready" && !isSiebertProvider() && availableDocumentTypes.state !== "ready")
  );

  return (
    <div class="provider">
      <style>{styles}</style>

      <Show when={isLoading()}>
        <div class="provider__position-wrapper">
          <documents-spinner title="Getting provider data..."/>
        </div>
      </Show>

      <Show when={account.error && !isLoading()}>
        <ErrorMessage refetch={refetch}/>
      </Show>

      <Show when={account.state === "ready" && (isSiebertProvider() || availableDocumentTypes.state === "ready")}>
        <Switch fallback={(
          <AccountDocuments
            accountNumber={props.accountNumber}
            accountId={account()!.accountId}
            clearingFirm={account()!.clearingFirm}
            availableDocumentTypes={availableDocumentTypes()}
            isAscOrder={localProps.isAscOrder}
          />
        )}>
          <Match when={account()!.clearingFirm === 'Siebert'}>
            <SiebertDocuments accountNumber={props.accountNumber}/>
          </Match>
        </Switch>
      </Show>
    </div>
  );
};
