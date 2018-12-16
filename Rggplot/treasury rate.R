library(tidyverse)
library(tidyquant)
library(scales)
library(tibbletime)

# Set up tickers
tickers<- c("GS10",   # 10-year constant maturity Treasury yield
            "TB3MS",  # 3-month Tbill rate
            "UNRATE", # unemployment rate
            "NROU"  ) # estimate of natural rate of unemployment from U.S. Congressional Budget Office

# download data via FRED 
df2<-tq_get(tickers,                         # get selected symbols
            get="economic.data",             # use FRED
            from="1954-01-01")               # go from 1954 forward

df2 %>% 
  spread(symbol,price) -> df3


# Convert quarterly naturla rate (NROU) data to monthly data by "filling down" using na.locf

df3 %>% 
  mutate(NROU2=na.locf(NROU,na.rm=F)) %>% 
  mutate(UGAP2=UNRATE-NROU2)-> df3

# Create some indicators for shaded plot

df3 <- mutate( df3, 
               up=ifelse(UNRATE>NROU2,UNRATE,NROU2),
               down=ifelse(UNRATE<NROU2,UNRATE,NROU2),
               up2=ifelse(GS10>TB3MS,GS10-TB3MS,0),
               down2=ifelse(GS10<TB3MS,GS10-TB3MS,0)
)

# Set up recession indicators

recessions.df = read.table(textConnection(
  "Peak, Trough
  1948-11-01, 1949-10-01
  1953-07-01, 1954-05-01
  1957-08-01, 1958-04-01
  1960-04-01, 1961-02-01
  1969-12-01, 1970-11-01
  1973-11-01, 1975-03-01
  1980-01-01, 1980-07-01
  1981-07-01, 1982-11-01
  1990-07-01, 1991-03-01
  2001-03-01, 2001-11-01
  2007-12-01, 2009-06-01"), sep=',',
  colClasses=c('Date', 'Date'), header=TRUE)


# Unemployment rate plot
g<-
  ggplot(data=filter(df3,!is.na(NROU2)),aes(x=date,y=UNRATE))+
  geom_rect(data=recessions.df, inherit.aes=F, aes(xmin=Peak, xmax=Trough, ymin=-Inf, ymax=+Inf), fill='darkgray', alpha=0.5) +
  geom_line(color="black")+
  geom_line(linetype=2,aes(y=NROU2))+
  geom_ribbon(aes(ymin=UNRATE,ymax=down),fill="#ea2c42",alpha=0.5)+
  geom_ribbon(aes(ymin=UNRATE,ymax=up),fill="#4286f4",alpha=0.5)  +
  scale_x_date(date_breaks="5 years",date_labels="%Y")+
  scale_y_continuous(sec.axis=dup_axis())+
  theme_minimal(base_size=8)+
  theme(legend.position="top",
        plot.caption=element_text(hjust=0),
        plot.subtitle=element_text(face="italic"),
        plot.title=element_text(size=16,face="bold"))+
  labs(x="",y="Percent",
       title="U.S. Unemployment Rate vs Natural Rate of Unemployment",
       subtitle="Solid line Unemployment Rate, dotted line Long-term Natural Rate of Unemployment")+
  geom_rug(aes(color=ifelse(UNRATE<=NROU2,"Below or Equal","Above")),sides="b")+
  scale_color_manual(values=c("#ea2c42","#4286f4"),name="Unemployment Rate Above/Below Natural Rate ")

# Slope of yield curve plot

g2<-
  ggplot(data=filter(df3,!is.na(TB3MS) & !is.na(GS10)),aes(x=date,y=GS10-TB3MS))+
  geom_rect(data=filter(recessions.df,year(Peak)>1952), inherit.aes=F, aes(xmin=Peak, xmax=Trough, ymin=-Inf, ymax=+Inf), fill='darkgray', alpha=0.5) +
  geom_line(color="black")+
  theme_minimal()+
  geom_ribbon(aes(ymin=0,ymax=down2),fill="#ea2c42",alpha=0.5)+
  geom_ribbon(aes(ymin=up2,ymax=0),fill="#4286f4",alpha=0.5)  +
  geom_rug(aes(color=ifelse(GS10>=TB3MS,">=0","<0")),sides="b")+
  scale_color_manual(values=c("#ea2c42","#4286f4"),name="Yield Curve Slope ")+
  scale_x_date(date_breaks="5 years",date_labels="%Y")+
  scale_y_continuous(sec.axis=dup_axis())+
  labs(x="",y="Difference in percentage points",title="10-year minus 3-month U.S. Treasury rates", caption = "* Grey periods are recession",
       subtitle="Difference in percentage points, monthly averages")+
  geom_hline(yintercept=0,color="black")+
  theme(legend.position="top",
        plot.caption=element_text(hjust=0),
        plot.subtitle=element_text(face="italic",size=9),
        plot.title=element_text(face="bold",size=14,hjust = 0.5))

g2
ggsave("g2.png", width = 18, height = 10)