.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    paste(strwrap('USGS Research Package: 
https://owi.usgs.gov/R/packages.html#research'),
      collapse='\n'))
}


#' Analyze ToxCast data in relation to measured concentrations.
#' 
#' \code{toxEval} includes a set of functions to analyze, visualize, and 
#' organize measured concentration data as it relates to ToxCast data 
#' (default) or other user-selected chemical-biological interaction 
#' benchmark data such as water quality criteria. The intent of 
#' these analyses is to develop a better understanding of the potential 
#' biological relevance of environmental chemistry data. Results can 
#' be used to prioritize which chemicals at which sites may be of 
#' greatest concern. These methods are meant to be used as a screening 
#' technique to predict potential for biological influence from chemicals 
#' that ultimately need to be validated with direct biological assays. 

#'
#' \tabular{ll}{
#' Package: \tab toxEval\cr
#' Type: \tab Package\cr
#' License: \tab Unlimited for this package, dependencies have more restrictive licensing.\cr
#' Copyright: \tab This software is in the public domain because it contains materials
#' that originally came from the United States Geological Survey, an agency of
#' the United States Department of Interior. For more information, see the
#' official USGS copyright policy at
#' https://www.usgs.gov/visual-id/credit_usgs.html#copyright\cr
#' LazyLoad: \tab yes\cr
#' }
#'
#'
#' @name toxEval-package
#' @docType package
#' @author Laura De Cicco \email{ldecicco@@usgs.gov}. Steven Corsi  
#' @keywords ToxCast
NULL

#' ACC values included with toxEval. 
#' 
#' Downloaded on October 2015 from ToxCast. The data were
#' combined from files in the "INVITRODB_V2_LEVEL5" folder. 
#' At the time of toxEval package release, this information was found:
#' \url{https://www.epa.gov/chemical-research/toxicity-forecaster-toxcasttm-data}
#' in the "ToxCast & Tox21 Data Spreadsheet" data set. 
#' ACC values are the in the "ACC" column (winning model) and units are 
#' log micro-Molarity (log \eqn{\mu}M).
#' 
#' @references U.S. EPA. 2015. ToxCast & Tox21 Summary Files from invitrodb_v2. 
#' Retrieved from \url{https://www.epa.gov/chemical-research/toxicity-forecaster-toxcasttm-data}
#' on October 28, 2015. Data released October 2015.
#'  
#' @source \url{https://www.epa.gov/chemical-research/toxicity-forecaster-toxcasttm-data}
#'
#'@aliases ToxCast_ACC
#'@return data frame with columns CAS, chnm (chemical name), flags, endPoint, and ACC (value).
#'@name ToxCast_ACC
#'@docType data
#'@export ToxCast_ACC
#'@keywords datasets
#'@examples
#'ACCColumnNames <- names(ToxCast_ACC)
NULL

