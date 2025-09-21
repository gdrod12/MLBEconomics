#' Combine game information with ballpark capacity data
#'
#' This function merges Retrosheet game information (from `gameinfo.csv`)
#' with ballpark capacity data scraped from \url{https://www.seamheads.com/ballparks/}.
#' The result is a dataset that links individual games with stadium capacities
#' and associated weather/field conditions.
#'
#' @param year Integer. The season year for which to scrape contemporary
#'   ballpark capacity data (e.g., `2024`).
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{site}{Character. Ballpark site identifier.}
#'   \item{gid}{Character. Retrosheet game ID.}
#'   \item{date}{Date. Game date parsed from the `gid`.}
#'   \item{visteam}{Character. Visiting team identifier.}
#'   \item{hometeam}{Character. Home team identifier.}
#'   \item{starttime}{Character. Reported start time of the game.}
#'   \item{attendance}{Numeric. Reported game attendance.}
#'   \item{Capacity}{Character/numeric. Reported stadium seating capacity.}
#'   \item{vruns}{Integer. Visiting team runs.}
#'   \item{hruns}{Integer. Home team runs.}
#'   \item{temp}{Integer. Reported temperature.}
#'   \item{fieldcond}{Character. Field condition description.}
#'   \item{precip}{Character. Precipitation conditions.}
#'   \item{sky}{Character. Sky conditions.}
#'   \item{winddir}{Character. Wind direction.}
#' }
#'
#' @details
#' - The function reads `gameinfo.csv` from the package’s `extdata/` folder.
#' - Ballpark capacity data is obtained from \code{\link{scrape_old_ballparks}}.
#' - The two datasets are merged by `site` (game location) and `season` (game year).
#'
#' @importFrom readr read_csv
#' @importFrom dplyr reframe
#'
#' @examples
#' \dontrun{
#' # Combine 2024 game info with ballpark data
#' combined <- combine_ballpark_data(2024)
#' head(combined)
#' }
#'
#' @export

combine_ballpark_data <- function(year)
{
  gameinfo<-readr::read_csv(system.file("extdata", "gameinfo.csv", package = "MLBEconomics")) %>%
    dplyr::reframe(gid, visteam, hometeam, site, starttime, attendance,
            fieldcond, precip, sky, temp, winddir, windspeed,
            gametype, vruns, hruns, season)
  capacity_data <- scrape_old_ballparks(year) %>%
    filter(!duplicated(team_id))
  combined_data <- merge(gameinfo, capacity_data,
                by.x=c("site"), by.y=c("team_id"), all.x=T) %>%
    dplyr::reframe(site, gid, date=as.Date(substr(gid, 4, 12), format = "%Y%m%d"),
            visteam, hometeam, starttime, attendance, Capacity,
            vruns, hruns, temp, fieldcond, precip, sky, winddir)
}
