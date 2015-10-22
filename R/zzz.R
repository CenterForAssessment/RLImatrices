`.onLoad` <- 
function(libname, pkgname) {
}


`.onAttach` <- 
function(libname, pkgname) {
	if (interactive()) {
		packageStartupMessage('RLImatrices ',paste(paste(unlist(strsplit(as.character(packageVersion("RLImatrices")), "[.]")), c(".", "-", ".", ""), sep=""), collapse=""),'  For help type: help("RLImatrices")')
	}
}
