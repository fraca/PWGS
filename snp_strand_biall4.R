
#in_file="/home/marco/pool_first/snp_BED/p11C_tot_th_SNP_scaf/scaffold_2.varscan"
#in_file="/home/marco/pool_first/snp_BED_old/p07C_tot_SNP_scaf/scaffold_1.varscan"
#in_file="/home/marco/pool_first/snp_BED_old/p14E_tot_SNP_scaf/scaffold_1.varscan"
snp_biall=function(in_file) {
  tab=read.table(in_file,stringsAsFactors=FALSE)
  tab_or=tab
  ## remove strand bias
  ratio_ref=tab[,16]/(tab[,16]+tab[,17])
  ratio_alt=tab[,18]/(tab[,18]+tab[,19])
  
  rem_ref=c(which(ratio_ref<=0.1),which(ratio_ref>=0.9))
  rem_alt=c(which(ratio_alt<=0.1),which(ratio_alt>=0.9))
  rem=union(rem_ref,rem_alt)
  
  if(length(rem)!=0) {
  tab=tab[-rem,]
  
  }
  
  ##remove SNP N in ref.
  rem_N=which(tab[,4]=="N")
  if(length(rem_N)!=0) {
    tab=tab[-rem_N,]  
  }
  
  ## remove triallelic
  dup=which(duplicated(tab[,2]) | duplicated(tab[nrow(tab):1,2])[nrow(tab):1])
  
  if(length(dup)!=0) {
    tab=tab[-dup,]
  }

  rem2=unique(c(rem,dup,rem_N))

  write.table(cbind(tab_or[rem2,1],as.integer(tab_or[rem2,2]),as.integer(tab_or[rem2,2])),quote=F,sep="\t",col.names = F,row.names = F,file=paste(in_file,"_temp_rem",sep=""))
  
  write.table(tab,quote=F,sep="\t",col.names = F,row.names = F,file=in_file)
  #write.table(tab,quote=F,sep="\t",col.names = F,row.names = F,file=paste(in_file,"2",sep=""))

  ###remove below 0.03 and up 0.97 only for NPStat
  
  rem=union(which(tab[,7]/(tab[,6]+tab[,7])<=0.03),which(tab[,7]/(tab[,6]+tab[,7])>=0.97))
  tab=tab[-rem,]
  
  cat(tab[,2],sep="\n",file=gsub(".varscan","_varscan.snp",in_file))

}

args <- commandArgs(trailingOnly = TRUE)

snp_biall(args[1])

