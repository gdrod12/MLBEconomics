library(tidyverse)
devtools::install_github("gdrod12/MLBEconomics")
zips_batter_data<-MLBEconomics::zips_batter_data |>
  dplyr::mutate(WAR=ifelse(season==2020, WAR*162/60,
                       WAR))
zips_pitcher_data<-MLBEconomics::zips_pitcher_data |>
  mutate(war_ip=WAR/IP)

league_fips <- test |>
  group_by(season) |>
  reframe(fip=median(FIP))

df_next <- zips_batter_data |>
  dplyr::mutate(season = season - 1) |>    # shift seasons down by 1
  dplyr::select(PlayerId, season, WAR_next = WAR)

df_joined <- zips_batter_data |>
  dplyr::left_join(df_next, by = c("PlayerId", "season"))
player_results <- read.csv(
  system.file("extdata", "player_results.csv", package = "MLBEconomics")
)

sp_data <- read.csv(
  system.file("extdata", "sp_data.csv", package = "MLBEconomics")
)
sp_means <- sp_data |>
  group_by(Season) |>
  reframe(mean_sp_fip=sum(IP*FIP)/sum(IP))
rp_data <- read.csv(
  system.file("extdata", "rp_data.csv", package = "MLBEconomics")
)
rp_means <- rp_data |>
  group_by(Season) |>
  reframe(mean_rp_fip=sum(IP*FIP)/sum(IP))
zips_pitcher_data<-zips_pitcher_data |>
  filter(season!=2010) |>
  left_join(sp_means, by=c("season"="Season")) |>
  left_join(rp_means, by=c("season"="Season")) |>
  mutate(league_fip=ifelse(G/GS>2, mean_rp_fip, mean_sp_fip),
         replacement=ifelse(G/GS>2, 0.03, 0.12)) |>
  mutate(waa=(league_fip - FIP)/9.7,
         calc_war=(waa+replacement)*IP/9,
         calc_waa=waa*IP/9)


  test<-merge(df_joined, player_results, by.x=c("PlayerId",
                                      "MLBAMID",
                                      "NameASCII",
                                      "Name",
                                      "season"),
            by.y=c("PlayerId",
                   "MLBAMID",
                   "NameASCII",
                   "Name",
                   "Season")) |>
  dplyr::filter(season<2025) |>
  dplyr::mutate(WAR_next=ifelse(is.na(WAR_next), 0, WAR_next)) |>
  dplyr::mutate(war_next_diff = WAR_next-WAR.x)

ggplot2::ggplot(data=test, ggplot2::aes(x=Age, y=war_next_diff)) +
  ggplot2::geom_point() +
  ggplot2::geom_smooth()
model_poly <- lm(war_next_diff ~ poly(Age, 2, raw = TRUE), data = test)
summary(model_poly)
ggplot2::ggplot(test, ggplot2::aes(Age, war_next_diff)) +
  ggplot2::geom_point(alpha = 0.3) +
  ggplot2::geom_smooth(method = "lm", formula = y ~ poly(x, 2), color = "blue") +
  ggplot2::theme_minimal()
model_poly_int <- lm(
  WAR.y ~ Age*WAR.x,
  data = test
)
summary(model_poly_int)
test$predicted <- model_poly_int$fitted.values


predict_future_war <- function(age, war, model, seasons = 5) {
  out <- data.frame(season = 0:seasons, Age = NA, PredWAR = NA)
  out$Age[1] <- age
  out$PredWAR[1] <- war

  for (i in 2:(seasons + 1)) {
    out$Age[i] <- out$Age[i - 1] + 1
    war_next_diff <- predict(model, newdata = data.frame(
      Age = out$Age[i - 1],
      WAR = out$PredWAR[i - 1]
    ))
    out$PredWAR[i] <- out$PredWAR[i - 1] + war_next_diff
  }

  return(out)
}

project_war <- function(df, model, n_years = 5) {
  # Check that required predictors exist
  needed <- all(c("Age", "WAR.x") %in% names(df))
  if (!needed) stop("Your dataframe must contain columns 'Age' and 'WAR'")

  df_proj <- df

  # Store original Age/WAR for reference
  df_proj$Age_0 <- df_proj$Age
  df_proj$WAR_0 <- df_proj$WAR.x

  # Loop through future years
  for (i in 1:n_years) {
    # Make sure prediction input matches model terms
    pred_diff <- predict(model, df_proj)
    print(df_proj)
    # Verify length matches number of rows
    if (length(pred_diff) != nrow(df_proj)) {
      stop("Prediction length mismatch — check your model formula and column names.")
    }

    # Predicted WAR for next year
    df_proj[[paste0("WAR_", i)]] <- pred_diff

    # Store next year's age
    df_proj[[paste0("Age_", i)]] <- df_proj$Age + 1

    # Update for next iteration
    df_proj$WAR.x <- df_proj[[paste0("WAR_", i)]]
    df_proj$Age <- df_proj[[paste0("Age_", i)]]
  }

  return(df_proj)
}

