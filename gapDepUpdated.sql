-- packages with more than 4 years gap in updates
-- ordered by number of dependendents (if not dependent, absent from result)
WITH
    OrderedDeps AS (
        SELECT
            Name, COUNT(Name) as Count
        FROM
            `bigquery-public-data.deps_dev_v1.DependentsLatest`
        WHERE
            System="PYPI"
        GROUP BY
            Name
        ORDER BY
            Count DESC
    ),
    GapUpdates AS (
        SELECT 
            Name, Version, UpstreamPublishedAt,
            -- TIMESTAMP_DIFF does not support month
            DATE_DIFF( 
                CAST(
                    LAG(UpstreamPublishedAt) OVER (PARTITION BY Name ORDER BY UpstreamPublishedAt DESC)
                    AS DATE
                    ),
                CAST(UpstreamPublishedAt AS DATE),
                MONTH
            ) AS Diff
        FROM
            `deps-dev-insights.internal_v1.PackageVersionsLatest`
        WHERE
            System="PYPI"
        ORDER BY
            Name DESC,
            UpstreamPublishedAt DESC
    )
SELECT
    DISTINCT(ga.Name), ga.Diff, od.Count
FROM
    GapUpdates AS ga
INNER JOIN
    OrderedDeps AS od
ON 
    ga.Name = od.Name
WHERE
    ga.Diff > 48

ORDER BY
    od.Count DESC,
    ga.Diff DESC
LIMIT
    100


    