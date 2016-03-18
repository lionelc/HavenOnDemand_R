HODClient <- setClass(
     # Set the name for the class
     "HODClient",

        # Define the slots
     slots = c(
        apikey = "character",
        jobs = "list",
	    version = "character",
	    indexes = "NULL"
        ),

        # Set the default values for the slots. (optional)
     prototype=list(
	    apikey="",
        jobs=list(),
	    version = "v1",
	    indexes = c()
        ),

        # Make a function that can test to see if the data is consistent.
        # This is not called if you have an initialize function defined!
     validity=function(object)
     {
          if(nchar(object@apikey) <= 0) {
              return("apikey can't be empty")
          }
         return(TRUE)
     }
)

#set api key
setGeneric(name="setHODApikey",
    def=function(theObject,keyVal)
    {
        standardGeneric("setHODApikey")
    }
)

setMethod(f="setHODApikey",
    signature="HODClient",
    definition=function(theObject,keyVal)
    {
        theObject@apikey <- keyVal
        return(theObject)
    }
)

#set api key
setGeneric(name="setHODApiKey",
    def=function(theObject,keyVal)
    {
        standardGeneric("setHODApiKey")
    }
)

setMethod(f="setHODApiKey",
	signature="HODClient",
	definition=function(theObject,keyVal)
	{
    	theObject@apikey <- keyVal
    	return(theObject)
	}
)

#set version
setGeneric(name="setHODVersion",
    def=function(theObject,ver)
    {
        standardGeneric("setHODVersion")
    }
)

setMethod(f="setHODVersion",
    signature="HODClient",
    definition=function(theObject,ver)
    {
		if(ver != "v1" && ver != "v2")
		{
		   stop("Version must be v1 or v2")
		}
        theObject@version <- ver
        return(theObject)
    }
)

setGeneric(name="delHODJobname",
    def=function(theObject, jobname)
    {
        standardGeneric("delHODJobname")
    }
)

setMethod(f="delHODJobname",
    signature="HODClient",
    definition=function(theObject,jobname)
    {
		if(!jobname %in% names(theObject@jobs))
		{
		   stop(paste("jobname", jobname, "not in client"))
		}

		jobind <- which(jobname %in% names(theObject@jobs))
        theObject@jobs <- theObject@jobs[-jobind]
        return(theObject)
    }
)


#postHODSync
setGeneric(name="postHODSync",
    def=function(theObject, jobtype, ..., params=list(), verbose=FALSE)
    {
       standardGeneric("postHODSync")
    }
)

setMethod(f="postHODSync",
   signature="HODClient",
   definition=function(theObject, jobtype, ..., params = list(), verbose=FALSE)
   {
   	   uristr <- "https://api.havenondemand.com/1/api/sync/"
	   uristr <- paste(uristr, jobtype, sep="")
	   uristr <- paste(uristr, theObject@version, sep="/")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- merge(params, list(apikey=theObject@apikey))

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, ..., .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
		print("There is no return from your API call which may be caused by an error. Please check the API name and version: ")
		print(paste("name: ", jobtype, " version: ", theObject@version, sep=""))
		return(NULL)
	   }	
       rr
    }
)

#posting an async job, the return is a combo object (as a list): the updated HODClient and a status as boolean
setGeneric(name="postHODAsync",
    def=function(theObject, jobtype, jobname, ..., params=list(), verbose=FALSE)
    {
        standardGeneric("postHODAsync")
    }
)

setMethod(f="postHODAsync",
    signature="HODClient",
    definition=function(theObject, jobtype, jobname, ..., params = list(), verbose=FALSE)
   {
       uristr <- "https://api.havenondemand.com/1/api/async/"
	   uristr <- paste(uristr, jobtype, sep="")
	   uristr <- paste(uristr, theObject@version, sep="/")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- merge(params, list(apikey=theObject@apikey))

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, ..., .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
			print("There is no return from your API call which may be caused by an error. Please check the API name and version: ")
			print(paste("name: ", jobtype, " version: ", theObject@version, sep=""))
			return(list(client=theObject, status=FALSE))
	   }	
	   #parse the result and get the jobid
	   require(jsonlite)
	   rrlist <- fromJSON(rr)
	   curlist <- list(rrlist$jobID)
	   curlist <- setNames(curlist, c(jobname))

       theObject@jobs <- merge(theObject@jobs, curlist)
	   return(list(client=theObject, status=TRUE))
    }
)

