# code to prepare `AWS` dataset goes here
pool <- pool::dbPool(
  drv = RMariaDB::MariaDB(),
  dbname = "db_gp",
  host = 'mysql.cduzrgqgkfht.us-east-2.rds.amazonaws.com',
  username = 'root',
  password = '9Blw33caY',
  port = 3306
)
# 
# DBI::dbExecute(pool, "CREATE TABLE reporte_zoom_webinar (
#   idReporte INT AUTO_INCREMENT PRIMARY KEY,
#   num_webinar INT,
#   fecha DATE,
#   Asistio VARCHAR(10),
#   Nombre VARCHAR(50),
#   Apellido VARCHAR(50),
#   Usuario VARCHAR(100),
#   correo VARCHAR(50),
#   telefono VARCHAR(50),
#   hora_registro DATETIME,
#   hora_entrada DATETIME,
#   hora_salida DATETIME
# );")
# 
# DBI::dbRemoveTable(pool,"reporte_zoom_webinar")
# # reporte_zum <- list.files("data",pattern = ".csv") %>%
# #   imap(~read_csv(glue::glue("data/{.x}")) %>%
# #   mutate(num_webinar = .y, fecha = ymd(gsub(".csv", "", .x)))) %>%
# #   reduce(bind_rows) %>%
# #   filter(!`Nombre de fuente` %in% c('AMIGOS', 'Amigos'), !Nombre %in% c('TEAM EMILIO', 'TEAM', 'test'))
# # 
# # bd_reporte_subir <- bind_rows(
# # reporte_zum %>% filter(num_webinar < 3) %>%
# # mutate(
# #   hora_registro = gsub("mar.", "", `Hora de registro`),
# #   hora_registro =  paste("March ", hora_registro) %>% mdy_hms() %>% floor_date(unit = "minute"),
# #   hora_entrada = gsub("mar.", "", `Puesto de trabajo`),
# #   hora_salida = gsub("mar.", "", `Hora de salida`),
# #   hora_entrada = paste("March ", hora_entrada) %>% mdy_hms() %>% floor_date(unit = "minute"),
# #   hora_salida = paste("March ", hora_salida) %>% mdy_hms() %>% floor_date(unit = "minute")),
# # reporte_zum %>% filter(num_webinar >= 3) %>%
# # mutate(
# #   hora_registro = floor_date(mdy_hms(`Hora de registro`),unit = "minute"),
# #   hora_entrada = floor_date(mdy_hms(`Puesto de trabajo`),unit = "minute"),
# #   hora_salida =  floor_date(mdy_hms(`Hora de salida`),unit = "minute"))
# # ) %>% select(
# #   num_webinar, fecha, asistio = Asistió, Nombre, Apellido, telefono = Teléfono,
# #   correo = `Correo electrónico`, usuario = `Nombre de usuario (nombre original)`,
# #   hora_registro, hora_entrada, hora_salida)
# # DBI::dbWriteTable(pool, "reporte_zoom_webinar", value = bd_reporte_subir, append = T)
# reporte_zoom_webinar_bd <- tbl(pool, "reporte_zoom_webinar") %>% collect()

