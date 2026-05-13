import { Component, Show, createMemo } from "solid-js";
import { LocalizationProvider, useLocalization } from "@etna-widget/localization";
import { ApiContextProvider } from "app/contexts/apiContext";
import { Provider } from "app/components/Provider/Provider";
import { accountDocumentsFallbackTranslations } from "app/utils/fallbackTranslations";
import type { AccountDocumentsWidgetProps } from "./entry-lib";
import styles from "./App.css?inline";

const AppContent: Component<AccountDocumentsWidgetProps> = (props) => {
  const { t } = useLocalization();
  
  // TODO: find solution to handle reactive props
  const accountDocumentsPropsInitialized = createMemo(() =>
    props.apiUrl
    && props.apiKey
    && props.accountNumber
  );

  return(
    <div class="app">
      <style>{styles}</style>

      <Show when={props.styles}>
        <style>{props.styles}</style>
      </Show>

      <Show
        when={accountDocumentsPropsInitialized()}
        fallback={(
          <div class="app__loading-wrapper">
            <documents-spinner title={t('gettingProperties')}/>
          </div>
        )}
      >
        <ApiContextProvider
          apiUrl={props.apiUrl}
          apiKey={props.apiKey}
          token={props.token}
        >
          <Provider
            accountNumber={props.accountNumber}
            isAscOrder={props.isAscOrder}
          />
        </ApiContextProvider>
      </Show>
    </div>
  );
};

const App: Component<AccountDocumentsWidgetProps> = (props) => {
  return(
    <LocalizationProvider
      locale={props.locale}
      cdnUrl={props.localizationCdnUrl}
      fallbackTranslations={accountDocumentsFallbackTranslations}
    >
      <AppContent {...props} />
    </LocalizationProvider>
  );
};

export default App;
