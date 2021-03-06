

plot_chemical_boxplots <- function(chemical_summary, 
                                   manual_remove=NULL,
                                   mean_logic = FALSE,
                                   sum_logic = TRUE,
                                   plot_ND = TRUE,
                                   font_size = NA,
                                   title = NA,
                                   palette = NA,
                                   hit_threshold = NA){
  
  site <- EAR <- sumEAR <- meanEAR <- groupCol <- nonZero <- ".dplyr"
  chnm <- Class <- meanEAR <- x <- y <- max_med <- endPoint <- ".dplyr"

  cbValues <- c("#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628",
                "#DCDA4B","#999999","#00FFFF","#CEA226","#CC79A7","#4E26CE",
                "#FFFF00","#78C15A","#79AEAE","#FF0000","#00FF00","#B1611D",
                "#FFA500","#F4426e", "#800000", "#808000")
  
  if(!plot_ND){
    chemical_summary <- chemical_summary[chemical_summary$EAR > 0,]
  }
  
  if(length(unique(chemical_summary$Class)) > length(cbValues)){
    n <- length(unique(chemical_summary$Class))
    
    if(n > 20 & n<30){
      cbValues <- c(RColorBrewer::brewer.pal(n = 12, name = "Set3"),
                    RColorBrewer::brewer.pal(n = 8, name = "Set2"),
                    RColorBrewer::brewer.pal(n = max(c(3,n-20)), name = "Set1"))
    } else if (n <= 20){
      cbValues <- c(RColorBrewer::brewer.pal(n = 12, name = "Set3"),
                    RColorBrewer::brewer.pal(n =  max(c(3,n-12)), name = "Set2"))     
    } else {
      cbValues <- colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral"))(n)
    }
  }
  
  single_site <- length(unique(chemical_summary$site)) == 1
  
  y_label <- fancyLabels(category = "Chemical", mean_logic, sum_logic, single_site)
  
  if(single_site){
    
    # Single site order:
    orderColsBy <- chemical_summary %>%
      dplyr::group_by(chnm, Class) %>%
      dplyr::summarise(median = median(EAR[EAR != 0], na.rm = TRUE)) %>%
      dplyr::arrange(median)

    class_order <- orderColsBy %>%
      dplyr::group_by(Class) %>%
      dplyr::summarise(max_med = max(median, na.rm = TRUE)) %>%
      dplyr::arrange(max_med) %>%
      dplyr::pull(Class)
    
    orderedLevels <- chemical_summary %>%
      dplyr::group_by(chnm, Class) %>%
      dplyr::summarise(median = median(EAR[EAR != 0])) %>%
      dplyr::mutate(Class = factor(Class, levels = rev(class_order))) %>%
      dplyr::arrange(Class, dplyr::desc(median)) %>%
      dplyr::pull(chnm)

    chemical_summary$Class <- factor(as.character(chemical_summary$Class), levels = rev(class_order))
    chemical_summary$chnm <- factor(as.character(chemical_summary$chnm), levels = rev(orderedLevels))
    
    countNonZero <- chemical_summary %>%
      dplyr::group_by(chnm, Class) %>%
      dplyr::summarize(nonZero = as.character(length(unique(endPoint[EAR > 0]))),
                hits = as.character(length(unique(date[EAR > hit_threshold]))))
    
    countNonZero$hits[countNonZero$hits == "0"] <- ""
    
    label <- "# Endpoints"

    pretty_logs_new <-  prettyLogs(chemical_summary$EAR)
    
    toxPlot_All <- ggplot(data=chemical_summary)
    
    if(!all(is.na(palette))){
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x=chnm, y=EAR, fill=chnm),lwd=0.1,outlier.size=1) +
        scale_fill_manual(values = palette) +
        theme(legend.position = "none")
    } else {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x=chnm, y=EAR, fill=Class),
                     lwd=0.1,outlier.size=1)
    }
    
  } else {
    
    graphData <- graph_chem_data(chemical_summary=chemical_summary, 
                                 manual_remove=manual_remove,
                                 mean_logic=mean_logic,
                                 sum_logic=sum_logic)
    
    pretty_logs_new <-  prettyLogs(graphData$meanEAR)
    
    countNonZero <- graphData %>%
      dplyr::select(chnm, Class, meanEAR) %>%
      dplyr::group_by(chnm, Class) %>%
      dplyr::summarize(nonZero = as.character(sum(meanEAR>0)),
                hits = as.character(sum(meanEAR > hit_threshold)))
    
    countNonZero$hits[countNonZero$hits == "0"] <- ""
    
    label <- "# Sites"
    toxPlot_All <- ggplot(data=graphData) 
    
    if(!all(is.na(palette))){
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x=chnm, y=meanEAR, fill=chnm),lwd=0.1,outlier.size=1) +
        scale_fill_manual(values = palette) +
        theme(legend.position = "none")
    } else {
      toxPlot_All <- toxPlot_All +
        geom_boxplot(aes(x=chnm, y=meanEAR, fill=Class),
                     lwd=0.1,outlier.size=1)
    }
 
  }
  
  toxPlot_All <- toxPlot_All +
    scale_y_log10(y_label, labels=fancyNumbers,breaks=pretty_logs_new)  +
    theme_bw() +
    scale_x_discrete(drop = TRUE) +
    geom_hline(yintercept = hit_threshold, linetype="dashed", color="black") +
    theme(axis.text = element_text( color = "black"),
          axis.title.y = element_blank(),
          panel.background = element_blank(),
          plot.background = element_rect(fill = "transparent",colour = NA),
          strip.background = element_rect(fill = "transparent",colour = NA),
          strip.text.y = element_blank(),
          panel.border = element_blank(),
          axis.ticks = element_blank(),
          plot.title = element_text(hjust = 0.5))  
  
  if(all(is.na(palette))){
    toxPlot_All <- toxPlot_All +
      scale_fill_manual(values = cbValues, drop=FALSE) +
      guides(fill=guide_legend(ncol=6)) +
      theme(legend.position="bottom",
            legend.justification = "left",
            legend.background = element_rect(fill = "transparent", colour = "transparent"),
            legend.title=element_blank(),
            legend.key.height = unit(1,"line"))
  }
    
  if(!is.na(font_size)){
    toxPlot_All <- toxPlot_All +
      theme(axis.text = element_text(size = font_size),
            axis.title =   element_text(size=font_size))
  }

  if(utils::packageVersion("ggplot2") >= '3.0.0'){
    toxPlot_All <- toxPlot_All +
      coord_flip(clip = "off")
  } else {
    toxPlot_All <- toxPlot_All +
      coord_flip()      
  }
  
  plot_info <- ggplot_build(toxPlot_All)
  layout_stuff <- plot_info$layout
  
  if(utils::packageVersion("ggplot2") >= "2.2.1.9000"){
    ymin <- 10^(layout_stuff$panel_scales_y[[1]]$range$range[1])
    ymax <- 10^(layout_stuff$panel_scales_y[[1]]$range$range[2])
  } else {
    ymin <- 10^(layout_stuff$panel_ranges[[1]]$x.range[1])
    ymax <- 10^(layout_stuff$panel_ranges[[1]]$x.range[2])
  }
  
  toxPlot_All_withLabels <- toxPlot_All +
    geom_text(data=countNonZero, aes(x=chnm,label=nonZero, y=ymin), size = ifelse(is.na(font_size),2,0.30*font_size)) +
    geom_text(data=data.frame(x = Inf, y=ymin, label = label, stringsAsFactors = FALSE), 
            aes(x=x,  y=y, label = label),
            size=ifelse(is.na(font_size),3,0.30*font_size)) 
  
  nHitsEP <- countNonZero$hits
  
  if(isTRUE(sum(as.numeric(nHitsEP), na.rm = TRUE) > 0)) {
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      geom_text(data=countNonZero, aes(x=chnm, y=ymax,label=nHitsEP),size=ifelse(is.na(font_size),3,0.30*font_size)) +
      geom_text(data=data.frame(x = Inf, y=ymax, label = "# Hits", stringsAsFactors = FALSE), 
                aes(x = x,  y=y, label = label),
                size=ifelse(is.na(font_size),3,0.30*font_size))
  }
  
  if(!all(is.na(title))){
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      ggtitle(title)
    
    if(!is.na(font_size)){
      toxPlot_All_withLabels <- toxPlot_All_withLabels +
        theme(plot.title = element_text(size=font_size))
    }
  }
  
  if(!is.na(hit_threshold)) {
    toxPlot_All_withLabels <- toxPlot_All_withLabels +
      geom_text(data=data.frame(x = Inf, y=hit_threshold, label = "Threshold", stringsAsFactors = FALSE), 
                aes(x = x,  y=y, label = label),
                size=ifelse(is.na(font_size),3,0.30*font_size))
  }
  
  return(toxPlot_All_withLabels)
  
}

