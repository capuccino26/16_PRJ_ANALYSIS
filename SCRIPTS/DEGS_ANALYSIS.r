# Load Packages
library(Rsubread)
library(ape)
library(DESeq2)
library(ggplot2)
library(dendextend)
library(pheatmap)
library(genefilter)
library(vsn)
library(vioplot)
library(ggrepel)
library(EnhancedVolcano)
library(ggalt)
library(gridExtra)
library(grid)
library(volcano3D)
library(PoiClaClu)
library(enrichplot)
library(pathview)
library(tidyr)
library(ggpubr)
library(ggplotify)
library(enrichplot)
library(europepmc)
library(AnnotationHub)
library(DOSE)
library(dplyr)
library(stringr)
library(scales)
library(ComplexHeatmap)
library("readxl")
library(cowplot)
library(ggtext)
library(clusterProfiler)
library(GGally)
library(vcd)
library(dlookr)
library(corrplot)
library(tidyverse)
library(reshape2)

# Set environment
path<-"/DEGS/"
prjs <- read.csv2(sprintf("%slist.txt",path),sep="\t", header = FALSE)

# Loop for analysis of all projects listed
for(prji in prjs[,1]){
	print(prji)
	pathi<-sprintf("%s%s/",path,prji)
	acclist <- read.csv2(sprintf("%sSRR_Acc_List.txt",pathi), header = FALSE)
	sampleinfo <- read.csv2(sprintf("%ssampleinfo.txt",pathi),sep="\t", header = TRUE)
	contrast <- read.csv2(sprintf("%scontrast.txt",pathi),sep="\t", header = FALSE)

        # Generating coldata for entire analysis
	for(i in acclist[,1]){
		print(i)
		j<-subset(read.csv2(file=sprintf("%s/SALMON/%s_COMPGG/quant.sf", pathi, i),sep=""),select=c("Name","NumReads"))
		colnames(j)[2]<-i
		assign(i,j)
		if(exists("coldata")){
			print("Merging Coldata")
			coldata<-merge(coldata,j,by="Name")
		} else {
			print("Creating Coldata")
			coldata<-j}
		rm(j)
		rm(i)
	}
	rm(list = acclist$V1)
	rownames(coldata) <- coldata[,1]
	coldata <- coldata[,-1]
	coldata <- mutate_all(coldata, function(x) as.integer(as.character(x)))

        # DESEQ analysis
	dds <- DESeqDataSetFromMatrix(countData = coldata,colData = sampleinfo,design = ~ Status)
	dds <- DESeq(dds)
        ## Status defined my the contrast file
	res <- results(dds, contrast=c("Status",contrast$V1[1],contrast$V1[2]))
	restable <- as.data.frame(res)
        ## Save results
	if (!dir.exists(sprintf("%sRESULTS_COMPGG", pathi))){
		dir.create(sprintf("%sRESULTS_COMPGG", pathi))
		print("Results folder created")
	} else {
		print("Results folder already exists")
	}
	write.table(as.data.frame(res), file=sprintf("%sRESULTS_COMPGG/RES_deseqcsv.csv", pathi))
	write.csv2(as.data.frame(res), file=sprintf("%sRESULTS_COMPGG/RES_deseq.csv", pathi))

	## Normalization
	print("Normalization:")
	mincount<-10
	print(sprintf("Removing counts inferior to %s:",mincount))
	keep<-rowSums(counts(dds))>=mincount
	ddsnorm<-dds[keep,]
	ddsnorm<-DESeq(ddsnorm)
        ## DESEQ with normalized files
	resnorm <- results(ddsnorm, contrast=c("Status",contrast$V1[1],contrast$V1[2]))
	print(sprintf("Exporting Table of Normalized Results for %s counts Table",mincount))
	write.table(as.data.frame(resnorm), file=sprintf("%sRESULTS_COMPGG/RES_norm_deseqcsv.csv", pathi))
	write.csv2(as.data.frame(resnorm), file=sprintf("%sRESULTS_COMPGG/RES_norm_deseq.csv", pathi))
        ## Library size normalization
	print("Normalizing for Library Size:")
	resnormLS<-counts(ddsnorm,normalize=T)
	write.table(as.data.frame(resnormLS), file=sprintf("%sRESULTS_COMPGG/RES_normLS_deseqcsv.csv", pathi))
	write.csv2(as.data.frame(resnormLS), file=sprintf("%sRESULTS_COMPGG/RES_normLS_deseq.csv", pathi))
        ## Filtering by p and padj values
	pvalue<-0.05
	print(sprintf("Removing counts for p threshold of %s:",pvalue))
	resnormpvalue<-results(ddsnorm, contrast=c("Status",contrast$V1[1],contrast$V1[2]),alpha=pvalue)
	resnormpvalue<-resnormpvalue[order(resnormpvalue$padj),]
	write.table(as.data.frame(resnormpvalue), file=sprintf("%sRESULTS_COMPGG/RES_normpval_deseqcsv.csv", pathi))
	write.csv2(as.data.frame(resnormpvalue), file=sprintf("%sRESULTS_COMPGG/RES_normpval_deseq.csv", pathi))
	padj<-0.05
	print(sprintf("Selecting significant differential expression for FDR threshold of %s:",padj))
	signDE<-subset(resnormpvalue,padj<=padj)
	write.table(as.data.frame(signDE), file=sprintf("%sRESULTS_COMPGG/RES_SIGNDEcsv.csv", pathi))
	write.csv2(as.data.frame(signDE), file=sprintf("%sRESULTS_COMPGG/RES_SIGNDE.csv", pathi))
        ## Filtering significant Values
	signDEDF<-as.data.frame(signDE)
	print("Creating full table with LS normalization")
	mergedNM<-merge(resnormLS,signDEDF,by=0)
	rownames(mergedNM)<-mergedNM$Row.names
	mergedNM$Row.names <- NULL
	write.table(as.data.frame(mergedNM), file=sprintf("%sRESULTS_COMPGG/RES_MERGEDcsv.csv", pathi))
	write.csv2(as.data.frame(mergedNM), file=sprintf("%sRESULTS_COMPGG/RES_MERGED.csv", pathi))

	# Graphical Analysis
	print("Starting graphical analysis")
	#Pheatmap
	print("Heatmap Total")
	elements<-nrow(acclist)
	pheat<-mergedNM[,1:elements]
	row.names(pheat)<-rownames(mergedNM)
	#PCA
	print("PCA")
	png(sprintf("%sRESULTS_COMPGG/PCA1.png",pathi),width=800, height=800,res = 100)
	print(plotCounts(dds, gene=which.min(res$padj), intgroup="Status"))
	dev.off()
	graphics.off()
	vsd <- vst(dds, blind=FALSE)
	png(sprintf("%sRESULTS_COMPGG/PCA2.png",pathi),width=800, height=800,res = 100)
	if (!is.null(vsd$Run)) {
		print(plotPCA(vsd, intgroup=c("Status")) + geom_label_repel(aes(label = vsd$Run)))
	} else {
		print(plotPCA(vsd, intgroup=c("Status")) + geom_label_repel(aes(label = vsd$FileName)))
	}
	dev.off()
	graphics.off()
	##Comparative Pheatmap top genes
	topVarGenes <- head(order(rowVars(assay(vsd)), decreasing = TRUE), 20)
	mat  <- assay(vsd)[ topVarGenes, ]
	mat  <- mat - rowMeans(mat)
	write.table(as.data.frame(mat), file=sprintf("%sRESULTS_COMPGG/TOPVAR.csv", pathi))
	anno <- as.data.frame(colData(vsd)[, c("Status")])
	png(sprintf("%sRESULTS_COMPGG/pheattotal.png",pathi),width=800, height=800,res = 100)
	print(pheatmap(mat, annotation_col = anno,treeheight_row = 0,treeheight_col = 0))
	dev.off()
	graphics.off()
	#Dispersion
	print("Dispersion")
	png(sprintf("%sRESULTS_COMPGG/dispersion.png",pathi),width=800, height=800,res = 100)
	plotMA(res)
	dev.off()
	graphics.off()
	png(sprintf("%sRESULTS_COMPGG/dispersion2.png",pathi),width=800, height=800,res = 100)
	plotDispEsts(dds)
	dev.off()
	graphics.off()
	#Poisson
	poisd <- PoissonDistance(t(counts(dds)))
	samplePoisDistMatrix <- as.matrix( poisd$dd )
	rownames(samplePoisDistMatrix) <- paste(dds$Run)
	colnames(samplePoisDistMatrix) <- paste(dds$Run)
	png(sprintf("%sRESULTS_COMPGG/poiss.png",pathi),width=800, height=800,res = 100)
	print(pheatmap(samplePoisDistMatrix,clustering_distance_rows = poisd$dd,clustering_distance_cols = poisd$dd))
	dev.off()
	graphics.off()
	##Comparative Pheatmap
	sampleDists <- dist(t(assay(vsd)))
	sampleDistMatrixB <- as.matrix(sampleDists)
	png(sprintf("%sRESULTS_COMPGG/pheatcomp.png",pathi),width=800, height=800,res = 100)
	print(pheatmap(sampleDistMatrixB, clustering_distance_rows = sampleDists, clustering_distance_cols = sampleDists,treeheight_row = 0,treeheight_col = 0))
	dev.off()
	graphics.off()
	#Dendogram
	print("Dendogram")
	data_subset <- as.matrix(coldata[rowSums(coldata)>200000,])
	if(nrow(data_subset)>0){
		my_hclust_gene <- hclust(dist(data_subset), method = "complete")
		png(sprintf("%sRESULTS_COMPGG/dendogram.png",pathi),width=5000, height=7000,res = 100)
		as.dendrogram(my_hclust_gene) %>% plot(horiz = TRUE)
		dev.off()
		graphics.off()
	}
	#Cook
	print("Cook")
	W <- res$stat
	maxCooks <- apply(assays(dds)[["cooks"]],1,max)
	idx <- !is.na(W)
	png(sprintf("%sRESULTS_COMPGG/cook.png",pathi),width=800, height=800,res = 100)
	plot(rank(W[idx]), maxCooks[idx], xlab="rank of Wald statistic",ylab="maximum Cook's distance per gene",ylim=c(0,5), cex=.4, col=heat.colors(10))
	dev.off()
	graphics.off()
	#Vioplot
	print("Vioplot")
	png(sprintf("%sRESULTS_COMPGG/vioplot.png",pathi),width=800, height=800,res = 100)
	vioplot(coldata,ylab="reads",las=2)
	dev.off()
	graphics.off()
	#Histograms
	print("Histograms")
	png(sprintf("%sRESULTS_COMPGG/histop.png",pathi),width=800, height=800,res = 100)
	hist(res$pvalue,breaks=20,col="grey")
	dev.off()
	graphics.off()
	png(sprintf("%sRESULTS_COMPGG/histopadj.png",pathi),width=800, height=800,res = 100)
	hist(res$padj,breaks=20,col="grey")
	dev.off()
	graphics.off()
	#Volcano
	print("Volcano")
	restable <- as.data.frame(res)
	##Select differential expression
	restable$diffexpressed <- "NO"
	restable$diffexpressed[restable$log2FoldChange > 2 & restable$pvalue < 0.05] <- "UP"
	restable$diffexpressed[restable$log2FoldChange < -2 & restable$pvalue < 0.05] <- "DOWN"
	write.table(as.data.frame(restable), file=sprintf("%sRESULTS_COMPGG/RES_DEGcsv.csv", pathi))
	write.csv2(as.data.frame(restable), file=sprintf("%sRESULTS_COMPGG/RES_DEG.csv", pathi))
	##Plot Diff Expression
	mycolors<-c("blue", "red", "black")
	names(mycolors)<-c("DOWN","UP","NO")
	volc1<-ggplot(data=restable, aes(x=log2FoldChange, y=-log10(pvalue), col=diffexpressed)) + geom_point() + theme_minimal()+geom_vline(xintercept=c(-2, 2), col="red")+geom_hline(yintercept=-log10(0.05), col="red")+ scale_color_manual(values=mycolors)
	ggsave(volc1, file=sprintf("%sRESULTS_COMPGG/volcano1.png",pathi),width=10,height=8,limitsize=FALSE)
	restable <- cbind(datalabel = rownames(restable), restable)
	volc2<-ggplot(data=restable, aes(x=log2FoldChange, y=-log10(pvalue), col=diffexpressed, label=datalabel)) + geom_point() + theme_minimal() + geom_text_repel(max.overlaps = 20, box.padding = 0.4, direction='x', hjust = 0.5,angle=90, force=0.5,xlim=c(-Inf,Inf),ylim=c(-Inf,Inf)) + scale_color_manual(values=c("blue", "black", "red")) + geom_vline(xintercept=c(-2, 2), col="red") + geom_hline(yintercept=-log10(0.05), col="red")+ coord_cartesian(clip = "off")
	ggsave(volc2, file=sprintf("%sRESULTS_COMPGG/volcano2.png",pathi),width=10,height=8,limitsize=FALSE)
	#Enchanced Volcano
	keyvals.colour <- ifelse(
		res$log2FoldChange < -2.0, 'blue',
		ifelse(res$log2FoldChange > 2.0, 'red',
			   'black'))
	keyvals.colour[is.na(keyvals.colour)] <- 'black'
	names(keyvals.colour)[keyvals.colour == 'red'] <- 'UP'
	names(keyvals.colour)[keyvals.colour == 'black'] <- 'NO'
	names(keyvals.colour)[keyvals.colour == 'blue'] <- 'DOWN'
	keyvals.shape[is.na(keyvals.shape)] <- 3
	names(keyvals.shape)[keyvals.shape == 3] <- 'Genes'
	names(keyvals.shape)[keyvals.shape == 17] <- 'DJ'
	ev<-EnhancedVolcano(res,
					lab = rownames(res),
					x = 'log2FoldChange',
					y = 'pvalue',
					subtitle = "",
					xlab = bquote(~Log[2]~ 'fold change'),
					title = 'Volcano Plot',
					pCutoff = 1e-05,
					FCcutoff = 1.0,
					pointSize = c(ifelse(names(keyvals.shape) == 'DJ', 5, 1)),
					labSize = 5.0,
					labCol = 'black',
					labFace = 'bold',
					boxedLabels = TRUE,
					colCustom = keyvals.colour,
					colAlpha = c(ifelse(names(keyvals.shape) == 'DJ', 1, 1)),
					legendPosition = 'right',
					legendLabSize = 20,
					legendIconSize = 20.0,
					shapeCustom = keyvals.shape,
					drawConnectors = TRUE,
					widthConnectors = 1.0,
					lengthConnectors = unit(0.5, "npc"),
					arrowheads = FALSE,
					maxoverlapsConnectors = Inf,
					gridlines.major = TRUE,
					gridlines.minor = TRUE,
					border = 'full',
					borderWidth = 2,
					borderColour = 'black')
	ggsave(ev, file=sprintf("%sRESULTS_COMPGG/volcdeg.png",pathi),width=15,height=12,limitsize=FALSE)
	evj<-EnhancedVolcano(res,
					lab = rownames(res),
					x = 'log2FoldChange',
					y = 'pvalue',
					subtitle = "",
					xlab = bquote(~Log[2]~ 'fold change'),
					title = 'Volcano Plot',
					pCutoff = 1e-05,
					FCcutoff = 1.0,
					pointSize = c(ifelse(names(keyvals.shape) == 'DJ', 5, 1)),
					labSize = 5.0,
					labCol = 'black',
					labFace = 'bold',
					boxedLabels = TRUE,
					colCustom = keyvals.colour,
					colAlpha = c(ifelse(names(keyvals.shape) == 'DJ', 1, 1)),
					legendPosition = 'right',
					legendLabSize = 20,
					legendIconSize = 20.0,
					shapeCustom = keyvals.shape,
					drawConnectors = TRUE,
					widthConnectors = 1.0,
					lengthConnectors = unit(0.5, "npc"),
					arrowheads = FALSE,
					maxoverlapsConnectors = Inf,
					gridlines.major = TRUE,
					gridlines.minor = TRUE,
					border = 'full',
					borderWidth = 2,
					borderColour = 'black')
	ggsave(evj, file=sprintf("%sRESULTS_COMPGG/volcjaca.png",pathi),width=15,height=12,limitsize=FALSE)
	assign(prji,coldata)
	write.table(get(prji), file=sprintf("%sCOMPLETENUMREADS.csv", pathi))
	rm(coldata)
	rm(sampleinfo)
	rm(acclist)
	}
