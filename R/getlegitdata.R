
create_beta_data <- function(){
  teamids <- readr::read_csv(
  "https://www.retrosheet.org/TEAMABR.TXT",
  col_names = FALSE) |>
  dplyr::select(-c(2, 6))

  colnames(teamids) <- c(
    "retro_id", "city", "nickname",
    "first_year")
  teamids <- teamids |>
    dplyr::filter(!(retro_id == "HOU" & nickname == "Colts"),
          !(retro_id == "MIL" & nickname == "Brewers"&first_year==1970))

  get_data <- function(game_index) {
  #get data
  data_input <- MLBEconomics::attendance_data |>
    dplyr::filter(gametype == "regular", season>=1990, season!=1994,
          season!=1995, season!=2020) |>
    # reshape so every team appears once per game (home and away)
    dplyr::mutate(date = as.Date(date)) |>
    dplyr::select(date, season, gametype, hometeam, visteam, hruns, vruns, attendance, capacity) |>
    tidyr::pivot_longer(
      cols = c(hometeam, visteam),
      names_to = "home_or_away",
      values_to = "team") |>
    dplyr::arrange(team, date, .by_group = TRUE) |>
    dplyr::group_by(team, season) |>
    dplyr::mutate(GameNum = dplyr::row_number()) |>
    dplyr::ungroup()

  record_before <- {data_input |>
      dplyr::filter(GameNum<game_index, home_or_away=="hometeam") |>
      dplyr::group_by(team, season, gametype) |>
      dplyr::reframe(
        home_wins   = sum(hruns > vruns, na.rm = TRUE),
        home_losses = sum(vruns > hruns, na.rm = TRUE),
        home_ties   = sum(hruns == vruns, na.rm = TRUE),
        .groups = "drop") |>
      dplyr::full_join(data_input |>
                dplyr::filter(GameNum<game_index, home_or_away=="visteam") |>
                dplyr::mutate(season = lubridate::year(date)) |>
                dplyr::group_by(team, season, gametype) |>
                dplyr::reframe(
                  away_wins   = sum(vruns > hruns, na.rm = TRUE),
                  away_losses = sum(hruns > vruns, na.rm = TRUE),
                  away_ties   = sum(hruns == vruns, na.rm = TRUE),
                  .groups = "drop"), by = c("team", "season", "gametype")) |>
      dplyr::mutate(
        total_wins   = ifelse(is.na(home_wins), 0, home_wins) +
          ifelse(is.na(away_wins), 0, away_wins),
        total_losses = ifelse(is.na(home_losses), 0, home_losses) +
          ifelse(is.na(away_losses), 0, away_losses),
        win_percentage=(total_wins)/(total_wins+total_losses)) |>
      dplyr::arrange(season, gametype, team)}
  #get mean attendance data for second half of season, (defined by being in July or later)
  attendance_after <- {data_input |>
      dplyr::filter(home_or_away=="hometeam") |>
      dplyr::filter(GameNum>=game_index) |>
      dplyr::group_by(team, season) |>
      dplyr::reframe(games = dplyr::n(),
              capacity=mean(capacity),
              total_attendance = sum(attendance, na.rm = TRUE),
              no_att = sum(is.na(attendance) | attendance == 0, na.rm = TRUE),
              .groups = "drop") |>
      dplyr::filter(season!=2020, season!=1994,
              season!=1995,
              season>=1990) |>
      dplyr::mutate(mean_attendance=total_attendance/(games-no_att)) |>
      dplyr::left_join(teamids, by = c("team" = "retro_id")) |>
      dplyr::left_join(MLBEconomics::vegas_data, by=c("city", "nickname",
                                             "team" = "retro_id",
                                             "season" = "year")) |>
      dplyr::left_join(record_before, by=c("team",
                                  "season")) |>
      dplyr::mutate(predicted_win_rate = preseason/162) |>
      dplyr::mutate(games_played = rowSums(dplyr::across(c(home_wins, home_losses,
                                                  away_wins, away_losses)),
                                         na.rm = TRUE)) |>
      dplyr::reframe(team, city, nickname, season, remaining_home_games=games,
           capacity, total_attendance, no_attendance_recorded=no_att,
           mean_attendance, preseason, win_percentage, games_played)}
    return(attendance_after)
  }
  return(purrr::reduce(lapply(2:161, get_data), rbind))
}

