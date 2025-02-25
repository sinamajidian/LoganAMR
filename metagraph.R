source("tools/metadata_sorting.R")


table_of_hits  = read_csv("alignments_humangut_wcollection_continent.csv")


summary_hits = table_of_hits %>%
  left_join( select(metadata, acc, assay_type ) , by = "acc") %>%
  group_by(collection_year, continent, DrugClass) %>%
  summarize(number_of_hits = n_distinct(contig_id) ,
            number_of_samples = n_distinct(acc) ,
            number_hits_amplicon = n_distinct(contig_id[assay_type == "AMPLICON"]),
            number_hits_non_amplicon = n_distinct(contig_id[assay_type != "AMPLICON"] ), 
            number_samples_amplicon = n_distinct(acc[assay_type == "AMPLICON"]),
            number_samples_non_amplicon = n_distinct(acc[assay_type != "AMPLICON"] ) ) %>%
  left_join(summary_table, by = c("continent", "collection_year") ) %>%
  dplyr::mutate( continent = factor(continent, 
                                    levels= c("Africa","Asia","Europe",
                                              "North America","South America",
                                              "Oceania") ) )


write_csv(summary_hits, "summary_of_hits_per_drugClass.csv")

# Reproducing the metagraph paper

metagraph_table = table_of_hits %>%
  ungroup() %>%
  dplyr::mutate(aminoglycoside = grepl("aminoglycoside antibiotic", DrugClass),
                cephamycin = grepl("cephamycin", DrugClass),
                diaminopyrimidine = grepl("diaminopyrimidine antibiotic", DrugClass),
                antiseptics =  grepl("disinfecting agents and antiseptics", DrugClass),
                fluoroquinolone = grepl("fluoroquinolone antibiotic", DrugClass),
                glycylcycline=grepl("glycylcycline", DrugClass) ) %>%
  dplyr::filter(rowSums(as.matrix(.[, 16:ncol(.)] ) ) > 0)   # filtering to keep the rows that have at least one true in columns 16:last column

metagrap_summary_table = metagraph_table %>%
  left_join( select(metadata, acc, assay_type ) , by = "acc") %>%
  group_by(continent, collection_year) %>%
  summarize(number_of_hits = n_distinct(contig_id) ,
            number_of_positive_samples = n_distinct(acc) ,
            number_hits_amplicon = n_distinct(contig_id[assay_type == "AMPLICON"]),
            number_hits_non_amplicon = n_distinct(contig_id[assay_type != "AMPLICON"] ), 
            number_samples_amplicon = n_distinct(acc[assay_type == "AMPLICON"]),
            number_samples_non_amplicon = n_distinct(acc[assay_type != "AMPLICON"] )) %>%
  left_join(summary_table, 
            by = c("continent", "collection_year"))
  

metagraph_table2 = lapply(X = colnames(metagraph_table)[16:ncol(metagraph_table)],
                        FUN = function(X){
                          data_table = metagraph_table %>%
                            dplyr::filter(!!sym(X) == TRUE) %>%
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
                                          number_of_positive_samples = 0)
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
  dplyr::mutate(drug_class = factor(drug_class, levels = colnames(metagraph_table)[16:ncol(metagraph_table)] ) ,
                continent = factor(continent, 
                                   levels= c("Africa","Asia","Europe",
                                             "North America","South America",
                                             "Oceania" ) ) )

### Replacing the NA and NaN with a 0.
metagraph_table2 <- metagraph_table2 %>%
  mutate(across(everything(), ~ replace_na(replace(., is.nan(.), 0), 0))) 

### Plotting all the samples
metagraph_plot = ggplot(metagraph_table2) +
  geom_col( aes( fill = drug_class, x = collection_year, y= normalized_hits ),
            position = position_dodge(width = 1), width = 0.7) +
  scale_fill_brewer(palette = "Dark2") +
  labs(x="Collection year", y="AMR gene Hits / # total gut microbiome samples", 
       fill= "Drug class", title = "Metagraph reproduction -  AMR genes hits among human gut microbiome samples") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~continent)

ggsave("plots/metagraph_hits_plot.png", metagraph_plot +
         facet_grid(drug_class~continent)  , height = 10, width = 12)

metagraph_perc_pos_samples_plot = ggplot(metagraph_table2) +
  geom_col( aes( fill = drug_class, x = collection_year, y= normalized_positive_samples_ratio * 100 ),
            position = position_dodge(width = 1), width = 0.7) +
  scale_fill_brewer(palette = "Dark2") +
  labs(x="Collection year", y="Percentage of samples positive to the AMR gene", 
       fill= "Drug class", title = "Metagraph reproduction -  AMR genes positive percentage among human gut microbiome samples") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~continent)

ggsave("plots/metagraph_perc_positive_samples_plot.png", metagraph_perc_pos_samples_plot +
         facet_grid(drug_class~continent)  , height = 10, width = 12)

### Plotting the non-Amplicon and hits samples only.

metagraph_hits_non_amplicon_plot = ggplot(metagraph_table2) +
  geom_col( aes( fill = drug_class, x = collection_year, y= normalized_hits_non_amplicon ),
            position = position_dodge(width = 1), width = 0.7) +
  scale_fill_brewer(palette = "Dark2") +
  labs(x="Collection year", y="AMR gene Hits / # total gut microbiome non-amplicon samples", 
       fill= "Drug class", title = "Metagraph reproduction -  AMR gene hits among non-AMPLICON human gut microbiome samples") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(drug_class~continent) 

ggsave("plots/metagraph_hits_non_amplicon_plot.png", metagraph_hits_non_amplicon_plot  , height = 10, width = 12)

metagraph_perc_pos_non_amplicon_samples_plot = ggplot(metagraph_table2) +
  geom_col( aes( fill = drug_class, x = collection_year, y= normalized_positive_samples_non_amplicon_ratio * 100 ),
            position = position_dodge(width = 1), width = 0.7) +
  scale_fill_brewer(palette = "Dark2") +
  labs(x="Collection year", y="Percentage of samples positive to the AMR gene", 
       fill= "Drug class", title = "Metagraph reproduction -  AMR genes positive percentage among non-AMPLICON human gut microbiome samples") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~continent)

ggsave("plots/metagraph_perc_positive_non_amplicon_samples_plot.png", metagraph_perc_pos_non_amplicon_samples_plot +
         facet_grid(drug_class~continent)  , height = 10, width = 12)
