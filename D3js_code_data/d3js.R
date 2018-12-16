library(threejs)
library(htmlwidgets)
df = read.csv('state_2018.csv')
MyJ3=scatterplot3js(df$Local_Spending_b,df$GDP_b,df$Population_m,
                    
                    color = (c(1:51)*3.6),#[as.factor(df$State)],
                    #color=df$State,
                    axisLabels=c('Local Spending (Billion$)',"Population(Million)","GDP(Billion$)"))
MyJ3
saveWidget(MyJ3, file="3djs.html", selfcontained = TRUE, libdir =
             NULL,
           
           background = "white")