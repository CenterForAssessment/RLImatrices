RLImatrices
===========

[![R-CMD-check](https://github.com/CenterForAssessment/RLImatrices/workflows/R-CMD-check/badge.svg)](https://github.com/CenterForAssessment/RLImatrices/actions)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/CenterForAssessment/RLImatrices/blob/master/LICENSE.md)

# Overview

The **RLImatrices** package provides historical baseline coefficient matrices for Renaissance Learning Inc. (RLI) Student Growth Percentile (SGPt) analyses. These matrices are essential components for calculating student growth percentiles and percentile growth trajectories using the [`rliSGP`](https://github.com/CenterForAssessment/SGP/blob/master/R/rliSGP.R) function from the [SGP Package](https://github.com/CenterForAssessment/SGP).

This package serves educational assessment professionals, researchers, and data analysts who work with RLI assessment data to measure and analyze student academic growth over time.

## What's Included

### Baseline Coefficient Matrices

The package contains two comprehensive datasets:

- **`RLI_SGPt_Baseline_Matrices`**: US-based coefficient matrices
- **`RLI_UK_SGPt_Baseline_Matrices`**: UK-based coefficient matrices

### Content Areas Covered

- **Early Literacy**: Foundational reading skills assessment
- **Reading**: Comprehensive reading assessment (STAR and RASCH variants)
- **Mathematics**: Mathematical proficiency assessment (STAR and RASCH variants)
- **Specialized Variants**: 
  - RASCH-based matrices for enhanced psychometric modeling
  - Spanish language assessments
  - Unified RASCH reading assessments

### Temporal Coverage

Historical data spanning multiple academic years from 2015-2016 through 2023-2024, with seasonal breakdowns (Fall, Winter, Spring) where applicable.

## Key Features

### Matrix Information Retrieval

The `getRLImatrixInfo()` function provides comprehensive metadata about available coefficient matrices:

```r
library(RLImatrices)

# Get latest US matrices information
latest_us <- getRLImatrixInfo()

# Get all available years for UK
all_uk <- getRLImatrixInfo(locale = "UK", year = "ALL")

# Get specific year data
specific_year <- getRLImatrixInfo(locale = "US", year = "2023_2024.3")
```

### Returned Information

For each matrix, you'll receive detailed metadata including:
- **Locale**: US or UK
- **Academic Year**: e.g., "2023_2024.3"
- **Content Area**: Subject domain
- **Matrix Specifications**: Dimensions, grade progressions, knots, boundaries
- **Sample Information**: Student count, time parameters
- **Version Details**: SGP package version, preparation date

## Installation

### From GitHub

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install RLImatrices
devtools::install_github("CenterForAssessment/RLImatrices")

# Load the package
library(RLImatrices)
```

### System Requirements

- **R**: Version 3.6 or higher
- **Dependencies**: `data.table` (automatically installed)
- **Suggested**: `SGP` package (version 1.3-7.0 or higher) for full functionality

### Platform-Specific Requirements

- **Windows**: [Rtools](http://cran.r-project.org/bin/windows/Rtools/)
- **macOS**: Xcode (available from App Store)
- **Linux**: `r-base-dev` package (or equivalent)

## Usage Examples

### Basic Matrix Information

```r
# Load the package
library(RLImatrices)
library(data.table)

# Get information about the latest available matrices
matrix_info <- getRLImatrixInfo()
print(matrix_info)

# View available content areas
unique(matrix_info$CONTENT_AREA)

# Check matrix dimensions
table(matrix_info$MATRIX_DIMENSION)
```

### Filtering and Analysis

```r
# Get all mathematics matrices for US
math_matrices <- getRLImatrixInfo(locale = "US", year = "ALL")
math_only <- math_matrices[CONTENT_AREA == "MATHEMATICS"]

# View student counts by year
math_only[, .(avg_students = mean(STUDENT_COUNT)), by = YEAR]

# Check available grade progressions
unique(math_only$GRADE_PROGRESSION)
```

### Integration with SGP Package

```r
# These matrices are designed to work with the SGP package
library(SGP)

# The matrices are automatically available when using rliSGP()
# See SGP package documentation for complete usage examples
```

## Data Structure

Each coefficient matrix contains:
- **Spline coefficients**: For growth trajectory modeling
- **Grade progressions**: Valid grade-to-grade transitions
- **Temporal parameters**: Time lag specifications
- **Boundary conditions**: Assessment score ranges
- **Knot specifications**: Spline breakpoints
- **Version metadata**: Creation details and sample sizes

## Version History

The package has evolved significantly since its initial release:
- **v18.9-2.0** (Current): Latest matrices with enhanced UK support
- **v17.0-0.0**: Added UK matrices for multiple content areas
- **v16.0-0.0**: Updated 2018-2019 data integration
- **v13.0-0.0**: Introduction of Spanish language assessments
- **v10.0-0.0**: READING_UNIFIED_RASCH matrices added
- **v1.0-0.0**: Initial release with Fall 2015-2016 baseline matrices

See the [NEWS file](inst/NEWS) for complete version history.

## Support and Documentation

- **GitHub Repository**: [https://github.com/CenterForAssessment/RLImatrices](https://github.com/CenterForAssessment/RLImatrices)
- **Issues and Bug Reports**: Use GitHub Issues for technical support
- **SGP Package Integration**: See [SGP documentation](https://github.com/CenterForAssessment/SGP) for analysis workflows

## Citation

When using this package in research or publications, please cite:

```r
citation("RLImatrices")
```

## License

This package is released under the MIT License. See [LICENSE.md](LICENSE.md) for details.

---

**Note**: This package is specifically designed for use with Renaissance Learning Inc. assessment data and requires appropriate data access permissions for practical application.
