export type ClearingFirm = "Siebert" | string;

export type AccountData = {
  accountId: number;
  clearingFirm: ClearingFirm;
}

export type AccountNumber = {
  accountNumber: string;
}

export enum UserRole {
  User = 1,
  AssetManager = 300,
  SuperVisor = 500,
  Admin = 1000,
}
