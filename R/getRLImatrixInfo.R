# --------------------------------------------------------------------------------
# getRLImatrixInfo.R
#
#   Return a data.table of metadata for every spline-matrix in RLImatrices:
#     - locale:       "US" or "UK"
#     - year:         e.g. "2023_2024.3"
#     - content_area: e.g. "EARLY_LITERACY.BASELINE"
#     - matrix_name:  e.g. "EARLY_LITERACY.2023_2024.3.qrmatrix_3_1"
#     - N, MAX_TIME, MAX_TIME_PRIOR, RANGE_TIME_LAG_(min/max),
#       SGP_Package_Version, Date_Prepared, nrow, ncol
#
#   Usage:
#     getRLImatrixInfo(locale = "US", year = NULL)
#       locale: "US" or "UK" (default = "US")
#       year:   NULL (latest available), "ALL", or exactly "YYYY_YYYY.X"
#
#   If `year = NULL`, picks the lexicographically-last year in that locale.
#   If `year = "ALL"`, returns every year present.  If `year = "<exactYear>"`,
#   but that year doesn't exist, you get a message and an empty data.table.
#
#   Depends on data.table; assumes that RLImatrices is already installed/loaded.
# --------------------------------------------------------------------------------

getRLImatrixInfo <- function(locale = "US", year = NULL) {

    ## Suppress R CMD check notes
    content_area <- matrix_name <- LOCALE <- YEAR <- CONTENT_AREA <- MATRIX_NAME <- NULL

  # ----------------------------------------
  # 1. Validate locale and pull in the right environment
  # ----------------------------------------
  locale <- toupper(locale)
  if (! locale %in% c("US", "UK")) {
    stop("`locale` must be either 'US' or 'UK'.")
  }
  
  # The two built-in environments live in the RLImatrices namespace:
  if (! requireNamespace("RLImatrices", quietly = TRUE)) {
    stop("The RLImatrices package must be installed and loadable.")
  }
  
  if (locale == "US") {
    envName <- "RLI_SGPt_Baseline_Matrices"
  } else {
    envName <- "RLI_UK_SGPt_Baseline_Matrices"
  }
  
  # Fetch the environment object from RLImatrices
  pkgEnv <- getNamespace("RLImatrices")
  if (! exists(envName, envir = pkgEnv)) {
    stop(sprintf("Cannot find environment '%s' in RLImatrices namespace.", envName))
  }
  baseEnv <- get(envName, envir = pkgEnv)
  
  # ----------------------------------------
  # 2. List all year-lists in that environment
  #    e.g. names(baseEnv) might be
  #      "RLI_SGPt_Baseline_Matrices_2019_2020.2",
  #      "RLI_SGPt_Baseline_Matrices_2023_2024.3", etc.
  # ----------------------------------------
  allEnvNames <- ls(envir = baseEnv)  # these are exactly the "list-names" inside that env
  # We expect something like "RLI_SGPt_Baseline_Matrices_YYYY_YYYY.X"
  
  # Strip off the common prefix "RLI_SGPt_Baseline_Matrices_" to get just the year-suffix:
  prefixPattern <- paste0(envName, "_")
  yearSuffixes <- sub(prefixPattern, "", allEnvNames, fixed = TRUE)
  
  # If there's no match meaning no lists, stop early
  if (length(yearSuffixes) == 0L) {
    stop(sprintf("No year-lists found inside environment '%s'.", envName))
  }
  
  # ----------------------------------------
  # 3. Decide which year(s) the user asked for
  # ----------------------------------------
  # If year is NULL, pick the "latest" by sorting lexically
  availableYears <- yearSuffixes
  if (is.null(year)) {
    # Sort lexically; the last one is "latest"
    sortedYears <- sort(availableYears)
    requestedYears <- tail(sortedYears, 1L)
  } else {
    if (toupper(year) == "ALL") {
      requestedYears <- availableYears
    } else {
      # Exact-match lookup
      if (! year %in% availableYears) {
        message(sprintf(
          "Requested year '%s' not found for locale '%s'.\nAvailable years: %s",
          year, locale,
          paste(sprintf("'%s'", availableYears), collapse = ", ")
        ))
        # Return an empty data.table with the correct column names
        emptyDT <- data.table::data.table(
          LOCALE                 = character(),
          YEAR                   = character(),
          CONTENT_AREA           = character(),
          MATRIX_NAME            = character(),
          STUDENT_COUNT          = integer(),
          MAX_TIME               = numeric(),
          MAX_TIME_PRIOR         = numeric(),
          RANGE_TIME_LAG_MIN     = integer(),
          RANGE_TIME_LAG_MAX     = integer(),
          SGP_PACKAGE_VERSION    = character(),
          DATE_PREPARED          = character(),
          NUMBER_OF_ROWS         = integer(),
          NUMBER_OF_COLUMNS      = integer()
        )
        return(emptyDT)
      }
      requestedYears <- year
    }
  }
  
  # ----------------------------------------
  # 4. For each requestedYear, pull out its full name and iterate
  # ----------------------------------------
  # Pre-allocate a list of data.tables (one per requestedYear), then rbindlist
  outList <- vector("list", length(requestedYears))
  
  for (iYear in seq_along(requestedYears)) {
    thisYear <- requestedYears[iYear]
    # Find the full environment-list name, i.e. the key in allEnvNames
    fullNameIndex <- which(yearSuffixes == thisYear)
    fullEnvName <- allEnvNames[fullNameIndex]
    
    # This is now a named list of content_area -> (list of splineMatrix objects)
    yearList <- baseEnv[[fullEnvName]]
    contentAreas <- names(yearList)  # e.g. "EARLY_LITERACY.BASELINE", "MATHEMATICS.BASELINE", etc.
    
    # For each content area, we'll dive into its list of splineMatrices
    rowsForYear <- vector("list", length(contentAreas))
    
    for (iCA in seq_along(contentAreas)) {
      caName <- contentAreas[iCA]
      matrixList <- yearList[[caName]]
      
      # Pre-allocate a temporary list to hold one row per matrixName
      tmpRows <- vector("list", length(matrixList))
      
      for (j in seq_along(matrixList)) {
        matName <- names(matrixList)[j]
        matObj <- matrixList[[j]]
        
        # Extract all the fields we need
        ## 1) Slots in matObj@Version$Matrix_Information
        MI     <- matObj@Version$Matrix_Information
        N      <- MI$N
        
        ## 2) SGPt sub-list
        SGPt   <- MI$SGPt
        MAX_TIME       <- SGPt$MAX_TIME
        MAX_TIME_PRIOR <- SGPt$MAX_TIME_PRIOR
        RTL            <- SGPt$RANGE_TIME_LAG
        # Defensive in case RANGE_TIME_LAG has length != 2
        if (length(RTL) >= 2L) {
          RT_MIN <- RTL[1]
          RT_MAX <- RTL[2]
        } else {
          RT_MIN <- NA_real_
          RT_MAX <- NA_real_
        }
        
        ## 3) The two version-level fields
        pkgVer <- matObj@Version$SGP_Package_Version
        datePrep <- matObj@Version$Date_Prepared
        
        ## 4) Dimensions
        matrix_dimension <- paste(dim(matObj), collapse = " x ")

        ## 5) Grade Progression
        grade_progression <- paste(matObj@Grade_Progression[[1]], collapse = ", ")

        ## 6) Knots & Boundaries 
        knots <- paste(matObj@Knots[[1]], collapse = ", ")
        boundaries <- paste(matObj@Boundaries[[1]], collapse = ", ")
        
        # Build one row as a named list
        tmpRows[[j]] <- list(
          LOCALE              = locale,
          YEAR                = thisYear,
          CONTENT_AREA        = gsub("\\.BASELINE", "", caName),
          MATRIX_NAME         = matName,
          GRADE_PROGRESSION   = grade_progression,
          STUDENT_COUNT       = N,
          MAX_TIME            = MAX_TIME,
          MAX_TIME_PRIOR      = MAX_TIME_PRIOR,
          RANGE_TIME_LAG_MIN  = RT_MIN,
          RANGE_TIME_LAG_MAX  = RT_MAX,
          SGP_PACKAGE_VERSION = pkgVer,
          DATE_PREPARED       = datePrep,
          MATRIX_DIMENSION    = matrix_dimension,
          KNOTS               = knots,
          BOUNDARIES          = boundaries
        )
      }
      
      # Convert that content-area's rows to a data.table
      rowsForYear[[iCA]] <- data.table::rbindlist(tmpRows)
    }
    
    # Bind together all content_area data.tables for thisYear
    outList[[iYear]] <- data.table::rbindlist(rowsForYear)
  }
  
  # Finally, stack all years into one big data.table
  resultDT <- data.table::rbindlist(outList)
  
  # (Optionally, set a key for fast sorting/filtering)
  data.table::setkey(resultDT, LOCALE, YEAR, CONTENT_AREA, MATRIX_NAME)
  return(resultDT)
}

# --------------------------------------------------------------------------------
# Example usage (assuming that RLImatrices is installed and attached):
#
#   library(data.table)
#   library(RLImatrices)
#
#   # 1) Get ONLY the latest US year:
#   dt_latest_US <- getRLImatrixInfo()         # since locale="US" and year=NULL
#   head(dt_latest_US)
#
#   # 2) Get ALL years for US:
#   dt_all_US    <- getRLImatrixInfo("US", "ALL")
#   table(dt_all_US$year)
#
#   # 3) Get just the 2019_2020.2 slice for UK:
#   dt_UK_1920   <- getRLImatrixInfo("UK", "2019_2020.2")
#
#   # 4) If you supply a year that doesn't exist:
#   dt_bad       <- getRLImatrixInfo("US", "1900_1901.1")
#     # -> you'll get a message plus an empty data.table
# --------------------------------------------------------------------------------