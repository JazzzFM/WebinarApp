# pool <- pool::dbPool(
#   drv = RMariaDB::MariaDB(),
#   dbname = "db_gp",
#   host = 'mysql.cduzrgqgkfht.us-east-2.rds.amazonaws.com',
#   username = 'root',
#   password = '9Blw33caY',
#   port = 3306
# )
# 
# conn <- DBI::dbConnect(RSQLite::SQLite(), "./data/reporte_zoom.db")
# 
# onStop(function() {
#   pool::poolClose(pool)
# })
# 
# bd_reporte_zoom <- "reporte_zoom_webinar"
# bd_horas_webinar <- "horas_webinar"