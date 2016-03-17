# HPE HavenOnDemand R (prepared for the TopCoder contest)

## Description
 This is the wrapper for R users who have interest in using HPE Haven OnDemand APIs. It provides a straightforward way for calling the APIs directly from R. The connection between your R client and HPE server side is via POST connections. Once you create a HODClient with your apikey, you can call the corresponding API using postHODSync() or postHODAsync(). 
 
 Besides, It also includes i) text index operations: create, add_text_to, and delete text indexes; and ii) some local operations that help you on track with your indexes and HavenOnDemand jobs (especially the async ones).

## Usage

### Installation

R is already capable of providing a developer-friendly way that you can directly install a package from github. Here we go:

```
install.packages("devtools")
library(devtools)
install_github("HavenOnDemand_R", "lionelc")
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

cl <- HODClient(apikey="your_api_key", version="v1")



