# reprex only
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(dygraphs))
suppressPackageStartupMessages(library(crayon))

options(shiny.reactlog=T)

shinyServer(function(input, output,session) {
# Hide the refresh button for today
  userid <- reactiveVal()
  shinyjs::hide(id = "well1")
  shinyjs::hide(id = "Mainboxes")
  sitedata <- reactiveVal()
  siteDT1 <- reactiveVal()
  siteDT2 <- reactiveVal()
  dy1 <- reactiveVal()
  dy2 <- reactiveVal()
  
  site <- reactiveValues(
    rdsfile=NA_character_,
    name=NA_character_,
    params = data.table()
  )
  
  # hardcoding only 2 date values for reprex
  datmaster <- seq.Date(as_date("2021-06-02"),by = "1 day",length.out = 2)
  
  output$datepicker <- renderUI({
    dateInput(inputId = "datepicker",label = "Select Date",
              min = min(datmaster),
              max = max(datmaster),
              value = max(datmaster)
                )
  })
  
  # Hide the ST boxes when date is changed and until the LOAD button is clicked
  observeEvent(input$datepicker, {
    shinyjs::hideElement(id = "well1")
    shinyjs::hideElement(id = "well2")
    dy1(dy_nodata("Will update after all parameters are selected and 'Update charts' is clicked"))
    dy2( dy_nodata("Will update after all parameters are selected and 'Update charts' is clicked"))
    cat(crayon::bgYellow("\nNew Date selected:",input$datepicker))
    if(length(input$datepicker) ==0) message("NULL DATE..NO ACTION")
  })
  
  
  # Start processing on clicking Load button (after site and date selection)
  observeEvent(input$loaddata,{
    # If date has fuel data
      rdsfile <- paste0(input$datepicker,".RDS")
      cat("\nLoading new RDS file:",rdsfile," and printing it now:\n")
      fulldayDT <- readRDS(rdsfile)
      sitedata(fulldayDT)
      if(nrow(sitedata())>0) {
        cat("\nONE day data loaded for site ",green(input$site)," with ",nrow(sitedata()), "rows.")
        shinyjs::showElement(id = "well1")
        shinyjs::showElement(id = "well2")
        # Get the available parameters to load the choices on the input selection
        site$params <- load_parameters(sitedata())
        param_str <- site$params[,choices:=paste(code,name,site$name)][,choices]
        choice1 <- param_str[str_detect(param_str,"101")][1]
        choice2 <- param_str[str_detect(param_str,"4101")][1]
        if(is.na(choice2)) choice2 <- param_str[str_detect(param_str,"141")][1]
        
        updateSelectInput(session = session,inputId = "STu1",choices = param_str,selected = choice1)
        updateSelectInput(session = session,inputId = "STu2",choices = param_str,selected = choice2)
      } else
        message("Null DT found in the RDS file:",rdsfile)
    
  })
 
  # Plot Charts button clicked should refresh all charts with new site, date and STs
  observeEvent(c(input$plot),{
    shinyjs::showElement("Mainboxes")
      message("..datepicker has EM data")
      updateBox(id = "chart1",action = "update",session = session,
                options = list(title=h2(input$STu1)))
      STsel <- str_extract(input$STu1,"^\\d+") %>% str_trim %>% as.integer() # take the first number
      cat("\nST extracted from the user input 1 is:",bgYellow(STsel))
      siteDT1(sitedata()[ST==STsel])
      updateBox(id = "chart2",action = "update",session = session,
                options = list(title=h2(input$STu1)))
      STsel2 <- str_extract(input$STu2,"^\\d+") %>% str_trim %>% as.integer()
      cat("\nST extracted from the user input 2 is:",bgYellow(STsel2))
      siteDT2(sitedata()[ST==STsel2])

      if(nrow(siteDT1())==0){
        message("DT1 has zero rows.. identify and fix that first")
        dy1(dy_nodata("Variable missing in the database"))
      } else  {
        message("\nsiteDT1 data for ",input$site, " loaded to reactive chart having this content:")
        print(siteDT1())
        dy1(dygen(siteDT1(),site=input$site))
      }
      
      if(nrow(siteDT2())==0){
        message("DT2 has zero rows.. identify and fix that first")
        dy2(dy_nodata("Variable missing in the database"))
      } else {
        message("\nsiteDT2 data for ",input$site, " loaded to reactive chart having this content:")
        print(siteDT2())
        dy2(dygen(siteDT2(),site=input$site))
      }
  },ignoreInit = T)
  
  
  
  # Main action is to hide the parameters on changing the site
  observeEvent(c(input$site),{
    cat("\n=================\nNEW SITE SELECTED:",bgGreen(input$site),"\n=================")
    hideElement("well1")
    hideElement("well2")
    site$name <- "BERLIN23"
    dy1(dy_nodata("Select parameters for site and click Update Charts"))
    dy2( dy_nodata("Select parameters for site and click Update Charts"))
     })
    
#   Output two charts
  output$tsd1 <- renderDygraph({
    dy1()
  })
  output$tsd2 <- renderDygraph({
    dy2()
  })
  
})
