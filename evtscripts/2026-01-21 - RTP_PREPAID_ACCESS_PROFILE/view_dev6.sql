WITH record_union AS (
    SELECT
        au.*
        ,ad.ip_code
        -- au.access_date AS access_datetime
        -- ,au.access_code
        -- ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(au.access_code) AS access_rule
        -- ,au.access_locn_code
        -- ,au.access_prod_type_code
        -- ,ad.ip_code
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


SELECT * FROM record_union
ORDER BY access_date;

-- with join, no qualify
-- 52,844,962 rows
-- with join, with qualify
-- 52,495,784 rows
-- without
-- 55,729,020 rows


SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE 
    access_src_code = 2 
    AND access_date >= DATEADD(YEAR, -1, access_date)
QUALIFY COUNT(*) OVER (PARTITION BY access_code) > 1
ORDER BY access_code, access_date;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE hash_match = -1698892465542781014.00000;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL_ARCHIVE
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE
WHERE access_code = 'THRST0338HX88H6FL';
-- ORDER BY access_date;

SELECT * FROM EDW_TRB_PRD.SEMANTIC.VW_ACCESS_DETAIL_PROFILE
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT MIN(access_date) FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL;
-- 2025-06-04 06:55:31.810
SELECT MAX(access_date) FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL_ARCHIVE;
-- 2025-06-03 17:49:27.727

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE LIMIT 1000;