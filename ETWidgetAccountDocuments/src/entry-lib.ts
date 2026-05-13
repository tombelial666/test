/**
 * Public TypeScript types exported from `@etna-widget/account-documents`.
 *
 * This file serves as the entry point for type definitions that consumers
 * of this widget can import for type safety and IDE autocompletion.
 *
 * IMPORTANT:
 * Keep this file free of imports from other packages so that
 * the generated `dist/entry-lib.d.ts` does not pull in external
 * type dependencies and cannot break consumer builds.
 */

/**
 * Locale code used by the widget (e.g. `"en-US"`, `"ru-RU"`).
 *
 * Kept as `string` here intentionally to avoid depending on
 * `@etna-widget/localization` types in the public `d.ts`.
 */
type WidgetLocale = string;

/**
 * The only public type exported from this package.
 */
export type AccountDocumentsWidgetProps = {
  apiUrl: string;
  apiKey: string;
  token?: string;
  accountNumber: string;
  styles?: string;
  isAscOrder?: boolean;
  locale?: WidgetLocale;
  localizationCdnUrl?: string;
};
