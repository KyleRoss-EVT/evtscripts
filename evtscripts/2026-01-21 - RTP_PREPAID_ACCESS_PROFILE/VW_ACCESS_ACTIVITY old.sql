create or replace view EDW_TRB_PRD.SEMANTIC.VW_ACCESS_ACTIVITY(
    
    "Access Date",
    "Access Hour",
    "Access Rule Code",
    "Access Rule",
    "Access Category Code",
    "Access Category",
    "Product Type Code",
    "Product Type",  
    "Resort Group Code",
    "Resort Code",
    "Resort",
    "Location Group Code",
    "Location Code",
    "Location",
    "Revenue Location Code",
    "Access Days",
    "Uses"
    
) as (

-- #################################################
-- Naming shorthand explained
-- #################################################

-- S = step, number +1 per successive step in original stored query
-- I = insert, number +1 per successive insert in original stored query
-- U = update, number +1 per successive update in original stored query
-- use_summary / i_UseSummary / use_sum_
-- summary / i_Summary / sum_
-- daily_summary / i_DailySummary / day_sum_

-- #################################################

-- -------------------
-- Current access data
-- -------------------

WITH use_sum_S1_I1 as (
    SELECT 
        ACCESS_DATE as ACCESS_DATETIME,
        EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(ACCESS_CODE) as ACCESS_RULE, -- Function extracts ACCESS_RULE from ACCESS_CODE depending on length
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
		COUNT(*) as USE_COUNT
	FROM
        EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
	GROUP BY
        ACCESS_DATE,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
    ),

-- -------------------
-- Archived access data
-- -------------------

use_sum_S2_I2 as (
    SELECT 
        ACCESS_DATE as ACCESS_DATETIME,
        EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(ACCESS_CODE) as ACCESS_RULE, -- Function extracts ACCESS_RULE from ACCESS_CODE depending on length
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
		COUNT(*) as USE_COUNT
	FROM
        EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
	GROUP BY
        ACCESS_DATE,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
    ),

-- -------------------
-- Unioned access data
-- -------------------
-- Access Date time is seperated into date and hour, and truncated
-- Renamed as 'use_summary_union' and used in place of the 'i_Summary' from original strored query

use_summary_union as (
    SELECT
        DATE_TRUNC('DAY', ACCESS_DATETIME) as ACCESS_DATE,
        -- UDF to get the hour as a float representing the most recent half-hour interval
        -- As an example: 2am - 3am
        --  - minutes 0.00-29.99 would be 2.0
        --  - minutes 30.00-59.99 would be 2.5
        EDW_TRB_PRD.SEMANTIC.RECENT_HALF_HOUR(ACCESS_DATETIME) as ACCESS_HOUR,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
        SUM(USE_COUNT) as TOTAL_USES
    FROM
        (
            SELECT * FROM use_sum_S1_I1
            UNION
            SELECT * FROM use_sum_S2_I2
        )
    GROUP BY
        ACCESS_DATE,
        ACCESS_HOUR,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
),

-- -------------------
-- Current daily summary data
-- -------------------

day_sum_S3_I1 as (
    SELECT 
        ACCESS_DATE as ACCESS_DATETIME,
        EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(ACCESS_CODE) as ACCESS_RULE, -- Function extracts ACCESS_RULE from ACCESS_CODE depending on length
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
		COUNT(*) as DAY_COUNT
	FROM
        EDW_TRB_PRD.CURATED.RTP_ACCESS_DAILY_SUMM
	GROUP BY
        ACCESS_DATE,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
    ),

-- -------------------
-- Archived daily summary data
-- -------------------

day_sum_S4_I2 as (
    SELECT 
        ACCESS_DATE as ACCESS_DATETIME,
        EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(ACCESS_CODE) as ACCESS_RULE, -- Function extracts ACCESS_RULE from ACCESS_CODE depending on length
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
		COUNT(*) as DAY_COUNT
	FROM
        EDW_TRB_PRD.CURATED.RTP_ACCESS_DAILY_SUMM_ARCH
	GROUP BY
        ACCESS_DATE,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
    ),

-- -------------------
-- Unioned daily summary data
-- -------------------
-- Access Date time is seperated into date and hour, and truncated
-- Renamed as 'daily_summary_union' and used in place of the 'i_DailySummary' from original strored query

daily_summary_union as (
    SELECT
        DATE_TRUNC('DAY', ACCESS_DATETIME) as ACCESS_DATE,
        EDW_TRB_PRD.SEMANTIC.RECENT_HALF_HOUR(ACCESS_DATETIME) AS ACCESS_HOUR,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE,
        SUM(DAY_COUNT) as TOTAL_DAYS
    FROM
        (
            SELECT * FROM day_sum_S3_I1
            UNION
            SELECT * FROM day_sum_S4_I2
        )
    GROUP BY
        ACCESS_DATE,
        ACCESS_HOUR,
        ACCESS_RULE,
        ACCESS_LOCN_CODE,
		ACCESS_PROD_TYPE_CODE
),

-- ------------------------------------
-- Joining in fields from other sources
-- ------------------------------------

final as (
    SELECT
        usu.ACCESS_DATE as ACCESS_DATE,
        usu.ACCESS_HOUR as ACCESS_HOUR,
        usu.ACCESS_RULE as ACCESS_RULE,
        usu.ACCESS_LOCN_CODE as ACCESS_LOCN_CODE,
        usu.ACCESS_PROD_TYPE_CODE as ACCESS_PROD_TYPE_CODE,
        dsu.TOTAL_DAYS as TOTAL_DAYS,
        usu.TOTAL_USES as TOTAL_USES,
        IFNULL(ar."DESC", usu.ACCESS_RULE) as ACCESS_RULE_DESC, -- sum_S10_U4
        ar.DISP_ORDER as ACCESS_RULE_ORDER,
        ar.ACCESS_RULE_CTGY_CODE as ACCESS_RULE_CTGY_CODE,
        IFNULL(arc."DESC", usu.ACCESS_RULE) as ACCESS_RULE_CTGY, -- sum_S12_U6
        arc.DISP_ORDER as ACCESS_RULE_CTGY_ORDER,
        apt."DESC" as ACCESS_PROD_TYPE_DESC,
        l."DESC" as ACCESS_LOCN_DESC,
        l.DISP_ORDER as ACCESS_LOCN_ORDER,
        l.RESORT_CODE as RESORT_CODE,
        al.ACCESS_LOCN_GRP_CODE as ACCESS_LOCN_GRP_CODE,
        arlg.REV_LOCN_CODE as REV_LOCN_CODE,
        r."DESC" as RESORT_DESC,
        r.DISP_ORDER as RESORT_ORDER,
        r.RESORT_GRP_CODE as RESORT_GRP_CODE
    FROM
        use_summary_union as usu
    LEFT JOIN
        daily_summary_union as dsu
        ON
            dsu.ACCESS_DATE = usu.ACCESS_DATE AND
            dsu.ACCESS_HOUR = usu.ACCESS_HOUR AND
            dsu.ACCESS_RULE = usu.ACCESS_RULE AND
            dsu.ACCESS_LOCN_CODE = usu.ACCESS_LOCN_CODE AND
            dsu.ACCESS_PROD_TYPE_CODE = usu.ACCESS_PROD_TYPE_CODE
    LEFT JOIN -- sum_S9_U3
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE as ar
        ON
            ar.ACCESS_RULE = usu.ACCESS_RULE
    LEFT JOIN -- sum_S11_U5
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_CTGY as arc
        ON
            arc.ACCESS_RULE_CTGY_CODE = ar.ACCESS_RULE_CTGY_CODE
    LEFT JOIN -- sum_S13_U7
        EDW_TRB_PRD.CURATED.RTP_ACCESS_PROD_TYPE as apt
        ON
            apt.ACCESS_PROD_TYPE_CODE = usu.ACCESS_PROD_TYPE_CODE
    LEFT JOIN -- sum_S14_U8 (1/2)
        EDW_TRB_PRD.CURATED.RTP_ACCESS_LOCN as al
        ON
            al.ACCESS_LOCN_CODE = usu.ACCESS_LOCN_CODE
    LEFT JOIN -- sum_S14_U8 (2/2)
        EDW_TRB_PRD.CURATED.RTP_LOCN as l
        ON
            l.LOCN_CODE = al.ACCESS_LOCN_CODE
    LEFT JOIN -- sum_S15_U9
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_LOCN_GRP as arlg
        ON
            arlg.ACCESS_RULE = usu.ACCESS_RULE AND
            arlg.ACCESS_LOCN_GRP_CODE = al.ACCESS_LOCN_GRP_CODE
    LEFT JOIN -- sum_S16_U10
        EDW_TRB_PRD.CURATED.RTP_RESORT as r
        ON
            r.RESORT_CODE = l.RESORT_CODE
)

-- Passing the following to the view, renaming and removing some columns
SELECT
    ACCESS_DATE as "Access Date",
    ACCESS_HOUR::DECIMAL(3,1) as "Access Hour",
    ACCESS_RULE as "Access Rule Code",
    ACCESS_RULE_DESC as "Access Rule",
    ACCESS_RULE_CTGY_CODE as "Access Category Code",
    ACCESS_RULE_CTGY as "Access Category",
    ACCESS_PROD_TYPE_CODE as "Product Type Code",
    ACCESS_PROD_TYPE_DESC as "Product Type",  
    RESORT_GRP_CODE as "Resort Group Code",
    RESORT_CODE as "Resort Code",
    RESORT_DESC as "Resort",
    ACCESS_LOCN_GRP_CODE as "Location Group Code",
    ACCESS_LOCN_CODE as "Location Code",
    ACCESS_LOCN_DESC as "Location",
    REV_LOCN_CODE as "Revenue Location Code",
    SUM(TOTAL_DAYS) as "Access Days",
    SUM(TOTAL_USES) as "Uses"
FROM
    final
WHERE ACCESS_DATE >= 
    (SELECT DATE_VAR FROM EDW_TRB_PRD.SEMANTIC.TRB_VARIABLES WHERE VARIABLE_NAME = 'Thredbo Date Min')
GROUP BY
    ACCESS_DATE,
    ACCESS_HOUR,
    ACCESS_RULE,
    ACCESS_RULE_DESC,
    ACCESS_RULE_CTGY_CODE,
    ACCESS_RULE_CTGY,
    ACCESS_PROD_TYPE_CODE,
    ACCESS_PROD_TYPE_DESC,
    RESORT_GRP_CODE,
    RESORT_CODE,
    RESORT_DESC,
    ACCESS_LOCN_GRP_CODE,
    ACCESS_LOCN_CODE,
    ACCESS_LOCN_DESC,
    REV_LOCN_CODE

)
;

-- Stored Query Reference: 
-- proc_reportAccessRuleActivity.sql
-- "Documents - Group BI & Analytics\PBI\Thredbo\RTP Stored Queries Reference"