#' @export
#' @rdname plot_tox_boxplots
graph_chem_data <- function(chemical_summary, 
                            manual_remove=NULL,
                            mean_logic = FALSE,
                            sum_logic = TRUE){
  
  site <- chnm <- Class <- EAR <- sumEAR <- meanEAR <- ".dplyr"


  if(!sum_logic){
    graphData <- chemical_summary %>%
      dplyr::group_by(site, chnm, Class) %>%
      dplyr::summarise(meanEAR=ifelse(mean_logic,mean(EAR),max(EAR))) %>%
      data.frame()     
  } else {
    #With new dplyr...will need to filter out na's in meanEAR
    graphData <- chemical_summary %>%
      dplyr::group_by(site,date,chnm) %>%
      dplyr::summarise(sumEAR=sum(EAR,na.rm = TRUE)) %>%
      data.frame() %>%
      dplyr::group_by(site, chnm) %>%
      dplyr::summarise(meanEAR=ifelse(mean_logic,mean(sumEAR),max(sumEAR))) %>%
      data.frame() %>%
      dplyr::left_join(dplyr::distinct(dplyr::select(chemical_summary, chnm, Class)), by = "chnm")
  }
  
  if(!is.null(manual_remove)){
    graphData <- dplyr::filter(graphData, !(chnm %in% manual_remove))
  }
  
  return(graphData)
}

