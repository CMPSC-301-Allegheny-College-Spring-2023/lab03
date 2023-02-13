# Date: 13 Feb 2023
# Lab03: Gene Expression Analysis
# Name: Add Your Name Here 

# Please note: You will not have to edit this code in order to run it. This assignment does not assume that you understand the science behind the plots -- this work is an exercise in being able to infer patters or trends from an exploratory analysis. 

rm(list = ls()) # clear out the variables from memory to make a clean execution of the code.

# If you want to remove all previous plots and clear the console, run the following two lines.
graphics.off() # clear out all plots from previous work.

cat("\014") # clear the console

########################################################

#Load the data:
# Select file NCI60.rda from your repository directory data/ when prompted. You will see this file as a variable the Global Environment panel of rStudio.
load(file.choose())

# Select file NCI60cells.rda from your repository directory data/ when prompted. You will see this file as a variable the Global Environment panel of rStudio.
load(file.choose())



# You will probably need to install the Mosaic library. 
# install.packages("mosaic")


# Load the libraries
library(tidyverse)
library(dplyr)
library(mosaic)







##############################################
# Question 1: What does gsub() do in this code block? (Hint: use the online help in R using the '?' symbol.)

Narrow <- NCI60 %>% tidyr::gather(cellLine, expression, -Probe)
CellTypes <- NCI60cells %>% select(cellLine, tissue) %>% mutate(cellLine=gsub("\\:",".", as.character(cellLine)))
##############################################



# Create a subset of the data
Narrow <- Narrow %>% inner_join(CellTypes)

# Isolate the TOP3A types of probe samples
Probe_TOP3A <- Narrow %>% filter(Probe == "TOP3A")

# Find the mean of each type of each type of cancer tissue
SummaryStats <- Probe_TOP3A %>% group_by(tissue) %>%  summarise(mn_exp = exp(mean(expression, na.rm=TRUE, .groups = 'drop')), .groups = 'drop')


##############################################
# Question 2: What is shown in Plot 1? (What can you determine?)
plot(SummaryStats, main ="Plot 1 ") 
###############################################



##############################################
# Question 3: Plot 2 is a scaled view of the same information from Plot 1. How does Plot 2 provide more information than Plot 1?
SummaryStats %>% ggplot(aes(x = tissue, y = mn_exp)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle =30, hjust=1)) + ggtitle("Plot 2")
#############################################







##############################################
# Question 4: What does "mutate()" do in this code block?
# Question 5: What does "summarise()" do in this code block?
SummaryStats <- SummaryStats %>% mutate(tissue = reorder(tissue, mn_exp))
SummaryStats <- Probe_TOP3A %>% group_by(tissue) %>% summarise(mn=mean(expression, na.rm=TRUE), se = (sd(expression, na.rm=TRUE) / sqrt(n())), .groups = 'drop')
#############################################





##############################################
# Question 6: Apart from the colors red and blue to draw the points, what is the main difference between Plot 3a and Plot 3b? For example, is Plot 3b more informative than Plot 3a? Explain.

SummaryStats %>% ggplot(aes(x = tissue, y = mn)) +  geom_point(data = Probe_TOP3A, aes(x = tissue, y = expression), color = "blue") + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Plot 3a")

SummaryStats %>% ggplot(aes(x = tissue, y = exp(mn))) +  geom_point(data = Probe_TOP3A, aes(x = tissue, y = exp(expression)),color="red") + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Plot 3b")
#############################################



##############################################
# Question 7: Interpret the results of Plot 4 in terms of the magnitude of the y-axis.

# plot only histogram
SummaryStats %>% ggplot(aes(x = tissue, y = exp(mn))) + geom_bar(stat = "identity", fill = "grey", color = NA) + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Plot 4")
##############################################







##############################################
# Question 8: In Plot 5, both of the previous plots have been combined together on the same canvas. How does this, either help or confuse the output of the analysis?

# Create both plots together on same canvas
SummaryStats %>% ggplot(aes(x = tissue, y = exp(mn))) + geom_bar(stat = "identity", fill = "grey", color = NA) + geom_point(data = Probe_TOP3A, aes(x = tissue, y = exp(expression)),color ="red") + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Plot 5")
##############################################


# Add some error bars
SummaryStats <- SummaryStats %>% mutate(top = mn * 2 * se , bottom = mn - 2 * se)




##############################################
# Question 9: What do the whiskers (i.e., the big "I" shaped structures above each histogram bar) convey in this plot? Why might we need to know this information?

