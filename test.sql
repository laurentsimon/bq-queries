SELECT * FROM `bigquery-public-data.deps_dev_v1.Projects` ORDER BY StarsCount DESC LIMIT 10 #WHERE DATE(SnapshotAt) = "2023-06-22"

SELECT DISTINCT COUNT(D.Name) FROM `bigquery-public-data.deps_dev_v1.DependenciesLatest` as D WHERE System="NPM" AND D.Name  LIKE '%>%'

SELECT COUNT(*) FROM
(
SELECT DISTINCT D.Dependency.Name FROM bigquery-public-data.deps_dev_v1.DependenciesLatest as D WHERE D.System="NPM" AND D.Dependency.Name NOT LIKE '%>%' 
  EXCEPT DISTINCT 
SELECT P.Name FROM bigquery-public-data.deps_dev_v1.DependenciesLatest as P WHERE P.System="NPM"
)

SELECT DISTINCT D.Dependency.Name FROM bigquery-public-data.deps_dev_v1.DependenciesLatest as D WHERE D.System="NPM" AND D.Dependency.Name NOT LIKE '%>%' 
  EXCEPT DISTINCT 
SELECT P.Name FROM bigquery-public-data.deps_dev_v1.DependenciesLatest as P WHERE P.System="NPM"
LIMIT 10

AND UpstreamPublishedAt < '2020-01-30 00:00:00'
SELECT System, Name, Version, UpstreamPublishedAt
FROM `deps-dev-insights.internal_v1.PackageVersionsLatest`
WHERE System = 'NPM'
AND Name = 'express'
ORDER BY UpstreamPublishedAt DESC;

SELECT COUNT(*), Name
FROM `deps-dev-insights.internal_v1.PackageVersionsLatest` as PVL
WHERE System = 'NPM'
GROUP BY Name
LIMIT 20

SELECT 
    System, Name, Version, UpstreamPublishedAt
FROM 
    `deps-dev-insights.internal_v1.PackageVersionsLatest` PVL1
WHERE 
    System = 'NPM'
ORDER BY 
    Name, UpstreamPublishedAt DESC
ORDER BY 
    UpstreamPublishedAt DESC
AND NOT EXISTS
(
    SELECT
        Name
    FROM
        `deps-dev-insights.internal_v1.PackageVersionsLatest` PVL2
    WHERE
        PVL1.Name = PVL2.Name
    AND
        PVL2.UpstreamPublishedAt > '2020-01-30 00:00:00'
)
LIMIT 10;

SELECT DISTINCT
    Name, Version, UpstreamPublishedAt
FROM
    `deps-dev-insights.internal_v1.PackageVersionsLatest` PVL2
WHERE
    System="NPM"
AND NOT
    PVL2.UpstreamPublishedAt > '2015-01-30 00:00:00'
ORDER BY
    UpstreamPublishedAt DESC
LIMIT 10;

WITH
    DepCount AS (
        SELECT
            Name, COUNT(*)
        FROM
            `deps-dev-insights.internal_v1.DependentsLatest`
        WHERE
            System="NPM"
        GROUP BY
            Name
  )
  
WITH
  Durs AS (
    SELECT
      System,
      Name,
      TIMESTAMP_DIFF(
        COALESCE(IntervalEnd, CURRENT_TIMESTAMP()), IntervalStart, DAY)
        AS Duration,
      IsOutOfDate,
      0 < ARRAY_LENGTH(Warnings) AS HasWarnings
    FROM
      `deps-dev-insights.internal_v1.RequirementDurationsLatest`
  ),
  AggDurs AS (
    SELECT
      System,
      Name,
      SUM(Duration) AS TotalRequirementDuration,
      SUM(IF(IsOutOfDate AND (NOT HasWarnings), Duration, 0))
        AS OutOfDateDuration
    FROM
      Durs
    GROUP BY
      System,
      Name
  )
SELECT
  d.System,
  d.Name,
  d.TotalRequirementDuration,
  d.OutOfDateDuration,
  CAST(d.OutOfDateDuration AS FLOAT64)
    / CAST(d.TotalRequirementDuration AS FLOAT64) AS Ratio,
  SUM(p.DependentInfo.PackagesApprox) AS DependentsApprox
FROM AggDurs AS d
INNER JOIN `deps-dev-insights.internal_v1.PackageVersionsLatest` AS p
  USING (System, Name)
WHERE TotalRequirementDuration > 0
GROUP BY 1, 2, 3, 4, 5
ORDER BY Ratio DESC

https://www.sqlservertutorial.net/sql-server-basics/sql-server-exists/