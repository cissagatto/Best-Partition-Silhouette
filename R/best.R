cat("\n\n##############################################################")
cat("\n# START SELECT BEST SILHOUETTE PARTITION                       #")
cat("\n################################################################\n\n")


##############################################################################
# BEST PARTITION SILHOUETTE ECC                                              #
# Copyright (C) 2022                                                         #
#                                                                            #
# This code is free software: you can redistribute it and/or modify it under #
# the terms of the GNU General Public License as published by the Free       #
# Software Foundation, either version 3 of the License, or (at your option)  #
# any later version. This code is distributed in the hope that it will be    #
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General   #
# Public License for more details.                                           #
#                                                                            #
# Elaine Cecilia Gatto | Prof. Dr. Ricardo Cerri | Prof. Dr. Mauri           #
# Ferrandin | Federal University of Sao Carlos                               #
# (UFSCar: https://www2.ufscar.br/) Campus Sao Carlos | Computer Department  #
# (DC: https://site.dc.ufscar.br/) | Program of Post Graduation in Computer  #
# Science (PPG-CC: http://ppgcc.dc.ufscar.br/) | Bioinformatics and Machine  #
# Learning Group (BIOMAL: http://www.biomal.ufscar.br/)                      #
#                                                                            #
##############################################################################


###########################################################################
#
###########################################################################
FolderRoot = "~/Best-Partition-Silhouette"
FolderScripts = "~/Best-Partition-Silhouette/R"


###########################################################################
#
###########################################################################
# LOAD LIBRARIES
setwd(FolderScripts)
source("libraries.R")

setwd(FolderScripts)
source("utils.R")

setwd(FolderScripts)
source("run.R")



###############################################################################
# R Options Configuration                                                     #
###############################################################################
options(java.parameters = "-Xmx64g")  # JAVA
options(show.error.messages = TRUE)   # ERROR MESSAGES
options(scipen=20)                    # number of places after the comma



###############################################################################
# Reading the "datasets-original.csv" file to get dataset information         #
# for code execution!                                                         #
###############################################################################
setwd(FolderRoot)
datasets <- data.frame(read.csv("datasets-original.csv"))



###############################################################################
# ARGS COMMAND LINE                                                          #
###############################################################################
cat("\n#####################################")
cat("\n# GET ARGUMENTS FROM COMMAND LINE   #")
cat("\n#####################################\n\n")
args <- commandArgs(TRUE)



###############################################################################
# FIRST ARGUMENT: getting specific dataset information being processed        #
# from csv file                                                               #
###############################################################################

# config_file = "~/Best-Partition-Silhouette/config-files/jaccard/ward.d2/sj-GpositiveGO.csv"

config_file <- args[1]

if(file.exists(config_file)==FALSE){
  cat("\n################################################################")
  cat("#\n Missing Config File! Verify the following path:              #")
  cat("#\n ", config_file, "                                            #")
  cat("#################################################################\n\n")
  break
} else {
  cat("\n########################################")
  cat("\n# Properly loaded configuration file!  #")
  cat("\n########################################\n\n")
}


cat("\n########################################")
cat("\n# PARAMETERS READ                    #\n")
config = data.frame(read.csv(config_file))
print(config)
cat("\n########################################\n\n")

parameters = list()

# DATASET_PATH
dataset_path = toString(config$Value[1])
dataset_path = str_remove(dataset_path, pattern = " ")
parameters$Path.Dataset = dataset_path

# TEMPORARTY_PATH
folderResults = toString(config$Value[2])
folderResults = str_remove(folderResults, pattern = " ")
parameters$Folder.Results = folderResults

# PARTITIONS_PATH
Dendogram = toString(config$Value[3])
Dendogram = str_remove(Dendogram, pattern = " ")
parameters$Dendogram = Dendogram

# PARTITIONS_PATH
Partitions_Path = toString(config$Value[4])
Partitions_Path = str_remove(Partitions_Path, pattern = " ")
parameters$Path.Partitions = Partitions_Path

