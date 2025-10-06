library(tidyverse)
teamids <- read_csv(
  "https://www.retrosheet.org/TEAMABR.TXT",
  col_names = FALSE
) |>
  select(-c(2, 6))

colnames(teamids) <- c(
  "retro_id", "city", "nickname",
  "first_year"
)
teamids
vegas_data<-MLBEconomics::vegas_data
team_names_vegas <- vegas_data |>
  reframe(team, year)
write_csv(team_names_vegas, "vegas_namehelper.csv")




file_path <- "inst/extdata/vegas_translations.csv"

vegas_translations <- read_csv("inst/extdata/vegas_translations.csv")

attendance_data <- attendance_data
retrosheet_names <- attendance_data |>
  left_join(teamids, by = c("hometeam" = "retro_id")) |>
  reframe(retro_id=hometeam, city, nickname, season) |>
  group_by(retro_id, city, nickname, season) |>
  reframe(games=n()) |>
  filter(season>=1990, !is.na(city))
write_csv(retrosheet_names, "retrosheet_seasonnames.csv")
#get season record data
season_records <- attendance_data |>
  mutate(season = year(date)) |>
  group_by(team = hometeam, season, gametype) |>
  summarise(
    home_wins   = sum(hruns > vruns, na.rm = TRUE),
    home_losses = sum(vruns > hruns, na.rm = TRUE),
    home_ties   = sum(hruns == vruns, na.rm = TRUE),
    .groups = "drop"
  ) |>
  full_join(
    attendance_data |>
      mutate(season = year(date)) |>
      group_by(team = visteam, season, gametype) |>
      summarise(
        away_wins   = sum(vruns > hruns, na.rm = TRUE),
        away_losses = sum(hruns > vruns, na.rm = TRUE),
        away_ties   = sum(hruns == vruns, na.rm = TRUE),
        .groups = "drop"
      ),
    by = c("team", "season", "gametype")
  ) |>
  mutate(
    total_wins   = home_wins + away_wins,
    total_losses = home_losses + away_losses,
    total_ties   = home_ties + away_ties
  ) |>
  arrange(season, gametype, team)

#get mean attendance data
mean_attendance <- attendance_data |>
  mutate(season = year(date)) |>
  group_by(hometeam, season) |>
  summarise(
    games = n(),
    capacity=mean(capacity),
    total_attendance = sum(attendance, na.rm = TRUE),
    no_att = sum(is.na(attendance) | attendance == 0, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(mean_attendance=total_attendance/(games-no_att)) |>
  left_join(teamids, by = c("hometeam" = "retro_id")) |>
  mutate(team_name = paste0(city, " ", nickname)) |>
  left_join(vegas_data, by=c("team_name" = "team",
                             "season" = "year")) |>
  left_join(season_records |>
              filter(gametype=="regular"), by=c("hometeam"="team",
                                 "season")) |>
  mutate(over_under10 = as.factor(ifelse(total_wins>preseason, 1, 0)),
         percent_filled = mean_attendance/capacity)

ggplot(data=mean_attendance |>
         filter(season!=2020, season>=1990), aes(x=preseason, y=mean_attendance, color=over_under10)) +
  geom_point() +
  geom_smooth(method="lm", se=F)

ggplot(data=mean_attendance |>
         filter(season!=2020, season!=1994, season!=1995, season>=1990, games>70), aes(y=mean_attendance)) +
  geom_point(aes(x=total_wins), color="4B0082", alpha=0.4) +
  geom_smooth(aes(x=total_wins), method="lm", se=F, color="blue", size=1.5) +
  geom_point(aes(x=preseason), color="#E83A1C", alpha=0.4) +
  geom_smooth(aes(x=preseason), method="lm", se=F, color="red", size=1.5) +
  ggtitle("Preseason expectation better predicts attendance than actual win/loss",
          subtitle="Preseason expectations in red, season outcome in blue (data from 1990-2024)") +
  xlab("Win Total") +
  ylab("Average Attendance")

ggplot(data=mean_attendance |>
         filter(season!=2020, season!=1994, season!=1995, season>=1990, games>70), aes(y=percent_filled)) +
  geom_point(aes(x=total_wins), color="4B0082", alpha=0.4) +
  geom_smooth(aes(x=total_wins), method="lm", se=F, color="blue", size=1.5) +
  geom_point(aes(x=preseason), color="#E83A1C", alpha=0.4) +
  geom_smooth(aes(x=preseason), method="lm", se=F, color="red", size=1.5) +
  ggtitle("Preseason expectation better predicts attendance than actual win/loss",
          subtitle="Preseason expectations in red, season outcome in blue (data from 1990-2024)") +
  xlab("Proportion of Stadium Filled") +
  ylab("Average Attendance")
test <- mean_attendance |>
  filter(season!=2020, season>=1990, games>5)
