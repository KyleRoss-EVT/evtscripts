WITH record_union AS (
    SELECT
        au.access_date AS access_datetime
        ,au.access_code
        ,au.access_locn_code
        ,au.access_prod_type_code
        ,ad.ip_code
    FROM
        (
            SELECT 
                *, 
                SEQ8() AS row_id
            FROM
            (
                SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM

                UNION ALL

                SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
                WHERE access_date < TIMESTAMP '2010-05-29 13:13:25.080'
            )
        ) AS au
    INNER JOIN EDW_TRB_PRD.SEMANTIC.VW_ACCESS_DETAIL_PROFILE as ad ON 
        ad.access_date = au.access_date
        AND ad.access_code = au.access_code
        AND ad.access_source_code = au.access_src_code
        AND ad.access_prod_type_code = au.access_prod_type_code
        AND ad.access_location_code = au.access_locn_code
        AND ad.media_access_code = au.media_access_code
    QUALIFY 
        ROW_NUMBER() OVER (PARTITION BY au.row_id ORDER BY ad.access_date, ad.row_id) = 1
)

,records_transform AS (
        SELECT
            TO_DATE(access_datetime) AS access_date
            ,EDW_TRB_PRD.SEMANTIC.RECENT_HALF_HOUR(access_datetime) AS access_hour
            ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(access_code) AS access_rule
            ,access_locn_code
            ,access_prod_type_code
            ,ip_code
        FROM record_union
)

,aggregate AS (
    SELECT
            access_date
            ,access_hour
            ,access_rule
            ,access_locn_code
            ,access_prod_type_code
            ,ip_code
            ,COUNT(*) AS use_count
    FROM records_transform
    GROUP BY
        access_date
        ,access_hour
        ,access_rule
        ,access_locn_code
        ,access_prod_type_code
        ,ip_code
)

,expanded AS (
    SELECT 
        a.access_date
        ,a.access_hour
        ,a.access_rule
        ,a.access_locn_code
        ,a.access_prod_type_code
        ,a.ip_code
        ,IFNULL(ar.desc, a.access_rule) as access_rule_desc
        ,ar.access_rule_ctgy_code
        ,IFNULL(arc.desc, a.access_rule) as access_rule_ctgy
        ,apt.desc AS access_prod_type_desc
        ,al.access_locn_grp_code
        ,l.desc AS access_locn_desc
        ,l.resort_code
        ,arlg.rev_locn_code
        ,r.desc AS resort_desc
        ,r.resort_grp_code
        ,a.use_count
    FROM aggregate AS a
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE as ar ON ar.access_rule = a.access_rule
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_CTGY as arc ON arc.access_rule_ctgy_code = ar.access_rule_ctgy_code
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_PROD_TYPE as apt ON apt.access_prod_type_code = a.access_prod_type_code
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_LOCN as al ON al.access_locn_code = a.access_locn_code
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_LOCN as l ON l.locn_code = al.access_locn_code
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_LOCN_GRP as arlg ON 
            arlg.access_rule = a.access_rule 
            AND arlg.access_locn_grp_code = al.access_locn_grp_code
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_RESORT as r ON r.resort_code = l.resort_code
    WHERE ACCESS_DATE >= 
        (SELECT DATE_VAR FROM EDW_TRB_PRD.SEMANTIC.TRB_VARIABLES WHERE VARIABLE_NAME = 'Thredbo Date Min')
)

SELECT
    access_date
    ,SUM(use_count)
FROM expanded
GROUP BY access_date
-- Use count 
-- 27542092
-- vs pbi
-- 28563661

