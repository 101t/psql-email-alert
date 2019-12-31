CREATE OR REPLACE VIEW v_timesheets AS 
	SELECT e.partner_name employee,
	a.date ts_date,
	a.name ts_desc,
	d.name task_name,
	c.name project_name,
	a.amount,
	a.unit_amount  
	--b.total_attendance,
	--b.total_timesheet,
	--b.total_difference,
	FROM account_analytic_line a LEFT JOIN project_task d ON a.task_id = d.id,
	project_project b,
	account_analytic_account c,
	v_users e,
	--hr_timesheet_attendance_report b
	WHERE a.project_id = b.id
	AND b.analytic_account_id = c.id
	AND a.user_id = e.user_id