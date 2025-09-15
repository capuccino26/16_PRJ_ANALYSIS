# Install packages
if (!require("readxl")) install.packages("readxl", dependencies = TRUE)
if (!require("ggplot2")) install.packages("ggplot2", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)
if (!require("tidyr")) install.packages("tidyr", dependencies = TRUE)
if (!require("fs")) install.packages("fs", dependencies = TRUE)

# Load packages
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(fs)

# Set working environment
path <- "/DIVERGING"
output_dir <- sprintf("%s/RESULTS", path)

# Create directories
if (!dir_exists(output_dir)) dir_create(output_dir)

## Load data table (not provided here)
file_path <- sprintf("%s/TABLE.csv", path)
df <- read.csv2(file_path)

# Filter for the gene of interest
gene_of_interest <- "AT5G25940"
df_gene <- df %>% filter(`shared.name` == gene_of_interest)

# Check if gene is available in the Data Table
if (nrow(df_gene) == 0) {
    stop(sprintf("Error: Gene '%s' not found.", gene_of_interest))
}

# Transform to Long format
df_long <- df_gene %>%
    pivot_longer(cols = -shared.name, names_to = "Project", values_to = "Expression") %>%
    mutate(Expression = as.numeric(Expression))

# Remove NA
df_long <- df_long %>% filter(!is.na(Expression))

# Customizations
custom_theme <- theme_minimal(base_size = 16) +
    theme(
        panel.grid = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 20, margin = margin(r = 15)),
        axis.title.y = element_blank(),
        plot.title = element_text(size=40,hjust = 0.5),
        plot.margin = margin(t = 20, r = 120, b = 20, l = 120)
    )
label_offset <- max(abs(df_long$Expression), na.rm = TRUE) * 0.18  # Evita erro caso tenha NA

# Create diverging bar chart
p <- ggplot(df_long, aes(x = reorder(Project, Expression), y = Expression, fill = Expression > 0)) +
    geom_bar(stat = "identity", color = "black", width = 0.6) +
    geom_text(aes(label = round(Expression, 2), 
                  y = ifelse(Expression > 0, Expression + label_offset, Expression - label_offset)), 
              size = 12) +
    scale_fill_manual(values = c("red", "blue"), guide = "none") +
    labs(title = sprintf("Log2 Fold-Change - %s", gene_of_interest)) +
    coord_flip(clip = "off") +
    custom_theme
file_output <- sprintf("%s/RESULTS/expression_%s.png", path, gene_of_interest)
ggsave(file_output, plot = p, width = 12, height = 8, dpi = 300, units = "in", limitsize = FALSE)
