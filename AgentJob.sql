-- =====================================
-- 6. SQL Agent Job Script (runs nightly)
-- =====================================
-- NOTE: Run this in [msdb] context. Requires SQL Agent enabled.
-- Adjust job owner and category as needed.

USE msdb;
GO

EXEC dbo.sp_add_job @job_name = N'SampleDataMart_LoadJob';

EXEC sp_add_jobstep
    @job_name = N'SampleDataMart_LoadJob',
    @step_name = N'Load New Sales Data',
    @subsystem = N'TSQL',
    @command = N'EXEC SampleDataMart.dbo.usp_LoadNewSalesData;',
    @database_name = N'SampleDataMart';

EXEC sp_add_schedule
    @schedule_name = N'Daily_9AM',
    @freq_type = 4,  -- daily
    @freq_interval = 1,
    @active_start_time = 090000;  -- 9:00 AM

EXEC sp_attach_schedule
    @job_name = N'SampleDataMart_LoadJob',
    @schedule_name = N'Daily_9AM';

EXEC sp_add_jobserver @job_name = N'SampleDataMart_LoadJob';
GO


USE msdb;
GO

-- Job 1: Regional Summary every 5 minutes
EXEC sp_add_job @job_name = N'Refresh Regional Sales Summary';
EXEC sp_add_jobstep 
    @job_name = N'Refresh Regional Sales Summary',
    @step_name = N'Run usp_RefreshRegionalSalesSummary',
    @subsystem = N'TSQL',
    @command = N'EXEC SampleDataMart.dbo.usp_RefreshRegionalSalesSummary;',
    @database_name = N'SampleDataMart';
EXEC sp_add_schedule 
    @schedule_name = N'Every5Min',
    @freq_type = 4, -- daily
    @freq_interval = 1,
    @freq_subday_type = 4, -- minutes
    @freq_subday_interval = 5;
EXEC sp_attach_schedule 
    @job_name = N'Refresh Regional Sales Summary',
    @schedule_name = N'Every5Min';
EXEC sp_add_jobserver @job_name = N'Refresh Regional Sales Summary';
GO

-- Job 2: Insert Random Sale every 10 minutes
EXEC sp_add_job @job_name = N'Insert Random Sale';
EXEC sp_add_jobstep 
    @job_name = N'Insert Random Sale',
    @step_name = N'Run usp_InsertRandomSale',
    @subsystem = N'TSQL',
    @command = N'EXEC SampleDataMart.dbo.usp_InsertRandomSale;',
    @database_name = N'SampleDataMart';
EXEC sp_add_schedule 
    @schedule_name = N'Every10Min',
    @freq_type = 4, -- daily
    @freq_interval = 1,
    @freq_subday_type = 4, -- minutes
    @freq_subday_interval = 10;
EXEC sp_attach_schedule 
    @job_name = N'Insert Random Sale',
    @schedule_name = N'Every10Min';
EXEC sp_add_jobserver @job_name = N'Insert Random Sale';
GO