# If we need to update the ACC data frame, here is
# is a function that *should* do it, assuming
# the format is the same. I might not count on that
# however....that is why it is an internal only function.
# This is staying commented out because it adds 
# extraneous notes:
# update_ACC <- function(path_to_files){
#   library(data.table)
#   library(dplyr)
#   library(tidyr)
#   # Data originally from:
#   # ftp://newftp.epa.gov/COMPTOX/ToxCast_Data_Oct_2015/README_INVITRODB_V2_LEVEL5.pdf
#   # https://www.epa.gov/sites/production/files/2015-08/documents/toxcast_assay_annotation_data_users_guide_20141021.pdf
#   # path_to_files <- "D:/LADData/RCode/toxEval_Archive/INVITRODB_V2_LEVEL5"
# 
#   files <- list.files(path = path_to_files)
#   
#   x <- fread(file.path(path_to_files, files[1]))
#   
#   filtered <- select(x, chnm, casn, aenm, logc_min, logc_max, modl_acc,
#                      modl, actp, modl_ga, flags, hitc,gsid_rep) %>%
#     filter(hitc == 1)
#   
#   for(i in files[-1]){
#     subX <- fread(file.path(path_to_files,i)) 
#     
#     subFiltered <- select(subX, chnm, casn, aenm, logc_min, logc_max, modl_acc,
#                           modl, actp, modl_ga, flags, hitc,gsid_rep) %>%
#       filter(hitc == 1)
#     
#     filtered <- bind_rows(filtered, subFiltered)
#   }
#   
#   ACCgain <- filter(filtered, hitc == 1) %>%
#     filter(gsid_rep == 1) %>%
#     select(casn, chnm, aenm, modl_acc, flags) %>%
#     spread(key = aenm, value = modl_acc)
#
#   ACC <- ACCgain %>%
#     gather(endPoint, ACC, -casn, -chnm, -flags) %>%
#     filter(!is.na(ACC)) %>%
#     rename(CAS = casn)
#   
#   # Something we considered but decided not to do was:
#   
#   # ACCgain2 <- filter(filtered, hitc == 1) %>%
#   #   filter(gsid_rep == 1) %>%
#   #   select(casn, chnm, aenm, modl_acc, flags, logc_min) %>%
#   #   mutate(newFlag = modl_acc < logc_min) %>%
#   #   mutate(value = ifelse(newFlag, log10((10^modl_acc)/10), modl_acc)) 
#   
# }

#' Endpoint information from ToxCast
#' 
#' Downloaded on October 2015 from ToxCast. The file name of the
#' raw data was "Assay_Summary_151020.csv" from the zip file 
#' "Assay_Information_Oct_2015.zip". At the time
#' of the toxEval package release, these data were found at:
#' \url{https://www.epa.gov/chemical-research/toxicity-forecaster-toxcasttm-data}
#' in the section marked "Download Assay Information", in the 
#' ToxCast & Tox21 high-throughput assay information data set.
#'
#'
#'@name end_point_info
#'@aliases end_point_info
#'@docType data
#'@keywords datasets
#' @references U.S. EPA. 2014. ToxCast Assay Annotation Data User Guide. 
#' Retrieved from \url{https://www.epa.gov/chemical-research/toxcast-assay-annotation-data-user-guide}.
#'  
#' @source \url{https://www.epa.gov/chemical-research/toxcast-assay-annotation-data-user-guide}
#'@export end_point_info
#'@return data frame with 86 columns. The columns and definitions
#'are discussed in the "ToxCast Assay Annotation Version 1.0 Data User Guide (PDF)" (see source)
#'@examples
#'end_point_info <- end_point_info
#'head(end_point_info[,1:5])
NULL

#' ToxCast Chemical Information 
#' 
#' Downloaded on October 2015 from ToxCast. The file name of the
#' raw data was "TOX21IDs_v4b_23Oct2014_QCdetails.xlsx", 
#' from the US EPA DSSTox DATA RELEASE OCTOBER 2015. At the time
#' of toxEval package release, this information was found:
#' \url{https://www.epa.gov/chemical-research/toxicity-forecaster-toxcasttm-data}
#' in the section marked "Download ToxCast Chemical Information". This 
#' was in the "ToxCast & Tox21 Chemicals Distributed Structure-Searchable Toxicity Database (DSSTox files)"
#' data set.
#'
#'@aliases tox_chemicals
#'@name tox_chemicals
#'@return data frame with columns: "ToxCast_chid","DSSTox_Substance_Id",
#'"DSSTox_Structure_Id","DSSTox_QC.Level",    
#'"Substance_Name","Substance_CASRN",    
#'"Substance_Type","Substance_Note",     
#'"Structure_SMILES","Structure_InChI",    
#'"Structure_InChIKey","Structure_Formula",  
#'"Structure_MolWt" 
#'@docType data
#'@keywords datasets
#'@export tox_chemicals
#'@examples
#'head(tox_chemicals)
NULL
