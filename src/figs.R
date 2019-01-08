library(ggplot2)
library(ggthemes)
library(Cairo)
library(reshape2)

# set working directory
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# load and plot estimated endmembers
S <- read.csv("../results/anmf-estimated-endmembers.csv", header = FALSE)

colnames(S) <- c("Autofluor","DY-415","DY-490","ATTO 520", "ATTO 550", "TRX", "ATTO 620", "ATTO 655")
S$Wavelength <- c(415,424,432,441,450,459,468,477,504,513,522,531,540,549,575,584,593,602,611,620,647,656,665,674,682,691)

S <- melt(S,  id.vars = 'Wavelength', variable.name = 'Endmember')
plt.S <- ggplot(S, aes(Wavelength, value)) +
                geom_ribbon(aes(ymin=0, ymax=value, fill=Endmember), color="black", alpha=0.2) +
                ylab("Intensity") + labs(fill="") +
                theme_few()
ggsave("../results/anmf-estimated-endmembers.jpg", plot=plt.S, width=11, height=7, dpi=350)