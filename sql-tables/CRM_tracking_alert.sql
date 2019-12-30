CREATE OR REPLACE VIEW v_crm_tracking_alert AS

SELECT a.id lead_id,
	b.name lead_stage,
	a.name lead_name,
	substr((SELECT x.activity
	FROM v_crm_activities x
	WHERE x.activity_id IN (
	SELECT MAX(activity_id) activity_id FROM v_crm_activities
	WHERE activity_status  = 'Done' group by lead_id) AND x.lead_id = a.id),1,510) last_activity, (
	SELECT TO_CHAR(x.done_on,'DD-Mon-YY') done_on FROM v_crm_activities x
	WHERE x.activity_id IN (
	SELECT MAX(activity_id) activity_id FROM v_crm_activities
	WHERE activity_status  = 'Done' group by lead_id) AND x.lead_id = a.id) last_activity_date, (
	SELECT x.assigned_to FROM v_crm_activities x
	WHERE x.activity_id IN (
	SELECT MAX(activity_id) activity_id FROM v_crm_activities
	WHERE activity_status  = 'Done' group by lead_id) AND x.lead_id = a.id) last_activity_by, SUBSTR((
	SELECT x.activity FROM v_crm_activities x
	WHERE x.due_on IN (
	SELECT MIN(z.due_on) FROM v_crm_activities z
	WHERE z.activity_status <> 'Done' AND z.lead_id = a.id) AND x.lead_id = a.id),1,510) next_activity, (
	SELECT TO_CHAR(x.due_on ,'DD-Mon-YY') due_on FROM v_crm_activities x
	WHERE x.due_on IN (
	SELECT MIN(z.due_on) FROM v_crm_activities z
	WHERE z.activity_status <> 'Done' AND z.lead_id = a.id) AND x.lead_id = a.id) next_activity_date, (
	SELECT x.assigned_to FROM v_crm_activities x
	WHERE x.due_on IN (
	SELECT MIN(z.due_on) FROM v_crm_activities z 
	WHERE z.activity_status <> 'Done' AND z.lead_id = a.id) AND x.lead_id = a.id) next_activity_by, (
	SELECT x.activity_status FROM v_crm_activities x 
	WHERE x.due_on IN (
	SELECT MIN(z.due_on) FROM v_crm_activities z
	WHERE z.activity_status <> 'Done' AND z.lead_id = a.id) AND x.lead_id = a.id) next_activity_status (
	SELECT x.assigned_to FROM crm_lead a, crm_stage b
	WHERE a.stage_id = b.id 
	ORDER BY b.name = 'New Leads' desc,
		b.name = 'Proposition' desc,
		b.name = 'Opportunity' desc,
		b.name = 'Qualified Opportunity' desc,
		b.name = 'Negotiation' desc,
		b.name = 'Won' desc,
		b.name = 'Lost' desc
		AND a.res_id = 15