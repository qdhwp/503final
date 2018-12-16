library(networkD3)
ntw=read.csv('network_data.csv')
#ntw$Leading.export.market,ntw$Country
ntw2=select(ntw,'Country','Leading.export.market')
#ntw$Leading.import.source
ntw3=select(ntw,'Country','Leading.import.source')
#simpleNetwork(ntw$Country,ntw$Leading.export.market)
export<-simpleNetwork(ntw2)
import<-simpleNetwork(ntw3)
saveNetwork(export, "export_network.html", selfcontained = TRUE)
saveNetwork(import, "import_network.html", selfcontained = TRUE)