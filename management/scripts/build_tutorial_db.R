# management/build_tutorial_db.R

library(tidyverse)
library(yaml)
library(fs)
library(stringr)
library(writexl)

# ---- CONFIG ----
learn_dir <- "pages/learn-qgis"      # folder with your tutorials
output_dir <- "management/db"        # folder to store CSV/XLSX
dir_create(output_dir)               # create if doesn't exist

# ---- GET QMD FILES ----
qmd_files <- dir_ls(
  path = learn_dir,
  recurse = TRUE,
  glob = "*.qmd"
) |>
  discard(~ str_detect(.x, "index.qmd"))

# ---- FUNCTION TO READ METADATA ----
read_qmd_metadata <- function(file) {
  lines <- readLines(file, warn = FALSE)
  
  # check if YAML front matter exists
  if (!str_detect(lines[1], "^---")) return(NULL)
  
  yaml_end <- which(lines[-1] == "---")[1] + 1
  yaml_text <- paste(lines[2:(yaml_end - 1)], collapse = "\n")
  meta <- yaml::yaml.load(yaml_text)
  
  # file info
  info <- file_info(file)
  creation_time <- info$birth_time %||% info$modification_time
  
  # detect callouts and images (fixed ignore_case)
  callouts <- any(str_detect(lines, regex("^:::\\s*\\{\\.callout-", ignore_case = TRUE)))
  images   <- any(str_detect(lines, "!\\["))
  
  tibble(
    file_path      = file,
    title          = meta$title %||% NA,
    description    = meta$description %||% NA,
    categories     = paste(meta$categories %||% NA, collapse = ", "),
    level          = meta$level %||% NA,
    format         = meta$format %||% NA,
    date           = meta$date %||% NA,
    word_count     = str_count(paste(lines[(yaml_end + 1):length(lines)], collapse = " "), "\\w+"),
    has_callouts   = callouts,
    has_images     = images,
    creation_time  = creation_time,
    last_modified  = info$modification_time
  )
}


# ---- BUILD DATABASE ----
tutorial_db <- qmd_files |>
  map_dfr(read_qmd_metadata)

# ---- EXPORT CSV AND XLSX WITH DATE ----
today <- Sys.Date()
csv_file  <- file.path(output_dir, paste0("tutorial_db_", today, ".csv"))
xlsx_file <- file.path(output_dir, paste0("tutorial_db_", today, ".xlsx"))

write_csv(tutorial_db, csv_file)
writexl::write_xlsx(tutorial_db, xlsx_file)

message("Tutorial database saved to CSV: ", csv_file)
message("Tutorial database saved to XLSX: ", xlsx_file)
