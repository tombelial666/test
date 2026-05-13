import {
  registerSpinnerAsWebComponent,
  SpinnerWebCmpAttrs,
  setTheme,
} from '@etna-trader/etna-ui';

const prefix = 'documents';

declare module 'solid-js' {
  namespace JSX {
    interface IntrinsicElements {
      ['documents-spinner']: SpinnerWebCmpAttrs;
    }
  }
}

export const initEtnaUi = (): void => {
  setTheme('light');
  registerSpinnerAsWebComponent(prefix);
};
