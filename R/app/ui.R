library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("CLAMS Data"),
  
  # Sidebar data input, plot settings, and grouping
  sidebarLayout(
    sidebarPanel(
      fileInput("fname", "File:"),
      selectizeInput("sheets", "Choose parameters", choices = param_choices, 
                     multiple = TRUE),
      dateRangeInput("dates", "Dates"),
      actionButton("accept", "Accept"),
      tags$hr(),
      h3("Plot settings"),
      radioButtons("plottype", "Plot type", inline = TRUE,
                   choices = c("Full" = "full", "Paired average" = "paired"))
    ),
      
    # Show plot and save
    mainPanel(
      plotOutput("plot")
    )
  )
))