#' analisis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @import dplyr ggplot2 tidyr shinycssloaders lubridate magrittr highcharter

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
             shinycssloaders::withSpinner(highchartOutput(ns("porcentajesA")))
      ),
      column(width =  12, class = "shadowBox",     
             shinycssloaders::withSpinner(highchartOutput(ns("NoAsistieron")))
      ))
    )
}
    
#' analisis Server Function
#'
#' @noRd 
mod_analisis_server <- function(input, output, session, BD = BD){
  ns <- session$ns
  
  observeEvent(BD$horas_web, {
    num <- BD$horas_web %>% pull(num_webinar)
    updateSelectizeInput(session, 'filtro',
                         choices = num,
                         selected = num,
                         server = TRUE)
  })
  
  # Gráficas ----------------------------------- 
  
  output$Atencion <- renderPlot({
    horas <-  BD$horas_web %>% filter(num_webinar %in% !!input$filtro) %>% as.vector()
    BD$zum %>% 
      filter(num_webinar %in% !!input$filtro, Asistio != "No") %>%
      retencion_atencion(horas = horas)
  })

  output$porcentaje <- renderPlot({
    horas <- BD$horas_web %>% filter(num_webinar %in% !!input$filtro) %>% as.vector()
    bd_si <- BD$zum %>% filter(num_webinar %in% !!input$filtro, Asistio != "No")
    bd_r <- BD$zum %>% filter(num_webinar %in% !!input$filtro)

      timel_pct_audiencia(bd_1 = bd_si, bd_2 = bd_r, horas = horas)
  })

  output$porcentajesA <- renderHighchart({
    BD$zum %>% porcentaje_asistencia_vs_no()
  })

  output$NoAsistieron <- renderHighchart({
   BD$zum %>% historico_asistencia_vs_no(BD$horas_web)
  })
  
}
    
## To be copied in the UI
# mod_analisis_ui("analisis_ui_1")
    
## To be copied in the server
# callModule(mod_analisis_server, "analisis_ui_1")
 
