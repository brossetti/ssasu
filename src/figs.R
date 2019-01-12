library(ggplot2)
library(ggthemes)
library(reshape2)

# set working directory
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# labels
endmember.names = c("Autofluor","DY-415","DY-490","ATTO 520", "ATTO 550", "TRX", "ATTO 620", "ATTO 655")
wavelengths = c(415,424,432,441,450,459,468,477,504,513,522,531,540,549,575,584,593,602,611,620,647,656,665,674,682,691)
test.image.names = c("E1","E2","F1","F2","N1","N2","X1","X2","Z1","Z2")

# load and plot estimated endmembers
S.true <- read.csv("../data/ref/fluorometer-endmembers-full.csv", header = TRUE)
S.mean <- read.csv("../results/mean-estimated-endmembers.csv", header = FALSE)
S.anmf <- read.csv("../results/anmf-estimated-endmembers.csv", header = FALSE)

colnames(S.true) <- c("Wavelength",endmember.names[-1])
colnames(S.mean) <- endmember.names
colnames(S.anmf) <- endmember.names
S.mean$Wavelength <- wavelengths
S.anmf$Wavelength <- wavelengths

S.true <- melt(S.true,  id.vars = 'Wavelength', variable.name = 'Endmember')
S.mean.na <- melt(S.mean[,-1],  id.vars = 'Wavelength', variable.name = 'Endmember')
S.anmf.na <- melt(S.anmf[,-1],  id.vars = 'Wavelength', variable.name = 'Endmember')

plt.S <- ggplot() +
                geom_ribbon(data=S.true,aes(x=Wavelength, ymin=0, ymax=value, fill=Endmember), color="black", alpha=0.2) +
                geom_line(data=S.mean.na,aes(x=Wavelength, y=value, color=Endmember), linetype="dotted") + 
                geom_line(data=S.anmf.na,aes(x=Wavelength, y=value, color=Endmember), linetype="longdash") +
                geom_vline(xintercept=c(488,561,633), color="gray") +
                ylab("Intensity") + labs(fill="") +
                theme_few()
ggsave("../results/endmembers.jpg", plot=plt.S, width=11, height=7, dpi=350)

# load and metrics
RE <- read.csv("../results/reconstruction-error.csv", header = FALSE)
PI <- read.csv("../results/proportion-indeterminacy.csv", header = FALSE)

colnames(RE) <- c("NLS","SSASU")
colnames(PI) <- c("NLS","SSASU")
RE$TestImage <- test.image.names
PI$TestImage <- test.image.names

RE <- melt(RE,  id.vars = 'TestImage', variable.name = 'Method')
PI <- melt(PI,  id.vars = 'TestImage', variable.name = 'Method')

plt.RE <- ggplot(data=RE, aes(x=TestImage, y=value, fill=Method)) +
                 geom_col(position="dodge") +
                 ylab("Reconstruction Error") + xlab("Test Image") + labs(fill="") +
                 theme_few()
plt.PI <- ggplot(data=PI, aes(x=TestImage, y=value, fill=Method)) +
                 geom_col(position="dodge") +
                 ylab("Proportion Indeterminacy") + xlab("Test Image") + labs(fill="") +
                 theme_few()
ggsave("../results/reconstruction-error.jpg", plot=plt.RE, width=10, height=8, dpi=350)
ggsave("../results/proportion-indeterminacy.jpg", plot=plt.PI, width=10, height=8, dpi=350)


