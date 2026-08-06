# Rename PNG files in a folder with sequential numbers: 01.png, 02.png, etc.

#' Rename PNG files with sequential numbering
#'
#' @param folder_path Path to folder containing PNG files (default: current directory)
#' @param start_num Starting number (default: 1)
#' @param prefix Optional prefix before numbers (default: "")
#' @param digits Number of digits for zero-padding (default: 2)
#' @param preview If TRUE, show preview without renaming (default: FALSE)
#'
rename_pngs <- function(folder_path = ".", 
                        start_num = 1, 
                        prefix = "", 
                        digits = 2,
                        preview = FALSE) {
  
  # Check if folder exists
  if (!dir.exists(folder_path)) {
    stop("Folder does not exist: ", folder_path)
  }
  
  # Get all PNG files, sorted alphabetically
  png_files <- list.files(folder_path, 
                          pattern = "\\.png$", 
                          full.names = TRUE,
                          ignore.case = TRUE)
  
  if (length(png_files) == 0) {
    message("No PNG files found in: ", folder_path)
    return(invisible(NULL))
  }
  
  # Sort files
  png_files <- sort(png_files)
  
  # Generate new names
  new_names <- paste0(prefix, 
                      sprintf(paste0("%0", digits, "d"), 
                              seq(start_num, length.out = length(png_files))),
                      ".png")
  
  # Create full paths for new names
  new_paths <- file.path(folder_path, new_names)
  
  # Show preview
  cat("Found", length(png_files), "PNG files\n")
  cat(rep("-", 60), "\n", sep = "")
  cat("Old name", strrep(" ", 35), "New name\n")
  cat(rep("-", 60), "\n", sep = "")
  
  for (i in seq_along(png_files)) {
    old_name <- basename(png_files[i])
    cat(sprintf("%-40s -> %s\n", old_name, new_names[i]))
  }
  
  cat(rep("-", 60), "\n", sep = "")
  
  # If preview mode, stop here
  if (preview) {
    cat("\nPreview mode - no files renamed\n")
    return(invisible(data.frame(old = png_files, new = new_paths)))
  }
  
  # Ask for confirmation (if interactive)
  if (interactive()) {
    response <- readline("Proceed with renaming? (y/n): ")
    if (tolower(trimws(response)) != "y") {
      cat("Cancelled.\n")
      return(invisible(NULL))
    }
  }
  
  # Rename files
  cat("\nRenaming files...\n")
  success <- file.rename(png_files, new_paths)
  
  if (all(success)) {
    cat("✓ Successfully renamed", length(png_files), "files!\n")
  } else {
    warning("Some files could not be renamed")
    cat("Failed files:\n")
    print(png_files[!success])
  }
  
  invisible(data.frame(old = png_files, new = new_paths, success = success))
}

# -----------------------------------------------------------------------------
# USAGE EXAMPLES
# -----------------------------------------------------------------------------

# Example 1: Rename PNGs in current directory to 01.png, 02.png, etc.
# rename_pngs()

# Example 2: Rename PNGs in specific folder
# rename_pngs("path/to/folder")

# Example 3: Start numbering from 5
# rename_pngs(start_num = 5)

# Example 4: Add prefix
# rename_pngs(prefix = "image_")  # Results: image_01.png, image_02.png, etc.

# Example 5: Use 3 digits
# rename_pngs(digits = 3)  # Results: 001.png, 002.png, etc.

# Example 6: Preview without renaming
# rename_pngs(preview = TRUE)

# Example 7: Combine options
# rename_pngs("images/tutorial", start_num = 1, prefix = "step_", digits = 2)

# -----------------------------------------------------------------------------
# QUICK USE: Just run this line for current directory
# -----------------------------------------------------------------------------
rename_pngs()