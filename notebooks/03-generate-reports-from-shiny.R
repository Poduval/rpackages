# Notes
# Copy the report file to a temporary directory before processing i. 
# The format of the report generated can be defined
# Knit the document, passing in the `params` list, and eval it in a
# child of the global environment (this isolates the code in the document

# library
library(shiny)

ui <- fluidPage(
  sliderInput("slider", "n", 1, 100, 50),
  plotOutput('plot'),
  downloadButton("download", "download")
)

server = function(input, output) {
  
  output$plot <- renderPlot({
    plot(x = rnorm(input$slider), 
         y = log(rnorm(input$slider)),
         xlab = 'n',
         ylab = 'log(n)',
         main = 'n vs. long(n)',
         col = 'blue')
  })
  
  output$download <- downloadHandler(
    
    filename = "reports_from_shiny.html", 
    content = function(file) {
      
      rmd_file <- file.path(tempdir(), 
                            "generate_reports_from_shiny.Rmd")
      
      file.copy("generate_reports_from_shiny.Rmd", 
                rmd_file, 
                overwrite = T)
      
      # Set up parameters to pass to Rmd document
      params <- list(n = input$slider)
      
      # from the code in this app).
      rmarkdown::render(rmd_file, 
                        output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
}

# run app
shinyApp(ui, server)
