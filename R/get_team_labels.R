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

  team_info <- lapply(team_ids, function(x) {
    df <- subset(data, hometeam == x | visteam == x)
    years <- as.integer(format(df$date, "%Y"))
    home_stadiums <- unique(df$site[df$hometeam == x])
    n_stadiums <- length(home_stadiums)
    if (length(years) == 0) {
      label <- paste(x, "(no games)")
      start_year <- Inf
    } else {
      label <- paste0(x, " (", min(years), "–", max(years),
                      ", ", n_stadiums, " home stadiums)")
      start_year <- min(years)
      end_year <- max(years)
    }
    data.frame(team = x, label = label,
               prefix = substr(x, 1, 2),
               start_year = start_year,
               end_year = end_year,
               stringsAsFactors = FALSE)
  })

  team_info <- do.call(rbind, team_info)

  # sort by prefix (alphabetically), then by start_year
  team_info <- team_info[order(team_info$prefix, team_info$end_year), ]

  return(team_info$label)
}

