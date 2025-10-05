#' Clean and Combine Free Agency Data
#'
#' Reads, cleans, and merges yearly free agency data from the `free_agency_data.xlsx`
#' file stored in the package’s `extdata` directory. Each sheet corresponds to a different
#' year, and this function standardizes their structure, converts data types, and combines
#' all years into a single cleaned dataset.
#'
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Locates the Excel file within the installed package using \code{system.file()}.
#'   \item Identifies all sheet names (each representing a year) and removes the summary sheets
#'         "FA Spending" and "FA Trends".
#'   \item Iterates through each sheet:
#'     \itemize{
#'       \item Reads the raw data with no column names.
#'       \item Detects the header row based on the location of the "Player" label.
#'       \item Sets column names and removes pre-header rows.
#'       \item Automatically converts column types with \code{readr::type_convert()}.
#'       \item Adds a `year` column for identification.
#'     }
#'   \item Concatenates all years into one data frame.
#'   \item Selects and renames key columns to standardized names, computing
#'         an aggregated \code{age} variable as the sum of all available age columns.
#' }
#'
#' @return
#' A cleaned tibble containing player-level free agency data with consistent column names,
#' including:
#' \itemize{
#'   \item \code{Player}
#'   \item \code{position}
#'   \item \code{age}
#'   \item \code{qualifying_offer}
#'   \item \code{old_team}
#'   \item \code{new_team}
#'   \item \code{years}
#'   \item \code{guarantee}
#'   \item \code{option}
#'   \item \code{opt_out}
#'   \item \code{player_agent}
#'   \item \code{club_owner}
#'   \item \code{general_manager}
#'   \item \code{year}
#' }
#'
#' @examples
#' \dontrun{
#' fa_data <- clean_fa_data()
#' head(fa_data)
#' }
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom readr type_convert
#' @importFrom purrr reduce
#' @importFrom dplyr bind_rows reframe
#'
#' @noRd


clean_fa_data <- function(){
  #read in data locally
  file_path <- "inst/extdata/free_agent_data.xlsx"
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
  #reduce the looped data
  data<-purrr::reduce(all_years, dplyr::bind_rows)
  #data and name cleaning
  data <- data |>
    dplyr::mutate(
      age = rowSums(
        dplyr::select(data, tidyselect::any_of(c(
          "Age 7/1/25", "Age 7/1/24", "Age 7/1/23",
          "Age 7/1/22", "Age 7/1/21", "Age"
        ))),
        na.rm = TRUE
      )
    ) |>
    dplyr::reframe(Player, position=`Pos'n`, age,
                   qualifying_offer = `Qual    Offer`,
                   old_team = `Old    Club`, new_team = `New Club`,
                   years=Years, guarantee=Guarantee, option=Option,
                   opt_out = `Opt Out`, player_agent=`Player Agent`,
                   club_owner = `Club Owner`, general_manager = `Baseball Ops      head / club GM`,
                   year) |>
    dplyr::filter(age>20, !is.na(years))

}