# SIMILARITY
similarity = toString(config$Value[5])
similarity = str_remove(similarity, pattern = " ")
parameters$Similarity = similarity

# DATASET_NAME
dataset_name = toString(config$Value[6])
dataset_name = str_remove(dataset_name, pattern = " ")
parameters$Dataset.Name = dataset_name

# DATASET_NUMBER
number_dataset = as.numeric(config$Value[7])
parameters$Number.Dataset = number_dataset

# NUMBER_FOLDS
number_folds = as.numeric(config$Value[8])
parameters$Number.Folds = number_folds

# NUMBER_CORES
number_cores = as.numeric(config$Value[9])
parameters$Number.Cores = number_cores

# DATASET_INFO
ds = datasets[number_dataset,]
parameters$Dataset.Info = ds



###############################################################################
# Creating temporary processing folder                                        #
###############################################################################
if (dir.exists(folderResults) == FALSE) {dir.create(folderResults)}



###############################################################################
# Creating all directories that will be needed for code processing            #
###############################################################################
cat("\n######################")
cat("\n# Get directories    #")
cat("\n######################\n")
diretorios <- directories(dataset_name, folderResults, similarity)
print(diretorios)
cat("\n\n")


#####################################
parameters$Folders = diretorios
#####################################


###############################################################################
# Copying datasets from ROOT folder on server                                 #
###############################################################################

cat("\n####################################################################")
cat("\n# Checking the dataset tar.gz file                                 #")
cat("\n####################################################################\n\n")
str00 = paste(dataset_path, "/", ds$Name,".tar.gz", sep = "")
str00 = str_remove(str00, pattern = " ")

if(file.exists(str00)==FALSE){

  cat("\n######################################################################")
  cat("\n# The tar.gz file for the dataset to be processed does not exist!    #")
  cat("\n# Please pass the path of the tar.gz file in the configuration file! #")
  cat("\n# The path entered was: ", str00, "                                  #")
  cat("\n######################################################################\n\n")
  break

} else {

  cat("\n####################################################################")
  cat("\n# tar.gz file of the DATASET loaded correctly!                     #")
  cat("\n####################################################################\n\n")

  # COPIANDO
  str01 = paste("cp ", str00, " ", diretorios$folderDatasets, sep = "")
  res = system(str01)
  if (res != 0) {
    cat("\nError: ", str01)
    break
  }

  # DESCOMPACTANDO
  str02 = paste("tar xzf ", diretorios$folderDatasets, "/", ds$Name,
                ".tar.gz -C ", diretorios$folderDatasets, sep = "")
  res = system(str02)
  if (res != 0) {
    cat("\nError: ", str02)
    break
  }

  #APAGANDO
  str03 = paste("rm ", diretorios$folderDatasets, "/", ds$Name,
                ".tar.gz", sep = "")
  res = system(str03)
  if (res != 0) {
    cat("\nError: ", str03)
    break
  }

}



###############################################################################
# Copying PARTITIONS from ROOT folder on server                               #
###############################################################################

cat("\n####################################################################")
cat("\n# Checking the PARTITIONS tar.gz file                              #")
cat("\n####################################################################\n\n")
str00 = paste(Partitions_Path, "/", ds$Name,".tar.gz", sep = "")
str00 = str_remove(str00, pattern = " ")

