labor_data <- read.csv("labor_income.csv")
labor_data=labor_data[1:52,]
p <- plot_ly(labor_data)%>%
  add_trace( x = ~year, y = ~male_workers_NO, text = ~sub("^", "Median earnings(2017 adjust $): ", labor_data$male_median_earnings ), type = 'scatter', mode = 'markers',
             marker = list(size = ~(scale(male_median_earnings)+2)*5, opacity = 1,color='0080FF'),name ="Male") %>%
  add_trace( x = ~year, y = ~female_workers_NO, text = ~sub("^", "Median earnings(2017 adjust $): ", labor_data$female_median_earnings ), type = 'scatter', mode = 'markers',
             marker = list(size = ~(scale(female_median_earnings)+2)*5, opacity =1 ,color='FF99FF'),name ="Female") %>%
  layout(title = '<b>Number(height) and Real Median Earnings(size) of Total Workers in the US by Sex</b>',
         xaxis = list(showgrid = TRUE,title="Number of Workers"),
         yaxis = list(showgrid = TRUE, title="Year"))
chart_link = api_create(p, filename="bubble-income")
chart_link