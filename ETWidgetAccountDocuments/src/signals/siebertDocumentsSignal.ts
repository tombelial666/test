import { createResource, Resource } from "solid-js";
import { AccountNumber } from "app/types/common";
import { mobileSettingsMapper } from "app/utils/mappers/mobileSettingsMapper";
import { useApi } from "app/contexts/apiContext";
import * as CryptoJS from "crypto-js";

type Return = {
  iFrameUrl: Resource<string>;
};

export function siebertDocumentsSignal(props: AccountNumber): Return {
  const { appApi } = useApi();

  const timeRoundingProcess = (): string => {
    const currentTime = new Date();

    currentTime.setUTCSeconds(0);
    const minutesUTC = currentTime.getUTCMinutes();
    const roundedMinutes = minutesUTC - (minutesUTC % 5);
    currentTime.setUTCMinutes(roundedMinutes);

    const day = currentTime.toLocaleString("en-US", {
      timeZone: "UTC",
      month: "2-digit",
      day: "2-digit",
      year: "numeric",
    });

    const time = currentTime.toLocaleString("en-US", {
      timeZone: "UTC",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: false,
    });

    return `${day} ${time}`;
  };

  const [iFrameUrl, { refetch }] = createResource(
    () => props.accountNumber,
    async (accountNumber) => {
      try {
        const response = await appApi.getMobileSettings();
        const mappedSettings = mobileSettingsMapper(response);

        const roundedUTCTime = timeRoundingProcess();
        const valueForHashing = props.accountNumber + roundedUTCTime + mappedSettings.secretSalt;
        const hashToken = CryptoJS.SHA1(valueForHashing).toString();

        return `${mappedSettings.url}/?clientId=${mappedSettings.clientId}&account=${accountNumber}&hashedstring=${hashToken}`;
      } catch (error) {
        throw (error);
      }
    },
  );

  return {
    iFrameUrl,
  };
}
