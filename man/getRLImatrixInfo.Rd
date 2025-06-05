\name{getRLImatrixInfo}
\alias{getRLImatrixInfo}
\title{Retrieve Metadata for Spline Matrices in the RLImatrices Package}
\description{
Returns a \code{data.table} where each row corresponds to a single spline-matrix object
(used to represent growth-norm coefficient spline matrices) in the \pkg{RLImatrices}
package.  The output includes fields such as sample size, model formula, time-lag bounds,
package version, and the date the matrix was prepared, along with dimensions and identifying
information (locale, year, content area, and matrix name).
}
\usage{
getRLImatrixInfo(locale = "US", year = NULL)
}
\arguments{
  \item{locale}{Character scalar, either \dQuote{US} or \dQuote{UK}.  Indicates which
    built-in environment (and thus which set of growth-norm matrices) to query. Default is
    \dQuote{US}.}

  \item{year}{Character scalar, either \code{NULL}, \dQuote{ALL}, or one of the exact
    year-suffixes available in the chosen locale.  Each year-suffix has the form
    \dQuote{YYYY_YYYY.X} (for example, \dQuote{2023_2024.3}).  If set to \code{NULL}, the
    function automatically picks the lexicographically last (i.e.\ "latest") year suffix.
    If set to \dQuote{ALL}, the function returns metadata for every available year in that
    locale.  If set to a specific suffix (e.g.\ \dQuote{2023_2024.3}) that is not present,
    a message is printed and an empty \code{data.table} is returned.}
}
\details{
The \pkg{RLImatrices} package internally stores two environments:

\describe{
  \item{\dQuote{RLI_SGPt_Baseline_Matrices}}{Contains all US-based spline matrices.}
  \item{\dQuote{RLI_UK_SGPt_Baseline_Matrices}}{Contains all UK-based spline matrices.}
}

Within each environment, objects are named \samp{RLI_SGPt_Baseline_Matrices_\emph{<year_suffix>}}.
Each \samp{<year_suffix>} is a list whose names correspond to content areas (e.g.\ 
\code{"EARLY_LITERACY.BASELINE"}, \code{"MATHEMATICS.BASELINE"}, etc.).  Inside each 
content-area list are spline-matrix objects of class \code{splineMatrix} (from the \pkg{SGP}
package).  Each such object has slots such as:

\itemize{
  \item \code{@.Data}: the numeric matrix (dimensions often 10 x 100, etc.).
  \item \code{@Knots}, \code{@Boundaries}: lists of boundary information.
  \item \code{@Content_Areas}, \code{@Grade_Progression}, \code{@Time}, \code{@Time_Lags}.
  \item \code{@Version}: a list with subfields 
    \code{SGP_Package_Version}, \code{Date_Prepared}, and 
    \code{Matrix_Information}.  Under \code{Matrix_Information}, there is an integer
    \code{N} (sample size), a character \code{Model} (the quantile-regression formula),
    and a sub-list \code{SGPt} containing 
    \code{VARIABLES}, \code{MAX_TIME}, \code{MAX_TIME_PRIOR}, \code{RANGE_TIME_LAG}, etc.
}

\strong{getRLImatrixInfo()} traverses the requested environment (US or UK), selects either
one year (if \code{year} is provided exactly), all years (if \code{year = "ALL"}), or the
latest year (if \code{year = NULL}).  It then loops through each content-area and each
spline-matrix in that content area, extracting the following pieces of metadata:

\itemize{
  \item \code{locale}:  the input locale (\dQuote{US} or \dQuote{UK}).
  \item \code{year}:  the year-suffix (e.g.\ \dQuote{2023_2024.3}).
  \item \code{content_area}:  the name of the content-area list (e.g.\ 
    \dQuote{EARLY_LITERACY.BASELINE}).
  \item \code{matrix_name}:  the exact list-element name (e.g.\ 
    \dQuote{EARLY_LITERACY.2023_2024.3.qrmatrix_3_1}).
  \item \code{N}:  integer sample size (\code{@Version$Matrix_Information$N}).
  \item \code{Model}:  string formula (\code{@Version$Matrix_Information$Model}).
  \item \code{MAX_TIME}: numeric (\code{@Version$Matrix_Information$SGPt$MAX_TIME}).
  \item \code{MAX_TIME_PRIOR}: numeric (\code{@Version$Matrix_Information$SGPt$MAX_TIME_PRIOR}).
  \item \code{RANGE_TIME_LAG_MIN}, \code{RANGE_TIME_LAG_MAX}: the two numeric endpoints of
    \code{@Version$Matrix_Information$SGPt$RANGE_TIME_LAG}.
  \item \code{SGP_Package_Version}: character (the version of the SGP package used).
  \item \code{Date_Prepared}: character (e.g.\ \dQuote{Friday March 14 13:22:36 2025}).
  \item \code{nrow}, \code{ncol}: integer dimensions of the numeric matrix itself
    (\code{dim(matObj)}).
}

The final return value is a single \code{data.table} with one row per spline-matrix, keyed by
\code{locale}, \code{year}, \code{content_area}, and \code{matrix_name}.  If
\code{year} is not found in the selected environment, a message is printed listing the
available year(s), and an empty \code{data.table} (with the appropriate column structure)
is returned invisibly.
}
\value{
A \code{data.table} with columns:

\itemize{
  \item \code{locale} (\code{character}):  \dQuote{US} or \dQuote{UK}.
  \item \code{year} (\code{character}):  The year-suffix (e.g.\ \dQuote{2023_2024.3}).
  \item \code{content_area} (\code{character}):  The name of the content-area list
    (e.g.\ \dQuote{EARLY_LITERACY.BASELINE}).
  \item \code{matrix_name} (\code{character}):  The exact spline-matrix list name
    (e.g.\ \dQuote{EARLY_LITERACY.2023_2024.3.qrmatrix_3_1}).
  \item \code{N} (\code{integer}):  Sample size used to fit this spline.
  \item \code{Model} (\code{character}):  The quantile regression formula (as a string).
  \item \code{MAX_TIME} (\code{numeric}):  Maximum time value in the spline fit.
  \item \code{MAX_TIME_PRIOR} (\code{numeric}):  Maximum time-prior value.
  \item \code{RANGE_TIME_LAG_MIN} (\code{numeric}):  Lower bound of the time-lag range.
  \item \code{RANGE_TIME_LAG_MAX} (\code{numeric}):  Upper bound of the time-lag range.
  \item \code{SGP_Package_Version} (\code{character}):  Version of the SGP package used.
  \item \code{Date_Prepared} (\code{character}):  Date/time stamp when the matrix was prepared.
  \item \code{NUMBER_OF_ROWS} (\code{integer}):  Number of rows (features) in the spline matrix.
  \item \code{NUMBER_OF_COLUMNS} (\code{integer}):  Number of columns (quantiles) in the spline matrix.
}
If \code{year} is specified but not found, the function prints a message and returns an
\code{data.table} with zero rows and the same column names.
}

\examples{
\dontrun{
  # 1) Return metadata for the latest US year
  library(data.table)
  library(RLImatrices)
  dt1 <- getRLImatrixInfo()
  head(dt1)
  
  # 2) Return metadata for all available years in US
  dt_all_US <- getRLImatrixInfo(locale = "US", year = "ALL")
  unique(dt_all_US$year)
  
  # 3) Return metadata for a specific year in UK (if that year exists)
  dt_UK_specific <- getRLImatrixInfo(locale = "UK", year = "2023_2024.3")
  if (nrow(dt_UK_specific) > 0L) {
    print(head(dt_UK_specific))
  }
  
  # 4) Attempting a non-existent year returns an empty data.table with a message
  dt_missing <- getRLImatrixInfo(locale = "US", year = "1900_1901.1")
  print(dt_missing)  # 0-row data.table
}
}
