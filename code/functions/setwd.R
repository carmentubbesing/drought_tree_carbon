setwd_drought <- function() {
  if(length(grep("code",getwd()))>0){
  setwd("../")  
} else if(substr(getwd(),nchar(getwd())-8,nchar(getwd()))=="Documents") {
  setwd("drought_tree_carbon/")
} else {
  setwd("~/drought_tree_carbon/")
} 
}
