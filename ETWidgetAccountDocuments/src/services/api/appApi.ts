import { IAppApi } from "app/services/contracts/common";
import { IAccountDto } from "app/services/contracts/account";
import { IMobileSettingsDto } from "app/services/contracts/mobileSettings";
import { QueryParams } from "app/scenes/AccountDocuments/types";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { HttpClient } from "app/services/httpClient";
import { IUser } from "app/services/contracts/user";
import { PaginationResponse } from "app/types/paginationResponse";
import { ITradingAccountDto } from "app/services/contracts/tradingAccount";

export class AppApi implements IAppApi {
  constructor(protected readonly httpClient: HttpClient) {}

  public getMe(): Promise<IUser> {
    const endpoint = "/users/@me/info";
    return this.httpClient.get<IUser>(endpoint);
  }

  public getAllAccounts(accountNumber: string): Promise<PaginationResponse<ITradingAccountDto>> {
    const queryParams = {
      pageNumber: 0,
      pageSize: 1,
      filter: `ClearingAccount='${accountNumber}'`,
    }

    const endpoint = "/accounts/all";
    return this.httpClient.get<PaginationResponse<ITradingAccountDto>>(endpoint, queryParams);
  }

  public getAccounts(): Promise<IAccountDto[]> {
    const endpoint = "/users/@me/accounts";
    return this.httpClient.get<IAccountDto[]>(endpoint);
  }

  public getMobileSettings(): Promise<IMobileSettingsDto> {
    const endpoint = "/applications/mobile/settings";
    return this.httpClient.get<IMobileSettingsDto>(endpoint);
  }

  public getProviderSettings(providerName: string): Promise<Record<string, string>> {
    const endpoint = `/ams/settings/providers/${encodeURIComponent(providerName)}`;
    return this.httpClient.get<Record<string, string>>(endpoint);
  }

  public getDocuments(
    params: QueryParams,
    accountId: number,
  ): Promise<IAccountDocumentsDto[]> {
    const endpoint = `/accounts/${accountId}/edocs/`;

    return this.httpClient.get<IAccountDocumentsDto[]>(
      endpoint,
      params,
    );
  }

  public getDocumentById(
    accountId: number,
    edocId: string,
  ) {
    const endpoint = `/accounts/${accountId}/edocs/${edocId}`;
    return this.httpClient.get<Blob>(endpoint);
  }
}
