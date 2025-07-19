# Youden Index Calculation (R Shiny App)

This R Shiny application provides a user-friendly interface for calculating the Youden Index, a common measure used in diagnostic test evaluation. The Youden Index (J) quantifies the overall effectiveness of a diagnostic marker and is defined as sensitivity + specificity - 1. It helps in identifying the optimal cut-off point for a diagnostic test.

## Features

*   **Data Upload:** Easily upload your dataset in CSV format.
*   *   **Youden Index Calculation:** Calculate the Youden Index for various cut-off points.
    *   *   **Optimal Cut-off:** Identify the optimal cut-off point that maximizes the Youden Index.
        *   *   **Visualizations:** Generate plots to visualize sensitivity, specificity, and Youden Index across different cut-off points.
         
            *   ## Installation and Usage
         
            *   To run this application locally, you need to have R and RStudio installed, along with the following R packages:
         
            *   ```R
                install.packages(c("shiny", "pROC", "DT", "ggplot2"))
                ```

                Once the packages are installed, you can run the application using the `app.R` and `ui.R` files:

                ```R
                shiny::runApp("path/to/your/app_directory")
                ```

                ## Data Format

                Your input CSV file should contain at least two columns:

                1.  **`outcome`**: Binary outcome variable (e.g., 0 for control, 1 for disease).
                2.  2.  **`marker`**: Continuous or ordinal values for the diagnostic marker.
                  
                    3.  ## Example
                  
                    4.  An example dataset is provided within the application for demonstration purposes.
                  
                    5.  ## Contributing
                  
                    6.  Contributions are welcome! Please feel free to open an issue or submit a pull request.
                  
                    7.  ## License
                  
                    8.  This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
                    9.  
