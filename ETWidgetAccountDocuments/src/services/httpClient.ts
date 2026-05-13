import { IHttpClient, RequestMethod } from "app/services/contracts/common";

type ApiParams = {
  url: string;
  headers: HeadersInit;
  token?: string;
}

export class HttpClient implements IHttpClient {
  private readonly headers: HeadersInit;
  private readonly basePathname: string;
  private readonly url;

  constructor({
    url,
    headers,
    token,
  }: ApiParams) {
    this.url = new URL(url);
    this.basePathname = this.url.pathname;
    this.headers = headers;

    if (token) {
      this.headers = {
        ...this.headers,
        "Authorization": `Bearer ${token}`,
      }
    }
  }

  public async get<T>(
    endpoint: string,
    params?: Record<string, string | number | boolean>,
  ): Promise<T> {
    return this.request<T>(
      endpoint,
      'GET',
      undefined,
      params,
    );
  }

  private async request<T>(
    endpoint: string,
    method: RequestMethod,
    data?: Record<string, string | number | boolean | object>,
    params?: Record<string, string | number | boolean>,
  ): Promise<T> {
    try {
      this.url.search = this.getSearchParams(params);

      this.url.pathname = this.basePathname + endpoint;

      const requestInit: RequestInit = {
        method,
        headers: this.headers,
        credentials: "include",
      };

      if (data) {
        requestInit.body = JSON.stringify(data);
      }

      const response = await fetch(this.url, requestInit);

      if (!response.ok) {
        throw new Error(response.statusText);
      }

      const contentType = response.headers.get("content-type");
      if (contentType === "application/pdf") {
        return await response.blob() as T;
      }

      return await response.json();
    } catch (e) {
      throw e;
    }
  }

  private getSearchParams(params?: Record<string, string | number | boolean>) {
    if (params) {
      const searchParams = new URLSearchParams();

      Object.keys(params).forEach((key) => {
        searchParams.set(key, params[key].toString());
      });

      return searchParams;
    }

    return "";
  }
}
