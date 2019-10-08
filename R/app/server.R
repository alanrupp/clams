library(shiny)

# Server actions to plot data
shinyServer(function(input, output, session) {
  
  # - Read in data ------------------------------------------------------------
  observeEvent(input$fname, {
    infile <- input$fname
    
    # get parameter choices
    observeEvent(input$sheets, {
      df <- map(input$sheets, ~ read_data(infile$datapath, .x))
      names(df) <- names(input$sheets)
      
      min_date <- as.Date(min(df[[1]]$Day))
      max_date <- as.Date(max(df[[1]]$Day))
      
      # select only some dates
      updateDateRangeInput(session, "dates", "Dates",
                           start = min_date, end = max_date,
                           min = min_date, max = max_date)
      observeEvent(input$dates, {
        df <- map(df, 
                  ~ filter(.x, Day >= input$dates[1] & Day <= input$dates[2])
        )
      })
    })
    
  })
  
  # - Plot data ---------------------------------------------------------------
  observeEvent(input$accept, {
    if (input$plottype == "full") {
      output$plot <- renderPlot({ plot_continuous(df, input$sheets) })
    }
  })
  
  
  
})