#' Get the ACC values for a selection of chemicals
#' 
#' The \code{get_ACC} function retrieves the activity concentration at cutoff 
#' (ACC) values for specified chemicals. 
#' 
#' The data used in toxEval were combined from files in the 
#' "INVITRODB_V2_LEVEL5" directory that were included in the October 2015 
#' release of the ToxCast database. The function \code{get_ACC} will 
#' convert the ACC values in the ToxCast database from units of (log \eqn{\mu}M) 
#' to units of \eqn{\mu}g/L, and reformat the data as input to toxEval.
#' 
#' @param CAS Vector of CAS. 
#' @return data frame with columns CAS, chnm, flags, endPoint, ACC, MlWt, and ACC_value
#' @export
#' @examples
#' CAS <- c("121-00-6","136-85-6","80-05-7","84-65-1","5436-43-1","126-73-8")
#' ACC <- get_ACC(CAS)
get_ACC <- function(CAS){
  
  # Getting rid of NSE warnings:
  Structure_MolWt <- Substance_CASRN <- casn <- Substance_Name <- ".dplyr"
  chnm <- flags <- MlWt <- ACC_value <- casrn <- endPoint <- ".dplyr"
  
  chem_list <- dplyr::select(tox_chemicals,
                             casrn = Substance_CASRN,
                             MlWt = Structure_MolWt) %>%
    dplyr::filter(casrn %in% CAS) 
  
  ACC <- ToxCast_ACC %>%
    dplyr::filter(CAS %in% CAS) %>%
    dplyr::right_join(chem_list,
               by= c("CAS"="casrn")) %>%
    data.frame() %>%
    dplyr::mutate(ACC_value = 10^ACC,
                  ACC_value = ACC_value * MlWt) %>%
    dplyr::filter(!is.na(ACC_value)) %>%
    dplyr::left_join(dplyr::select(tox_chemicals, 
                                   CAS = Substance_CASRN, 
                                   chnm = Substance_Name), by="CAS")

  if(any(is.na(ACC$MlWt))){
    warning("Some chemicals are missing molecular weights")
  }
  
  return(ACC)

}