# Load packages
library(ggplot2)
library(dplyr)
library(tidyr)

# LOAD DATA
setwd("/FULL_GENOMES/PRJNA975299/")
# SUMMARY FILE
file_summary <- "RESULTS/RES_DEG_SUMMARY.csv"

# Read CSV file with genomes summary
dados <- read.csv(file_summary)

# Select columns to plot
plot_data <- dados %>%
  select(GENOME, DEGs, ANNOTATION, HYPOTHETICAL)

# Transform data to long (ggplot2)
long_data <- plot_data %>%
  pivot_longer(
    cols = c(DEGs, ANNOTATION, HYPOTHETICAL),
    names_to = "Category",
    values_to = "Count"
  )

# Convert 'Category' to factor
long_data$Category <- factor(long_data$Category, 
                                 levels = c("DEGs", "ANNOTATION", "HYPOTHETICAL"),
                                 labels = c("DEGs", "Annotated", "Hypothetical"))


# Generate visualization
final_p <- ggplot(long_data, aes(x = GENOME, y = Count, fill = Category)) +
  
  # Add bars and position "dodge" for side bars
  geom_bar(stat = "identity", position = position_dodge(preserve = "single")) +
  
  # Add exact values to bars
  geom_text(aes(label = Count), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5,
            size = 2.5,
            color = "black") +

  # Define pallet
  scale_fill_manual(values = c("DEGs" = "#E67E22", "Annotated" = "#3498DB", "Hypothetical" = "#2ECC71")) +
  
  # Add title and labels
  labs(
    title = "Comparative Analysis of DEGs and Annotation by Genome",
    subtitle = "Total count of DEGs, annotated genes and hypothetical proteins",
    x = "Genome",
    y = "Total Count",
    fill = "Type"
  ) +
  
  # Clean theme
  theme_minimal(base_size = 14) +
  
  # Customizations
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, size = 11, margin = margin(b=15)),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    legend.position = "top"
  ) +

  # Adjust Y limits
  scale_y_continuous(expand = expansion(mult = c(0, .1)))


# Save file
ggsave(
  "GENOMES_SUMMARY.png",
  plot = final_p,
  width = 12,
  height = 7,
  dpi = 300
)