# # DBI::dbExecute(pool, "ALTER TABLE reporte_zoom_webinar ADD activo TINYINT;")
# # DBI::dbExecute(pool, "UPDATE reporte_zoom_webinar SET activo = 0  WHERE correo IN ('blanca.sanchezg@gmail.com',
# # 'pedroasuncion.madera@gmail.com',
# # 'brandon_mgm@hotmail.com',
# # 'rslicona@gmail.com',
# # 'htsreto@outlook.com',
# # 'carvisu682@gmail.com',
# # 'hernandezdominguezf780@gmail.com'
# # 'nathy.conta@gmail.com',
# # 'cesarleon873@gmail.com',
# # 'zacil_ha@rocketmail.com',
# # 'orisabe2016@gmail.com',
# # 'solovino69mx@gmail.com',
# # 'carloszcortes@hotmail.com',
# # 'ventasbuenasteolo@gmail.com',
# # 'gerardorl@outlook.com',
# # 'yortizmar@hotmail.com',
# # 'cana_456@hotmail.com',
# # 'virginia.rinconluis@gmail.com',
# # 'pandytablonda@gmail.com',
# # 'ivanovpsy@yahoo.com',
# # 'yummaidaliv@gmail.com',
# # 'roderpack@hotmail.com',
# # 'claus_vm20@hotmail.com',
# # 'a.g.alvaradoflores@gmail.com',
# # 'fuca811030@hotmail.com',
# # 'elviaramirez8000@gmail.com',
# # 'alifevantage@gmail.com',
# # 'aztecasur60@gmail.com',
# # 'j2808s011@gmail.com',
# # 'ness10r11@outlook.com',
# # 'bernagt87@gmail.com',
# # 'giovanni.rubin@live.com',
# # 'ind_salamanca@hotmail.com',
# # 'tazpink_@hotmail.com',
# # 'torres.ae.16@gmail.com',
# # 'blancaarinesarmendariz@gmail.com',
# # 'sandia092012@gmail.com',
# # 'dlermax@gmail.com',
# # 'akajixblood@gmail.com',
# # 'mireyamacias03@gmail.com',
# # 'garp09@yahoo.com.mx',
# # 'nataly.ortiz88@gmail.com',
# # 'martin.villar@hotmail.com',
# # 'buira@hotmail.com',
# # 'sandyjljuarez@gmail.com',
# # 'constantino.fernando@gmail.com',
# # 'aecx_@hotmail.com',
# # 'eaj31416@gmail.com',
# # 'antongr0831@gmail.com',
# # 'xelemder@hotmail.com',
# # 'vera_imagen@hotmail.com',
# # 'e.caballero.medina@gmail.com',
# # 'betobfw@gmail.com',
# # 'r.mata.h@gmail.com',
# # 'rocha.estephanie@gmail.com',
# # 'deopeabodie@gmail.com',
# # 'montse_casillas10@hotmail.com',
# # 'zetsubou.vic@gmail.com',
# # 'mitzicortesosnaya@gmail.com',
# # 'majodg39@gmail.com',
# # 'rbk_bar.do@hotmail.com',
# # 'angelofmusic_15@hotmail.com');")
# 
# DBI::dbExecute(pool, "CREATE TABLE horas_webinar (
#   idHoras INT AUTO_INCREMENT PRIMARY KEY,
#   num_webinar INT,
#   webinar VARCHAR(50),
#   historia_previa VARCHAR(50),
#   tres_secretos VARCHAR(50),
#   oferta VARCHAR(50),
#   preguntas VARCHAR(50),
#   hora_webinar DATETIME
# );")
# 
 # DBI::dbRemoveTable(pool,"horas_webinar")
# # bd_horas_webinar <- tibble::tibble(
# #   num_webinar = c(1, 2, 3, 4, 5, 6),
# #   webinar = c("Primer Webinar", "Segundo Webinar", "Tercer Webinar", "Cuarto Webinar", "Quinto Webinar", "Sexto Webinar"),
# #   historia_previa = c('19:16:00', '12:20:00', '12:44:00', '19:30:00', '19:24:00', '19:30:00'),
# #   tres_secretos = c('20:02:00', '13:25:00', '13:51:00', '20:30:00', '20:30:00', '20:30:00'),
# #   oferta = c('20:22:00', '13:41:00', '14:20:00', '20:50:00', '20:45:00', '20:55:00'),
# #   preguntas = c('20:47:00', '14:13:00', '14:42:00', '21:20:00', '21:15:00', '21:25:00'),
# #   hora_webinar = c('2021/03/18 19:00:00', '2021/03/20 12:00:00', '2021/03/26 12:00:00', '2021/04/08 19:00:00', '2021/04/15 19:00:00', '2021/04/21 19:00:00') %>% as_datetime()
# #   )
# # DBI::dbExecute(pool, "UPDATE horas_webinar SET preguntas = '21:25:00' WHERE num_webinar = 7;")
# # DBI::dbWriteTable(pool, "horas_webinar", value = bd_horas_webinar, append = T)
# # tbl(pool, "horas_webinar")
# # DBI::dbExecute(pool, "ALTER TABLE horas_webinar ADD reto VARCHAR(50);")
# # DBI::dbExecute(pool, "ALTER TABLE horas_webinar ADD secreto_3 VARCHAR(50);")
# # DBI::dbExecute(pool, "UPDATE horas_webinar SET secreto_1 = '19:53:00', secreto_2 = '20:13:00', secreto_3 = '20:33:00' WHERE num_webinar = 8;")
# # DBI::dbExecute(pool, "UPDATE horas_webinar SET historia_previa = '19:20:00', secreto_1 = '19:47:00', secreto_2 = '20:12:00', secreto_3 = '20:42:00', reto = '20:49:00' WHERE num_webinar = 8;")
# # DBI::dbExecute(pool, "UPDATE horas_webinar SET tres_secretos = '20:42:00' WHERE num_webinar = 8;")
