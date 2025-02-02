library(RColorBrewer)
library(ggplot2)
library(ggthemes)
library(reshape2)

# set working directory
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# labels
endmember.names = c("Autofluor","DY-415","DY-490","ATTO 520", "ATTO 550", "TRX", "ATTO 620", "ATTO 655")
wavelengths = c(415,424,432,441,450,459,468,477,504,513,522,531,540,549,575,584,593,602,611,620,647,656,665,674,682,691)
test.image.names = c("A1","A2","B1","B2","C1","C2","D1","D2","E1","E2")

##### Endmember Plot
# load and plot estimated endmembers
S.true <- read.csv(file.path("..","data","ref","fluorometer-endmembers-full.csv"), header = TRUE)
S.mean <- read.csv(file.path("..","results","mean-estimated-endmembers.csv"), header = FALSE)
S.anmf <- read.csv(file.path("..","results","anmf-estimated-endmembers.csv"), header = FALSE)

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
                geom_line(data=S.mean.na,aes(x=Wavelength, y=value, color=Endmember), linetype="dotted",show.legend=FALSE) +
                geom_line(data=S.anmf.na,aes(x=Wavelength, y=value, color=Endmember), linetype="longdash",show.legend=FALSE) +
                geom_vline(xintercept=c(488,561,633), color="gray") +
                ylab("Intensity") + labs(fill="") + scale_fill_hue(h.start=90, direction=-1) +
                scale_color_hue(h.start=90, direction=-1) + theme_few()
ggsave(file.path("..","results","endmembers.tiff"), plot=plt.S, width=11, height=7, dpi=350)
ggsave(file.path("..","results","endmembers.jpg"), plot=plt.S, width=11, height=7, dpi=350)

##### Autofluorescence Plot
# load and plot autofluroescence endmembers
AF <- list()
for (sample in c("A","B","C","D","E")) {
  for (fov in c("1","2")) {
    tmp <- read.csv(file.path("..","results","ssasu", paste(sample,"-TDFH2-",fov,"-ssasu-S.csv",sep="")), header = FALSE)
    AF[paste(sample,fov,sep="")] <- tmp[1]
  }
}

AF$Wavelength <- wavelengths

S.mean.af <- melt(S.mean[c(1,9)], id.vars = "Wavelength", variable.name = "Endmember")
AF <- melt(data.frame(AF),  id.vars = 'Wavelength', variable.name = 'TestImage')

plt.AF <- ggplot() +
                geom_ribbon(data=S.mean.af,aes(x=Wavelength, ymin=0, ymax=value), color="black", alpha=0.2) +
                geom_line(data=AF,aes(x=Wavelength, y=value, color=TestImage)) +
                #geom_vline(xintercept=c(488,561,633), color="gray") +
                ylab("Intensity") + labs(color="") +
                theme_few()

ggsave(file.path("..","results","autofluor.tiff"), plot=plt.AF, width=11, height=7, dpi=350)
ggsave(file.path("..","results","autofluor.jpg"), plot=plt.AF, width=11, height=7, dpi=350)

##### Metrics Plots
# load and plot metrics
RE <- read.csv(file.path("..","results","reconstruction-error.csv"), header = FALSE)
PI <- read.csv(file.path("..","results","proportion-indeterminacy.csv"), header = FALSE)

colnames(RE) <- c("NLS","PoissonNMF","SSASU","SUnSAL","SUnSAL-TV")
colnames(PI) <- c("NLS","PoissonNMF","SSASU","SUnSAL","SUnSAL-TV")
RE$TestImage <- test.image.names
PI$TestImage <- test.image.names
RE <- RE[c(3,1,2,4,5,6)]
PI <- PI[c(3,1,2,4,5,6)]

RE <- melt(RE,  id.vars = 'TestImage', variable.name = 'Method')
PI <- melt(PI,  id.vars = 'TestImage', variable.name = 'Method')

plt.RE <- ggplot(data=RE, aes(x=TestImage, y=value, fill=Method)) +
                 geom_col(position="dodge", color="black") + ylim(0,0.15) +
                 ylab("Relative Reconstruction Error") + xlab("Test Image") + labs(fill="") +
                 scale_fill_brewer(palette="Set2") + theme_few() + theme(legend.position="none")
plt.PI <- ggplot(data=PI, aes(x=TestImage, y=value, fill=Method)) +
                 geom_col(position="dodge", color="black") + ylim(0,1) +
                 ylab("Proportion Indeterminacy") + xlab("Test Image") + labs(fill="") +
                 scale_fill_brewer(palette="Set2") + theme_few() + theme(legend.position = 'bottom')

ggsave(file.path("..","results","reconstruction-error.tiff"), plot=plt.RE, width=10, height=5, dpi=350)
ggsave(file.path("..","results","reconstruction-error.jpg"), plot=plt.RE, width=10, height=5, dpi=350)
ggsave(file.path("..","results","proportion-indeterminacy.tiff"), plot=plt.PI, width=10, height=6, dpi=350)
ggsave(file.path("..","results","proportion-indeterminacy.jpg"), plot=plt.PI, width=10, height=6, dpi=350)
