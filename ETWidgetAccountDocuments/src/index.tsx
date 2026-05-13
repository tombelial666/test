import { customElement } from "solid-element";
import { initEtnaUi } from "app/ui-kit-init";
import { render } from "solid-js/web";
import App from "app/App";

initEtnaUi();

if (import.meta.env.DEV) {
  render(() => (
    <App
      apiUrl={import.meta.env.VITE_ACCOUNT_DOCUMENTS_URL}
      apiKey={import.meta.env.VITE_ACCOUNT_DOCUMENTS_API_KEY}
      token={import.meta.env.VITE_ACCOUNT_DOCUMENTS_TOKEN}
      accountNumber={import.meta.env.VITE_ACCOUNT_NUMBER}
    />
  ), document.getElementById('root') as HTMLElement);
} else {
  customElement('account-documents-widget', {
    accountNumber: "",
    apiUrl: "",
    apiKey: "",
    token: "",
    styles: undefined,
    isAscOrder: undefined,
    locale: undefined,
    localizationCdnUrl: undefined,
  }, App);
}
