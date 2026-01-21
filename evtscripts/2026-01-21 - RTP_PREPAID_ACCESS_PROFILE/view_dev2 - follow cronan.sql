
SELECT MIN(access_date) FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL;

WITH access_detail AS (
        SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL

        UNION ALL

        SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL_ARCHIVE
        WHERE access_date < TIMESTAMP '2025-06-04 06:55:31.810'
)

SELECT 
    ad.access_date,
    ad.access_code,
    ad.access_location_code,
    l.desc AS access_location_desc,
    g.gate_name,
    arc.access_rule_ctgy_code,
    arc.desc AS access_rule_ctgy_desc,
    apt.access_prod_type_code,
    apt.desc AS access_prod_type_desc,
    ar.access_rule,
    ar.desc AS access_rule_desc,
    pap.ip_code,
    ad.media_access_code,
    pap.product_header_code
FROM access_detail AS ad
INNER JOIN EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE AS pap ON pap.access_code = ad.access_code
INNER JOIN EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE AS ar ON ar.access_rule = pap.access_rule
INNER JOIN EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_CTGY AS arc ON arc.access_rule_ctgy_code = ar.access_rule_ctgy_code
INNER JOIN EDW_TRB_PRD.CURATED.RTP_LOCN AS l ON l.locn_code = ad.access_location_code
INNER JOIN EDW_TRB_PRD.CURATED.RTP_ACCESS_PROD_TYPE AS apt ON apt.access_prod_type_code = ad.access_product_type_code
INNER JOIN EDW_TRB_PRD.CURATED.RTP_GATE AS g ON g.gate_code = ad.hand_held_id
WHERE 
    pap.prepaid_access_status_code IN (1, 3)
    AND l.locn_ref = 'Access Location'
    AND ad.return_code IN (0, 14, 27)
ORDER BY ad.accessdate
;

-- JOIN dbo.prepaidaccessprofile pap WITH (nolock)
--     ON ad.accesscode = pap.accesscode
--     AND pap.prepaidaccessstatuscode IN ( 1, 3 )
-- JOIN dbo.accessrule ar WITH (nolock)
--     ON ar.accessrule = pap.accessrule
-- JOIN dbo.accessrulecategory arc WITH (nolock)
--     ON arc.accessrulecategorycode = ar.accessrulecategorycode

-- DNU
-- JOIN dbo.accessrulegroup arg WITH (nolock)
--     ON arg.accessrulegroupcode = arc.accessrulegroupcode
-- 

-- JOIN dbo.location l WITH (nolock)
--     ON l.locationcode = ad.accesslocationcode
--     AND l.locationreference = 'Access Location'
-- JOIN dbo.accessproducttype apt WITH (nolock)
--     ON apt.accessproducttypecode = ad.accessproducttypecode
JOIN dbo.gate g WITH (nolock)
    ON g.gatecode = ad.handheldid
WHERE  ad.returncode IN ( 0, 14, 27 )
       AND ad.accessdate > '2025-09-25'