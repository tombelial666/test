2026-04-08 11:48:33.159 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:48:33.175 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39419 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:48:33.175 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:48:33.206 +00:00 [ERR] Paper trading clearing action failed to update account 40127 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:48:33.206 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:48:40.233 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0322440. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:48:51.222 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0180920. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:00.167 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0180158. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:01.638 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0287326. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:03.170 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20625 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:49:03.170 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:49:03.186 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39420 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:49:03.186 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:49:03.217 +00:00 [ERR] Paper trading clearing action failed to update account 40128 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:49:03.217 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:49:11.245 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0076983. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:22.245 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0140979. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:31.207 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0268149. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:32.678 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0267172. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:33.178 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20626 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:49:33.178 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:49:33.193 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39421 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:49:33.193 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:49:33.225 +00:00 [ERR] Paper trading clearing action failed to update account 40129 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:49:33.225 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:49:42.280 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0206490. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:49:53.282 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0257654. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:00.054 +00:00 [INF] Action event execution: "FCStone UpdateAccount" [Etna.Trading.Oms.Actions.ActionManager]
2026-04-08 11:50:00.054 +00:00 [INF] Start action "FCStone UpdateAccount", Date: 04/08/2026 11:50:00 [Etna.Trading.Oms.Actions.ActionManager]
2026-04-08 11:50:00.054 +00:00 [INF] Loading file from SFTP sftp://mft.stonex.com:22/home/etna/sftp/backend/fcstone_tests/Accounts_20260408.csv to "C:\Deployment\Etna\Clearing\FCStone\20260408\Accounts_20260408.csv" [Etna.Trading.Oms.Clearing.StartOfDay.SftpFileLoader]
2026-04-08 11:50:02.243 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0254565. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:03.181 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20627 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:50:03.181 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:50:03.197 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39422 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:50:03.197 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:50:03.228 +00:00 [ERR] Paper trading clearing action failed to update account 40130 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:50:03.228 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:50:03.713 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0273066. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:05.380 +00:00 [ERR] Error occured during processing action "FCStone UpdateAccount". Error: "Permission denied (password)." [Etna.Trading.Oms.Actions.ActionManager]
Renci.SshNet.Common.SshAuthenticationException: Permission denied (password).
   at Renci.SshNet.ClientAuthentication.Authenticate(IConnectionInfoInternal connectionInfo, ISession session)
   at Renci.SshNet.ConnectionInfo.Authenticate(ISession session, IServiceFactory serviceFactory)
   at Renci.SshNet.Session.Connect()
   at Renci.SshNet.BaseClient.CreateAndConnectSession()
   at Renci.SshNet.BaseClient.Connect()
   at Etna.Trading.Oms.Clearing.StartOfDay.SftpFileLoader.<LoadFileAsync>d__9.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\FileLoaders\Sources\SftpFileLoader.cs:line 79
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Trading.Oms.Clearing.StartOfDay.SingleFileClearingProvider`2.<ReadFileAsync>d__8`1.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\Providers\SingleFileClearingProvider.cs:line 48
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Trading.Oms.Clearing.StartOfDay.SingleFileClearingProvider`2.<GetDataAsync>d__7.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\Providers\SingleFileClearingProvider.cs:line 0
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Trading.Oms.Clearing.StartOfDay.FCStone.UpdateAccountProvider.<GetDataAsync>d__13.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\FCStone\UpdateAccount\UpdateAccountProvider.cs:line 84
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Common.Extensions.AsyncExtensions.Sync[T](Task`1 task)
   at Etna.Trading.Oms.Clearing.StartOfDay.FCStone.UpdateAccountProvider.GetData(DateTime eventDate) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\FCStone\UpdateAccount\UpdateAccountProvider.cs:line 53
   at Etna.Trading.Oms.Actions.ActionManager.ProcessProvider(ActionEvent actionEvent, ActionProviderStatus actionProviderStatus) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Actions\ActionManager.cs:line 453
