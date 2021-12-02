#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
source("pdplot2.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Normal Distribution"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("mean",
                        "Mean:",
                        min = -2.0,
                        max = 2.0,
                        value = 0),
            sliderInput("sd",
                        "Standard deviation:",
                        min = .01,
                        max = 3,
                        value = 1)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        p1 <- pdplot2(
            seq(-5, 5, 0.01),
            mean = input$mean,
            sd = input$sd,
            type = "normal",
            show.color = TRUE
        ) +
        scale_color_manual(labels = input$sd,
            values = c("#800000")
        )

        df <- data.frame(
            x = rnorm(seq(-5, 5, 0.01), 0, input$sd)
        )
        p2 <- ggplot(df, aes(x)) +
            stat_ecdf(geom = "step", color = "#800000", size = 1) +
            theme_minimal() +
            theme(
                legend.position = c(.90, .55),
                legend.title = element_text(size = 14),
                legend.box.background = element_rect(colour = "black"),
                legend.title.align = 0.5,
                legend.text = element_text(size = 14)
            )

        gridExtra::grid.arrange(p1, p2)
    })

}

# Run the application
shinyApp(ui = ui, server = server)
