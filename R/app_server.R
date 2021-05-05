#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
#' @import dbplyr dplyr 
app_server <- function( input, output, session ) {
  
  bd <- reactiveValues(
    zum = tbl(pool, bd_reporte_zoom) %>% collect(),
    horas_web = tbl(pool, bd_horas_webinar) %>% collect() 
  )

  # Módulo de Análisis
  callModule(mod_analisis_server, "analisis_ui_1", bd = bd)
  
  # Módulo de procesamiento y descarga
  callModule(mod_procesar_descargar_server, "procesar_descargar_ui_1", bd = bd)
}
