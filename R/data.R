#' Historical Baseball Game Data
#'
#'A dataset containing game by game MLB attendance data alongside other variables from 1899 to 2024
#'
#' @format A data frame with 221,176 rows and 15 variables:
#' \describe{
#'   \item{site}{Stadium code (character)}
#'   \item{gid}{Game ID (character)}
#'   \item{date}{Date of game (Date)}
#'   \item{visteam}{Visiting team code (character)}
#'   \item{hometeam}{Home team code (character)}
#'   \item{starttime}{Start time of game (hms object)}
#'   \item{attendance}{Reported attendance (numeric)}
#'   \item{Capacity}{Stadium capacity, if known (character)}
#'   \item{vruns}{Runs scored by visiting team (numeric)}
#'   \item{hruns}{Runs scored by home team (numeric)}
#'   \item{temp}{Reported temperature (numeric)}
#'   \item{fieldcond}{Field condition (character)}
#'   \item{precip}{Precipitation conditions (character)}
#'   \item{sky}{Sky condition (character)}
#'   \item{winddir}{Wind direction (character)}
#' }
#' @source Seamheads.com
"attendance_data"

#' Team labels dataset
#'
#' A dataset containing labels for each MLB team with year ranges and
#' number of home stadiums. Generated internally by `get_team_labels()`.
#'
#' @format A character vector with one label per team.
#' @examples
#' data(team_labels)
#' head(team_labels)
"team_labels"


#' Vegas Preseason Win Totals
#'
#' A dataset of MLB preseason Vegas win totals scraped from SportsOddsHistory,
#' spanning 1990–2020s.
#'
#' @format A tibble with columns:
#' \describe{
#'   \item{team}{Team name (character).}
#'   \item{year}{Season year (numeric).}
#'   \item{preseason}{Preseason Vegas win total (numeric).}
#' }
#'
#' @source \url{https://www.sportsoddshistory.com/mlb-regular-season-win-total-results-by-team/}
"vegas_data"

