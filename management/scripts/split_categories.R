library(tidyverse)
library(yaml)

# Directory containing your tutorials
tutorials_dir <- "pages/learn-qgis"

# Find all .qmd files
qmd_files <- list.files(
  path = tutorials_dir,
  pattern = "\\.qmd$",
  recursive = TRUE,
  full.names = TRUE
)

for (filepath in qmd_files) {
  # Read the file
  content <- readLines(filepath, encoding = "UTF-8")
  
  # Find the YAML frontmatter boundaries
  yaml_starts <- which(content == "---")
  
  if (length(yaml_starts) >= 2) {
    yaml_end <- yaml_starts[2]
    yaml_lines <- content[2:(yaml_end - 1)]
    yaml_str <- paste(yaml_lines, collapse = "\n")
    
    # Parse YAML
    tryCatch({
      data <- yaml.load(yaml_str)
      
      # Split categories if they exist
      if (!is.null(data$tutorial) && !is.null(data$tutorial$categories)) {
        # Split categories by semicolon
        new_categories <- data$tutorial$categories %>%
          str_split(";") %>%
          unlist() %>%
          str_trim()
        
        data$tutorial$categories <- as.list(new_categories)
      }
      
      # Convert back to YAML
      new_yaml <- yaml::as.yaml(data)
      
      # Reconstruct the file
      new_content <- c(
        "---",
        new_yaml,
        "---",
        content[(yaml_end + 1):length(content)]
      )
      
      # Write back to file
      writeLines(new_content, filepath, useBytes = TRUE)
      
      cat(sprintf("✓ Updated %s\n", filepath))
      
    }, error = function(e) {
      cat(sprintf("✗ Error in %s: %s\n", filepath, e$message))
    })
  }
}

cat("\nDone!\n")
