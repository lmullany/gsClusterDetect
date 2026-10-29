# Generate Census Tract Centroids for a State

Pulls census tracts using tigris, computes tract centroids, and returns
a three-column data.table with GEOID, latitude, and longitude.

## Usage

``` r
tract_generator(st, county = NULL, use_cache = TRUE, ...)
```

## Arguments

- st:

  Character scalar; either a 2-digit state FIPS code (for example,
  `"24"`) or a 2-letter USPS abbreviation (for example, `"MD"`).

- county:

  A three-digit FIPS code (string) of the county or counties to subset
  on. This can also be a county name or vector of names.

- use_cache:

  a boolean, defaults to TRUE, to set tigris option to use cache

- ...:

  arguments to be passed on to tigris::tracts()

## Value

A `data.table` with columns:

- geoid:

  11-digit tract GEOID (`state(2) + county(3) + tract(6)`)

- latitude:

  Centroid latitude in WGS84

- longitude:

  Centroid longitude in WGS84

## Examples

``` r
md_tracts <- tract_generator("24")
md_tracts2 <- tract_generator("MD")
howard_county_tracts <- tract_generator("MD", county = "027")
head(md_tracts)
#>          geoid latitude longitude
#>         <char>    <num>     <num>
#> 1: 24013511000 39.53226 -77.09618
#> 2: 24510160600 39.29675 -76.66401
#> 3: 24510271802 39.34468 -76.67707
#> 4: 24005411309 39.41019 -76.43914
#> 5: 24005408303 39.46964 -76.71628
#> 6: 24005407002 39.67417 -76.62187
```
