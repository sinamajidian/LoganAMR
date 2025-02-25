source("tools/metagraph_all_classes.R")

library(tidyverse)
library(paletteer)

# Finding the 10 drug classes closest to significance
ordered_prevalence_list = drug_models_stats %>%
  clean_names() %>%
  as_tibble() %>%
  arrange(p_value)

top10_drugs =  unique(ordered_prevalence_list$drug) %>%
  head(n=10)

################################################################################
# Plotting the prevalence of the top10 drugs.

# Define the fixed prediction range for years
years_range <- seq(2009, 2023, by = 0.5)

# Generate predictions for each continent and drug class
smooth_predictions <- lapply(names(drug_models), function(drug) {
  drug_data <- metagraph_table_complete %>%
    filter(drug_class == drug)
  
  lapply(unique(drug_data$continent), function(continent) {
    # Filter data for the specific continent
    continent_data <- drug_data %>% filter(continent == continent)
    
    # Create a new data frame for prediction
    pred_data <- data.frame(
      collection_year = years_range,
      continent = continent
    )
    
    # Generate predictions using the GAM model
    pred_data$y_pred <- predict(drug_models[[drug]], newdata = pred_data, type = "response")
    pred_data$drug_class <- drug
    pred_data
  }) %>% bind_rows()
}) %>% bind_rows()

# Filter smooth_predictions for top 10 drugs
smooth_predictions_filtered <- smooth_predictions %>%
  filter(drug_class %in% top10_drugs)

# Create a named vector to map full drug names to simplified ones
drug_name_map <- c(
  "fluoroquinolone antibiotic" = "Fluoroquinolones",
  "diaminopyrimidine antibiotic" = "Diaminopyrimidines",
  "nybomycin-like antibiotic" = "Nybomycin-like",
  "cephalosporin" = "Cephalosporins",
  "elfamycin antibiotic" = "Elfamycins",
  "rifamycin antibiotic" = "Rifamycins",
  "penam" = "Penams",
  "aminocoumarin antibiotic" = "Aminocoumarins",
  "sulfonamide antibiotic" = "Sulfonamides",
  "penem" = "Penems"
)


# Plots based on our analysis
new_metagraph_like_plot_prevalence <- ggplot(
  filter(metagraph_table_complete, drug_class %in% top10_drugs),
  aes(x = collection_year, y = normalized_positive_samples_non_amplicon_ratio)
) +
  geom_point(alpha = 0.5) +  # Scatter points for observed data
  geom_line(data = smooth_predictions_filtered, 
            aes(x = collection_year, y = y_pred, color = continent), 
            linewidth = 1) +  # Add smooth lines with corrected linewidth aesthetic
  scale_color_manual(values = paletteer_d(`"awtools::mpalette"`) ) +
  facet_grid(drug_class ~ continent, labeller = labeller(drug_class = drug_name_map)) +  # Facet by drug_class and continent
  labs(
    x = "Year",
    y = "Prevalence (Normalized Positive Samples)",
    title = "Prevalence of AMR Genes by Continent and Drug Class (our top 10 drugs)"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text.x = element_text(size = 12),
        strip.text.y = element_text(size = 9))

ggsave("plots/new_metagraph_like_plot_prevalence.png", new_metagraph_like_plot_prevalence , height = 12, width = 12)

################################################################################9
# Redoing the metagraph analysis, with the metagraph chosen drugs


# Metagraph chosen drugs
metagraph_chosen_drugs = c("aminoglycoside antibiotic", "cephamycin", 
                           "diaminopyrimidine antibiotic", 
                           "disinfecting agents and antiseptics", 
                           "fluoroquinolone antibiotic", "glycylcycline")

metagraph_chosen_drugs_map = c("aminoglycoside antibiotic" = "Aminoglycoside", 
                               "cephamycin" = "Cephamycins", 
                           "diaminopyrimidine antibiotic" = "Diaminopyrimidines", 
                           "disinfecting agents and antiseptics" = "Antiseptics", 
                           "fluoroquinolone antibiotic" = "Fluoroquinolones", 
                           "glycylcycline" = "Glycylcyclines")


smooth_predictions_metagraph_drugs_filtered <- smooth_predictions %>%
  filter(drug_class %in% metagraph_chosen_drugs)


new_metagraph_like_plot_prevalence_metagraph_drugs <- ggplot(
  filter(metagraph_table_complete, drug_class %in% metagraph_chosen_drugs),
  aes(x = collection_year, y = normalized_positive_samples_non_amplicon_ratio)
) +
  geom_point(alpha = 0.5) +  # Scatter points for observed data
  geom_line(data = smooth_predictions_metagraph_drugs_filtered, 
            aes(x = collection_year, y = y_pred, color = continent), 
            linewidth = 1) +  # Add smooth lines with corrected linewidth aesthetic
  scale_color_manual(values = paletteer_d(`"awtools::mpalette"`) ) +
  facet_grid(drug_class ~ continent, labeller = labeller(drug_class = metagraph_chosen_drugs_map)) +  # Facet by drug_class and continent
  labs(
    x = "Year",
    y = "Prevalence (Normalized Positive Samples)",
    title = "Prevalence of AMR Genes by Continent and Drug Class (Metagraph top 6 drugs)"
  ) +
  # theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_text(size = 12))

ggsave("plots/new_metagraph_like_plot_prevalence_metagraph_drugs.png", new_metagraph_like_plot_prevalence_metagraph_drugs  , height = 12, width = 12)