setGeneric(name="checkHODStatus",
    def=function(theObject, jobname, verbose=FALSE)
    {
        standardGeneric("checkHODStatus")
    }
)

setMethod(f="checkHODStatus",
   signature="HODClient",
   definition=function(theObject, jobname, verbose=FALSE)
   {
	   jobnames <- names(theObject@jobs)
	   if(!jobname %in% jobnames)
	   {
		  print(paste("The job name", jobname ,"can't be identified in client. Please check the correct job name/client and try again."))
		  return(NULL)
	   }

	   jobind <- which(jobname %in% jobnames)[1]
	   jobid <- theObject@jobs[[jobind]]

	   uristr <- "https://api.havenondemand.com/1/job/status/"
	   uristr <- paste(uristr, jobid, sep="")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- list(apikey=theObject@apikey)

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || is.logical(rr))
	   {
		print("There is no return from your API call which may be caused by an error. Please check the job name and version: ")
		print(paste("jobname: ", jobname, " version: ", theObject@version, sep=""))
		return(NULL)
	   }
	   rr
    }
)

setGeneric(name="checkHODResult",
    def=function(theObject, jobname, verbose=FALSE)
    {
        standardGeneric("checkHODResult")
    }
)

setMethod(f="checkHODResult",
   signature="HODClient",
   definition=function(theObject, jobname, verbose=FALSE)
   {
	   jobnames <- names(theObject@jobs)
	   if(!jobname %in% jobnames)
	   {
		  print(paste("The job name", jobname ,"can't be identified in client. Please check the correct job name/client and try again."))
		  return(NULL)
	   }

	   jobind <- which(jobname %in% jobnames)[1]
	   jobid <- theObject@jobs[[jobind]]

	   uristr <- "https://api.havenondemand.com/1/job/result/"
	   uristr <- paste(uristr, jobid, sep="")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- list(apikey=theObject@apikey)

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || is.logical(rr))
	   {
		print("There is no return from your API call which may be caused by an error. Please check the job name and version: ")
		print(paste("jobname: ", jobname, " version: ", theObject@version, sep=""))
		return(NULL)
	   }
	   rr
    }
)

setGeneric(name="createHODTextIndex",
    def=function(theObject, indexname, flavor="standard", verbose=FALSE)
    {
        standardGeneric("createHODTextIndex")
    }
)

setMethod(f="createHODTextIndex",
   signature="HODClient",
   definition=function(theObject, indexname, flavor="standard", verbose=FALSE)
   {
   	   if(indexname %in% theObject@indexes)
   	   	   stop(paste("The indexname is already in your HODClient:", indexname))
   	   
	   uristr <- "https://api.havenondemand.com/1/api/sync/"
	   uristr <- paste(uristr, "createtextindex", sep="")
	   uristr <- paste(uristr, theObject@version, sep="/")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- list(apikey=theObject@apikey, index=indexname, flavor=flavor)

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
		print("There is no return from your API call which may be caused by an error or you may have already created an index. Please check the API name and version: ")
		print(paste("name: ", "createtextindex", " version: ", theObject@version, sep=""))
		print("The index was not created when you called API.")
		return(list(client=theObject, status=FALSE))
	   }	
       
       require(jsonlite)
   	   msglist <- fromJSON(rr)
   	   if(!"message" %in% names(msglist) || !"index" %in% names(msglist) || msglist$message != "index created")
   		{
   			stop("The index was not created when you called API.")
   		}
   		
   		indexname <- msglist$index
   		if(!indexname %in% theObject@indexes)
   			theObject@indexes <- c(theObject@indexes, indexname)
   		return(list(client=theObject, status=TRUE))
    }
)

