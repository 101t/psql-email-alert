drop view  v_crm_activities;

create view v_crm_activities

as

select    a.id activity_id,

                           case      when current_date = a.date_deadline::date then 'Planned Today'

                                                       when current_date > a.date_deadline::date then 'Delayed'

                                                       when current_date < a.date_deadline::date then 'Planned' end activity_status,

                           b.name activity_type,

                           c.id lead_id,

                           c.name lead_name,

                           a.summary activity,

                            regexp_replace(regexp_replace(a.note, E'<.*?>', '', 'g' ), E'&nbsp;', '', 'g') activity_note,

                           d.partner_name assigned_to,

                           a.create_date::date assigned_on,

                           a.date_deadline due_on,

                           null done_on

from     mail_activity a,

                           mail_activity_type b,

                           crm_lead c,

                           v_users d

where   a.activity_type_id = b.id

                           and a.res_id = c.id

                           and a.user_id = d.user_id

                           and a.res_model = 'crm.lead'

UNION ALL

select  a.id activity_id,

                           'Done' Activity_status,

                           c.name activity_type,

                           b.id lead_id,

                           b.name lead_name,

replace(replace(regexp_replace(regexp_replace(a.body, E'<.*?>', '', 'g' ), E'&nbsp;', '', 'g'),'

',''),'             ','') activity,

                           ''::text activity_note,

                           d.partner_name done_by,

                           null assigned_on,

                           null due_on,

                           a.date::date done_on

                          

from     mail_message a,

                           crm_lead b,

                           mail_activity_type c,

                           v_users d

 

where   a.res_id = b.id

                           and a.author_id = d.partner_id

                           and a.mail_activity_type_id = c.id;

                           --and a.record_name = 'ENGIE | Italy ERP'

create view v_crm_tracking_alert

as

select    a.id lead_id,

                           b.name lead_stage,

                           a.name lead_name,

                           substr((select x.activity

                            from v_crm_activities x

                            where x.activity_id in (select max(activity_id) activity_id

                                                                                                              from     v_crm_activities

                                                                                                              where activity_status  = 'Done' group by lead_id)

                                           and x.lead_id = a.id),1,510) last_activity,

                  (select to_char(x.done_on,'DD-Mon-YY') done_on

                            from v_crm_activities x

                            where x.activity_id in (select max(activity_id) activity_id

                                                                                                              from     v_crm_activities

                                                                                                              where activity_status  = 'Done' group by lead_id)

                                            and x.lead_id = a.id) last_activity_date,

                  (select x.assigned_to

                            from v_crm_activities x

                            where x.activity_id in (select max(activity_id) activity_id

                                                                                                              from     v_crm_activities

                                                                                                              where activity_status  = 'Done' group by lead_id)

                                            and x.lead_id = a.id) last_activity_by,

                           substr((select x.activity

                            from v_crm_activities x

                            where x.due_on in (select min(z.due_on)

                                                                                                             from v_crm_activities z

                                                                                                             where z.activity_status <> 'Done' and z.lead_id = a.id)

                                            and x.lead_id = a.id),1,510) next_activity,

                  (select to_char(x.due_on ,'DD-Mon-YY') due_on

                           from v_crm_activities x

                            where x.due_on in (select min(z.due_on)

                                                                                                             from v_crm_activities z

                                                                                                             where z.activity_status <> 'Done' and z.lead_id = a.id)

                                            and x.lead_id = a.id) next_activity_date,

                  (select x.assigned_to

                            from v_crm_activities x

                            where x.due_on in (select min(z.due_on)

                                                                                                from v_crm_activities z

                                                                                                where z.activity_status <> 'Done' and z.lead_id = a.id)

                                            and x.lead_id = a.id) next_activity_by,

                  (select x.activity_status

                            from v_crm_activities x

                            where x.due_on in (select min(z.due_on)

                                                                                                from v_crm_activities z

                                                                                                where z.activity_status <> 'Done' and z.lead_id = a.id)

                                            and x.lead_id = a.id) next_activity_status

from      crm_lead a,

                           crm_stage b

where   a.stage_id = b.id

order by             b.name = 'New Leads' desc,

                                         b.name = 'Proposition' desc,

                                         b.name = 'Opportunity' desc,

                                         b.name = 'Qualified Opportunity' desc,

                                         b.name = 'Negotiation' desc,

                                         b.name = 'Won' desc,

                                         b.name = 'Lost' desc