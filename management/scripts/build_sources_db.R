library(tidyverse)
library(yaml)
library(fs)
library(writexl)

yaml_file <- "pages/find-data/sources.yml"       # your YAML file
output_csv <- "management/db/sources.csv"

# Read YAML
sources <- yaml.load_file(yaml_file)

# Add a date column (today by default)
today <- Sys.Date()

# Convert to tibble/dataframe
sources_df <- map_dfr(sources, ~ tibble(
  name        = .x$name %||% NA,
  description = .x$description %||% NA,
  type        = .x$type %||% NA,
  region      = .x$region %||% NA,
  format      = .x$format %||% NA,
  categories  = paste(.x$categories %||% NA, collapse = ", "),
  date        = today
))

# Export CSV/XLSX for editing
write_csv(sources_df, output_csv)
writexl::write_xlsx(sources_df, output_csv)

message("Sources exported to CSV/XLSX with date: ", output_csv)
