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
    @schedule_name = N'Daily_2AM',
    @freq_type = 4,  -- daily
    @freq_interval = 1,
    @active_start_time = 020000;  -- 2:00 AM

EXEC sp_attach_schedule
    @job_name = N'SampleDataMart_LoadJob',
    @schedule_name = N'Daily_2AM';

EXEC sp_add_jobserver @job_name = N'SampleDataMart_LoadJob';
GO
