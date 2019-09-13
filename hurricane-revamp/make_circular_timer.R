
# Testing some timer ideas out


timestep_min <- 15
dts <- seq(as.POSIXct("2019-08-01 00:00"), as.POSIXct("2019-08-02 23:59"), by = 60*timestep_min)

dow <- format(dts, "%A")
md <- format(dts, "%b. %d")
hrs <- as.numeric(format(dts, "%H"))
mins <- as.numeric(format(dts, "%M"))

angle_increment <- (2*pi) / (24*(60/timestep_min))
start_angle <- pi
rot_dir <- -1
timer_r <- 2
text_r <- 1

# pi = 6 AM
# How many hours before/after 6 AM does the animation start:
time_decimal <- head(hrs, 1) + head(mins, 1)/60
start_symbol_angle <- pi - ((time_decimal - 6) * 4)*angle_increment

draw_polygon <- function(x0, y0, r, from_angle, to_angle, rot_dir = -1, 
                         border = "black", col = NA, lwd = 1, lty = "solid") {
  
  theta <- seq(from_angle, to_angle, by = rot_dir*0.002)
  x_out <- x0 + r*cos(theta)
  y_out <- y0 + r*sin(theta)
  
  polygon(c(x0, x_out, x0),
          c(y0, y_out, y0),
          border = border, 
          col = col,
          lwd = lwd,
          lty = lty)
}

draw_symbol <- function(x0, y0, r, angle, rot_dir = -1, 
                        cex = 1, is_day = TRUE) {
  
  if(is_day) {
    # Copied sun symbol from https://unicode-search.net/unicode-namesearch.pl?term=SUN
    pch <- "☀"
    col <- "gold"
  } else {
    # Copied moon symbol from https://unicode-search.net/unicode-namesearch.pl?term=MOON
    pch <- "🌑" #"🌙"
    col <- "#79C1F1"
    r <- r*1.1 # move moon so it's centered better
  }
  
  theta <- angle# * rot_dir
  x_out <- x0 + r*cos(theta)
  y_out <- y0 + r*sin(theta)
  
  points(x_out, y_out, pch = pch, col = col, cex = cex)
  
}

angle_i <- start_symbol_angle
frame_names <- sprintf("hurricane-revamp/timer_frames/frame%03d.png", 1:length(dts))
for(d in 1:length(dts)) {
  
  # setup plot
  png(frame_names[d])
  par(mar = c(2,2,2,2), xpd = TRUE)
  plot(-2:2, -2:2, axes=FALSE, type = 'n', xlab = "", ylab="")
  
  # draw the timer wheel
  draw_polygon(x0 = 0, y0 = 0, r = timer_r,
               from_angle = start_angle, to_angle = 2*pi*rot_dir,
               border = "darkgrey", col = "white", lwd = 2, lty = "dotted")
  
  # inside fill wheel
  draw_polygon(x0 = 0, y0 = 0, r = text_r,
               from_angle = 0, to_angle = 2*pi*rot_dir,
               border = NA, col = "white", lwd = 0.2)
  
  # We are assuming daytime is 6 am to 6 pm
  is_daytime <- hrs[d] >= 6 & hrs[d] < 18
  
  text(0, 0, labels = sprintf("%s\n%s", dow[d], md[d]), cex = 4, col = "darkgrey")
  draw_symbol(0, 0, 2, angle_i, cex = 10, is_day = is_daytime)
  
  # increment the angle
  angle_i <- start_symbol_angle + d*angle_increment*rot_dir
  
  dev.off()
}

# Make a GIF
png_files <- paste(frame_names, collapse = ' ')
#png_files <- paste(sprintf("hurricane-revamp/frame%03d.png", c(1, 20, 40, 60, 80, 100, 120, 140, 160, 180)), collapse = " ")
tmp_dir <- "hurricane-revamp/tmp"
frame_delay <- 10#5
out_file <- "hurricane-revamp/sunset_timer3.gif"
magick_command <- sprintf(
  'magick convert -define registry:temporary-path=%s -limit memory 24GiB -delay %d -loop 0 %s %s',
  tmp_dir, frame_delay, png_files, out_file)
system(magick_command)
