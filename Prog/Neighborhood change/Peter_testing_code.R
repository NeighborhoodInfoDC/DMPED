# Peter Tatian testing code

############################################################################
# 1_compile analysis data.R

# Black population
sum(race_population_2000$non_hispanic_black_pop)
sum(race_population_12$non_hispanic_black_pop)
sum(race_population_22$non_hispanic_black_pop_2022)

# % Black population
pop2000 <- sum(race_population_2000$non_hispanic_white_pop,race_population_2000$non_hispanic_black_pop,
               race_population_2000$hispanic_or_latino_pop,race_population_2000$non_hispanic_aapi_pop,
               race_population_2000$non_hispanic_other_pop)

pop2012 <- sum(race_population_12$non_hispanic_white_pop,race_population_12$non_hispanic_black_pop,
               race_population_12$hispanic_or_latino_pop,race_population_12$non_hispanic_aapi_pop,
               race_population_12$non_hispanic_other_pop)

pop2022 <- sum(race_population_22$non_hispanic_white_pop_2022,race_population_22$non_hispanic_black_pop_2022,
               race_population_22$hispanic_or_latino_pop_2022,race_population_22$non_hispanic_aapi_pop_2022,
               race_population_22$non_hispanic_other_pop_2022)

sum(race_population_2000$non_hispanic_black_pop)/pop2000
sum(race_population_12$non_hispanic_black_pop)/pop2012
sum(race_population_22$non_hispanic_black_pop_2022)/pop2022

