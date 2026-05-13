import { createContext, ParentComponent, useContext } from "solid-js";
import { HttpClient } from "app/services/httpClient";
import { AppApi } from "app/services/api/appApi";

type ApiContextProps = {
  apiUrl: string;
  apiKey: string;
  token?: string;
};

type ApiContext = {
  appApi: AppApi;
};

export const ApiContext = createContext<ApiContext>();
export const useApi = () => {
  const ctx = useContext(ApiContext);

  if (!ctx) throw new Error('Service context unreachable');
  return ctx;
};

export const ApiContextProvider: ParentComponent<ApiContextProps> = (props) => {
  const httpClient = new HttpClient({
    url: props.apiUrl,
    token: props.token,
    headers: {
      "Accept": "application/json",
      "Et-App-Key": props.apiKey,
    }
  });
  const appApi = new AppApi(httpClient);

  return (
    <ApiContext.Provider value={{ appApi }}>
      {props.children}
    </ApiContext.Provider>
  );
};
