library(shiny)

function(input, output){
  
  # Reactive expression to compose a data frame containing all of
  # the count values
  countValues<- reactive({
    TP= 1000*input$PP*input$Sens
    FN= 1000*input$PP*(1-input$Sens)
    FP= 1000*(1-input$PP)*(1-input$Spec)
    TN= 1000*(1-input$PP)*input$Spec
    Dpos= TP+FN
    Dneg= FP+TN
    Tpos= TP+FP
    Tneg= FN+TN
    total= 1000
    counttable<- data.frame(TP, FP, FN, TN, Dpos, Dneg, Tpos, Tneg, total)
  })
  
  tableValues <- reactive({
    # call counts from the last reactive function
    data<- countValues()
    
    # Compose two by two data table
    twoXtwo<-  function(x, y){
      tab = matrix(c(data$TP, data$FN, data$Dpos, data$FP, data$TN, data$Dneg, data$Tpos, data$Tneg, data$total), nrow=3)
      n = list(c("Test(+)", "Test(-)", "Total"), c("Dx(+)", "Dx(-)", "Total"))
      dimnames(tab) = n
      tab = as.table(tab)
      dim
      tab
    }
    twoXtwo(x,y)
  }) 
  
  
  calculateValues<- reactive({
    # call counts from the count reactive function
    data<- countValues()
    
    # Compose another data frame of reactive values based on counts
    Se<- data$TP / (data$TP + data$FN)
    Sp<- data$TN / (data$TN + data$FP)
    LRpos<- Se / (1-Sp)
    LRneg<- Sp / (1-Se)
    LRsens<- Se / (1-Se)
    LRspec<- Sp / (1-Sp)
    PPP<- data$TP / (data$TP + data$FP)
    NPP<- data$TN / (data$TN + data$FN)
    PREpos<- input$PP/(1-input$PP)
    PREneg<- (1-input$PP)/input$PP
    POSTpos<- PREpos*LRpos
    POSTneg<- PREneg*LRneg
    PPP<- POSTpos/(POSTpos+1)
    NPP<- POSTneg/(POSTneg+1)
    IPPP<- PPP-input$PP
    INPP<- NPP-input$PP
    QPPP<- as.numeric(ifelse((PPP-input$PP)/(1-input$PP)>=0, (PPP-input$PP)/(1-input$PP), 0))
    QNPP<- as.numeric(ifelse((NPP-input$PP)/(1-input$PP)>=0, (NPP-input$PP)/(1-input$PP), 0))
    Qsens<- (LRsens-input$PP)/(1-input$PP)
    Qspec<- (LRspec-(1-input$PP))/input$PP
    
    calculatetable<- data.frame(PREpos, PREneg, POSTpos, POSTneg, 
                                LRsens, LRspec, LRpos, LRneg, QPPP, QNPP,  
                                Se, Sp, PPP, NPP, IPPP, INPP, row.names="values")
  })
  
  
  PrePost<- reactive({
    data<- calculateValues()
    data<- data[,1:4]
    
    tab = matrix(data, ncol=4)
    n = list(c("Values"), c("PRE_Test(+)","PRE_Test(-)","POST_Test(+)","POST_Test(-)"))
    dimnames(tab) = n
    tab = as.table(tab)
    dim
    tab
  })
  
  
  TabularOdds<- reactive({
    data<- calculateValues()
    data<- data[,5:10]
    
    tab = matrix(data, ncol=6)
    n = list(c("Values"), c("LR(Se)","LR(Sp)","LR(PPP)","LR(NPP)","Q(PPP)","Q(NPP)"))
    dimnames(tab) = n
    tab = as.table(tab)
    dim
    tab
  })
  
  
  # Show the values using an HTML table
  output$values <- renderTable({
    tableValues()
  })
  output$probabilities <- renderTable({
    data<- calculateValues()
    data[,11:16]
  })
  
  output$tabularodds <- renderTable({
    data<- TabularOdds()
  })
  output$prepost <- renderTable({
    data<- PrePost()
  })
  
  
}
