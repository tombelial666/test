import { IAccountDto } from "app/services/contracts/account";

export interface ITradingAccountDto extends Omit<IAccountDto, "Owners" | "DisplayAccountName" | "AccessType" | "Alias"> {
  AccountHolder: string;
  FirstName: string;
  LastName: string;
  Login: string;
}
