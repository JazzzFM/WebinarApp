procesamiento_metricas <- function(bd){
  
  df <- bd %>% mutate(
    `Total Pauta` = `Pauta Branding` + `Pauta Marketing`,
    `Total Publicidad` = `Total Pauta` + `Incentivo(AppleWatch)`,
    porcentAsistencia = 100*AsistentesTotales/Registros,
    porcentAsistenciaMáxima = 100*AsistenciaMáxima/Registros,
    `$CostoXlead` = `Total Pauta`/Registros,
    porcentConversiónLegacy = VentasLegacy/AsistenciaMáxima,
    `$VentasWebinar` = VentasLegacy*costo,
    `$Ganancia` = `$VentasWebinar`- `Total Publicidad`,
    ventaSeguimiento = c(0,0,0),
    ComisionesVentas = ventaSeguimiento*0.7*costo,
    porcentConversiónSeguimiento = ventaSeguimiento/AsistenciaMáxima,
    `$VentatotalSeguimiento` = ventaSeguimiento*costo,
    VentasTotales = ventaSeguimiento + VentasLegacy,
    porcentConversiónTotal = porcentConversiónSeguimiento + porcentConversiónLegacy,
    `$VentaTotal` = `$VentasWebinar` + `$VentatotalSeguimiento`,
    UtilidadNeta = `$VentaTotal` - ComisionesVentas - `Total Publicidad`,
    ROAS = `$VentaTotal`/`Total Pauta`
  )
  
  return(df)
}

procesar_segmentacion <- function(bd, horas_w, hora_inicio){
  
  Asist <- dplyr::filter(bd, Asistio == 'Sí') %>% 
    dplyr::mutate(
      telefono = stringr::str_replace_all(string=telefono, pattern=" ", repl=""),
      NombreCompleto = paste(Nombre, Apellido, sep = " "),
      telefono = gsub("\\+52", "", telefono),
      telefono = paste("+52", telefono, sep = ""))%>% 
    dplyr::select(
      fecha, usuario, 
      NombreCompleto, correo, telefono, hora_entrada , hora_salida) %>% 
    dplyr::arrange(desc(hora_salida - hora_entrada))
  
  horas_w <- c(horas_w[2:5], "hora_inicio" = paste(hora_inicio, "00", sep = ":"))
  fechaWeb <- pull(Asist, fecha) %>% unique()
  fechaCompleta <- paste(fechaWeb, horas_w, sep = " ")
  horas <- lubridate::as_datetime(fechaCompleta)
  
  Asist <- Asist %>% 
    dplyr::mutate(
    InicioWebinar = horas[5],
    DelMinuto = lubridate::minute(lubridate::seconds_to_period(hora_entrada - InicioWebinar)),
    AlMinuto = round(hora_salida - InicioWebinar, 2),
    'Se fue historia previa' = ifelse(hora_salida <= horas[1], "Sí", "No"),
    'Se fue 3 Secretos' = ifelse(hora_salida <= horas[2]  & hora_salida > horas[1] , "Sí", "No"),
    'Se fue oferta' = ifelse(hora_salida <= horas[3] & hora_salida > horas[2], "Sí", "No"),
    'Se fue ronda de preguntas'  = ifelse(hora_salida <= horas[4]  & hora_salida > horas[3], "Sí", "No"),
    'Completaron el webinar' = ifelse(hora_salida > horas[5], "Sí", "No"),
    Prioridad = case_when(
      `Completaron el webinar`=="Sí" ~ 1,
      `Se fue oferta`=="Sí" ~ 2,
      `Se fue ronda de preguntas`=="Sí"|`Se fue 3 Secretos`=="Sí"|`Se fue historia previa`=="Sí" ~ 3),
    WhatsApp = paste("https://wa.me/", telefono, sep = ""),
    `Hora de la llamada` = NA,
    Estatus = NA,
    `¿Te resultó de utilidad la información proporcionada en el webinar?` = NA,
    `¿Qué temas del webinar te gustaron?` = NA,
    `¿Qué temas del webinar no te gustaron?` = NA,
    `¿Qué contenidos te hubiera gustado escuchar?` = NA,
    `¿Qué contenido te hubiera gustado profundizar?` = NA,
    `¿Qué tan clara te queda la información del webinar?` = NA,
    `¿Consideras que la duración del webinar fue la correcta?` = NA,
    `Compró` = NA,
    `Motivación para no comprar` = NA,
    `Invitación al siguiente webinar /registrado` = NA,
    `Retro` = NA) %>% select(-InicioWebinar)
  
  return(Asist)
}

procesar_no_asistio <- function(base_historico, bd){
  
  aux <-  dplyr::filter(base_historico, Asistio == 'No') %>%
          dplyr::select(fecha, Nombre, correo, telefono) 
  
  NO <- dplyr::filter(bd, Asistio == 'No') %>%
        dplyr::select(fecha, Nombre, correo, telefono) %>% 
        dplyr::mutate( 
          telefono = stringr::str_replace_all(string = telefono, pattern=" ", repl=""),
          telefono = gsub("\\+52", "", telefono),
          telefono = paste("+52", telefono, sep = ""))

  JA <- dplyr::bind_rows(NO, aux)
  
  JA <- JA %>% 
      dplyr::group_by(correo, telefono) %>% summarise(count = n()) %>% 
      dplyr::arrange(desc(count)) %>%
      dplyr::mutate(WhatsApp = paste("https://wa.me/", telefono, sep = ""), Desechar = NA) 
  
  return(JA)  
}