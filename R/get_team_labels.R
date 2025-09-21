#' Build team labels (internal)
#'
#' Generates labels for each team, summarizing their game years and number of
#' home stadiums. Used internally to create the `team_labels` dataset.
#'
#' @param data A data frame with columns: date, hometeam, visteam, site.
#' @return A character vector of labels, one per team.
#' @keywords internal
#' @noRd
get_team_labels <- function(data) {
  team_ids <- unique(data$hometeam)
  team_labels <- lapply(team_ids, function(x) {
    df <- subset(data, hometeam == x | visteam == x)
    years <- as.integer(format(df$date, "%Y"))
    home_stadiums <- unique(df$site[df$hometeam == x])
    n_stadiums <- length(home_stadiums)
    if (length(years) == 0) paste(x, "(no games)") else
      paste0(x, " (", min(years), "–", max(years), ", ", n_stadiums, " home stadiums)")
  })
  return(team_labels)
}

