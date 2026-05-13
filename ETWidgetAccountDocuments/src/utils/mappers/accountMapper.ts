import { IAccountDto } from "app/services/contracts/account";
import { AccountData } from "app/types/common";
import { ITradingAccountDto } from "app/services/contracts/tradingAccount";

export const accountMapper = (dto: IAccountDto | ITradingAccountDto): AccountData => {
  return {
    accountId: dto.Id,
    clearingFirm: dto.ClearingFirm,
  }
}
