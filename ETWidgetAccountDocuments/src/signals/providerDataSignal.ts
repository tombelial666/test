import { AccountData, AccountNumber, UserRole } from "app/types/common";
import { createResource, Resource } from "solid-js";
import { accountMapper } from "app/utils/mappers/accountMapper";
import { useApi } from "app/contexts/apiContext";

type Return = {
  refetch: () => void;
  account: Resource<AccountData>;
};

export function providerDataSignal(props: AccountNumber): Return {
  const { appApi } = useApi();

  const [account, { refetch }] = createResource(
    () => props.accountNumber,
    async (accountNumber) => {
      try {
        const user = await appApi.getMe();

        let accountsList;
        if (user.Role === UserRole.Admin) {
          const { Result } = await appApi.getAllAccounts(accountNumber);
          accountsList = Result;
        } else {
          accountsList = await appApi.getAccounts();
        }

        const currentAccount = accountsList.find((account) => account.ClearingAccount === accountNumber);

        return accountMapper(currentAccount!);
      } catch (error) {
        throw (error);
      }
    },
  );

  return {
    refetch,
    account,
  };
}
