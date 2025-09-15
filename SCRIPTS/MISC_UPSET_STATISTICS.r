# Load packages
library(dplyr)

# Set environment
path= "/UPSET"
setwd(path)

if (!dir.exists(sprintf("%s/OUTPUT",path))) {
  dir.create(sprintf("%s/OUTPUT",path), recursive = TRUE)
}

df <- read.delim(sprintf("%s/16_INTERSECTIONS.tsv", path), 
                 sep = "\t", 
                 header = TRUE, 
                 stringsAsFactors = FALSE)

df$Shared_Projects <- rowSums(df[, -ncol(df)] == "True")

# Convert to numeric
df$count <- as.numeric(df$count)

# Cluster by count of Shared_Projects
summary_df <- aggregate(count ~ Shared_Projects, data = df, sum)

# Summary
output_path <- sprintf("%s/OUTPUT/summary_report.txt", path)
writeLines(c(
  "Shared Projects Summary Report",
  "--------------------------------",
  sprintf("Total Nodes for Shared Projects %d: %d", summary_df$Shared_Projects, summary_df$count)
), con = output_path)

# Unique Nodes
# Definir diretório
dir_path <- "/UPSET/GENES_SHARED"

# List CSV files
files <- list.files(dir_path, pattern = "^genes_shared_.*\\.csv$", full.names = TRUE)

# Create unique list for CSV files and shared projects
unique_genes_list <- list()
intersections_count <- list()

# Calculate the number of intersections
total_genes <- length(unique(unlist(unique_genes_list)))
total_intersections <- sum(unlist(intersections_count))

# Generate output
output_path <- "/UPSET/OUTPUT/unique_genes_report.txt"
report_lines <- c("Unique Shared Genes Summary", "--------------------------------")
for (num_projects in sort(as.numeric(names(unique_genes_list)))) {
    genes <- unique_genes_list[[as.character(num_projects)]]
    num_intersections <- intersections_count[[as.character(num_projects)]]
    percentage_genes <- (length(genes) / total_genes) * 100
    percentage_intersections <- (num_intersections / total_intersections) * 100
    report_lines <- c(report_lines, 
                      sprintf("Unique Nodes for %s projects: %d (%.2f%%)", num_projects, length(genes), percentage_genes),
                      sprintf("Number of intersections: %d (%.2f%%)", num_intersections, percentage_intersections),
                      paste("Genes:", paste(genes, collapse = ", ")))
}
writeLines(report_lines, output_path)

# Filter Table
table_file <- file.path(path, "NET_TABLE.csv")
## Files with IDS for analysis
ids_file <- file.path(path, "IDS.txt")
output_file <- file.path(path, "NET_TABLE_FILTERED.csv")
ids_list <- scan(ids_file, what = character(), sep = ",", quiet = TRUE) %>% trimws()

## Load Main Table (not provided)
df <- read.csv(table_file, sep = ";", stringsAsFactors = FALSE)

## Filter
df_filtered <- df %>% 
  filter(`shared.name` %in% ids_list) %>% 
  select(`shared.name`, `X16_MEANS`, `X16_MAX`, `X16_MIN`, `FREQUENCY_08`, `function.`) %>% 
  rename(
    Node = `shared.name`,
    `Mean Expression` = `X16_MEANS`,
    `Max Expression` = `X16_MAX`,
    `Min Expression` = `X16_MIN`,
    `Intersections Frequency` = `FREQUENCY_08`,
    Function = `function.`
  )

# Save filtered table
write.table(df_filtered, output_file, sep = ";", row.names = FALSE, quote = FALSE)