2026-04-08 11:50:05.395 +00:00 [INF] Action event execution: "FCStone Positions" [Etna.Trading.Oms.Actions.ActionManager]
2026-04-08 11:50:05.395 +00:00 [INF] Start action "FCStone Positions", Date: 04/08/2026 11:50:05 [Etna.Trading.Oms.Actions.ActionManager]
2026-04-08 11:50:05.395 +00:00 [INF] Loading file from SFTP sftp://mft.stonex.com:22/home/etna/sftp/backend/fcstone_tests/Positions_20260408.csv to "C:\Deployment\Etna\Clearing\FCStone\20260408\Positions_20260408.csv" [Etna.Trading.Oms.Clearing.StartOfDay.SftpFileLoader]
2026-04-08 11:50:10.870 +00:00 [ERR] Error occured during processing action "FCStone Positions". Error: "Permission denied (password)." [Etna.Trading.Oms.Actions.ActionManager]
Renci.SshNet.Common.SshAuthenticationException: Permission denied (password).
   at Renci.SshNet.ClientAuthentication.Authenticate(IConnectionInfoInternal connectionInfo, ISession session)
   at Renci.SshNet.ConnectionInfo.Authenticate(ISession session, IServiceFactory serviceFactory)
   at Renci.SshNet.Session.Connect()
   at Renci.SshNet.BaseClient.CreateAndConnectSession()
   at Renci.SshNet.BaseClient.Connect()
   at Etna.Trading.Oms.Clearing.StartOfDay.SftpFileLoader.<LoadFileAsync>d__9.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\FileLoaders\Sources\SftpFileLoader.cs:line 79
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Trading.Oms.Clearing.StartOfDay.SingleFileClearingProvider`2.<ReadFileAsync>d__8`1.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\Providers\SingleFileClearingProvider.cs:line 48
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Trading.Oms.Clearing.StartOfDay.SingleFileClearingProvider`2.<GetDataAsync>d__7.MoveNext() in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\Infrastructure\Providers\SingleFileClearingProvider.cs:line 0
--- End of stack trace from previous location where exception was thrown ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at Etna.Common.Extensions.AsyncExtensions.Sync[T](Task`1 task)
   at Etna.Trading.Oms.Clearing.StartOfDay.FCStone.PositionSecurityProvider.GetData(DateTime eventDate) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Components\Etna.Trading.Oms.Clearing\StartOfDay\FCStone\Positions\PositionSecurityProvider.cs:line 0
   at Etna.Trading.Oms.Actions.ActionManager.ProcessProvider(ActionEvent actionEvent, ActionProviderStatus actionProviderStatus) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Actions\ActionManager.cs:line 453
