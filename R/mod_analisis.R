#' analisis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @import dplyr ggplot2 tidyr shinycssloaders lubridate magrittr

mod_analisis_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectizeInput(ns("filtro"), label = "Seleccione el número webinar",
    choices = NULL, selected = NULL, multiple = F
      ),
    # Gráficos
    fluidRow(
      column(width = 12, class = "shadowBox", 
      shinycssloaders::withSpinner(plotOutput(ns("Atencion")))
      ),
      column(width = 12, class = "shadowBox",
             shinycssloaders::withSpinner(plotOutput(ns("porcentaje")))
      ),
      column(width =  12, class = "shadowBox",     
             shinycssloaders::withSpinner(plotOutput(ns("porcentajesA")))
      ),
      column(width =  12, class = "shadowBox",     
             shinycssloaders::withSpinner(plotOutput(ns("NoAsistieron")))
      ))
    )
}
    
#' analisis Server Function
#'
#' @noRd 
mod_analisis_server <- function(input, output, session, bd = bd){
  ns <- session$ns
  
  observeEvent(bd$horas_web, {
    num <- bd$horas_web %>% pull(num_webinar)
    updateSelectizeInput(session, 'filtro',
                         choices = num,
                         selected = num,
                         server = TRUE)
  })
  
  # Gráficas ----------------------------------- 
  
  output$Atencion <- renderPlot({
    horas <- bd$horas_web %>% filter(num_webinar %in% !!input$filtro) %>% as.vector()
    bd$zum %>% filter(num_webinar %in% !!input$filtro, Asistio != "No") %>%
      retencion_atencion(horas = horas)
  })

  output$porcentaje <- renderPlot({
    horas <- bd$horas_web %>% filter(num_webinar %in% !!input$filtro) %>% as.vector()
    bd$zum %>% filter(num_webinar %in% !!input$filtro, Asistio != "No") %>%
      timel_pct_audiencia(horas = horas)
  })

  output$porcentajesA <- renderPlot({
    bd$zum %>% porcentaje_asistencia_vs_no()
  })

  output$NoAsistieron <- renderPlot({
    bd$zum %>% historico_asistencia_vs_no(bd$horas_web)
  })
  
}
    
## To be copied in the UI
# mod_analisis_ui("analisis_ui_1")
    
## To be copied in the server
# callModule(mod_analisis_server, "analisis_ui_1")
 
