
generate_gif <- function(gif_file, img_fns) {
  
  img_fn_string <- paste(img_fns, collapse = " ")
  magick_command <- sprintf('convert -delay 100 -loop 0 %s %s', img_fn_string, gif_file)
  
  if(Sys.info()[['sysname']] == "Windows") {
    magick_command <- sprintf('magick %s', magick_command)
  }
  
  system(magick_command)
  
  # Simplify GIF using gifsicle
  system(sprintf('gifsicle -b %s', gif_file))
  
  return(gif_file)
}
