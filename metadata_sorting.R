library(tidyverse)
library(lubridate)
library(egg)

metadata = read_csv(file = "metadata_human_gut_metagenome3.csv", col_names = T)

metadata = metadata %>%
  dplyr::mutate(collection_year = 
                  lubridate::year(as.Date( 
                    gsub("\\[|\\]", "", collection_date_sam) ) ) ) %>%
  dplyr::filter(!grepl("uncalculated", geo_loc_name_country_continent_calc)  &
           !is.na(geo_loc_name_country_continent_calc) ) %>%
  dplyr::filter(!is.na(collection_year)) %>%
  dplyr::rename(continent = geo_loc_name_country_continent_calc) %>%
  dplyr::mutate( continent = factor(continent, 
                                    levels= c("Africa","Asia","Europe",
                                              "North America","South America",
                                              "Oceania") ) )
  

summary_table = metadata %>%
  group_by(continent , collection_year) %>%
  summarize(total_number_samples = n_distinct(acc),
            number_total_samples_amplicon = n_distinct(acc[assay_type == "AMPLICON"]),
            number_total_samples_non_amplicon = n_distinct(acc[assay_type != "AMPLICON"] ) )


sample_distribution = ggplot(summary_table) +
  geom_col(aes(fill = continent,
               x = collection_year, 
               y= total_number_samples)) +
#  scale_y_continuous(limits = c(0, 15000)) +
  scale_fill_brewer(palette = "Set1") +
  labs(x="Collection year", y="number of samples", fill= "Continent") 

ggsave("plots/sample_distribution.png", sample_distribution)

ggsave("plots/sample_distribution_byContinent.png", sample_distribution+
         scale_y_continuous(limits = c(0, 15000)) + facet_wrap(~continent , nrow = 2) )

  

summary_table2 = metadata %>%
  group_by(continent , assay_type) %>%
  summarize(number_samples = n_distinct(acc) )

a = ggplot(summary_table2) +
  geom_col(aes(fill = librarysource, 
               x = continent ,
               y = number_samples) ,
           position = position_dodge(width = 0.8)) 

b = ggplot(summary_table2) +
  geom_col(aes(fill = assay_type, 
               x = continent ,
               y = number_samples) ,
           position = position_dodge(width = 0.8)) 

combined_plot = egg::ggarrange(plots = list(a,b) , 
                               labels = c("Library Source", "Assay Type"))

ggsave("plots/summary/metadata.png", combined_plot, width = 10, height = 10)

# Filter both tables for the specific continent and collection year
metadata_filtered <- metadata %>%
  filter(continent == "South America", collection_year == 2014)

metagraph_filtered <- metagraph_table %>%
  filter(continent == "South America", collection_year == 2014)

# Find `acc` values in metadata but not in metagraph_table
acc_in_metadata_not_metagraph <- setdiff(metadata_filtered$acc, metagraph_filtered$acc)

# Find `acc` values in metagraph_table but not in metadata
acc_in_metagraph_not_metadata <- setdiff(metagraph_filtered$acc, metadata_filtered$acc)



