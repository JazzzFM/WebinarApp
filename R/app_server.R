#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
#' @import dbplyr dplyr DBI

app_server <- function( input, output, session ) {

  BD <- reactiveValues(
    zum = reporte_zoom_webinar_bd,
    horas_web = horas_webinar_bd
  )

  # Módulo de Análisis
  callModule(mod_analisis_server, "analisis_ui_1", BD = BD)
  
  # Módulo de procesamiento y descarga
  callModule(mod_procesar_descargar_server, "procesar_descargar_ui_1", BD = BD)
}
