# reprex ONLY
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(dygraphs))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(shinydashboardPlus))
suppressPackageStartupMessages(library(gt))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(shinyWidgets))
suppressPackageStartupMessages(library(shinycssloaders))
suppressPackageStartupMessages(library(bslib))
suppressPackageStartupMessages(library(shinyjs))
s1 <- fread("site.txt")
sites <- s1[["topic"]]
names(sites) <- s1[["site_name"]]

ui <-  dashboardPage(dashboardHeader(),
    sidebar = dashboardSidebar(id="sbar",minified = F, useShinyjs(), width = "300px",
                               selectInput(inputId = "site","Site",choices = sites,selected = "dand"),
                               shiny::uiOutput("datepicker"),
                               actionButton("loaddata","Load Data"),
                               div(id="well1",
                               selectInput("STu1","Select Parameter 1",choices = "Waiting for update"),
                               selectInput("STu2","Select Parameter 2",choices = "Waiting for update")
                               ),
                               div(id = "well2",
                               actionButton("plot","Update Charts")
                               )
                               ),
    body = dashboardBody(
        fluidRow(id = "Mainboxes",
        box(title = "Chart 1", id = "chart1", dygraphOutput("tsd1")),
        box(title = "Chart 2", id = "chart2", dygraphOutput("tsd2"))
            )
    )
)
# End of UI
