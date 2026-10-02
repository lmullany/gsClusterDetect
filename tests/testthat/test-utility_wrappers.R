testthat::test_that("find_clusters_by_df returns clusters or JSON", {
  location <- example_count_data <- NULL
  data(
    "example_count_data",
    package = "gsClusterDetect",
    envir = environment()
  )

  cases <- data.table::copy(example_count_data)
  result <- gsClusterDetect::find_clusters_by_df(
    cases,
    threshold_val = 50,
    level = "county",
    return_json = TRUE,
    spline_lookup = "01",
    baseline_length = 60,
    max_test_window_days = 7,
    baseline_adjustment = "add_one",
    use_fast = TRUE
  )

  testthat::expect_type(result, "character")
  parsed <- jsonlite::fromJSON(result)
  testthat::expect_true(
    all(c("cluster_alert_table", "cluster_location_counts") %in% names(parsed))
  )
  testthat::expect_gt(nrow(parsed$cluster_alert_table), 0)
  testthat::expect_gt(nrow(parsed$cluster_location_counts), 0)

  clusters <- gsClusterDetect::find_clusters_by_df(
    cases,
    threshold_val = 50,
    level = "county",
    return_json = FALSE,
    spline_lookup = "01",
    baseline_length = 60,
    max_test_window_days = 7,
    baseline_adjustment = "add_one",
    use_fast = TRUE
  )

  testthat::expect_s3_class(clusters, "clusters")
  testthat::expect_true(
    all(c("cluster_alert_table", "cluster_location_counts") %in% names(clusters))
  )
  testthat::expect_gt(nrow(clusters$cluster_alert_table), 0)
  testthat::expect_gt(nrow(clusters$cluster_location_counts), 0)
})

testthat::test_that("find_clusters_by_df validates its inputs", {
  location <- example_count_data <- NULL
  data(
    "example_count_data",
    package = "gsClusterDetect",
    envir = environment()
  )

  testthat::expect_error(
    gsClusterDetect::find_clusters_by_df(
      example_count_data,
      threshold_val = -1,
      level = "county"
    ),
    "positive numeric"
  )
  testthat::expect_error(
    gsClusterDetect::find_clusters_by_df(
      example_count_data,
      threshold_val = 50,
      level = "state"
    ),
    "arg"
  )
  testthat::expect_error(
    gsClusterDetect::find_clusters_by_df(
      example_count_data[, c("location", "date")],
      threshold_val = 50,
      level = "county"
    ),
    "required columns"
  )
})
