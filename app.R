# Importation des librairies necessaires
library(shiny)
library(shinythemes)
library(wordcloud2)
library(colourpicker)
library(tm)

# Fonction Word cloud ########################################

create_wordcloud <- function(data, num_words = 100, background = "white") {
  
  # Conversion du texte fournu en une dataframe de fréquences de mots
  if (is.character(data)) {
    corpus <- Corpus(VectorSource(data))
    corpus <- tm_map(corpus, tolower)
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, removeWords, stopwords("english"))
    tdm <- as.matrix(TermDocumentMatrix(corpus))
    data <- sort(rowSums(tdm), decreasing = TRUE)
    data <- data.frame(word = names(data), freq = as.numeric(data))
  }
  
  # num_words 
  if (!is.numeric(num_words) || num_words < 3) {
    num_words <- 3
  }  
  
  # top n des mots qui apparaissent le plus dans le texte
  data <- head(data, n = num_words)
  if (nrow(data) == 0) {
    return(NULL)
  }
  
  wordcloud2(data, backgroundColor = background)
}

##################################################################



ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  h1("APPLICATION WEB R SHINY POUR LA VISUALISATION DE NUAGE DE MOTS"),
  
  h2("Auteur : Josue AFOUDA"),
  
  tags$a("Suivez-moi sur Linkedin", href='https://www.linkedin.com/in/josu%C3%A9-afouda/'),
  
  sidebarLayout(
    sidebarPanel(
      # textarea input
      textAreaInput("text", "Enter text", rows = 10),
      numericInput("num", "Maximum number of words",
                   value = 100, min = 5),
      colourInput("col", "Background color", value = "white"),
      actionButton(inputId = "run", label = "Run")
    ),
    mainPanel(
      wordcloud2Output("cloud")
    )
  )
)

server <- function(input, output) {
  output$cloud <- renderWordcloud2({
    input$run
    isolate({
      # Graphique de visualisation du nuage de mots
      create_wordcloud(data = input$text, num_words = input$num,
                       background = input$col)
    })
  })
}

shinyApp(ui = ui, server = server)