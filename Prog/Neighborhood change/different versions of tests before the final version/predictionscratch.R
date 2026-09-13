predicted <- predict(OLS1, predictionmaster2, type = "response")
predictionmaster2$predictedchangeinblack <- predicted


test <- predictionmaster2 %>% 
  select(GEOID,predictedchangeinblack,changeblack_2022,non_hispanic_black_hh_2022) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_hh_2022) %>% 
  filter(pct<(-0.1))

quintile_cutoffs <- quantile(popbyrace$non_hispanic_black_pop_2022, probs = seq(0, 1, by = 0.1))
print(quintile_cutoffs)

# 0%    10%    20%    30%    40%    50%    60%    70%    80%    90%   100% 
# 0.0  152.5  213.0  397.0  683.0 1024.5 1468.0 1990.0 2669.0 3332.0 5720.0 

Testresult <- predictionmaster2 %>% 
  left_join(neighborhoodname, by=c("GEOID")) %>% 
  left_join(predictionmaster, by=c("GEOID")) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_hh_2022.x) %>% 
  mutate(startpop=ntile(non_hispanic_black_hh_2022.x,10)) %>% 
  # select(GEOID, NBH_NAMES,Ward, NAME.y, displacement, predictedchangeinblack) %>% 
  # select(GEOID,predictedchangeinblack,non_hispanic_black_hh_2022-non_hispanic_black_hh_2000_2020)
  mutate(lossmorethan10=ifelse(pct<-0.1 & startpop>2 ,1,0),
         lossmorethan20=ifelse(pct<-0.2 & startpop>2 ,1,0)) %>% 
  select(GEOID,pct,lossmorethan10,lossmorethan20)

quintile_cutoffs <- quantile(Testresult$pct, probs = seq(0, 1, by = 0.1))
print(quintile_cutoffs)

upcomingdisplacement <- predicteddisplacementmap %>% 
  left_join(Testresult,by=c("GEOID")) %>% 
  filter(lossmorethan20==1) %>% 
  filter(non_hispanic_black_hh_2022.x>213)



ggplot() +
  # geom_sf(data =predicteddisplacementmap, aes( fill = `neighborhood category`))+
  # scale_fill_manual(name="neighborhoodchange type", values = urban_colors8, guide = guide_legend(override.aes = list(linetype = "blank", 
  #                                                                                                                    shape = NA)))+ 
  # geom_sf(BBCF, mapping = aes(), fill=NA,lwd =  0.5, color="#fdbf11",show.legend = "line")+
  # geom_sf(cog_all, mapping = aes(), fill=NA,lwd =  1, color="#ec008b",show.legend = "line")+
  # scale_color_manual(values = 'transparent', guide = guide_legend(override.aes = list(linetype = "solid"))) +
  # geom_sf(water_sf, mapping=aes(), fill="#dcdbdb", color="#dcdbdb", size=0.05)+
  # coord_sf(datum = NA)+
  # theme(
  #   panel.grid.major = element_line(colour = "transparent", linewidth = 0),
  #   axis.title = element_blank(),
  #   axis.line.y = element_blank(),
  #   plot.caption = element_text(hjust = 0, linewidth = 16),
  #   plot.title = element_text(linewidth = 18),
  #   legend.title=element_text(linewidth=14),
  #   legend.text = element_text(linewidth = 14)
  # 
  # )+
  guides(color = guide_legend(override.aes = list(size=5)))+
  geom_sf(data = tractboundary_20, fill = "transparent", color="#adabac")+
  coord_sf(datum = NA)+
  geom_sf(data = upcomingdisplacement, fill = "transparent", color="#ec008b")+
  coord_sf(datum = NA)+
  labs(title = paste0("Neighborhood Change in DC based on OTR sales data"),
       subtitle= "Increased displacement risk area highlighted in red",
       caption = "Source: Census 2000, ACS 5-year estimates 2008-2012, 2018-2022")


#test the new combination of thresholds for loss of black population
popchange <- master6 %>% 
  mutate(loss_2000_2012=total_hh_2012_2020-total_hh_2000_2020,
         loss_2012_2022=total_hh_2022-total_hh_2012_2020) %>% 
  filter(loss_2012_2022<0) %>% 
  select(GEOID, Ward,NBH_NAMES,loss_2000_2012, loss_2000_2012,loss_2012_2022) %>% 
  group_by(NBH_NAMES,Ward) %>% 
  count()

# Density plot for comparing two periods
ggplot(popchange) +
  geom_density(aes(x = loss_2000_2012, color = "2000-2012"), fill = "blue", alpha = 0.3) +
  geom_density(aes(x = loss_2012_2022, color = "2012-2022"), fill = "green", alpha = 0.3) +
  labs(
    title = "Comparison of Population Change Distribution",
    x = "Population Change",
    y = "Density"
  ) +
  scale_color_manual(values = c("2000-2012" = "blue", "2012-2022" = "green")) +
  theme_minimal()


test <- predictionmaster2 %>% 
  # left_join(neighborhoodname, by=c("GEOID")) %>% 
  # left_join(predictionmaster, by=c("GEOID")) %>% 
  mutate(pct=predictedchangeinblack/non_hispanic_black_pop_2022) %>% 
  mutate(pct=ifelse(pct<(-1),-1,pct)) %>% 
  mutate(startpop=ntile(non_hispanic_black_pop_2022,10)) %>% 
  mutate(lossmorethan10=ifelse((pct< -0.1|predictedchangeinblack< -50)& startpop>2,1,0),
         lossmorethan20=ifelse(pct< -0.2 & startpop>2 ,1,0)) %>% 
  select(GEOID,NBH_NAMES,neighborhoodtype,predictedchangeinblack,changeblack_2022,startpop,non_hispanic_black_pop_2022,pct,lossmorethan10,lossmorethan20) %>% 
  mutate(predicted_class=ifelse(lossmorethan20==1,1,0))
