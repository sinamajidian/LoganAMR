

# Prevalence test using a Binomial GAM model specific for AMPLICON samples
# Fit GAMs for the remaining drug classes
drug_models_amplicon <- lapply(drug_classes_to_keep, function(drug) {
  drug_data <- metagraph_table_complete %>% 
    filter(drug_class == drug) %>%
    filter(number_total_samples_amplicon > 0)
  
  gam(normalized_positive_samples_amplicon_ratio ~ 
        s(collection_year, by=continent) + continent,
      family = binomial,
      data = drug_data)
}) %>% setNames(drug_classes_to_keep)

smooth_predictions_amplicon <- lapply(names(drug_models_amplicon), function(drug) {
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
    pred_data$y_pred <- predict(drug_models_amplicon[[drug]], newdata = pred_data, type = "response")
    pred_data$drug_class <- drug
    pred_data
  }) %>% bind_rows()
}) %>% bind_rows()

years_range <- seq(2009, 2023, by = 0.5)

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


smooth_predictions_metagraph_drugs_filtered_amplicon <- smooth_predictions_amplicon %>%
  filter(drug_class %in% metagraph_chosen_drugs)


new_metagraph_like_plot_prevalence_metagraph_drugs_amplicon <- ggplot(
  filter(metagraph_table_complete, drug_class %in% metagraph_chosen_drugs),
  aes(x = collection_year, y = normalized_positive_samples_amplicon_ratio)
) +
  geom_point(alpha = 0.5) +  # Scatter points for observed data
  geom_line(data = smooth_predictions_metagraph_drugs_filtered_amplicon, 
            aes(x = collection_year, y = y_pred, color = continent), 
            linewidth = 1) +  # Add smooth lines with corrected linewidth aesthetic
  scale_color_manual(values = paletteer_d(`"awtools::mpalette"`) ) +
  facet_grid(drug_class ~ continent, labeller = labeller(drug_class = metagraph_chosen_drugs_map)) +  # Facet by drug_class and continent
  labs(
    x = "Year",
    y = "Prevalence in AMPLICON samples (Normalized Positive Samples)",
    title = "Prevalence of AMR Genes by Continent and Drug Class on AMPLICON samples (Metagraph top 6 drugs)"
  ) +
  # theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.text = element_text(size = 12))

ggsave("plots/new_metagraph_like_plot_prevalence_metagraph_drugs_amplicon.png", 
       new_metagraph_like_plot_prevalence_metagraph_drugs_amplicon  , 
       height = 12, width = 12)
