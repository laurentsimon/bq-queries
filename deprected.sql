SELECT
  System,
  Version,
  Name,
  Deprecated
FROM
  `deps-dev-insights.internal_v1.PackageVersionsLatest`
WHERE
  Deprecated IS NOT NULL
LIMIT
  10;
-- NPM: 93544