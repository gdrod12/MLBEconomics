#' Historical MLB Attendance Data
#'
#' A dataset containing game-level attendance and game information for Major League Baseball
#' (and predecessor leagues) from 1926 onward, including team identifiers, scores, and basic
#' environmental conditions.
#'
#' @format A data frame with 221,173 observations and 17 variables:
#' \describe{
#'   \item{site}{Character. Retrosheet park or site identifier.}
#'   \item{gid}{Character. Unique game identifier (e.g., "ACY192610060").}
#'   \item{date}{Date. Date on which the game was played.}
#'   \item{season}{Numeric. Season year (e.g., 1926, 1927, ...).}
#'   \item{visteam}{Character. Visiting team 3-letter Retrosheet code.}
#'   \item{hometeam}{Character. Home team 3-letter Retrosheet code.}
#'   \item{starttime}{hms. Game start time, when available.}
#'   \item{attendance}{Numeric. Reported paid attendance. May be 0 or NA for missing data.}
#'   \item{capacity}{Numeric. Ballpark seating capacity for the given game, when available.}
#'   \item{vruns}{Numeric. Runs scored by the visiting team.}
#'   \item{hruns}{Numeric. Runs scored by the home team.}
#'   \item{temp}{Numeric. Reported game-time temperature in °F, if available (0 indicates missing).}
#'   \item{fieldcond}{Character. Field condition (e.g., "dry", "damp", "unknown").}
#'   \item{precip}{Character. Precipitation conditions (e.g., "none", "drizzle", "unknown").}
#'   \item{sky}{Character. Sky condition (e.g., "sunny", "cloudy", "unknown").}
#'   \item{winddir}{Character. Wind direction descriptor (e.g., "in from LF", "unknown").}
#'   \item{gametype}{Character. Type of game ("championship", "exhibition", "postseason", etc.).}
#' }
#'
#' @source Data compiled from \href{https://www.retrosheet.org/}{Retrosheet Game Logs},
#' merged with supplemental capacity and environmental data from Seamheads Ballparks and MLB sources.
#'
#' @details
#' This dataset serves as a core input for MLB attendance and capacity analysis in the
#' \pkg{MLBEconomics} package. Missing attendance or capacity values reflect historical
#' record limitations. Weather-related fields are largely unavailable for pre-1970 games.
#'
#' @examples
#' data(attendance_data)
#' dplyr::glimpse(attendance_data)
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

#' MLB Team Revenue and Cost Breakdown (2022–2024)
#'
#' A dataset containing annual nominal revenues and costs for Major League Baseball operations,
#' grouped by major business categories.
#'
#' @format A tibble (or data frame) with 15 rows and 3 variables:
#' \describe{
#'   \item{year}{Numeric. The fiscal year of record (2022–2024).}
#'   \item{category}{Character. The category of revenue or cost. One of:
#'   \code{"baseball_event"}, \code{"broadcasting"}, \code{"retail_licensing"},
#'   \code{"other"}, or \code{"baseball_costs"}.}
#'   \item{revenue_nominal}{Character. The nominal dollar amount in U.S. dollars
#'   as reported, formatted with a leading \code{"$"} sign and commas. Negative
#'   values represent expenses.}
#' }
#'
#' @details
#' This dataset summarizes the Atlanta Braves' primary business revenue streams and operational costs
#' from 2022 through 2024. It reflects nominal figures (not adjusted for inflation) as
#' reported by internal financial summaries. Categories are grouped into event-based income,
#' media/broadcasting, retail and licensing, miscellaneous income, and baseball-related costs.
#'
#' @source Internal Atlanta Braves finance reports (compiled manually, 2022–2024)
#'
#' @examples
#' data(braves_revenue)
#' head(braves_revenue)
"braves_revenue"


#' MLB Opening Day Salaries (2000–2025)
#'
#' A dataset containing Major League Baseball player salaries on Opening Day
#' rosters from 2000 through 2025. Each row represents a player’s salary record
#' for a given season, including position, salary, and years of MLB service time
#' when available.
#'
#' @format A tibble (or data frame) with 26,128 rows and 5 variables:
#' \describe{
#'   \item{player}{Character. Player’s full name in "Last, First" format.}
#'   \item{position}{Character. Primary field position abbreviation (e.g., \code{"1b"}, \code{"ss"}, \code{"rf"}).}
#'   \item{salary}{Numeric. Player’s annual salary in U.S. dollars for that season.}
#'   \item{season}{Numeric. Year corresponding to the MLB season.}
#'   \item{service_time}{Numeric. Player’s total MLB service time (in years), when available; may contain \code{NA}.}
#' }
#'
#' @details
#' This dataset combines Opening Day salary information across multiple MLB seasons.
#' Data from 2000–2009 were collected from earlier-format sheets that omit service time,
#' while 2010–2025 data include standardized service time and salary fields.
#'
#' All salaries are nominal and represent reported Opening Day contract figures
#' rather than prorated or end-of-year totals.
#'
#' @source
#' Cot's baseball contracts (2000–2025).
#'
#' @examples
#' data(opening_day_salaries)
#' dplyr::glimpse(opening_day_salaries)
#' dplyr::filter(opening_day_salaries, season == 2009) |> head()
"opening_day_salaries"

#' MLB Free Agent Contract Data (1991–2025)
#'
#' A dataset containing information on Major League Baseball free agent signings
#' from 1991 through 2025, including player demographics, contract details,
#' and team affiliations.
#'
#' @format A tibble (or data frame) with 4,505 rows and 14 variables:
#' \describe{
#'   \item{Player}{Character. Player’s full name in "Last, First" format.}
#'   \item{position}{Character. Player’s position abbreviation (e.g., \code{"rf"}, \code{"lhp-s"}, \code{"ss"}).}
#'   \item{age}{Numeric. Player’s age at the time of signing.}
#'   \item{qualifying_offer}{Character. Whether the player received and/or accepted a qualifying offer (\code{"rejected"}, \code{"accepted"}, or \code{NA}).}
#'   \item{old_team}{Character. Abbreviation of the player’s prior MLB team.}
#'   \item{new_team}{Character. Abbreviation of the MLB team signing the player.}
#'   \item{years}{Numeric. Contract length in years.}
#'   \item{guarantee}{Numeric. Total guaranteed value of the contract in U.S. dollars.}
#'   \item{option}{Character. Option type included in the deal (e.g., \code{"team"}, \code{"player"}, or \code{"mutual"}); may be \code{NA}.}
#'   \item{opt_out}{Character. Whether the contract includes an opt-out clause; may be \code{NA}.}
#'   \item{player_agent}{Character. The player’s representation agency or agent name.}
#'   \item{club_owner}{Character. Name of the team’s principal owner at the time of signing.}
#'   \item{general_manager}{Character. Team’s general manager or baseball operations head(s).}
#'   \item{year}{Character. Year the contract was signed or became official.}
#' }
#'
#' @details
#' This dataset consolidates MLB free agent contract information over a 34-year period,
#' capturing both high-profile and lower-tier signings. It includes data from publicly
#' available transaction logs, team announcements, and verified media reports.
#'
#' The \code{guarantee} field reflects total guaranteed money (excluding incentives).
#' When applicable, qualifying offer status, option clauses, and opt-out details
#' are included for completeness.
#'
#' @source
#' Compiled from Cot’s Baseball Contracts (1991–2025).
#'
#' @examples
#' data(free_agent_data)
#' dplyr::glimpse(free_agent_data)
#' dplyr::filter(free_agent_data, year == "2025", new_team == "NYN") |> head()
"free_agent_data"

