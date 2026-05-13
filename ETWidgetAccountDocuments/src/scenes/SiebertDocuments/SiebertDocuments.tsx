import { Component, createEffect, createSignal, Show } from "solid-js";
import { siebertDocumentsSignal } from "app/signals/siebertDocumentsSignal";
import { AccountNumber } from "app/types/common";
import styles from "./SiebertDocuments.css?inline";

export const SiebertDocuments: Component<AccountNumber> = (props) => {
  const [loading, setLoading] = createSignal<boolean>(true);

  const { iFrameUrl } = siebertDocumentsSignal({ accountNumber: props.accountNumber });

  let iFrameRef;

  createEffect(() => {
    iFrameRef.onload = () => {
      setLoading(false);
    };
  });

  return (
    <div class="siebert-documents">
      <style>{styles}</style>

      <Show when={loading() || iFrameUrl.loading}>
        <div class="siebert-documents__spinner-wrapper">
          <documents-spinner/>
        </div>
      </Show>

      <iframe
        ref={iFrameRef}
        class="siebert-documents__iframe"
        src={iFrameUrl()}
      />
    </div>
  );
};
