library(optparse)
library(knitr)

option_list = list(
  make_option(
    c("-o", "--output"),
    type="character",
    default="init.R", 
    help="output file to tangler R code into [default= %default]"
  )
); 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

knit(input = "../docs/notes.Rmd", output = opt$output, quiet=T, tangle=T)
