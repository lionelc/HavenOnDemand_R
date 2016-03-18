# HPE HavenOnDemand R (prepared for the TopCoder contest)

## Description
 This is the wrapper for R users who have interest in using HPE Haven OnDemand APIs. It provides a straightforward way for calling the APIs directly from R. The connection between your R client and HPE server side is via POST request method. Once you create a HODClient with your apikey, you can call the corresponding API using postHODSync() or postHODAsync(). 
 
 Besides, It also includes i) text index operations: create, add_text_to, and delete text indexes; and ii) some local operations that help you on track with your indexes and HavenOnDemand jobs (especially the async ones).

## Usage

### Installation

R is already capable of providing a developer-friendly way that you can directly install a package from github. Here we go:

```
install.packages("devtools")
library(devtools)
install_github("lionelc/HavenOnDemand_R")
```

### Importing

The standard way: 
```
library(HavenOnDemand)
```
Or
```
require(HavenOnDemand)
```

### Client initialization

```
cl <- HODClient(apikey="your_api_key", version="v1")
```
Alternatively, you can create an empty cient first, and then call the setters:

```
cl <- HODClient()
cl <- setHODApikey(cl, your_apikey)
cl <- setHODVersion(cl, "v1")
```

Note: if you are not a guru in R, please note that it's just the tradition of R for using a style of "cl <- setHODApikey(cl, value)" instead of "cl.setHODApikey(value)". The object-oriented pattern in R unfortunately can't encapsulate methods inside the class. In other APIs of this package, it follows a similar way: the return object would include a client that you can keep the track. 

### Sending synchronous requests 

Basically, once you know the API type (e.g. querytextindex, analyzesentiment, extracttext) and the parameters it asks (check HPE official documents: https://dev.havenondemand.com/apis ), you can freely add them and form your R API call with postHODSync() :

```
result <- postHODSync(cl, "querytextindex", text="California",  indexes="wiki_eng", print="all")
```

Or 

```
param <- list(text="California",  indexes="wiki_eng", print="all")
result <- postHODSync(cl, "querytextindex", param)
```

The parameters can also include a file path, if it is a part of the requirement for a specific API. The return result is a JSON object.

### Parsing the result

R has a good JSON parser as in library "jsonlite", which is adequate for this package. jsonlite is also a dependency for installing this package. 

For synchronous requests, the results would be returned at once. 
```
require(jsonlite)
result_list <- fromJSON(result)
```
A list in R is like a dictionary which is relatively more type-free. As long as you know the response format, you can use "result_list$field_name" to get the corresponding field.

### Sending asynchronous requests

As HPE HavenOnDemand supports both request modes, the usage in R is a little bit more elaborated. Now we don't expect an immediate result (like sync calls in json), and the HODClient actually can helps you keep track with your async jobs. 

```
combobj <- postHODAsync(cl, "querytextindex", "job1")
cl <- combobj$client
```

In this way, you name the job as "job1" so you can keep track on the client, plus the client contains the information of your submitted async job that you can check later. Also, you could use a shortcut to get the status of this async task by checking "combobj$status": 

```
> combobj$status
[1] TRUE
```

### Checking the status/result of asynchronous requests

Once the async job is submitted, a hand-shake is needed for retrieving the status/result. Luckily, the job id from your async request is saved in your client. So,

Check the status (return is a JSON object):
```
status_result <- checkHODStatus(cl, "job1")
```

Check the result (if the job is ready, checkHODStatus() return contains the result too):
```
result <- checkHODResult(cl, "job1")
```




