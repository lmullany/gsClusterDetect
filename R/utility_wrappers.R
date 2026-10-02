#' Wrapper: Find clusters by data frame only
#'
#' Wrapper around \code{find_clusters()} where only a data frame in the usual
#' location, date, count format, a threshold value (distance limit), and the
#' geographic resolution is required. The appropriate distance list will be
#' auto created based on detected the states/locations given the data frame
#' location column. The result can be returned as json, if desired
#'
#' @param df The data frame with location (char), date (IDate), and count (int)
#' columns
#' @param threshold_val The cluster threshold (int) in miles
#' @param level Can be "zip" or "county"
#' @param return_json set to TRUE to return json
#' @param ... other arguments passed on to \code{find_clusters()}
#' @seealso [find_clusters()]
#' @export
#' @returns result from find_clusters(), optionally converted to json
#' @examples
#' find_clusters_by_df(example_count_data, 50, "county", return_json = FALSE)
#'
find_clusters_by_df <- function(
  df,
  threshold_val,
  level,
  return_json = FALSE,
  ...
) {
  # match the level
  level <- match.arg(level, choices = c("zip", "county"))

  # check that threshold_val is numeric and >0
  if (!is.numeric(threshold_val) || threshold_val < 0) {
    stop("threshold value must be a positive numeric value in miles")
  }

  # requires that the df has location, date, and count columns
  check_vars(df, c("location", "date", "count"))

  # set input to data.table
  data.table::setDT(df)

  # fix the date as IDate
  df[, date := data.table::as.IDate(date)]

  # get the states, based on the location values in the data frame
  tryCatch(
    states <- identify_states(df = df, level = level),
    error = function(e) stop("failed to identify states from data frame.")
  )

  if (is.null(states)) stop("failed to identify states from data frame")

  tryCatch(
    {
      # get the distance object using create_dist_list
      dist_list <- create_dist_list(
        level = level,
        threshold = threshold_val,
        st = states
      )
    },
    error = function(e) stop("failed to created distance list")
  )

  # get the maximum date
  latest_date <- max(df[, date], na.rm = TRUE)

  # call the find_clusters function
  clusters <- find_clusters(
    cases = df,
    distance_matrix = dist_list,
    detect_date = latest_date,
    distance_limit = threshold_val,
    # include any passed through args
    ...
  )

  # return conditionally as json or as regular result
  if (return_json == TRUE) {
    jsonlite::toJSON(clusters, pretty = TRUE)
  } else {
    clusters
  }
}
