# Change symbol completely

x_locs <- c(0, -1.5, -2, -1.5, 2, 3, 4, 4.5, 4)
y_locs <- c(1, 2, 3, 4, 5, 6, 4.5, 4, 3.5)

interp_step <- 0.1

# interpolate between points for smooth path
pos <- lapply(1:(length(x_locs)-1), FUN = function(i, x, y) {
  x_dir <- ifelse(x[i] > x[i+1], -1, 1)
  
  # playing with the best way to make it smooth
  x_new <- seq(x[i], x[i+1], by = interp_step*x_dir)
  # first one in sequence is being duplicated so get rid of it except for the very first time
  if(i > 1) x_new <- x_new[-1]
  
  y_new <- seq(y[i], y[i+1], length.out = length(x_new))
  return(data.frame(x = x_new, y = y_new))
}, x = x_locs, y = y_locs)

pos_df <- do.call("rbind", pos)

# How many points along the track?
n_pts <- nrow(pos_df)

# Setup rotation configs
rot_dir <- 1
rot_increment <- 20*rot_dir # in degrees
rot_f <- 0

# Set up size and color configs
max_cex <- 5
base_color <- "#3f3f3f"
hex_transparency_codes <- data.frame(
  # From: https://gist.github.com/lopspower/03fb1cc0ac9f32ef38f4
  percentile = 100:0,
  code = c("FF", "FC","FA", "F7","F5", "F2","F0", "ED","EB", "E8","E6", "E3","E0", 
           "DE","DB", "D9","D6", "D4","D1", "CF","CC", "C9","C7", "C4","C2", "BF","BD", 
           "BA","B8", "B5","B3", "B0","AD", "AB","A8", "A6","A3", "A1","9E", "9C","99", 
           "96","94", "91","8F", "8C","8A", "87","85", "82","80", "7D","7A", "78","75", 
           "73","70", "6E","6B", "69","66", "63","61", "5E","5C", "59","57", "54","52", 
           "4F","4D", "4A","47", "45","42", "40","3D", "3B","38", "36","33", "30","2E", 
           "2B","29", "26","24", "21","1F", "1C","1A", "17","14", "12","0F", "0D","0A", 
           "08","05", "03","00"),
  stringsAsFactors = FALSE
)
cex_df <- data.frame(TS = 1:n_pts)
col_df <- data.frame(TS = 1:n_pts)
for(i in 1:n_pts) {
  col_name_i <- sprintf("Pt_%02d", i)
  end_i <- i + (max_cex-1)
  end_i <- ifelse(end_i > n_pts, n_pts, end_i) # if we are past the end, stop at the last point
  
  replace_vec_cex <- (1:max_cex)[1:(end_i - i + 1)]
  cex_df[[col_name_i]] <- replace(rep(0, n_pts), i:end_i, replace_vec_cex)
  
  # Setup hex code in case it is filled
  fade_percentiles <- round(seq(80, 20, length.out = length(replace_vec_cex)), digits = 0)
  hex_i <- which(hex_transparency_codes$percentile %in% fade_percentiles)
  hex_transparencies <- hex_transparency_codes$code[rev(hex_i)]
  hex_tail <- paste0(base_color, hex_transparencies)
  
  replace_vec_col <- hex_tail
  col_df[[col_name_i]] <- replace(rep(base_color, n_pts), i:end_i, replace_vec_col)
}


frames_n <- 1:n_pts
frame_names <- sprintf("hurricane-revamp/track_frames_symbol/frame%03d.png", frames_n)

for(f in frames_n) {
  png(frame_names[f])
  par(mar = c(2,2,2,2), xpd = TRUE)
  plot(c(-3, 6), c(-2, 7), axes=FALSE, type = 'n', xlab = "", ylab="")
  
  # Setup track
  points(x_locs, y_locs, type='l', col = "grey", lty = "dotted")
  
  # Rotate & move point through time
  text(pos_df$x[f+5], pos_df$y[f+5], label = "Ѻ", 
       col = base_color, srt = rot_f, cex = max_cex)
  
  # Add tail
  points(pos_df$x[-f], pos_df$y[-f], pch = 1, col = col_df[[f+1]], cex = cex_df[[f+1]], lwd = 2)
  
  # increase rotation
  rot_f <- rot_f + rot_increment
  
  dev.off()
}

# Make a GIF
png_files <- paste(frame_names, collapse = ' ')
tmp_dir <- "hurricane-revamp/tmp"
frame_delay <- 10
out_file <- sprintf("hurricane-revamp/track_rotate_symbol_tail.gif")
magick_command <- sprintf(
  'magick convert -define registry:temporary-path=%s -limit memory 24GiB -delay %d -loop 0 %s %s',
  tmp_dir, frame_delay, png_files, out_file)
system(magick_command)

