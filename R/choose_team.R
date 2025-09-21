#' Interactive Team Selection (Internal)
#'
#' Presents an interactive menu of team labels and returns the corresponding team ID.
#' This is an internal helper function intended for use in package development.
#'
#' @param data A data frame containing at least a \code{hometeam} column.
#'
#' @details
#' Uses \code{utils::menu()} to display the available \code{team_labels} for selection.
#' Returns the team ID associated with the chosen label.
#'
#' Requires the object \code{team_labels} to exist in the package environment.
#'
#' @return A character string: the team ID selected by the user.
#'
#' @keywords internal

choose_team <- function(data) {
  # unique team IDs
  team_ids <- (unique(c(data$hometeam)))

  # menu for selection
  choice <- menu(team_labels, title = "Select a team:")

  # return just the team ID
  return(team_ids[choice])
}

