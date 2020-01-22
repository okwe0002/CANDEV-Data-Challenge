
## For quest # 3, we assume processed data is reliable.
## Considering only CCG data.
## Considering only one day, but one can connect several other csvs
## and create a view on the combined rows.

f <- stop("specify path to processed csv CCG data file")

require(sqldf)
require(rnaturalearth)
require(ggplot2)

# this creates an empty database.
sqldf("attach testingdb as new")

# Considering dynamic data as it contains the coords and speed data.
# Assuming the MMSIs are reliable to identify ships.
read.csv.sql(f, sql = "create table main.dyna as select * from file", 
             dbname = "testingdb")

# A condition can be specified to filter obs.
cond <- NULL
xmin <- -150
xmax <- -100
ymin <- 40
ymax <- 60
foo <- sqldf(paste0("
  select x, y, count() as ships
  from (
             select MMSI, round(Longitude_decimal_degrees) as x, round(Latitude_decimal_degrees) as y
             from dyna
             ", if (is.null(cond)) "" else cond, "
             group by MMSI, x, y
  )
  group by x, y
  having y > ", ymin," and y < ", ymax, " and x > ", xmin, " and x < ", xmax), dbname = "testingdb")

ggplot() +
  geom_sf(data = ne_countries(returnclass = "sf")) +
  geom_tile(data = foo, mapping = aes(x=x, y=y, fill=ships)) +
  coord_fixed() + xlab("longitude") + ylab("latitude") +
  coord_sf(xlim = c(xmin, xmax), ylim = c(ymin, ymax))
