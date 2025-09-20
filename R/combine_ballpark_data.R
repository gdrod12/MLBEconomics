#' @importFrom magrittr %>%
NULL

combine_ballpark_data <- function(year)
{
  gameinfo<-readr::read_csv(system.file("extdata", "gameinfo.csv", package = "MLBEconomics")) %>%
    dplyr::reframe(gid, visteam, hometeam, site, starttime, attendance,
            fieldcond, precip, sky, temp, winddir, windspeed,
            gametype, vruns, hruns, season)
  capacity_data <- scrape_old_ballparks(year)
  combined_data <- merge(gameinfo, capacity_data,
                by.x=c("site", "season"), by.y=c("team_id", "Year"), all.x=T) %>%
    dplyr::reframe(site, gid, date=as.Date(substr(gid, 4, 12), format = "%Y%m%d"),
            visteam, hometeam, starttime, attendance, Capacity,
            vruns, hruns, temp, fieldcond, precip, sky, winddir)
}
