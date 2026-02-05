# management/script/update_qmd_yamls.R

library(tidyverse)
library(readxl)
library(yaml)
library(fs)

# ---- CONFIG ----
db_file <- "management/db/tutorial_db_template.xlsx"  # your updated XLSX
qmd_root <- "pages/learn-qgis"

# ---- READ UPDATED DATABASE ----
tutorial_db <- read_xlsx(db_file) %>%
  mutate(
    categories = str_split(categories, ",\\s*")  # YAML expects list
  )

# ---- FUNCTION TO UPDATE QMD YAML ----
update_qmd_yaml <- function(file, new_meta) {
  lines <- readLines(file, warn = FALSE)
  
  # Detect YAML front matter
  if (!str_detect(lines[1], "^---")) {
    stop("No YAML front matter found in ", file)
  }
  yaml_end <- which(lines[-1] == "---")[1] + 1
  content_after_yaml <- lines[(yaml_end + 1):length(lines)]
  
  # Build updated YAML
  updated_yaml <- list(
    title       = new_meta$title,
    description = new_meta$description,
    categories  = new_meta$categories,
    level       = new_meta$level,
    level_code  = new_meta$level_code,
    level_color = new_meta$level_color,
    date        = as.character(new_meta$date)
  )
  
  # Convert list to YAML string
  yaml_text <- as.yaml(updated_yaml, indent = 2)
  yaml_lines <- c("---", str_split(yaml_text, "\n")[[1]], "---")
  
  # Combine updated YAML + original content
  writeLines(c(yaml_lines, content_after_yaml), file)
}

# ---- LOOP OVER TUTORIALS ----
for(i in seq_len(nrow(tutorial_db))) {
  row <- tutorial_db[i, ]
  file <- row$file_path
  
  # Make sure the file exists
  if (!file_exists(file)) {
    warning("File not found: ", file)
    next
  }
  
  update_qmd_yaml(file, row)
}

message("All QMD YAMLs updated successfully.")
