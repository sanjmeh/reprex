#reprex
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(shinydashboardPlus))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(dygraphs))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(purrr))

cat("\nApplication Starting. Loading data from disk")
cat("..loaded.")

#===== FUNCTIONS DEFINED HERE =====
sum2 <- function(x) sum(x,na.rm = T)


# NO DATA DYGRAPH
dy_nodata <- function(title="NO DATA AVAILABLE")  as.ts(x=NA) %>% 
  dygraph(main=title,height = 75) %>% 
  dyOptions(drawGrid = F,drawYAxis = F,drawXAxis = F,titleHeight = 40)



dygen <- function(tsd=NA,site=NA){
  dychart <- 
    tsd %>% 
    select(ts,VR) %>% 
    dygraph( group = site) %>% 
    dyRangeSelector(retainDateWindow = F) %>%
    dySeries(fillGraph = T)
  return(dychart)
}

# Function to load live ST parameters for the DT
load_parameters <- function(dt){
  fnames <- c("ELM8420.txt","ELM4100.txt")
  names(fnames) <- c("ELM8420","ELM4100")
  stdt <- fnames %>%  map(fread) %>% rbindlist(idcol = "device")
  stdt
}


##===== END OF FUNCTIONS=========

cat("\n...DONE with global.R..moving to shiny app")




# pass the json_split mqtt file
