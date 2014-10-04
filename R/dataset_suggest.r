#' Suggest datasets in GBIF.
#' 
#' Search that returns up to 20 matching datasets. Results are ordered by relevance.
#' 
#' @export
#' @template all
#' @template occ
#' @template dataset
#' 
#' @param subtype NOT YET IMPLEMENTED. Will allow filtering of datasets by their 
#'    dataset subtypes, DC or EML.
#' @param continent Not yet implemented, but will eventually allow filtering datasets
#'    by their continent(s) as given in our Continent enum.
#' @param description Return descriptions only (TRUE) or all data (FALSE, default)
#' 
#' @examples \dontrun{
#' # Suggest datasets of type "OCCURRENCE".
#' dataset_suggest(query="Amazon", type="OCCURRENCE")
#' 
#' # Suggest datasets tagged with keyword "france".
#' dataset_suggest(keyword="france")
#' 
#' # Suggest datasets owned by the organization with key 
#' # "07f617d0-c688-11d8-bf62-b8a03c50a862" (UK NBN).
#' dataset_suggest(owningOrg="07f617d0-c688-11d8-bf62-b8a03c50a862")
#' 
#' # Fulltext search for all datasets having the word "amsterdam" somewhere in 
#' # its metadata (title, description, etc).
#' dataset_suggest(query="amsterdam")
#' 
#' # Limited search
#' dataset_suggest(type="OCCURRENCE", limit=2)
#' dataset_suggest(type="OCCURRENCE", limit=2, start=10)
#' 
#' # Return just descriptions
#' dataset_suggest(type="OCCURRENCE", description=TRUE)
#' 
#' # Return metadata in a more human readable way (hard to manipulate though)
#' dataset_suggest(type="OCCURRENCE", pretty=TRUE)
#' 
#' # Search by country code. Lookup isocodes first, and use US for United States
#' isocodes[agrep("UNITED", isocodes$gbif_name),]
#' dataset_suggest(country="US")
#' 
#' # Search by decade
#' dataset_suggest(decade=1980)
#' }

dataset_suggest <- function(query = NULL, country = NULL, type = NULL, subtype = NULL, 
  keyword = NULL, owningOrg = NULL, hostingOrg = NULL, publishingCountry = NULL, 
  decade = NULL, continent = NULL, limit=20, start=NULL, callopts=list(), 
  pretty=FALSE, description=FALSE)
{
  url <- 'http://api.gbif.org/v1/dataset/suggest'
  args <- rgbif_compact(list(q=query,type=type,keyword=keyword,owningOrg=owningOrg,
                       hostingOrg=hostingOrg,publishingCountry=publishingCountry,
                       decade=decade,limit=limit,offset=start))
  tt <- gbif_GET(url, args, callopts)
  
  parse_dataset <- function(x){
    tmp <- rgbif_compact(list(
      key=x$key,
      type=x$type,
      title=x$title,
      hostingOrganization=x$hostingOrganizationTitle,
      hostingOrganizationKey=x$hostingOrganizationKey,
      owningOrganization=x$owningOrganizationTitle,
      owningOrganizationKey=x$owningOrganizationKey,
      publishingCountry=x$publishingCountry
    ))
    data.frame(tmp, stringsAsFactors=FALSE)
  }
  
  if(description){
    out <- vapply(tt, "[[", "", "title")
#     names(out) <- sapply(tt, "[[", "title")
  } else
  {
    if(length(tt)==1){
      out <- parse_dataset(x=tt$results)
    } else
    {
      out <- do.call(rbind.fill, lapply(tt, parse_dataset))
    }
  }
  
  if(pretty){
    printdata <- function(x){    
      cat(
        paste("type:", x$key),
        paste("type:", x$type),
        paste("title:", x$title),
        paste("hostingOrganization:", x$hostingOrganizationTitle),
        paste("hostingOrganizationKey:", x$hostingOrganizationKey),
        paste("owningOrganization:", x$owningOrganizationTitle),
        paste("owningOrganizationKey:", x$owningOrganizationKey), 
        paste("publishingCountry:", x$publishingCountry),
        paste("description:", x$description
        ), "\n", sep="\n")
    }
    if(length(tt)==1){
      invisible(printdata(tt))
    } else
    {
      invisible(lapply(tt, printdata)[[1]])
    }
  } else
  {
    return( out )
  }
}
