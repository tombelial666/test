# Account Documents widget

## Summary
Project based on Vite, SolidJS, Typescript.

After the modified code gets into the dev branch, pipeline will automatically raise the npm version.

## Technologies Stack
- [Typescript](https://www.typescriptlang.org/)
- [SolidJS](https://www.solidjs.com/)
- [Vite](https://vitejs.dev/)
- node: 20.11.1
- npm 10.2.4

## Project local Installation
- Clone project
- Install dependencies
```
npm install
```
- Create *.env* file and copy the keys there from *.env.example*
- Fill in the fields with the necessary data in the *.env* file
- start the project
```
npm run dev
```

## Properties description

*apiUrl* - public api url for fetching data

*apiKey* - key for api, for fetching data

*token* - authorization token for api (optional, if you want to use credentials)

*accountNumber* - active account number of the user (ClearingAccount)

*isAscOrder* - sorting order (optional, default is true)

*styles* - to overriding styles to a widget (optional, support only css)

*locale* - localization locale (optional, default: "en-US")

*localizationCdnUrl* - URL for loading translations from CDN (optional, fallback to built-in translations)

## TypeScript Types

The widget exports TypeScript types that can be imported for type safety and IDE autocompletion.

### Importing Types

```typescript
import type { AccountDocumentsWidgetProps } from '@etna-widget/account-documents';
```

### Main Type

- **`AccountDocumentsWidgetProps`** - Main widget configuration/props type. Use this to type your widget props:
  ```typescript
  import type { AccountDocumentsWidgetProps } from '@etna-widget/account-documents';
  
  const props: AccountDocumentsWidgetProps = {
    apiUrl: 'https://api.example.com',
    apiKey: 'your-api-key',
    accountNumber: '123456',
    isAscOrder: true,
    // ... other optional props
  };
  ```

### Example Usage in React/Vue/Solid

```typescript
import type { AccountDocumentsWidgetProps } from '@etna-widget/account-documents';

// In your component
function MyComponent() {
  const widgetProps: AccountDocumentsWidgetProps = {
    apiUrl: process.env.API_URL,
    apiKey: process.env.API_KEY,
    accountNumber: '123456',
    isAscOrder: true,
  };
  
  return <account-documents-widget {...widgetProps} />;
}
```

## Usage

Add file *.npmrc* in project (if there is none) and add *npm registry*
```
registry=https://registry.npmjs.org/
@etna-trader:registry=https://pkgs.dev.azure.com/etnasoft/ETNA_TRADER/_packaging/trader-npm/npm/registry/
@etna-widget:registry=https://pkgs.dev.azure.com/etnasoft/ETNA_TRADER/_packaging/trader-npm/npm/registry/
always-auth=true
```

### Angular
In the Angular directory install the widget
```
npm install @etna-widget/account-documents@0.x.x
```

In the project use it in *.html* files
```html
    <account-documents-widget
      [apiUrl]="apiUrl"
      [apiKey]="apiKey"
      [token]="token"
      [accountNumber]="accountNumber"
      [isAscOrder]="isAscOrder"
      [styles]="styles"
      [locale]="currentLocale"
      [localizationCdnUrl]="localizationCdnUrl"
    >
    </account-documents-widget>
```

Add the path from the executable file that is in the *node_modules* to the *angular.json*

Import `CUSTOM_ELEMENTS_SCHEMA` from `@angular/core` and add this schema in `@NgModule.schema`

### React Native

The most suitable way to use a widget is to use its CDN and html template in the WebView.

CDN usage:
```
<script src="https://cdn-widgets.s3.amazonaws.com/account-documents/v{VERSION}/account-documents.umd.js"></script>
```

html template:
```html
    <WebView
      originWhitelist={["*"]}
      source={{
        baseUrl: "YOUR_BASE_URL",
        html: `
            <!DOCTYPE html>
            <html lang="en">
                <head>
                  <meta charset="utf-8" />
                  <meta name="viewport" content="width=device-width, initial-scale=1" />
                  <script src="https://cdn-widgets.s3.amazonaws.com/account-documents/account-documents.umd.js"></script>
                </head>
            
                <body>
                    <account-documents-widget
                      api-url="YOUR_API_URL"
                      api-key="YOUR_API_KEY"
                      token="YOUR_TOKEN"
                      account-number="YOUR_ACCOUNT_NUMBER"
                      is-asc-order="true"
                      styles="styles"
                      locale="en-US"
                      localization-cdn-url="YOUR_LOCALIZATION_CDN_URL"
                    >
                    </account-documents-widget>
                </body>
            </html>
          `,
      }}
    ></WebView>
```

Fill in all the properties in the widget.

YOUR_BASE_URL - this is the url from which the html template will be perceived as the main one and will be substituted in the header "origin" in the request.

#### ATTENTION:

*Be careful when you use the widget as web components, then use the property through the kebab case. In frameworks, don't forget that properties should be reactive.*

## Localization

The widget supports internationalization with flexible translation loading:

### How it works
- **CDN Loading**: If `localizationCdnUrl` is provided, the widget loads translations from `{cdnUrl}/{locale}.json`
- **Fallback**: If CDN fails or missing translations, uses built-in English translations
- **Partial Fallback**: Missing individual translation keys automatically fall back to built-in values

### Supported locale
- `en-US` - English (default)

### Translation keys used
- `reload` - "Reload data" button text
- `loadMore` - "Load more" button text
- `somethingWentWrong` - Error message when something goes wrong
- `gettingProperties` - Loading message for widget initialization
- `date` - "Date" table header
- `account` - "Account" table header
- `document` - "Document" table header
- `includeAccountStatements` - "Statements" filter checkbox
- `includeTaxForms` - "Tax Forms" filter checkbox
- `includeTradeConfirmations` - "Trade Confirmations" filter checkbox
- `accountStatement` - "Account Statement" document type
- `tradeConfirmation` - "Trade Confirmation" document type
- `taxForm` - "Tax Form" document type
- `inserts` - "Inserts" label for document attachments

### Example JSON structure
```json
{
  "reload": "Reload data",
  "loadMore": "Load more",
  "somethingWentWrong": "Something went wrong. Please contact support.",
  "gettingProperties": "Getting properties...",
  "date": "Date",
  "account": "Account",
  "document": "Document",
  "includeAccountStatements": "Statements",
  "includeTaxForms": "Tax Forms",
  "includeTradeConfirmations": "Trade Confirmations",
  "accountStatement": "Account Statement",
  "tradeConfirmation": "Trade Confirmation",
  "taxForm": "Tax Form",
  "inserts": "Inserts"
}
```

### Important Requirements When Working with Localization

When adding new text elements to components, you **MUST** follow these rules:

#### ✅ Check Localization Before Development

1. **Check existing keys** - ensure that the required localization keys already exist in the system
2. **Add missing keys** - if needed keys don't exist, add them to the localization files
3. **Use flat structure** - all keys should be in `camelCase` format without nesting (e.g., `validationRequired`, `documentType`)
4. **Update all localization files**

#### 🔍 Where to Check Current Localization

Current localization files are stored in **S3 bucket CDN**. Contact the **DevOps** team for access to the following files:
- `en-US.json` - English localization
- Other language files as needed
