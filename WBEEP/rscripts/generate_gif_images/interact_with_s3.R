# Fetch S3 data for model output

fetch_s3_model_output <- function(date_ranges, s3_bucket, s3_model_output_loc, local_cache_loc) {
  
  # Setup credentials
  aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
  
  # File format: model_output_categorized_YYYY-MM-DD.csv
  date_seq <- sapply(date_ranges, function(x) as.character(seq(as.Date(x[1]), as.Date(x[2]), by = 1)))
  date_files <- sprintf("model_output_categorized_%s.csv", unlist(date_seq))
  s3_filenames <- file.path(s3_model_output_loc, date_files)
  local_filenames <- file.path(local_cache_loc, date_files)
  
  # Download data
  for(i in 1:length(date_files)) {
    aws.s3::save_object(object = s3_filenames[i], 
                        bucket = s3_bucket,
                        file = local_filenames[i])
  }
  
  return(local_filenames)
  
}

push_s3_model_maps <- function(local_img_files, s3_bucket, s3_img_loc) {
  
  # Setup credentials
  aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
  
  # Create filenames
  dates <- gsub("map_|.png", "", basename(local_img_files))
  date_files <- sprintf("map_%s.png", dates)
  s3_filenames <- file.path(s3_img_loc, date_files)
  
  # Push imgs to S3
  for(i in 1:length(date_files)) {
    aws.s3::put_object(object = s3_filenames[i], 
                       bucket = s3_bucket,
                       file = local_img_files[i])
  }
  
}

push_s3_gif <- function(local_gif_file, s3_bucket, s3_img_loc, s3_gif_file) {
  
  # Setup credentials
  aws.signature::use_credentials(profile='default', file=aws.signature::default_credentials_file())
  
  # S3 filepath
  s3_filepath <- file.path(s3_img_loc, s3_gif_file)
  
  # Push gif to S3
  aws.s3::put_object(object = s3_filepath, 
                     bucket = s3_bucket,
                     file = local_gif_file)
  
}