SummaryStats %>% ggplot(aes(x = tissue, y = exp(mn),color= tissue)) + geom_bar(stat = "identity", alpha = 0.2) + geom_errorbar(aes(x = tissue, ymin = exp(bottom), ymax = exp(top)), width = .5) + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Plot 7")
##############################################




# define an getR2Values() function
##############################################
# Question 10: The word, "function" is below in the code block. What does this part of the code do? Why do you suppose that it is necessary?

getR2Values <- function(data){
  # Note, if the "mosaic" library is not installed, then please use "install.packages("mosaic") to install it.
  mosaic::rsquared(lm(data$expression ~ data$tissue))
}
##############################################



##############################################
# Question 11: Some time is necessary to generate the variable, "ProbeR2". What is taking this code block so long to complete? What is the "lm()" function in R?

# Note: the do() function is analogous to summarise() and the unlist() function is for a simple translation to put the results of do() into a vector form to facilitate plotting.

# Note: The next line may take some minutes to complete.
#This code creates actual cases to describe relationships between anti-cancer drugs and probes  
ProbeR2 <- Narrow %>% group_by(Probe) %>% do(r2 = getR2Values(.)) %>% mutate(r2 = unlist(r2))
##############################################




##############################################
# Next, we would like to pull out the 30 probes with the largest R-squared values to be plotted. In terms of the test, these values indicate that the indepentant variables were able to successfully predict the dependent variables. In this test, these probes responded well (statistically) to tests.

#  Plot 8 is showing R-squared values which have been extracted from a linear model of each Probe. Although we have not yet discussed this form of analysis (regression analysis) in class, it is sufficient to say that R-squared values provide a statistic to determine a fitness of a model. For instance, the R-squared statistic provides a measurement of how much of the variation in a variable, known as a response variable, is accounted for in other explanatory variables. R-squared values extend from 0 to 1 where a zero-value represents a poor prediction by the explanatory variables, where-as a score of 1 indicates a perfect prediction by the explanatory variables. 






##############################################
# Question 12: With the above ideas about R-squared values in mind, which Probe in Plot 8 appears to be able to best explain the model?

Actual <- ProbeR2 %>% arrange(desc(r2)) %>% head(30) %>% mutate(Probe = reorder(Probe, desc(r2)))

Actual %>% ggplot(aes(x = Probe, y = r2))  + geom_point()  + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + ggtitle("Plot 8")
##############################################


# Next, we would like to determine whether the top 30 Probes that we plotted in Plot 8 were actually not relevant and may actually be false positives. Now, we will build a Null Hypothesis model out of a set of R-squared values to be used for a comparison. In Plot 8, we argued that those points described relationships between anti-cancer drugs and Probes from tissues. Now, we are going to try to build a model from our data in which there are NO relationships described by the anti-cancer drugs and the Probes in tissues. Then we will test that all the relationships that we plotted in Plot 8, are not included in a plot showing that NO relationships exist.



# Note: this might take some time to complete.
# This code creates null hypotheses cases  
NullR2 <- Narrow %>% group_by(Probe) %>% mutate(expression = mosaic::shuffle(expression)) %>% group_by(Probe) %>% do(r2 = getR2Values(.)) %>% mutate(r2 = unlist(r2))
##############################################






##############################################
# Question 13: In Plot 9 we see two curves. What can you infer about the relationships between the Actual cases of relationships and those cases for which no relationship exists? Remember, the blue curve corresponds to the variable "r2" and the red curve corresponds to the Null values.

ProbeR2 %>% ggplot(aes(x = r2)) + geom_density(fill = "blue", color = "blue4", alpha = .50) + geom_density(data = NullR2, aes(x = r2), fill = "pink", alpha = 0.45, color = "red") + ggtitle("Plot 9")
#Note: Actual cases are blue, Null cases are red.

##############################################



# order the list of NullR2 values. Take the top 30 and place these values in a new dataset called Null.
Null <- NullR2 %>% arrange(desc(r2)) %>% head(30) 

# Prepare data for a comparison of the data points representing successes, with non-successes.
Actual$null <- Null$r2


##############################################
# Question 14: Plot 10 is very important to determine a result concerning the Actual data sets and the Null data sets. Other than showing colored points, what does one conclude from Plot 10 about the above analysis? (For example, what non-random event do you determine?)

Actual %>% ggplot(aes(x = Probe, y = r2)) + geom_point(color = "blue") + geom_point(aes(y = null), color = "red") + theme(axis.text.x = element_text(angle = 45, hjust=1)) + ggtitle("Plot 10")

#Note: Actual cases are blue, Null cases are red.

##############################################

# Note: Did you remember to add your name to this source file?