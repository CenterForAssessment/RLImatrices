`.onLoad` <-
function(libname, pkgname) {
}


`.onAttach` <-
function(libname, pkgname) {
	if (interactive()) {
		packageStartupMessage('RLImatrices ', paste(paste0(unlist(strsplit(as.character(packageVersion("RLImatrices")), "[.]")), c(".", "-", ".", "")), collapse=""),' (5-28-2020). For help: >help("RLImatrices") or visit https://centerforassessment.github.io/RLImatrices')
	}
}
