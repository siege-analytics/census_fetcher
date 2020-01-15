/*
This is a file that measures how two sets of boundaries compare with each other:
    a. ESTIMATION/CREATION  (California, state FIPS = 6)
    b. REFERENCE
        - US Congress
        - US Counties
        - US SLDL
        - US SLDU
        - US Tab-Blocks
        - US ZCTA
        - US State
        - PDI precincts
    c. Shows
        - Containment overlaps & Ratios https://gis.stackexchange.com/questions/289558/finding-combinations-of-polygons-in-postgis
        - Non-containment overlaps & ratios https://gis.stackexchange.com/questions/187406/how-to-use-st-difference-and-st-intersection-in-case-of-multipolygons-postgis
    d. Unassigned/Holes
        - With respect to all of the above named districts :https://gis.stackexchange.com/questions/133134/how-to-detect-gaps-in-a-multipolygon-table-with-postgis
        - containments and non-containment intersections and ratios for where the holes are, e.g., how much of the district is unsassigned
        - holes should be defined in two ways
            - a space where the shapefile itself is NULL, such as a lake in the middle of a park
            - a space where the equivalent CONSTRUCTION_UNIT (tabulation_block, block_group, census_tract) is not assigned a value for DISTRICT in the plan table
*/

-- STEP 0: confirm everything is in EPSG: 4269

ALTER TABLE ca_five_districts
    ALTER COLUMN geom
        TYPE Geometry(MULTIPOLYGON, 4269)
        USING ST_Transform(geom, 4269);

ALTER TABLE tl_2019_us_cd_116
    ALTER COLUMN geom
        TYPE Geometry(MULTIPOLYGON, 4269)
        USING ST_Transform(geom, 4269);


-- this should be the intersections and it will have the area ranks from each of the composing tables
-- https://gis.stackexchange.com/questions/289558/finding-combinations-of-polygons-in-postgis


-- 1a Congressional Districts

DROP TABLE IF EXISTS
    plan_cong_all_int_src;

CREATE TABLE plan_cong_all_int_src AS (
    SELECT ROW_NUMBER() OVER ()                                              AS pid,
           plan.gid                                                          AS plan_id,
           census.gid                                                        as cong_id,
           plan.district                                                     AS plan_name,
           census.namelsad                                                   AS cong_name,
           plan.geom                                                         AS plan_geom,
           census.geom                                                       AS cong_geom,
           ST_MULTI(ST_BUFFER(ST_INTERSECTION(plan.geom, census.geom), 0.0)) AS intersection_geom
    FROM ca_five_districts AS plan
             INNER JOIN tl_2019_us_cd_116 AS census
                        ON (ST_INTERSECTS(plan.geom, census.geom))
    WHERE NOT ST_ISEMPTY(ST_BUFFER(ST_INTERSECTION(plan.geom, census.geom), 0.0)));

CREATE INDEX pln_cong_sdx
    ON
        plan_cong_all_int_src
            USING GIST (intersection_geom);

DROP TABLE IF EXISTS plan_cong_all_int_rep;

CREATE TABLE plan_cong_all_int_rep AS
    (SELECT src.pid AS pid,
            src.plan_id AS plan_id,
            src.cong_id AS cong_id,
            src.plan_name || ' - ' || src.cong_name AS composing_districts,
            ST_AREA(src.intersection_geom) / ST_AREA(src.plan_geom) AS overlap_ratio_for_plan,
            ST_AREA(src.intersection_geom) / ST_AREA(src.cong_geom) AS overlap_ratio_for_congress,
            src.intersection_geom   AS geom
     FROM plan_cong_all_int_src src);

DROP INDEX IF EXISTS
    pln_cng_all_int_sdx;

CREATE INDEX IF NOT EXISTS
    pln_cng_all_int_sdx
ON
    plan_cong_all_int_rep
    USING GIST(geom);

-- Get all parts of the districts that aren't contained by the intersecting CD

DROP TABLE IF EXISTS
    plan_cong_noncntned_int_src;

CREATE TABLE plan_cong_noncntned_int_src AS (
    SELECT ROW_NUMBER() OVER ()                                              AS pid,
           plan.gid                                                          AS plan_id,
           census.gid                                                        as cong_id,
           plan.district                                                     AS plan_name,
           census.namelsad                                                   AS cong_name,
           plan.geom                                                         AS plan_geom,
           census.geom                                                       AS cong_geom,
           ST_MULTI(ST_BUFFER(ST_INTERSECTION(plan.geom, census.geom), 0.0)) AS intersection_geom
    FROM ca_five_districts AS plan
             INNER JOIN tl_2019_us_cd_116 AS census
                        ON (ST_INTERSECTS(plan.geom, census.geom))
    WHERE NOT ST_ISEMPTY(ST_BUFFER(ST_INTERSECTION(plan.geom, census.geom), 0.0)));

CREATE INDEX pln_cong_noncntned_sdx
    ON
        plan_cong_noncntned_int_src
            USING GIST (intersection_geom);

DROP TABLE IF EXISTS plan_cong_noncntned_int_rep;

CREATE TABLE plan_cong_noncntned_int_rep AS
    (SELECT src.pid AS pid,
            src.plan_id AS plan_id,
            src.cong_id AS cong_id,
            src.plan_name || ' - ' || src.cong_name AS composing_districts,
            ST_AREA(src.intersection_geom) / ST_AREA(src.plan_geom) AS overlap_ratio_for_plan,
            ST_AREA(src.intersection_geom) / ST_AREA(src.cong_geom) AS overlap_ratio_for_congress,
            src.intersection_geom   AS geom
     FROM plan_cong_noncntned_int_src src);

DROP INDEX IF EXISTS
    pln_cong_noncntned_rep_sdx;

CREATE INDEX IF NOT EXISTS
    pln_cong_noncntned_rep_sdx
ON
    plan_cong_noncntned_int_rep
    USING GIST(geom);


-- GET ALL TAB BLOCKS THAT THE INTERSECTION CONTAINS AND AREAS