mmmm<-project_war(test, model_poly_int, n_years=15)
predict(model_poly_int, data.frame(Age=33, WAR.x=6.42))

library(mgcv)
gam_model <- gam(war_next_diff ~ s(Age), data = test)
plot(gam_model, pages = 2)


predict_future_war_wide <- function(model, data, n_years = 5) {

  # helper: recursively predict WAR forward n_years from a single starting point
  predict_forward <- function(age, war_current, n_years) {
    preds <- numeric(n_years)
    current_age <- age
    current_war <- war_current

    for (i in 1:n_years) {
      newdata <- data.frame(Age = current_age)
      pred_diff <- predict(model, newdata = newdata)
      current_war <- current_war + pred_diff  # add diff to current WAR
      preds[i] <- current_war
      current_age <- current_age + 1
    }
    return(as.list(preds))
  }

  # run prediction for each player-season
  projections <- data %>%
    mutate(proj = pmap(list(Age, WAR.x), ~predict_forward(..1, ..2, n_years))) %>%
    unnest_wider(proj, names_sep = "_") %>%
    rename_with(~paste0("proj_", seq_len(n_years)), starts_with("proj_"))

  return(projections)
}


proj_wide <- predict_future_war_wide(gam_model, test, n_years = 15)
head(proj_wide)
str(proj_wide)

summary(gam_model)



fa_data<-MLBEconomics::free_agent_data
str(fa_data)





library(stringr)

fa_data_clean <- fa_data %>%
  mutate(Name_clean = str_squish(str_replace(Player, "^\\s*([^,]+),\\s*(.+)$", "\\2 \\1")))
proj_wide_clean <- proj_wide %>%
  mutate(Name_clean = str_squish(Name))
str(fa_data_clean)
str(proj_wide_clean)

# --- 1. Join on Name_clean ---
joined <- fa_data_clean %>%
  inner_join(
    proj_wide_clean %>%
      select(Name_clean, Age, starts_with("proj_")),
    by = "Name_clean"
  ) %>%
  group_by(Name_clean, age, years, guarantee, old_team, new_team, player_agent) %>%
  slice_min(abs(Age - age), with_ties = FALSE) %>%  # pick projection closest to signing age
  ungroup()

# --- 2. Compute total projected WAR over contract length ---
fa_proj_summary <- joined %>%
  rowwise() %>%
  mutate(
    total_proj_war = {
      n <- as.integer(years)
      if (is.na(n) || n < 1) NA_real_
      else {
        proj_cols <- paste0("proj_", seq_len(n))
        proj_cols <- intersect(proj_cols, names(cur_data()))
        sum(unlist(cur_data()[proj_cols]), na.rm = TRUE)
      }
    },
    avg_annual_war = if (!is.na(total_proj_war)) total_proj_war / years else NA_real_
  ) %>%
  ungroup() %>%
  mutate(
    dollars_per_year = guarantee / years,
    dollars_per_war = ifelse(!is.na(total_proj_war) & total_proj_war > 0,
                             guarantee / total_proj_war, NA_real_)
  ) %>%
  select(
    Name_clean, age, years, guarantee,
    old_team, new_team, player_agent,
    total_proj_war, avg_annual_war,
    dollars_per_year, dollars_per_war, year
  )

ggplot(data=fa_proj_summary |>
         filter(Name_clean!="Shohei Ohtani"), aes(x=total_proj_war, y=guarantee)) +
  geom_point() +
  geom_smooth(method="lm")

ggplot(data=fa_proj_summary |>
         filter(Name_clean!="Shohei Ohtani"), aes(x=log(total_proj_war), y=log(guarantee))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_smooth(method="gam")
gam_salary <- gam(log(guarantee) ~ s(log(total_proj_war)), data = fa_proj_summary)

summary(gam_salary)
plot(gam_salary, shade = TRUE, main = "Smooth relationship: log(WAR) → log(Salary)")
summary(lm(data=fa_proj_summary, guarantee~total_proj_war))

summary(lm(data=fa_proj_summary, guarantee~total_proj_war+year))
