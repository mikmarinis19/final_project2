#Get libraries
library(data.table)
library(ggplot2)

#Get data
eng <- fread("England.frq", fill=TRUE)
han <- fread("Han.frq", fill=TRUE)
yor <- fread("Yoruba.frq", fill=TRUE)

#Look at allele frequencies column 
eng$AF_COL <- eng[[5]]
han$AF_COL <- han[[5]]
yor$AF_COL <- yor[[5]]

eng$AF <- get_af(eng$AF_COL)
han$AF <- get_af(han$AF_COL)
yor$AF <- get_af(yor$AF_COL)

#Merge chrom and pos column data
merged <- Reduce(function(x, y)
  merge(x, y, by=c("CHROM","POS")),
  list(
    eng[,.(CHROM,POS,ENG=AF)],
    han[,.(CHROM,POS,HAN=AF)],
    yor[,.(CHROM,POS,YOR=AF)]
  )
)

#PBS pipeline
fst <- function(pi1, pi2, dxy){
  1 - (pi1 + pi2) / (2 * dxy)
}

# π
piE <- 2 * merged$ENG * (1 - merged$ENG)
piH <- 2 * merged$HAN * (1 - merged$HAN)
piY <- 2 * merged$YOR * (1 - merged$YOR)

# dxy
dxy_EH <- merged$ENG * (1 - merged$HAN) + (1 - merged$ENG) * merged$HAN
dxy_EY <- merged$ENG * (1 - merged$YOR) + (1 - merged$ENG) * merged$YOR
dxy_HY <- merged$HAN * (1 - merged$YOR) + (1 - merged$HAN) * merged$YOR

# FST
merged$FST_EH <- fst(piE, piH, dxy_EH)
merged$FST_EY <- fst(piE, piY, dxy_EY)
merged$FST_HY <- fst(piH, piY, dxy_HY)

# PBS 
t1 <- -log(1 - merged$FST_EH)
t2 <- -log(1 - merged$FST_EY)
c12 <- -log(1 - merged$FST_HY)

merged$PBS_ENG <- (t1 + t2 - c12) / 2

#Clean data
merged <- merged[is.finite(PBS_ENG)]
merged <- merged[PBS_ENG > 0] 

#Genome coordinates
ey <- merged

#Get just the chromosome numbers
ey$CHROM <- gsub("chr", "", ey$CHROM)

#Get chromosomes 1-11 to plot (makes it manageable for PC)
ey <- ey[ey$CHROM %in% as.character(1:11)]

#Sort them numerically
ey$CHROM <- as.numeric(ey$CHROM)

#Set rows by chromosome and position
setorder(ey, CHROM, POS)

#Get chromosome offsets, and merge them into the table
chrom_sizes <- ey[, .(chr_len = max(POS)), by=CHROM]
chrom_sizes$cumlen <- c(0, cumsum(as.numeric(chrom_sizes$chr_len))[-nrow(chrom_sizes)])
ey <- merge(ey, chrom_sizes[,.(CHROM,cumlen)], by="CHROM")

#Use the table to get Manhattan coordinates
ey$BPcum <- ey$POS + ey$cumlen

#Lactase Persistant region 
lct_start <- 135000000
lct_end   <- 136500000

ey$lct <- ifelse(
  ey$CHROM == 2 &
    ey$POS >= lct_start &
    ey$POS <= lct_end,
  "LCT",
  "Other"
)

#This puts the x-coordinates half way between each plotted chromosome 
axisdf <- ey[, .(center = median(BPcum)), by=CHROM]

#Plot
plot1 <- ggplot() +
  geom_point(
    data = ey[lct == "Other"],
    aes(x = BPcum, y = PBS_ENG, color = as.factor(CHROM)),
    size = 0.4,
    alpha = 0.6
  ) +
  #This labels the lactase persistence region red 
  geom_point(
    data = ey[lct == "LCT"],
    aes(x = BPcum, y = PBS_ENG),
    color = "red",
    size = 1.2
  ) +
  #Scales the graph 
  scale_x_continuous(
    breaks = axisdf$center,
    labels = axisdf$CHROM
  ) +
  #Theme and labels 
  theme_bw() +
  
  labs(
    title = "PBS Manhattan Plot (Chr 1–11)",
    x = "Chromosome",
    y = "PBS"
  ) +
  
  theme(
    legend.position = "none",
    panel.grid = element_blank()
  )

print(plot1)


# Outliers

# Chosen outlier threshold is top 1% 
threshold <- quantile(ey$PBS_ENG, 0.99, na.rm = TRUE)
outliers <- ey[ey$PBS_ENG >= threshold, ]

# Sort outliers 
outliers <- outliers[order(-outliers$PBS_ENG), ]

# Print top results
print(head(outliers, 20))

#Check to see whether there are outlier(s) in the lactase persistent region 
lct_outliers <- outliers[
  outliers$CHROM == 2 & 
    outliers$POS >= 135000000 & 
    outliers$POS <= 136500000, 
]

#View all outliers in this region
print(lct_outliers)

#View the single highest outlier in this region
top_lct_hit <- lct_outliers[which.max(lct_outliers$PBS_ENG), ]
print(top_lct_hit)
