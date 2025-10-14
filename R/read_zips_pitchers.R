#' Load and Combine ZiPS Pitcher Projections
#'
#' Reads all available ZiPS pitcher projection CSV files (from the package's
#' `extdata` directory) from 2010 up to a user-specified ending year, combines
#' them into a single data frame, and returns the result with standardized
#' column names.
#'
#' Each yearly CSV file must be named using the convention
#' `"zipspitchers<year>.csv"`, e.g. `"zipspitchers2015.csv"`, and stored in
#' the `inst/extdata/` directory of the `MLBEconomics` package.
#'
#' @param end_year Integer. The final season year to include (e.g., `2024`).
#'   Data will be read from 2010 through `end_year` inclusive.
#'
#' @return A tibble containing the combined ZiPS pitcher projections with the
#'   following columns:
#'   \describe{
#'     \item{Name}{Pitcher’s name.}
#'     \item{Team}{Team abbreviation.}
#'     \item{IP}{Innings pitched.}
#'     \item{G}{Games pitched.}
#'     \item{GS}{Games started.}
#'     \item{ERA}{Earned run average.}
#'     \item{FIP}{Fielding Independent Pitching.}
#'     \item{WAR}{Wins Above Replacement.}
#'     \item{NameASCII}{ASCII-safe version of the pitcher’s name.}
#'     \item{PlayerId}{Internal player ID.}
#'     \item{MLBAMID}{MLB Advanced Media ID.}
#'     \item{season}{The season year.}
#'   }
#'
#' @examples
#' \dontrun{
#' zips_pitchers <- get_zips_pitchers(2023)
#' head(zips_pitchers)
#' }
#'
#' @importFrom readr read_csv
#' @importFrom purrr reduce
#' @importFrom dplyr select
#' @export
get_zips_pitchers <- function(end_year) {
  read_data <- function(year) {
    filename <- system.file("extdata", paste0("zipspitchers", year, ".csv"), package = "MLBEconomics")
    new_data <- readr::read_csv(filename)
    new_data$season <- year
    new_data
  }
  purrr::reduce(lapply(2010:end_year, read_data), rbind) |>
    dplyr::select(Name, Team, IP, G, GS, ERA, FIP, WAR,
                  NameASCII, PlayerId, MLBAMID, season)
}
