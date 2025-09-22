#' Plot Team Attendance with Stadium Changes
#'
#' This function plots a given team's home attendance over a specified range of seasons,
#' and highlights years when the team's primary stadium changed.
#'
#' @param team Character string. Team ID (must match the \code{hometeam} values in \code{attendance_data}).
#' @param start_year Integer. First season to include in the plot.
#' @param end_year Integer. Last season to include in the plot.
#'
#' @details
#' Attendance values are averaged across home games per season. Stadium changes are identified
#' from the \code{primary_sites} dataset, and change years are shown with vertical dashed lines.
#'
#' @return A \code{ggplot} object showing average attendance by season, with lines colored by stadium.
#'
#' @examples
#' \dontrun{
#' # Example: Plot Yankees attendance from 2000 to 2020
#' plot_team_attendance("NYY", 2000, 2020)
#' }
#' @importFrom magrittr %>%
#' @export


plot_team_attendance <- function(start_year, end_year) {
  # pick team interactively from your dataset
  team <- choose_team(MLBEconomics::attendance_data)

  #get primary sites for the team in question
  primary_sites <-MLBEconomics:: attendance_data |>
    dplyr::mutate(season = lubridate::year(date)) |>
    dplyr::filter(hometeam == team,
                  season >= start_year,
                  season <= end_year) |>
    dplyr::group_by(hometeam, season, site) |>
    dplyr::summarise(home_games = dplyr::n(), .groups = "drop") |>
    dplyr::group_by(hometeam, season) %>%
    dplyr::slice_max(order_by = home_games, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  # stadium-change years
  changes <- primary_sites |>
    dplyr::arrange(season) |>
    dplyr::mutate(prev_site = dplyr::lag(site),
                  stadium_changed = site != prev_site & !is.na(prev_site)) |>
    dplyr::filter(stadium_changed)

  # --- season attendance series (avg per season, colored by site) ---
  team_data <- MLBEconomics::attendance_data |>
    dplyr::mutate(season = lubridate::year(date)) |>
    dplyr::filter(hometeam == team,
                  season >= start_year,
                  season <= end_year,
                  !is.na(attendance)) |>
    dplyr::group_by(season, site) |>
    dplyr::summarise(avg_attendance = mean(attendance, na.rm = TRUE),
                     .groups = "drop")

  ggplot2::ggplot(team_data,
                  ggplot2::aes(x = season, y = avg_attendance,
                               group = site, color = site)) +
    ggplot2::geom_line(size = 1.2) +
    ggplot2::geom_point(size = 2) +
    ggplot2::geom_vline(data = changes,
                        ggplot2::aes(xintercept = season),
                        linetype = "dashed", color = "red") +
    ggplot2::labs(
      title = paste(team, "Attendance", start_year, "-", end_year),
      x = "Season", y = "Average Attendance", color = "Stadium"
    ) +
    ggplot2::theme_minimal()
}


