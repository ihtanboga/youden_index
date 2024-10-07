library(shiny)
library(plotly)
library(readxl)
library(haven)
library(data.table)
library(shinythemes)
library(shinyWidgets)
library(DT)

# Define UI
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Youden Index Calculator"),
  sidebarLayout(
    sidebarPanel(
      fileInput("data_file", "Upload Data File",
                accept = c(".xlsx", ".xls", ".csv", ".txt", ".sas7bdat", ".dta", ".sav")),
      uiOutput("variable_selectors"),
      actionButton("calculate", "Calculate Youden Index", class = "btn-primary"),
      br(), br(),
      downloadButton("download_results", "Download Results", class = "btn-success")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotlyOutput("youden_plot")),
        tabPanel("Results", DTOutput("results_table")),
        tabPanel("Data Preview", DTOutput("data_preview"))
      )
    )
  )
)


