library(tidyverse)

# Distribution of samples per sample type
summary_table_long = summary_table %>%
  pivot_longer(
    cols = c(number_total_samples_amplicon, number_total_samples_non_amplicon), 
    names_to = "sample_type", 
    values_to = "number_of_samples"
  )

distribution_of_samples_per_sample_type = ggplot(summary_table_long, 
       aes(x= collection_year, fill=sample_type , y = number_of_samples)) +
  geom_col() +
  scale_fill_brewer(palette = "Dark2",
                    labels = c("number_total_samples_amplicon" = "Amplicon",
                               "number_total_samples_non_amplicon" = "Non-Amplicon"))+
  labs(x="Collection year", y = "Number of samples", 
       fill = "Sample Type", title = "Distribution of samples per sample type") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
  facet_wrap(~continent , scales = "free_y")

ggsave(filename = "plots/summary/distribution_of_samples_per_sample_type.png", 
       distribution_of_samples_per_sample_type)

################################################################################
# Percentage of samples that are amplicon-based in each continent/year.

summary_table_perc_amplicon = summary_table %>%
  dplyr::mutate(amplicon_ratio = number_total_samples_amplicon / total_number_samples)

perc_samples_amplicon_based = ggplot(summary_table_perc_amplicon ,
       aes(x = collection_year, y= amplicon_ratio*100 ,  fill=continent)) +
  geom_col(position = position_dodge2() ) +
  scale_fill_brewer(palette = "Set1") +
  labs(x="Collection year", y = "Amplicon-based sample ratio (%)", fill = "Continent") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
  facet_wrap(~continent)

ggsave(filename = "plots/summary/perc_samples_amplicon_based.png",
       perc_samples_amplicon_based)


################################################################################

# Getting some summary statistics about the number of hits from amplicon vs non-amplicon samples

summary_for_amplicon_analysis = metagraph_table_complete %>%
  group_by(collection_year, continent) %>%
  summarize(sum_hits_amplicon = sum(number_hits_amplicon) ,
            sum_hits_non_amplicon = sum(number_hits_non_amplicon),
            total_number_amplicon = sum(number_total_samples_amplicon),
            total_number_non_amplicon = sum(number_total_samples_non_amplicon)) %>%
  dplyr::mutate(hits_per_sample_amplicon = sum_hits_amplicon / total_number_amplicon ,
                hits_per_sample_non_amplicon = sum_hits_non_amplicon / total_number_non_amplicon) %>%
  pivot_longer(cols = c(hits_per_sample_amplicon, hits_per_sample_non_amplicon),
               names_to = "sample_type",
               values_to = "number_of_hits")


summary_of_hits_sample_type_plot = ggplot(summary_for_amplicon_analysis ,
       aes(x=collection_year, y = number_of_hits, fill=sample_type)) +
  geom_col(position = position_dodge2() ) +
  scale_fill_brewer(palette = "Dark2",
    labels = c("hits_per_sample_amplicon" = "Amplicon",
                               "hits_per_sample_non_amplicon" = "Non-Amplicon")
  )+
  labs(x="Collection year", 
       y = "Number of hits per total number of samples of each type", 
       fill = "Sample Type",
       title = "Number of hits per total number of samples, normalized within each sample type" ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
  facet_wrap(~continent)

ggsave(filename = "plots/summary/summary_of_hits_sample_type_plot.png",
       summary_of_hits_sample_type_plot)


