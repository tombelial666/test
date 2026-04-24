-- TC-02: two sub-accounts under one base
SELECT ClearingAccountNumber, BaseClearingAccountNumber, Path, Type, GeneratedForDate, CreatedAt
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE BaseClearingAccountNumber = :base_account
ORDER BY ClearingAccountNumber, CreatedAt DESC;

-- TC-04 guard: ensure selected E/F are Fidelity in Account table
SELECT a.Id, a.ClearingAccount, a.ClearingFirm
FROM [etna_trader.ci-int-2.demo.etna].[dbo].[Account] a
WHERE a.ClearingAccount IN (:account_e, :account_f);

-- TC-03: dedup (no new rows in invoke window)
SELECT COUNT(*) AS rows_in_window
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE CreatedAt BETWEEN :invoke_start_utc AND :invoke_end_utc;

-- TC-03: by exact key/account
SELECT COUNT(*) AS row_count
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE ClearingAccountNumber = :clearing_account
  AND Path = :s3_key_path;

-- TC-05: migration/legacy sanity
SELECT COUNT(*) AS null_base_count
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE BaseClearingAccountNumber IS NULL;

-- TC-05: sample for manual verification of base derivation
SELECT TOP 100 ClearingAccountNumber, BaseClearingAccountNumber, CreatedAt
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
ORDER BY CreatedAt DESC;

-- TC-06: non-Fidelity identity
SELECT TOP 50 ClearingAccountNumber, BaseClearingAccountNumber, Type, Path, CreatedAt
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE ClearingAccountNumber = :non_fidelity_account
ORDER BY CreatedAt DESC;

-- TC-07: E-only edge (expect E present, no synthetic F)
SELECT ClearingAccountNumber, BaseClearingAccountNumber, Path, CreatedAt
FROM [et.ams.ci-int-2.demo.etna].[dbo].[S3AccountDocumentInfos]
WHERE BaseClearingAccountNumber = :base_account
  AND CreatedAt BETWEEN :invoke_start_utc AND :invoke_end_utc
ORDER BY CreatedAt DESC, ClearingAccountNumber;
