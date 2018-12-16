library(ggplot2)
library(scales)
ggplot(economics, aes(x = date, y = psavert)) +
  geom_line(color = "indianred3", 
            size=1 ) +
  geom_smooth() +scale_x_date(date_breaks = '5 years', 
                              labels = date_format("%b-%Y")) +
  labs(title = "Personal Savings Rate",
       subtitle = "Personal Savings Rate, monthly averages",
       x = "",
       y = "Personal Savings Rate(%)", caption = "* Grey periods are recession") +
  scale_y_continuous(sec.axis=dup_axis())+
  geom_rect(data=filter(recessions.df,year(Peak)>1965), inherit.aes=F, aes(xmin=Peak, xmax=Trough, ymin=-Inf, ymax=+Inf), fill='darkgray', alpha=0.5)+theme_minimal() +theme(legend.position="top",plot.caption=element_text(hjust=0),plot.subtitle=element_text(face="italic",size=9), plot.title=element_text(face="bold",size=14,hjust = 0.5))

#+geom_rug(aes(color=ifelse(GS10>=TB3MS,">=0","<0")),sides="b")
#+scale_x_continuous(breaks = round(seq(min(cpi$TIME), max(cpi$TIME), by = 5),1))
ggsave("economics.png", width = 18, height = 10)