# Define server
server <- function(input, output, session) {
  # Read data from uploaded file
  data <- reactive({
    req(input$data_file)
    ext <- tools::file_ext(input$data_file$name)
    
    tryCatch({
      df <- switch(ext,
                   xlsx = read_excel(input$data_file$datapath),
                   xls = read_excel(input$data_file$datapath),
                   csv = fread(input$data_file$datapath, data.table = FALSE),
                   txt = fread(input$data_file$datapath, data.table = FALSE),
                   sas7bdat = read_sas(input$data_file$datapath),
                   dta = read_dta(input$data_file$datapath),
                   sav = read_spss(input$data_file$datapath),
                   stop("Unsupported file format")
      )
      
      # Mark non-numeric values as NA
      df[] <- lapply(df, function(x) {
        if(is.character(x)) {
          as.numeric(as.character(x))
        } else {
          x
        }
      })
      
      return(df)
    }, error = function(e) {
      stop(paste("Data read error:", e$message))
    })
  })
  
  # Data preview
  output$data_preview <- renderDT({
    req(data())
    datatable(head(data(), 100), options = list(scrollX = TRUE))
  })
  
  # Update UI for variable selection
  output$variable_selectors <- renderUI({
    req(data())
    var_names <- names(data())
    
    tagList(
      selectInput("dependent_var", "Select Dependent Variable", choices = var_names),
      selectInput("independent_var", "Select Independent Variable", choices = var_names)
    )
  })
  
  # Calculate Youden index
  youden_index <- eventReactive(input$calculate, {
    req(input$dependent_var, input$independent_var)
    df <- data()
    dependent_var <- df[[input$dependent_var]]
    independent_var <- df[[input$independent_var]]
    
    validate(
      need(!all(is.na(dependent_var)), "The dependent variable contains all NA values."),
      need(!all(is.na(independent_var)), "The independent variable contains all NA values.")
    )
    
    calculate_sensitivity_specificity <- function(dependent_var, independent_var, cutoff) {
      predictions <- ifelse(independent_var >= cutoff, 1, 0)
      
      tp <- sum(dependent_var == 1 & predictions == 1, na.rm = TRUE)
      tn <- sum(dependent_var == 0 & predictions == 0, na.rm = TRUE)
      fp <- sum(dependent_var == 0 & predictions == 1, na.rm = TRUE)
      fn <- sum(dependent_var == 1 & predictions == 0, na.rm = TRUE)
      
      sensitivity <- tp / (tp + fn)
      specificity <- tn / (tn + fp)
      
      list(Sensitivity = sensitivity, Specificity = specificity)
    }
    
    cutoff_values <- seq(from = min(independent_var, na.rm = TRUE), 
                         to = max(independent_var, na.rm = TRUE), 
                         length.out = 100)
    results <- lapply(cutoff_values, function(cutoff) {
      calculate_sensitivity_specificity(dependent_var, independent_var, cutoff)
    })
    
    results_df <- data.frame(
      Cutoff = cutoff_values,
      Sensitivity = sapply(results, function(x) x$Sensitivity),
      Specificity = sapply(results, function(x) x$Specificity)
    )
    
    results_df$Youden <- results_df$Sensitivity + results_df$Specificity - 1
    results_df
  })
  
  # Plot Youden index using plotly
  output$youden_plot <- renderPlotly({
    req(youden_index())
    youden_df <- youden_index()
    
    plot_ly(youden_df, x = ~Cutoff) %>%
      add_trace(y = ~Youden, name = "Youden Index", type = "scatter", mode = "lines", line = list(color = "red", width = 2)) %>%
      add_trace(y = ~Sensitivity, name = "Sensitivity", type = "scatter", mode = "lines", line = list(color = "blue", width = 1)) %>%
      add_trace(y = ~Specificity, name = "Specificity", type = "scatter", mode = "lines", line = list(color = "green", width = 1)) %>%
      layout(title = "Youden Index, Sensitivity, and Specificity",
             xaxis = list(title = "Cutoff Value"),
             yaxis = list(title = "Value"),
             hovermode = "closest")
  })
  
  # Display results table
  output$results_table <- renderDT({
    req(youden_index())
    youden_df <- youden_index()
    optimal_cutoff <- youden_df$Cutoff[which.max(youden_df$Youden)]
    
    youden_df$Optimal <- ifelse(youden_df$Cutoff == optimal_cutoff, "Yes", "No")
    datatable(youden_df[order(-youden_df$Youden), ], options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Download results
  output$download_results <- downloadHandler(
    filename = function() {
      paste("youden_index_results_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(youden_index(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)