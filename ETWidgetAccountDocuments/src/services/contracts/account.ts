import { ClearingFirm } from "app/types/common";

export interface IAccountDto {
  Id: number;
  ClearingAccount: string;
  AccessType: string;
  MarginType: string;
  Enabled: boolean;
  Alias: string;
  ClearingFirm: ClearingFirm;
  DisplayAccountName: string;
  OwnerType: string;
}
