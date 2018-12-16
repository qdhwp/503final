library(tidyquant)
library(ggpomological)
library(extrafont)  # for the special fonts
library(cowplot)

df<- tq_get(c("MORTGAGE30US","HOUST"),get="economic.data",from="1959-01-01")
df$year<-year(df$date)
df <- mutate(df, decade=paste0(10*floor(year/10),"'s"))
df <- df %>% group_by(year,symbol) %>% mutate(week=row_number()) %>% ungroup() %>%
  group_by(decade) %>% mutate(weekd=row_number()) %>% ungroup() %>%
  mutate(yearf=factor(year))

df.mtg    <- filter(df, symbol=="MORTGAGE30US")
df.starts <- filter(df, symbol=="HOUST")
df <- df.mtg



df.ms <- df.starts  %>% filter(year(date)>1959) %>% mutate(month=month(date)) %>% group_by(decade, year,month) %>% summarize(price=mean(price,na.rm=T))  %>% ungroup() %>% 
  group_by(decade) %>% mutate(id=row_number()) %>% ungroup() %>% mutate(date=as.Date(ISOdate(year,month,1)))


myxy3<- function(dd, df=df){
  x<-filter(df,decade==dd)$price
  outdf<- data.frame(
    x=density(x)$x[which.max(density(x)$y)],
    y=max(density(x)$y,na.rm=T)
  )
}
df.textd <- data.frame(decade=unique(filter(df.starts, year(date)>1959)$decade)) %>% mutate(xy=map(decade,myxy3, df=df.starts)) %>% unnest(xy) 

g.dens.starts.plain <-
  ggplot(data= df.ms,
         aes(x=price, fill=decade,color=decade))+
  geom_density(alpha=0.35)+
  theme(legend.position="none")+
  scale_x_continuous(limits=c(0,2500),breaks=seq(0,2500,500))+
  scale_y_continuous(breaks=NULL,sec.axis=dup_axis())+
  geom_text(data=df.textd,aes(label=decade, x=x,y=y),size=12)+
  labs(x="Housing Starts (1000s, SAAR)", y= "estimated density\n")+
  theme(plot.caption=element_text(hjust=0),
        plot.title=element_text(face="bold"),
        axis.text=element_text(size=12))



g.line.starts.plain<-
  ggplot(data= df.ms,
         aes(x=date,y=price, fill=decade,color=decade))+
  geom_ribbon(alpha=0.35,color=NA, aes(ymin=0,ymax=price))+
  geom_line(size=1.05)+
  theme(legend.position="none")+
  geom_text( data= filter(df.ms, (year-floor(year/10)*10)==5 & month==6), aes(y=500,label=decade),
             size=6, color="white")+
  scale_y_continuous(limits=c(0,2600),breaks=seq(0,2500,500),sec.axis=dup_axis(),expand=c(0,0))+
  scale_x_date(date_breaks="5 year",date_labels="%Y",expand=c(0,0))+
  labs(x="",y="Housing Starts (1000s SAAR)\n",
       subtitle="Total Housing Starts",
       title="U.S. Housing Starts Grinding Higher",
       caption='* The “New Residential Construction Report,” known as "housing starts".')+
  theme(plot.caption=element_text(hjust=0),
        plot.title=element_text(face="bold"),
        axis.text=element_text(size=12))
g.line.starts.plain
g.dens.starts.plain
cowplot::plot_grid(g.line.starts.plain,g.dens.starts.plain, labels = "AUTO",cols=1)->aa
#save_plot("try.png", aa)
#multiplot(g.line.starts.plain,g.dens.starts.plain, cols=1)
ggsave("aa.png", width = 15, height = 20)