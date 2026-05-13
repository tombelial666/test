import { Component, Show } from "solid-js";
import { useLocalization } from "@etna-widget/localization";
import { Button } from "app/components/Button/Button";
import styles from "./ErrorMessage.css?inline";

type Props = {
  refetch?: () => void;
};

export const ErrorMessage: Component<Props> = (props) => {
  const { t } = useLocalization();
  
  return (
    <div class="error-message">
      <style>{styles}</style>

      <div class="error-message__message">
        {t('somethingWentWrong')}
      </div>

      <Show when={props.refetch}>
        <Button
          text={t('reload')}
          onClick={props.refetch!}
        />
      </Show>
    </div>
  );
};