setGeneric(name="addHODToTextIndex",
    def=function(theObject, indexname, ..., verbose=FALSE)
    {
        standardGeneric("addHODToTextIndex")
    }
)

setMethod(f="addHODToTextIndex",
   signature="HODClient",
   definition=function(theObject, indexname, ... , verbose=FALSE)
   {
   	   if(!indexname %in% theObject@indexes)
   	   	    stop(paste("the indexname must be already included in client. Please check the name:", indexname))
   	   
	   uristr <- "https://api.havenondemand.com/1/api/sync/"
	   uristr <- paste(uristr, "addtotextindex", sep="")
	   uristr <- paste(uristr, theObject@version, sep="/")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- list(apikey=theObject@apikey, index=indexname)

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, ..., .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
		print("There is no return from your API call which may be caused by an error. You must have a parameter for file/url/json/reference. Please check the API name and version: ")
		print(paste("name: ", "addtotextindex", " version: ", theObject@version, sep=""))
		return(NULL)
	   }	
       rr
    }
)

setGeneric(name="deleteHODTextIndex",
    def=function(theObject, indexname, verbose=FALSE)
    {
        standardGeneric("deleteHODTextIndex")
    }
)

setMethod(f="deleteHODTextIndex",
   signature="HODClient",
   definition=function(theObject, indexname, verbose=FALSE)
   {
   	   if(!indexname %in% theObject@indexes)
   	   {
   	   	  stop(paste("the indexname must be already included in client. Please check the name:", indexname))
   	   }
   	
	   uristr <- "https://api.havenondemand.com/1/api/sync/"
	   uristr <- paste(uristr, "deletetextindex", sep="")
	   uristr <- paste(uristr, theObject@version, sep="/")

	   if(verbose)
	   {
	       print(paste("API called in https: ", uristr, sep=""))
	   }
	   postparams <- list(apikey=theObject@apikey, index=indexname)

	   require(RCurl)	
	   rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
		print("There is no return from your API call which may be caused by an error or you may not have the index. Please check the API name and version: ")
		print(paste("name: ", "deletetextindex", " version: ", theObject@version, sep=""))
		stop("Deletion unsuccessful!")
	   }	
	   
	   #continue with the 2nd confirmation
	   require(jsonlite)
       confobj <- fromJSON(rr)
       confid <- confobj$confirm
       
       postparams <- merge(postparams, list(confirm=confid))
       rr <- NULL
	   flag <- FALSE
	   			   
	   rr <- tryCatch({
		postForm(uri=uristr, .params=postparams, .checkParams=verbose)
	    }, warning = function(w) {
			warning(w)
			if(verbose)
			{
			    warning("If you are sure your parameter is valid for the API you are calling, just ignore it.")
			}
		}, error = function(err)
		{
			warning(paste("Error: ", err))
			flag <- TRUE
		}, finally = {
		 rr <- NULL
	   })

	   if(!exists("rr") || flag || is.null(rr) || typeof(rr) == "logical")
	   {
		print("There is no return from your API call which may be caused by an error or you may not have the index. Please check the API name and version: ")
		print(paste("name: ", "deletetextindex", " version: ", theObject@version, sep=""))
		print("Deletion unsuccessful!")
		return(list(client=theObject, status=FALSE))
	   }	
	   
	   confobj <- fromJSON(rr)
	   confstat <- confobj$deleted
	   if(confstat)
	   {
	   		tmpind <- which(indexname %in% theObject@indexes)
	   		theObject@indexes <- theObject@indexes[-tmpind]
	   		return(list(client=theObject, status=TRUE))
	   }
	   else
	   {
	   		print(paste("Unsuccessful: return JSON object is ", as.character(rr)))	
	   		return(list(client=theObject, status=FALSE))   
	    }
    }
)