if(file.exists(str00)==FALSE){

  cat("\n######################################################################")
  cat("\n# The tar.gz file for the dataset to be processed does not exist!    #")
  cat("\n# Please pass the path of the tar.gz file in the configuration file! #")
  cat("\n# The path entered was: ", str00, "                                  #")
  cat("\n######################################################################\n\n")
  break

} else {

  cat("\n####################################################################")
  cat("\n# tar.gz file of the PARTITION loaded correctly!                   #")
  cat("\n####################################################################\n\n")

  # COPIANDO
  str01 = paste("cp ", str00, " ", diretorios$folderPartitions, sep = "")
  res = system(str01)
  if (res != 0) {
    cat("\nError: ", str01)
    break
  }

  # DESCOMPACTANDO
  str02 = paste("tar xzf ", diretorios$folderPartitions, "/", ds$Name,
                ".tar.gz -C ", diretorios$folderPartitions, sep = "")
  res = system(str02)
  if (res != 0) {
    cat("\nError: ", str02)
    break
  }

  #APAGANDO
  str03 = paste("rm ", diretorios$folderPartitions, "/", ds$Name,
                ".tar.gz", sep = "")
  res = system(str03)
  if (res != 0) {
    cat("\nError: ", str03)
    break
  }

}



cat("\n####################################################################")
cat("\n# EXECUTE                                                          #")
cat("\n####################################################################\n\n")
timeFinal <- system.time(results <- executaBPS(parameters))


print(timeFinal)
result_set <- t(data.matrix(timeFinal))
setwd(diretorios$folderOutputDataset)
write.csv(result_set, "Runtime.csv")


print(system(paste("rm -r ", diretorios$folderDatasets, sep="")))

print(system(paste("rm -r ", diretorios$folderPartitions, sep="")))


cat("\n####################################################################")
cat("\n# Compress folders and files                                       #")
cat("\n####################################################################\n\n")
str_a <- paste("tar -zcf ", diretorios$folderResults, "/", dataset_name,
               "-", similarity, "-best-partitions.tar.gz ",
               diretorios$folderResults, sep = "")
print(system(str_a))


cat("\n####################################################################")
cat("\n# Copy to root folder                                              #")
cat("\n####################################################################\n\n")

folder = paste(FolderRoot, "/Reports", sep="")
if(dir.exists(folder)==FALSE){dir.create(folder)}

folder2 = paste(folder, "/", similarity, sep="")
if(dir.exists(folder2)==FALSE){dir.create(folder2)}

folder3 = paste(folder2, "/", Dendogram, sep="")
if(dir.exists(folder3)==FALSE){dir.create(folder3)}

str_b <- paste("cp -r ", diretorios$folderResults, "/", dataset_name,
               "-", similarity, "-best-partitions.tar.gz ", folder3, sep = "")
print(system(str_b))

 
# cat("\n####################################################################")
# cat("\n# COPY TO GOOGLE DRIVE                                             #")
# cat("\n####################################################################\n\n")
# origem = diretorios$folderOutputDataset
# destino = paste("nuvem:Best-Partitions/", similarity,
#                "/Silhouette/", dataset_name, "/Output/", sep="")
# comando1 = paste("rclone -P copy ", origem, " ", destino, sep="")
# cat("\n", comando1, "\n")
# a = print(system(comando1))
# a = as.numeric(a)
# if(a != 0) {
# stop("Erro RCLONE")
# quit("yes")
# }

 

# cat("\n####################################################################")
# cat("\n# COPY TO GOOGLE DRIVE                                             #")
# cat("\n####################################################################\n\n")
# origem = diretorios$folderValidate
# destino = paste("nuvem:/Best-Partitions/", similarity,
#                 "/Silhouette/", dataset_name, "/Validate/", sep="")
# comando1 = paste("rclone -P copy ", origem, " ", destino, sep="")
# cat("\n", comando1, "\n")
# a = print(system(comando1))
# a = as.numeric(a)
# if(a != 0) {
#   stop("Erro RCLONE")
#   quit("yes")
# }



cat("\n####################################################################")
cat("\n# DELETE                                                           #")
cat("\n####################################################################\n\n")
str_c = paste("rm -r ", diretorios$folderResults, sep="")
print(system(str_c))

rm(list = ls())
gc()


cat("\n\n##############################################################")
cat("\n# END SELECT BEST SILHOUETTE PARTITION                         #")
cat("\n################################################################\n\n")
cat("\n\n\n\n")


#############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com              #
# Thank you very much!                                                      #
#############################################################################
