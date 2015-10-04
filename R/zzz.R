`.onLoad` <- 
function(libname, pkgname) {
}


`.onAttach` <- 
function(libname, pkgname) {
	if (interactive()) {
		packageStartupMessage('RLIdata ',paste(paste(unlist(strsplit(as.character(packageVersion("RLIdata")), "[.]")), c(".", "-", ".", ""), sep=""), collapse=""),'  For help type: help("RLIdata")')
	}
}
