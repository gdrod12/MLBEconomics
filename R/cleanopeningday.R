#' Clean MLB Opening Day Salary Data
#'
#' Reads and combines all sheets from the `mlb_salaries.xlsx` file located in
#' `inst/extdata/`, cleaning and standardizing the data structure across years.
#'
#' This function:
#' \itemize{
#'   \item Reads the first four columns of each sheet in the Excel workbook.
#'   \item Handles sheet-specific differences between pre-2010 and post-2010 data.
#'   \item Dynamically assigns column names based on the presence of a service time column.
#'   \item Converts salary and service time to numeric values.
#'   \item Adds a `season` column derived from the sheet name (first four characters).
#'   \item Filters out rows with missing or total summary data.
#' }
#'
#' @details
#' The Excel workbook should be located at `inst/extdata/mlb_salaries.xlsx`.
#' Sheets 1–16 (2010–2025) follow a consistent structure, while sheets 17–26
#' (2000–2009) have a slightly different format and are handled separately.
#'
#' @return
#' A tibble containing the cleaned and standardized MLB Opening Day salary data
#' across all seasons, with columns:
#' \describe{
#'   \item{player}{Player name.}
#'   \item{position}{Player's position.}
#'   \item{service_time}{Years of MLB service time (numeric, may contain NAs).}
#'   \item{salary}{Player's salary (numeric).}
#'   \item{season}{Season year as a numeric value.}
#' }
#'
#' @examples
#' \dontrun{
#' clean_data <- clean_opening_day()
#' head(clean_data)
#' }
#'
#' @keywords internal
#'
clean_opening_day <- function(){
  #establish file path
  path <- "inst/extdata/mlb_salaries.xlsx"
  #get sheet names
  sheets <- readxl::excel_sheets(path)
  #function to read first 4 columns and use row 2 as column names
  read_first4 <- function(sheet) {
    #read xlsx file into R
    df <- readxl::read_excel(
      path,
      sheet = sheet,
      range = readxl::cell_limits(c(3, 1), c(NA, 4)),
      col_names = FALSE)

    #detect if the 4th column is actually empty
    has_fourth_col_data <- !all(is.na(df[[4]]))

    #assign names dynamically
    if (has_fourth_col_data) {
      names(df) <- c("player", "position", "service_time", "salary")[seq_len(ncol(df))]
    } else {
      df <- df[, 1:3, drop = FALSE]
      names(df) <- c("player", "position", "salary")
      #rename the 3rd column to salary since it's likely salary if no service_time col
    }

    #numeric conversions
    if ("service_time" %in% names(df))
      df$service_time <- suppressWarnings(as.numeric(df$service_time))

    if ("salary" %in% names(df))
      df$salary <- suppressWarnings(as.numeric(df$salary))

    #add season from sheet name (first 4 chars)
    df$season <- as.numeric(substr(sheet, 1, 4))

    return(df)
  }


  # Read all sheets
  x20102025 <- purrr::reduce(lapply(sheets[1:16], read_first4), dplyr::bind_rows)
  #data pre 2009 is structured differently
  x20002009 <- purrr::reduce(lapply(sheets[17:26], read_first4), dplyr::bind_rows)
  #add a column for service time
  x20002009$service_time <- NA

  opening_data <- rbind(x20002009, x20102025) |>
    dplyr::filter(!is.na(player),
                  player!="TOTAL")
  return(opening_data)
}
