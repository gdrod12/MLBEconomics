

clean_fa_data <- function()
{
  #
  file_path <- system.file("extdata", "free_agency_data.xlsx", package = "MLBEconomics")
  # List sheet names (each year is a tab)
  sheets <- readxl::excel_sheets(file_path)
  sheets <- sheets[!sheets %in% c("FA Spending", "FA Trends")]
  # Loop through all years and store in a list
  all_years <- lapply(sheets, function(sheet) {
    df <- readxl::read_excel(file_path, sheet = sheet, col_names = FALSE)

    # find the row that has "Age" (or another reliable header column)
    header_row <- which(df[,1] == "Player")[1]   # example: 3rd col should be "Age"

    # set column names
    names(df) <- df[header_row, ]

    # drop all rows up to header
    df <- df[-c(1:header_row), ]

    # optional: convert types automatically
    df <- readr::type_convert(df, na = c("", "NA"))
    if ("Opt Out" %in% names(df)) {
      df$`Opt Out` <- as.character(df$`Opt Out`)
    }
    df$year <- sheet
    df
  })

  data<-purrr::reduce(all_years, dplyr::bind_rows)
  data <- data |>
    dplyr::reframe(Player, position=`Pos'n`,
                   age = sum(`Age 7/1/25`, `Age 7/1/24`, `Age 7/1/23`,
                             `Age 7/1/22`, `Age 7/1/21`, Age, na.rm=T),
                   qualifying_offer = `Qual    Offer`,
                   old_team = `Old    Club`, new_team = `New Club`,
                   years=Years, guarantee=Guarantee, option=Option,
                   opt_out = `Opt Out`, player_agent=`Player Agent`,
                   club_owner = `Club Owner`, general_manager = `Baseball Ops      head / club GM`,
                   year)

}

