import { QueryParams } from "app/scenes/AccountDocuments/types";
import { IAccountDocumentsDto } from "app/services/contracts/accountDocuments";
import { IMobileSettingsDto } from "app/services/contracts/mobileSettings";
import { IAccountDto } from "app/services/contracts/account";
import { IUser } from "app/services/contracts/user";
import { PaginationResponse } from "app/types/paginationResponse";
import { ITradingAccountDto } from "app/services/contracts/tradingAccount";

export interface IHttpClient {
  get<T>(
    endpoint: string,
    params?: Record<string, string | boolean>,
  ): Promise<T>;
}

export interface IAppApi {
  getMe(): Promise<IUser>;
  getAllAccounts(accountNumber: string): Promise<PaginationResponse<ITradingAccountDto>>;
  getAccounts(): Promise<IAccountDto[]>;
  getMobileSettings(): Promise<IMobileSettingsDto>;
  getProviderSettings(providerName: string): Promise<Record<string, string>>;
  getDocuments(
    params: QueryParams,
    accountId: number,
  ): Promise<IAccountDocumentsDto[]>;
  getDocumentById(
    accountId: number,
    documentId: string,
  )
}

export type RequestMethod = "GET" | "POST" | "PUT" | "DELETE";
