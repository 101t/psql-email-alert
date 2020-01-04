CREATE OR REPLACE VIEW v_users AS

SELECT  a.id user_id,
	a.login user_login,
	a.active user_active,
	b.id partner_id,
	b.name partner_name,
	b.display_name partner_display_name,
	b.active partner_active,
	b.email partner_email,
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(b.mobile,' ',''),'-',''),')',''),'(',''),'+','') partner_mobile 
	FROM res_users a, res_partner b
	WHERE a.partner_id = b.id;