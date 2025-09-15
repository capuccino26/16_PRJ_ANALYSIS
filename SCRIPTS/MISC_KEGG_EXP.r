# Load packages
library(readr)
library(dplyr)
library(tidyverse)
library(pheatmap)
library(dendextend)
library(ggplot2)

# Set Working Environment
path <- "/KEGG_EXP"
dffreqkegg <- read_delim("16_FREQKEGG.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
## The NET_TABLE is not provided
dfexpf <- read_delim("NET_TABLE.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)

# Filter genes for desired PATHWAY "ath00052"
genes_of_interest <- dffreqkegg %>%
  filter(PATHWAY == "ath00052") %>%
  pull(GENES) %>%
  str_split(";") %>%
  unlist() %>%
  unique()

# Create Results Folder
results_dir <- file.path(path, "RESULTS")
if (!dir.exists(results_dir)) {
  dir.create(results_dir)
}

# Loop for generating visualization for each gene of interest
for (gene in genes_of_interest) {
  df_gene <- dfexp16 %>% filter(`shared name` == gene)
  if (nrow(df_gene) == 0) {
    message(sprintf("Alert: Gene '%s' not found in the main Table, skipping..", gene))
    next
  }
  df_long <- df_gene %>%
    pivot_longer(cols = -`shared name`, names_to = "Project", values_to = "Expression") %>%
    mutate(Expression = as.numeric(Expression)) %>% 
    filter(!is.na(Expression))

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
  label_offset <- max(abs(df_long$Expression), na.rm = TRUE) * 0.18

  # Generate plot
  p <- ggplot(df_long, aes(x = reorder(Project, Expression), y = Expression, fill = Expression > 0)) +
    geom_bar(stat = "identity", color = "black", width = 0.6) +
    geom_text(aes(label = round(Expression, 2), 
                  y = ifelse(Expression > 0, Expression + label_offset, Expression - label_offset)), 
              size = 12) +
    scale_fill_manual(values = c("red", "blue"), guide = "none") +
    labs(title = sprintf("Log2 Fold-Change - %s", gene)) +
    coord_flip(clip = "off") +
    custom_theme
  file_output <- sprintf("%s/RESULTS/expression_%s.png", path, gene)
  ggsave(file_output, plot = p, width = 12, height = 8, dpi = 300, units = "in", limitsize = FALSE)
}

# Filter main table
df_filtered <- dfexp16 %>%
  filter(`shared name` %in% genes_of_interest)
row_names <- df_filtered$`shared name`
df_expression <- df_filtered %>%
  select(-`shared name`)
df_expression[is.na(df_expression)] <- 0
rownames(df_expression) <- row_names

# Normalize Data
df_expression_normalized <- scale(df_expression)

# Generate heatmaps for normalized data
pheatmap(df_expression_normalized, 
         cluster_rows = TRUE, 
         cluster_cols = TRUE, 
         scale = "none",
         show_rownames = TRUE, 
         show_colnames = TRUE,
         main = "Heatmap of normalized node expressions for pathway ATH00052")

pheatmap(df_expression, 
         cluster_rows = TRUE, 
         cluster_cols = FALSE, 
         scale = "none",
         show_rownames = TRUE, 
         show_colnames = TRUE,
         main = "Heatmap of absolute node expressions for pathway ATH00052",
         color = colorRampPalette(c("blue", "white", "red"))(50)  # Gradiente de azul para vermelho
)

# Define genes of interest
highlighted_genes <- c("2.4.1.123", "2.4.1.82", "2.7.1.11", "5.1.3.2")

# Create clustering
row_clusters <- ifelse(rownames(df_expression) %in% highlighted_genes, 1, 2)

# Reorder data for clustering
df_reordered <- df_expression[order(row_clusters), ]
rownames(df_reordered) <- rownames(df_expression)[order(row_clusters)]

# Generate manual dendogram
dend <- as.hclust(
  df_reordered %>% 
    dist() %>% 
    hclust() %>% 
    as.dendrogram() %>%
    branches_attr_by_clusters(row_clusters[order(row_clusters)], values = c("1" = 2, "2" = 1)) %>%
    set("branches_lwd", c(2, 1))
)

# Create heatmap
png("heatmap_highlight.png")
pheatmap(
  mat = as.matrix(df_reordered),
  cluster_rows = dend,
  cluster_cols = FALSE,
  show_rownames = TRUE,
  show_colnames = TRUE,
  labels_row = ifelse(
    rownames(df_reordered) %in% highlighted_genes,
    paste0("★ ", rownames(df_reordered)),
    rownames(df_reordered)
  ),
  main = "Heatmap for ath00052 nodes",
  color = colorRampPalette(c("blue", "white", "red"))(50),
  annotation_row = data.frame(
    Cluster = factor(row_clusters[order(row_clusters)], 
                    levels = 1:2, labels = c("Overrepresented", "Other")),
    row.names = rownames(df_reordered)
  ),
  annotation_colors = list(
    Cluster = c(Overrepresented = "gold", Other = "gray90")
  ),
  cutree_rows = 2,
  fontsize_row = 8,
  treeheight_row = 50
)
dev.off()
