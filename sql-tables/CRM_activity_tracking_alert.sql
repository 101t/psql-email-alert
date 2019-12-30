CREATE OR REPLACE VIEW v_crm_activities AS 
SELECT a.id activity_id,
	case when current_date = a.date_deadline::date then 'Planned Today'
		when current_date > a.date_deadline::date then 'Delayed'
		when current_date < a.date_deadline::date then 'Planned' end activity_status,
	b.name activity_type,
	c.id lead_id,
	c.name lead_name,
	a.summary activity,
	REGEXP_REPLACE(REGEXP_REPLACE(a.note, E'<.*?>', '', 'g' ), E'&nbsp;', '', 'g') activity_note,
	d.partner_name assigned_to,
	a.create_date::date assigned_on,
	a.date_deadline due_on,
	null done_on
FROM mail_activity a,
	mail_activity_type b,
	crm_lead c,
	v_users d
WHERE a.activity_type_id = b.id
	AND a.res_id = c.id
	AND a.user_id = d.user_id
	AND a.res_model = 'crm.lead'

UNION ALL

SELECT a.id activity_id,
	'Done' Activity_status,
	c.name activity_type,
	b.id lead_id,
	b.name lead_name,

REPLACE(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(a.body, E'<.*?>', '', 'g' ), E'&nbsp;', '', 'g'),'',''),'','') activity,
	''::text activity_note,
	d.partner_name done_by,
	null assigned_on,
	null due_on,
	a.date::date done_on

FROM mail_message a,
	crm_lead b,
	mail_activity_type c,
	v_users d

WHERE a.res_id = b.id
	AND a.author_id = d.partner_id
	AND a.mail_activity_type_id = c.id
	--AND a.record_name = 'ENGIE | Italy ERP'