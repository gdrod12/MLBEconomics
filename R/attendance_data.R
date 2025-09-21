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
