source("tools/metadata_sorting.R")
library(janitor)
library(mgcv)
library(tidyverse)

table_of_hits  = read_csv("alignments_humangut_wcollection_continent.csv")
table_of_drug_classes = read_tsv("card-data/aro_categories.tsv") %>%
  clean_names()



metagraph_table_complete = lapply(X = filter(table_of_drug_classes, 
                                     aro_category == "Drug Class")$aro_name,
                          FUN = function(X){
                            
                            data_table = table_of_hits %>%
                              ungroup() %>%
                              dplyr::filter(grepl(X, DrugClass) ) %>%
                              left_join( select(metadata, acc, assay_type ) , by = "acc") %>%
                              group_by(continent, collection_year) %>%
                              summarize(
                                number_of_hits = n_distinct(contig_id),
                                number_of_positive_samples = n_distinct(acc) ,
                                number_hits_amplicon = n_distinct(contig_id[assay_type == "AMPLICON"]),
                                number_hits_non_amplicon = n_distinct(contig_id[assay_type != "AMPLICON"] ), 
                                number_positive_samples_amplicon = n_distinct(acc[assay_type == "AMPLICON"]),
                                number_positive_samples_non_amplicon = n_distinct(acc[assay_type != "AMPLICON"] ),
                                .groups = "drop"  # Avoids grouped data issues downstream
                              ) %>%
                              tidyr::complete(
                                collection_year, continent, 
                                fill = list(number_of_hits = 0, 
                                            number_of_positive_samples = 0,
                                            number_hits_amplicon = 0 ,
                                            number_hits_non_amplicon = 0 ,
                                            number_positive_samples_amplicon = 0,
                                            number_positive_samples_non_amplicon = 0) #replacing NAs with 0
                              ) %>%  # Ensure all combinations are present
                              left_join(summary_table, 
                                        by = c("continent", "collection_year")) %>%
                              dplyr::mutate(
                                normalized_hits = number_of_hits / total_number_samples,
                                normalized_positive_samples_ratio = number_of_positive_samples / total_number_samples,
                                normalized_hits_amplicon = number_hits_amplicon / number_total_samples_amplicon,
                                normalized_hits_non_amplicon = number_hits_non_amplicon / number_total_samples_non_amplicon,
                                normalized_positive_samples_amplicon_ratio = number_positive_samples_amplicon / number_total_samples_amplicon ,
                                normalized_positive_samples_non_amplicon_ratio = number_positive_samples_non_amplicon / number_total_samples_non_amplicon ,
                                drug_class = X
                              )
                            
                            return(data_table)
                          }) %>%
  bind_rows() %>%
  dplyr::mutate(drug_class = factor(drug_class, levels = filter(table_of_drug_classes, 
                                                                aro_category == "Drug Class")$aro_name ) ,
                continent = factor(continent, 
                                   levels= c("Africa","Asia","Europe",
                                             "North America","South America",
                                             "Oceania" ) ) )


# Count number of observations per drug class
drug_counts <- metagraph_table_complete %>%
  group_by(drug_class) %>%
  summarize(n = n())

# Filter out drug classes with low counts for stats testing
drug_classes_to_keep <- drug_counts %>%
  filter(n >= 50) %>%
  pull(drug_class)


################################################################################
# Prevalence test using a Binomial GAM model
# Fit GAMs for the remaining drug classes
drug_models <- lapply(drug_classes_to_keep, function(drug) {
  drug_data <- metagraph_table_complete %>% 
    filter(drug_class == drug)
  
  gam(normalized_positive_samples_non_amplicon_ratio ~ 
        s(collection_year, by=continent) + continent,
      family = binomial,
      data = drug_data)
}) %>% setNames(drug_classes_to_keep)


# Getting the smooth terms of the analysis.

drug_models_stats = lapply(X = as.character(drug_classes_to_keep) ,
                           FUN = function(X){
                             model_results = as.data.frame( 
                               summary(drug_models[[X]])$s.table ) %>%
                               rownames_to_column(var = "Continent") %>%
                               dplyr::mutate(Continent = as.factor( 
                                 gsub(pattern="s\\(collection_year\\):continent",
                                      replacement = "", 
                                      Continent ) ) , 
                                 drug = X)
                           }) %>%
  bind_rows() %>%
  clean_names()


write_csv(x = drug_models_stats, "Prevalence_binomial_gam.csv")

################################################################################
# Testing it for hit counts with Neg. Binomial  GAM model

clean_data = metagraph_table_complete %>%
  dplyr::mutate(across(everything(), ~ replace_na(., 0)))

drug_models_NB_hits <- lapply(drug_classes_to_keep, function(drug) {
  drug_data <- clean_data %>% 
    filter(drug_class == drug)
  
  gam(normalized_hits_non_amplicon ~ 
        s(collection_year, by=continent) + continent,
      family = nb(),
      data = drug_data)
}) %>% setNames(drug_classes_to_keep)

# Getting the smooth terms of the analysis.

drug_models_hits_NB_stats = lapply(X = as.character(drug_classes_to_keep) ,
                           FUN = function(X){
                             model_results = as.data.frame( 
                               summary(drug_models_NB_hits[[X]])$s.table ) %>%
                               rownames_to_column(var = "Continent") %>%
                               dplyr::mutate(Continent = as.factor( 
                                 gsub(pattern="s\\(collection_year\\):continent",
                                      replacement = "", 
                                      Continent ) ) , 
                                 drug = X)
                           }) %>%
  bind_rows() %>%
  clean_names()


write_csv(x = drug_models_hits_NB_stats, "normalized_hits_Neg_binomial_gam.csv")

# Normalized hits using a Tweedie distribution

drug_models_tweedie_hits <- lapply(drug_classes_to_keep, function(drug) {
  drug_data <- clean_data %>% 
    filter(drug_class == drug)
  
  gam(normalized_hits_non_amplicon ~ 
        s(collection_year, by=continent) + continent,
      family = Tweedie(p = 1.5, link = "log"),  # Tweedie family
      data = drug_data)
}) %>% setNames(drug_classes_to_keep)


drug_models_hits_tweedie_stats = lapply(X = as.character(drug_classes_to_keep) ,
                                   FUN = function(X){
                                     model_results = as.data.frame( 
                                       summary(drug_models_tweedie_hits[[X]])$s.table ) %>%
                                       rownames_to_column(var = "Continent") %>%
                                       dplyr::mutate(Continent = as.factor( 
                                         gsub(pattern="s\\(collection_year\\):continent",
                                              replacement = "", 
                                              Continent ) ) , 
                                         drug = X)
                                   }) %>%
  bind_rows() %>%
  clean_names()



write_csv(x = drug_models_hits_tweedie_stats, "normalized_hits_tweedie_gam.csv")