2026-04-08 11:50:13.294 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0127459. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:24.319 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0283850. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:33.190 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20628 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:50:33.190 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:50:33.206 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39423 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:50:33.206 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:50:33.237 +00:00 [ERR] Paper trading clearing action failed to update account 40131 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:50:33.237 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:50:33.269 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0227350. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:34.738 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0227300. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:44.326 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0238999. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:50:55.344 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0119043. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:03.194 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20629 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:51:03.194 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:51:03.210 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39424 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:51:03.210 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:51:03.241 +00:00 [ERR] Paper trading clearing action failed to update account 40132 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:51:03.241 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:51:04.305 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0275084. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:05.781 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0327160. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:15.352 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0097034. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:20.377 +00:00 [INF] AccountContext is being removed from cache: AccountId=6 [Etna.Trading.Oms.Account.AccountContextManager]
2026-04-08 11:51:26.375 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0159273. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:33.162 +00:00 [ERR] error occur in OmsService_62306601_33370224_29686071ContractProxy_OmsContractProxy service: [Etna.Common.Service.LogErrorHandler]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetByUserId(Int32 userId, Nullable`1 accountAccessType) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 837
   at SyncInvokeIAccountDataGetUserAccounts(Object , Object[] , Object[] )
   at System.ServiceModel.Dispatcher.SyncMethodInvoker.Invoke(Object instance, Object[] inputs, Object[]& outputs)
   at System.ServiceModel.Dispatcher.DispatchOperationRuntime.InvokeBegin(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage5(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage11(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.MessageRpc.Process(Boolean isOperationContextSet)
ClientConnectionId:2fa97390-48bd-4d6f-9c81-d1bcea88958c
Error Number:-2,State:0,Class:11
2026-04-08 11:51:33.209 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20630 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:51:33.209 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:51:33.224 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39425 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:51:33.224 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:51:33.255 +00:00 [ERR] Paper trading clearing action failed to update account 40133 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:51:33.255 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.AccountContextManager.CreateAccountContext(Int32 accountId) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 328
   at Etna.Trading.Oms.Account.AccountContextManager.GetAccountContext(Int32 accountId, Boolean create) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\AccountContextManager.cs:line 129
   at Etna.Trading.Oms.Account.Action.PaperTradingClearingAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\PaperTradingClearingAction.cs:line 74
ClientConnectionId:9a463cd9-c8fd-4c7c-ba6c-b30538f67aa9
Error Number:-2,State:0,Class:11
2026-04-08 11:51:35.335 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://mg.ci-int-2.demo.etna.projects.etna.etnasoft.com:8016/. The connection attempt lasted for a time span of 00:00:21.0158833. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8016. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:36.805 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://staging.cboe.mghub.projects.etna.etnasoft.com:9056/. The connection attempt lasted for a time span of 00:00:21.0144809. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.156.0.78:9056. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:46.370 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:9954/. The connection attempt lasted for a time span of 00:00:21.0114272. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:9954. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:51:50.018 +00:00 [ERR] error occur in OmsService_62306601_33370224_29686071ContractProxy_OmsContractProxy service: [Etna.Common.Service.LogErrorHandler]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetByUserId(Int32 userId, Nullable`1 accountAccessType) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 837
   at SyncInvokeIAccountDataGetUserAccounts(Object , Object[] , Object[] )
   at System.ServiceModel.Dispatcher.SyncMethodInvoker.Invoke(Object instance, Object[] inputs, Object[]& outputs)
   at System.ServiceModel.Dispatcher.DispatchOperationRuntime.InvokeBegin(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage5(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.ImmutableDispatchRuntime.ProcessMessage11(MessageRpc& rpc)
   at System.ServiceModel.Dispatcher.MessageRpc.Process(Boolean isOperationContextSet)
ClientConnectionId:8488bde1-c58e-475a-9832-e4687018f7e5
Error Number:-2,State:0,Class:11
2026-04-08 11:51:57.398 +00:00 [WRN] Unable connect to remote host. "Could not connect to net.tcp://host.staging.mghub.projects.etna.etnasoft.com:8040/. The connection attempt lasted for a time span of 00:00:21.0152008. TCP error code 10060: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond 10.77.77.135:8040. " [Etna.Common.Service.ServiceProxyBase`1[[ContractProxy_IMessageSender, ProxyAssembly_e322cc95-61d3-4460-a8f5-42ea95597a67, Version=1.0.15356.1, Culture=neutral, PublicKeyToken=null]]]
2026-04-08 11:52:03.218 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 20631 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:52:03.218 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:58d294bd-1de0-499c-aeb2-41e25a181366
Error Number:-2,State:0,Class:11
2026-04-08 11:52:03.233 +00:00 [ERR] UnclearedFundsMaintenance action failed to update account 39426 [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
2026-04-08 11:52:03.233 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task& task, Boolean& usedCache, Boolean asyncWrite, Boolean inRetry)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)
   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)
   at Etna.Trading.Oms.Dal.NativeAccountDA.GetAccountById(Int32 id) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms.Dal\NativeAccountDA.cs:line 386
   at Etna.Trading.Oms.Account.Action.UnclearedFundsMaintenanceAction.Execute(String eventName, String argument, String eventState, DateTime date) in D:\AzureAgent\agent01\_work\11\s\src\Etna.Trading.Oms\Etna.Trading.Oms\Account\Action\UnclearedFundsMaintenanceAction.cs:line 48
ClientConnectionId:0fba28e3-d32f-4996-a5ab-4d205a4111a3
Error Number:-2,State:0,Class:11
2026-04-08 11:52:03.265 +00:00 [ERR] Paper trading clearing action failed to update account 40134 [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
2026-04-08 11:52:03.265 +00:00 [ERR] Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. [Etna.Trading.Oms.Account.Action.PaperTradingClearingAction]
System.Data.SqlClient.SqlException (0x80131904): Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean& dataReady)
   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()
   at System.Data.SqlClient.SqlDataReader.get_MetaData()
   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)
   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task& task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)
   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String meth