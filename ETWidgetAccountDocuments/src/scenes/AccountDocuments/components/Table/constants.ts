import { LocalizationHook } from '@etna-widget/localization';

export const typeNames = {
  AccountStatement: "Account Statement",
  TradeConfirmation: "Trade Confirmation",
  TaxForm: "Tax Form",
  ConfirmationLetter: "Confirmation Letter",
}

export const getLocalizedTypeNames = (t: LocalizationHook['t']) => ({
  AccountStatement: t('accountStatement'),
  TradeConfirmation: t('tradeConfirmation'),
  TaxForm: t('taxForm'),
  ConfirmationLetter: t('confirmationLetter'),
});
