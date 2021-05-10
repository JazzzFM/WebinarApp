retencion_atencion <- function(bd, horas){
  Asist <- bd %>% 
    dplyr::mutate(correo = as.factor(correo)) %>% 
    dplyr::group_by(correo) %>%
    dplyr::mutate(fecha_max = max(lubridate::ymd_hms(hora_salida))) %>% ungroup() %>% 
    dplyr::mutate(correo = forcats::fct_reorder(correo, fecha_max)) %>% 
    dplyr::select(correo, fecha, hora_entrada, hora_salida)
  
  y_0 <- pull(Asist, correo) %>% unique %>% length
  
  fechaWeb <- pull(Asist, fecha) %>% unique
  fechaCompleta <- paste(fechaWeb, horas, sep = " ")
  horas <- lubridate::as_datetime(fechaCompleta)

  Graph <- Asist %>% ggplot() +
      geom_segment(
        aes(y = correo, yend = correo, x = hora_entrada, xend = hora_salida),
        lineend = 'round', linejoin = 'round',
        size = 1, arrow = arrow(length = unit(0.05, "inches")))+ 
      geom_vline(xintercept = horas, linetype = "dotted", color = "blue", size = 1.0) +
      annotate(x = horas[4] - (15*60), y = y_0 - 3, geom = "label", hjust = 0.5, label = "Historia previa") +
      annotate(x = horas[5] - (30*60), y = y_0 - 3, geom = "label", hjust = 0.5, label = "3 Secretos") +
      annotate(x = horas[6] - (7*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Oferta") +
      annotate(x = horas[7] - (15*60), y = y_0 - 5, geom = "label", hjust = 0.5, label = "Ronda de preguntas") +
      annotate(x = horas[7], y = y_0 - 8, geom = "label", hjust = 0.5, label = "Fin Webinar") +
      labs(title = "Retención de la audiencia") +
      xlab("Tiempo de Webinar") +
      ylab("Correo de personas") +
      theme_minimal()
  
  return(Graph)
}

timel_pct_audiencia <- function(bd, horas){
  
  bd <- bd %>% 
    dplyr::group_by(correo) %>% 
    dplyr::mutate(
      fecha_ini = min(lubridate::ymd_hms(hora_entrada)),
      fecha_fin = max(lubridate::ymd_hms(hora_salida))
      )
  
  df <- bd %>%
    tidyr::complete(fecha_fin = seq( 
      from=as.POSIXct(min(fecha_ini), tz="UTC"),
      to=as.POSIXct(max(fecha_fin), tz="UTC"),
      by="1 min"), fill = list(fecha_fin = NA)) %>% 
    ungroup %>% 
    distinct(correo, fecha_fin) %>% 
    count(fecha_fin) %>% 
    dplyr::mutate(max = n == max(n)) %>% 
    dplyr::mutate(pct = n/max(n), abs = n, 
          color_pct = cut(pct,c(0,.25,.5,.75,.9,1), 
           c("(0%-25%]","(25%-50%]","(50%-75%]","(75%-90%]","(90%-100%]")))
  
  fechaWeb <- pull(bd, fecha)
  fechaCompleta <- paste(fechaWeb, horas, sep = " ")
  horas <- lubridate::as_datetime(fechaCompleta)
  
  x <- bd %>% pull(correo) %>% unique %>% length
  
  Graph <- df %>% ggplot(aes(x = fecha_fin, y = n, fill=color_pct, color=color_pct)) +
    geom_bar(stat = "identity") +
    geom_vline(xintercept = horas, linetype="dotted", color = "blue", size = 1.0) +
    annotate(x = horas[4] - (15*60), y = x, geom = "label", hjust = 0.5, label = "Historia previa") +
    annotate(x = horas[5] - (30*60), y = x, geom = "label", hjust = 0.5, label = "3 Secretos") +
    annotate(x = horas[6] - (5*60) , y = x , geom = "label", hjust = 0.5,label = "Oferta") +
    annotate(x = horas[7] - (15*60), y = x-1, geom = "label", hjust = 0.5, label = "Ronda de preguntas") +
    annotate(x = horas[7], y = x - 3, geom = "label", hjust = 0.5, label = "Fin Webinar") +
    annotate(x = min(df$fecha_fin), y = x + 4, geom = "label", hjust = 0,
             label = glue::glue(" Asistentes máximos: {max(df$n)} ({count(df,max) %>% filter(max) %>% pull(n)} mins)")) +
    annotate(x = min(df$fecha_fin), y = x + 2, geom = "label", hjust = 0, label = glue::glue(" Asistentes únicos: {x}")) +
    theme_minimal() 
  
  return(Graph)
}

porcentaje_asistencia_vs_no <- function(bd){
  Registros <- bd %>%
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('Registrados' = n())
  
  MAXWEB <- bd %>%
    dplyr::filter(Asistio != 'No') %>% 
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('Sí asistieron' = n())
  
  NOWEB <- bd %>%
    dplyr::filter(Asistio == 'No') %>% 
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('No asistieron' = n())
  
  historico <- dplyr::left_join(Registros, MAXWEB, by = "fecha") %>% dplyr::left_join(NOWEB, by = "fecha")
  longer_historico <- tidyr::pivot_longer(historico, Registrados:`No asistieron`, names_to = "categoria", values_to = "count")
  
 Graph <- longer_historico %>%
    filter(categoria != "Registrados") %>%
    group_by(fecha) %>%  mutate(perc = 100*count/sum(count)) %>%
    ggplot(aes(x = fecha, y = perc, fill = categoria)) +  ylab("Porcentaje Asistencia vs No Asistencia") +
    geom_bar(stat='identity') + theme_minimal()
 
 return(Graph)
}
  
historico_asistencia_vs_no <- function(bd_webinar, horas){
  df <- bd_webinar %>%
    dplyr::select(Asistio, hora_registro)
  
  fechas <- horas %>% select(hora_webinar) %>% pull
  
  Graph <- ggplot(df, aes(x = hora_registro, color = Asistio, fill = Asistio)) +
    geom_histogram(position = "dodge")+
    geom_vline(xintercept = fechas, linetype="dotted", color = "blue", size = 1.0) +
    annotate(x = fechas[1], y = 30, geom = "label", hjust = 0.5, label = "Primer Webinar") +
    annotate(x = fechas[2], y = 25, geom = "label", hjust = 0.5, label = "Segundo Webinar") +
    annotate(x = fechas[3], y = 30, geom = "label", hjust = 0.5, label = "Tercer Webinar") +
    annotate(x = fechas[4], y = 30, geom = "label", hjust = 0.5, label = "Cuarto Webinar") +
    annotate(x = fechas[5], y = 30, geom = "label", hjust = 0.5, label = "Quinto Webinar") +
    annotate(x = fechas[6], y = 30, geom = "label", hjust = 0.5, label = "Sexto Webinar") +
    annotate(x = fechas[7], y = 30, geom = "label", hjust = 0.5, label = "Septimo Webinar") +
    theme(legend.position="top") +
    theme_minimal()
  
  return(Graph)
}

graficar_pautas <- function(bd){
  p1 <- ggplot(bd, aes(x = Fecha, y = `Total Publicidad`)) + geom_path() + geom_point() + theme_minimal()
  p2 <- ggplot(bd, aes(x = Fecha, y = `Pauta Branding`)) + geom_path() + geom_point() + theme_minimal()
  p3 <- ggplot(bd, aes(x = Fecha, y = `Pauta Marketing`)) + geom_path() + geom_point() + theme_minimal()
  Graph <- p3 / p2 / p1 + plot_layout(heights = c(3,3,3))
  return(Graph)
}

graficar_registros <- function(bd){
  bd <- bd %>% select(Fecha, Registros, '$Ganancia')
  
  Graph <- ggplot() + 
    geom_line(data = bd, aes(x = Fecha, y = `$Ganancia`), color = "green") +
    theme_minimal()
  
  return(Graph)
}
