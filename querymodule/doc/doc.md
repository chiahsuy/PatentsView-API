# PatentsView Query Module API

PatentsView is a data visualization and analysis initiative intended to increase the value, utility, and transparency of US patent data.  The PatentsView database longitudinally links inventors, their organizations, addresses and activity using 1976-2014 data from the USPTO.  For more information on the algorithm used to create inventor identities, see [https://github.com/CSSIP-AIR/InventorDisambiguator](https://github.com/CSSIP-AIR/InventorDisambiguator).

The PatentsView API is developed with support of the USPTO and is open to the public.  The API is intended to enable researchers and developers to examine the dynamics of inventor patenting activity over time and space, study regional trends in innovative activity, and track patterns of patent citations.


## Table of Contents

* <a href="#patents_query">Patents Query</a>
	* <a href="#query_string_format">Query String Format</a> 
		* <a href="#query_string_syntax">Syntax</a>
		* <a href="#single_criterion">Single Criterion</a>
		* <a href="#joining_criteria">Joining Criteria</a>
		* <a href="#comparison_operators">Comparison Operators</a>
		* <a href="#negation">Negation</a>
		* <a href="#value_arrays">Value Arrays</a>
		* <a href="#complex_combinations">Complex Combinations</a>
		* <a href="#formats">Formats</a>
	* <a href="#field_list_format">Field List Format</a> 
	* <a href="#options_parameter">Options Parameter</a> 
		* <a href="#pagination">Pagination</a>
		* <a href="#matched_subentities_only">Matched Subentities Only</a>
		* <a href="#include_subentity_total_counts">Include Subentity Total Counts</a>
	* <a href="#sort_parameter">Sort Parameter</a> 
	* <a href="#results_format">Results Format</a> 
		* <a href="#results_format_json">JSON</a>
		* <a href="#results_format_xml">XML</a>
	* <a href="#response_status_codes">Response Status codes</a> 
	* <a href="#patent_field_list">Patent Field List</a> 
* <a href="#inventors_query">Inventors Query</a> 
	* <a href="#inventor_field_list">Inventor Field List</a>
* <a href="#assignees_query">Assignees Query</a> 
	* <a href="#assignee_field_list">Assignee Field List</a>
* <a href="#cpc_subsections_query">CPC Subsections Query</a> 
	* <a href="#cpc_subsection_field_list">CPC Subsection Field List</a>
* <a href="#uspc_mainclasses_query">USPC Mainclasses Query</a> 
	* <a href="#uspc_mainclass_field_list">USPC Mainclass Field List</a>
* <a href="#nber_subcategories_query">NBER Subcategories Query</a> 
	* <a href="#nber_subcategories_field_list">NBER Subcategories Field List</a>
* <a href="#locations_query">Locations Query</a> 
	* <a href="#location_field_list">Location Field List</a>
* <a href="#release_notes">Release Notes</a>


## <a name="patents_query"></a> Patents Query

<code>***GET*** /api/patents/query?q{,f,o,s}</code>

<code>***POST*** /api/patents/query</code>

To access prior or specific versions of the api, insert <code>/vN</code> after <code>api</code> in the URL. For example, 

<code>***GET*** /api/v1/patents/query?q{,f,o,s}</code>

This will search for patents matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>
<tr>
<th>Name</th>
<th>Description</th>
<th>Details</th>
</tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td> string, required<br/> example: <code>q={"inventor_last_name":"Whitney"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to patent_id, patent_number, and patent_title.</td>
<td>string, optional <br/> example: <code>f=["patent_number", "date"]</code></td>
</tr>

<tr>
<td><code>s</code></td>
<td>JSON formatted array of objects to sort the results. if not provided, defaults to the unique, internal patent identifier.</td>
<td>string, optional <br/> example: <code>s=[{"patent_number":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>

<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li><code>json</code></li>
<li><code>xml</code></li>
</ul>
</td>
<td>string, optional <br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/patents/query?q={"_gte":{"patent_date":"2007-01-04"}}&amp;f=["patent_number","patent_date"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/patents/query

with the body containing:

    {"q":{"_gte":{"patent_date":"2007-01-04"}},"f":["patent_number","patent_date"]}

### <a name="query_string_format"></a> Query String Format

The query string is always a single JSON object: `{}`, with properties and contained objects that determine the criteria for the query. 

Note: To aid in understanding the structure of the queries below and while creating your own, it is helpful to use JSON validators and visual parsers, like [http://www.jsoneditoronline.org/](http://www.jsoneditoronline.org/) and [http://jsonlint.com/](http://jsonlint.com/). Clicking on the <span class="fa fa-external-link"></span> icons below display the JSON in JSON Editor Online.

#### <a name="query_string_syntax"></a> Syntax

    q={criterion}
    criterion
        pair
        "_eq" : {simple_pair}
        "_neq" : {simple_pair}
        "_gt" : {simple_pair}
        "_gte" : {simple_pair}
        "_lt" : {simple_pair}
        "_lte" : {simple_pair}
        "_begins" : {simple_pair}
        "_contains" : {simple_pair}
        "_text_all" : {simple_pair}
        "_text_any" : {simple_pair}
        "_text_phrase" : {simple_pair}
        "_not" : {criterion}
        "_and" : [{criterion}, ...]
        "_or" : [{criterion}, ...]
    pair
        simple_pair
        "field" : [value, ...]
    simple_pair
        "field" : value

#### <a name="single_criterion"></a> Single Criterion

The basic criterion, which checks for equality, has the format: `{<field>:<value>}`, where `<field>` is the name of a database field and `<value>` is the value the field will be compared to for equality (see &ldquo;[Field List]()&rdquo; for a list of fields and their value data types). For example, this query string will return the patent with the patent number of 7861317:

`q={"patent_number":"7861317"}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22patent_number%22:7861317}"></a>

#### <a name="joining_criteria"></a> Joining Criteria

There can be multiple criteria within a query by using a join operator (`_and`, `_or`) and putting the criteria in an array using square brackets (&ldquo;`[`&rdquo; and &ldquo;`]`&rdquo;). The following has multiple criteria, and will return patents that have &ldquo;Whitney&rdquo; as an inventor and a grant date of January 4, 2007:

`q={"_and":[{"inventor_last_name":"Whitney"},{"patent_date":"2007-01-04"}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json=={%22_and%22:[{%22inventor_last_name%22:%22Whitney%22},{%22patent_date%22:%222007-01-04%22}]}"></a>

#### <a name="comparison_operators"></a> Comparison Operators

Comparison operators can be used to compare a field to a value using comparators besides just equality. The available comparison operators are:

* Integer, float, date, and string
    * `_eq` &mdash; equal to
    * `_neq` &mdash; not equal to
    * `_gt` &mdash; greater than
    * `_gte` &mdash; greater than or equal to
    * `_lt` &mdash; less than
    * `_lte` &mdash; less than or equal to
* String
    * `_begins` &mdash; the string begins with the value string
    * `_contains` &mdash; the string contains the value string
* Full text
    * `_text_all` &mdash; the text contains all the words in the value string
    * `_text_any` &mdash; the text contains any of the words in the value string
    * `_text_phrase` &mdash; the text contains the exact phrase of the value string

To specify a comparison operator for a criterion, nest the element containing the criterion inside an element that uses the comparison operator. For example, this query string will return all patents that have a grant date on or after January 4, 2007:

`q={"_gte":{"patent_date":"2007-01-04"}}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_gte%22:{%22patent_date%22:%222007-01-04%22}}"></a>

Note that `q={"_eq":{"patent_date":"2007-01-04"}}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_eq%22:{%22patent_date%22:%222007-01-04%22}}"></a> is functionally equivalent to `q={"patent_date":"2007-01-04"}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22patent_date%22:%222007-01-04%22}"></a>.

#### <a name="negation"></a> Negation

Negation does the opposite of the specified comparison. To specify the negation operator for a criterion, nest the element containing the criterion inside an element that uses the negation operator: `_not`. For example, this query string will return all patents that are not design patents:

`q={"_not":{"patent_type":"design"}}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_not%22:{%22patent_type%22:%22design%22}}"></a>

#### <a name="value_arrays"></a> Value Arrays

If the value of a criterion is an array, then the query will accept a match of any one of the array values. For example, this query will return all patents that have &ldquo;Whitney&rdquo; or &ldquo;Hopper&rdquo; as an inventor:

`q={"inventor_last_name":["Whitney","Hopper"]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22inventor_last_name%22:[%22Whitney%22,%22Hopper%22]}"></a>

Note that this is functionally equivalent to: `q={"_or":[{"inventor_last_name":"Whitney"},{"inventor_last_name":"Hopper"}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_or%22:[{%22inventor_last_name%22:%22Whitney%22},{%22inventor_last_name%22:%22Hopper%22}]}"></a>

#### <a name="complex_combinations"></a> Complex Combinations

These elements, criteria, arrays, and operators can be combined to define robust queries. Here are a few examples: 

* Patents with a grant date in 2007.
    * `q={"_and":[{"_gte":{"patent_date":"2007-01-04"}},{"_lte":{"patent_date":"2007-12-31"}}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_and%22:[{%22_gte%22:{%22patent_date%22:%222007-01-04%22}},{%22_lte%22:{%22patent_date%22:%222007-12-31%22}}]}"></a>
* Patents with an inventor with the last name of &ldquo;Whitney&rdquo; or &ldquo;Hopper&rdquo; and not a design patent and with a grant date in 2007.
    * `q={"_and":[{"inventor_last_name":["Whitney","Hopper"]},{"_not":{"patent_type":"design"}},{"_gte":{"patent_date":"2007-01-04"}},{"_lte":{"patent_date":"2007-12-31"}}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_and%22:[{%22inventor_last_name%22:[%22Whitney%22,%22Hopper%22]},{%22_not%22:{%22patent_type%22:%22design%22}},{%22_gte%22:{%22patent_date%22:%222007-01-04%22}},{%22_lte%22:{%22patent_date%22:%222007-12-31%22}}]}"></a>
* Patents with an inventor with the last name of &ldquo;Whitney&rdquo; or &ldquo;Hopper&rdquo; or with a title that contains &ldquo;cotton&rdquo; or &ldquo;gin&rdquo; or &ldquo;COBOL&rdquo;.
    * `q={"_or":[{"inventor_last_name":["Whitney","Hopper"]},{"_text_any":{"patent_title":"COBOL cotton gin"}}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_or%22:[{%22name_last%22:[%22Whitney%22,%22Hopper%22]},{%22_contains%22:{%22title%22:%22cotton%20gin%22}},{%22_contains%22:{%22title%22:%22COBOL%22}}]}"></a>
* Patents with an inventor with the last name of &ldquo;Whitney&rdquo; and with &ldquo;cotton gin&rdquo; in the title, or with an inventor with the last name of &ldquo;Hopper&rdquo; and with &ldquo;COBOL&rdquo; in the title.
    * `q={"_or":[{"_and":[{"inventor_last_name":"Whitney"},{"_text_phrase":{"patent_title":"cotton gin"}}]},{"_and":[{"inventor_last_name":"Hopper"},{"_text_all":{"patent_title":"COBOL"}}]}]}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json=={%22_or%22:[{%22_and%22:[{%22inventor_last_name%22:%22Whitney%22},{%22_text_phrase%22:{%22patent_title%22:%22cotton%20gin%22}}]},{%22_and%22:[{%22inventor_last_name%22:%22Hopper%22},{%22_text_all%22:{%22patent_title%22:%22COBOL%22}}]}]}"></a>

#### <a name="formats"></a> Formats

Dates are expected to be in ISO 8601 date format: YYYY-MM-DD.

### <a name="field_list_format"></a> Field List Format

The field list parameter is a JSON array of the names of the fields to be returned by the query. If not provided, the API will return a default set of fields. See &ldquo;[Field List](#patent_field_list)&rdquo; for the fields available for the results. The following example would return the patent numbers, inventor names, and dates for patents that meet the query criteria:

    f=["patent_number","inventor_last_name","patent_date"]

### <a name="options_parameter"></a> Options Parameter

The options parameter is a JSON formatted object of options to modify the query or results. Available options are:

* `page` and `per_page` &mdash; customize how may patents to return per page and which page.
* `coinventors` - whether coinventor data should be shown when using inventor fields in the query. Defaults to `true` if not provided.
* TBD &mdash; other options, for example other one-to-many relationships like classes, etc.

#### <a name="pagination"></a> Pagination

By default the API will return the first 25 results. The `page` and `per_page` options can be used to customize the set of results that is returned.

* The `page` option is 1-based and omitting the `page` option will return the first page of results.
* The `per_page` option specifies the number of results per page; it defaults to 25 and has a maximum of 10,000.
* An example for specifying pagination in the options parameter is: `o={"page":2,"per_page":50}`

#### <a name="matched_subentities_only"></a> Matched Subentities Only

The `matched_subentities_only` option is provided to indicate whether only those subentities that match their subentity-specific criteria should be included in the results. By default, only those subentities that match their respective query criteria will be included for each parent entity.

This is easiest to understand with an example, so consider this query:

`q={"_and":[{"_gte":{"patent_date":"2007-01-04"}},{"inventor_last_name":"Whitney"}]}&f=["patent_number","patent_date","inventor_last_name"]` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_and%22:[{%22_gte%22:{%22patent_date%22:%222007-01-04%22}},{%22inventor_last_name%22:%22Whitney%22}]}&amp;f=[%22patent_number%22,%22patent_date%22,%22inventor_last_name%22]"></a>

The results will include all the patents that have a grant date on or after January 4, 2007 and with an inventor with the last name &ldquo;Whitney&rdquo;. By default or when `{"matched_subentities_only":true}`, the results will only include the inventor data for the inventor &ldquo;Whitney&rdquo;. However if `{"matched_subentities_only":false}`, the results will include all inventors for the patents, even if their last name was not "Whitney".

__Example__

Consider this example. Assume the database only has the following content:

Patents:

<table>
<tr>
<th>PATENT_NUMBER</th>
<th>NUMBER</th> 
<th>DATE</th>
</tr>

<tr>
<td>PAT1</td>
<td>7861317</td>
<td>1/21/2007</td>
</tr>
</table>

Inventors:

<table>
<tr>
<th>INVENTOR_ID</th><th>PATENT_NUMBER</th><th>NAME_FIRST</th><th>NAME_LAST</th>
</tr>
<tr>
<td>INV1</td><td>pat1</td><td>Grace</td><td>Hopper</td>
</tr>
<tr>
<td>INV2</td><td>pat1</td><td>Eli</td><td>Whitney</td>
</tr>
<tr>
<td>INV3</td><td>pat1</td><td>Willis</td><td>Carrier</td>
</tr>
</table>

Also assume this query:

`q={"_and":[{"_gte":{"patent_date":"2007-01-04"}},{"inventor_last_name":"Whitney"}]}&f=["patent_number","patent_date","inventor_last_name"]` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_and%22:[{%22_gte%22:{%22patent_date%22:%222007-01-04%22}},{%22inventor_last_name%22:%22Whitney%22}]}"></a>

The results would be as such (including only the inventor with the last name of "Whitney"):

`{"patents":[{"patent_number":"pat1","patent_date":"2007-01-27","inventors":[{"inventor_last_name":"Whitney"}]}],"count":1,"total_patent_count":1}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22patents%22:[{%22patent_number%22:%22pat1%22,%22patent_date%22:%222007-01-27%22,%22inventors%22:[{%22inventor_last_name%22:%22Whitney%22}]}],%22count%22:1,%22total_patent_count%22:1}"></a>

However, if the setting was change to `false` like the following, the results would include subentity (i.e. inventor) data:

`q={"_and":[{"_gte":{"patent_date":"2007-01-04"}},{"inventor_last_name":"Whitney"}]}&f=["patent_number","patent_date","inventor_last_name"]&o={"matched_subentities_only":false}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22_and%22:[{%22_gte%22:{%22patent_date%22:%222007-01-04%22}},{%22inventor_last_name%22:%22Whitney%22}]}"></a>

`{"patents":[{"patent_number":"pat1","patent_date":"2007-01-27","inventors":[{"inventor_last_name":"Hopper"},{"inventor_last_name":"Whitney"},{"inventor_last_name":"Carrier"}]}],"count":1,"total_patent_count":1}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22patents%22:[{%22patent_number%22:%22pat1%22,%22patent_date%22:%222007-01-27%22,%22inventors%22:[{%22inventor_last_name%22:%22Hopper%22},{%22inventor_last_name%22:%22Whitney%22},{%22inventor_last_name%22:%22Carrier%22}]}],%22count%22:1,%22total_patent_count%22:1}"></a>

#### <a name="include_subentity_total_counts"></a> Include Subentity Total Counts

The `include_subentity_total_counts` option is provided to indicate whether the query results should include the total counts of unique subentities. By default, these counts are not returned. If `true`, then there will be a count of unique subentities for those subentities that have at least one field included in the result fields. These will be named, e.g., `total_inventor_count`, `total_assignee_count`, etc. 

### <a name="sort_parameter"></a> Sort Parameter

The sort parameter is a JSON formatted array of objects that specifies the sort order for the returned results. If empty or not provided, the default sort order will be ascending by patent number.

Each object in the array should be a pair, with the pair's key is one of the patent fields, and the value is either &ldquo;asc&rdquo; or &ldquo;desc&rdquo;, to indicate ascending or descending sort, respectively. 

All sort fields should be also necessarily included into the field list parameter ("f"). For example, if a user wants to sort all assignee organizations from assignee entity by their associated inventors' last names from inventor subentity, they should make sure that "inventor_last_name" is present in both the field list ("f") and the sort parameter ("s").

A couple examples should suffice for understanding:

* `s=[{"patent_num_claims":"desc"}`
    * Primary sort is by `patent_num_claims` in ascending order, so that patents with the most claims will be first, and those with least claims will be last.
* `s=[{"patent_date":"desc"},{"patent_number":"asc"}]`
    * Primary sort is by `patent_date` in descending order, secondarily by `patent_number` in ascending order.

### <a name="results_format"></a> Results Format

#### <a name="results_format_json"></a> JSON

##### <a name="results_format_json_syntax"></a> Syntax

    {"patents":[patent[,...]], "count":count, "total_patent_count":total_patent_count}
    patent
        {[key_value_pair[,...]][,related_group[,...]]}
    related_group
        "entity_name":[related_entity[,...]]
    related_entity
        {key_value_pair[,...]}
    entity_name
        { inventors | assignees | applications | application_citations | cited_patents | citedby_patents | ipcs | uspc_mainclasses | cpc_subsections }
    key_value_pair
        "field_name":value
            Where field_name is from the table of fields below.

##### <a name="results_format_json_example"></a> Example

`{"patents":[{"patent_number":"pat1","date":"2007-01-27","inventors":[{"inventor_last_name":"Hopper"},{"inventor_last_name":"Whitney"},{"inventor_last_name":"Carrier"}]}],"count":1,"total_patent_count":1}` <a class="fa fa-external-link" href="http://jsoneditoronline.org/?json={%22patents%22:[{%22patent_number%22:%22pat1%22,%22date%22:%222007-01-27%22,%22inventors%22:[{%22inventor_last_name%22:%22Hopper%22},{%22inventor_last_name%22:%22Whitney%22},{%22inventor_last_name%22:%22Carrier%22}]}],%22count%22:1,%22total_patent_count%22:1}"></a>

#### <a name="results_format_xml"></a> XML

##### <a name="results_format_xml_syntax"></a> Syntax

##### <a name="results_format_xml_example"></a> Example

    <root>
        <patents>
            <patent>
                <patent_number>pat1</patent_number>
                <inventors>
                    <inventor>
                        <inventor_last_name>Hopper</inventor_last_name>
                    </inventor>
                    <inventor>
                        <inventor_last_name>Carrier</inventor_last_name>
                    </inventor>
                </inventors>
            </patent>
        </patents>
        <count>1</count>
        <total_patent_count>1</total_patent_count>
    </root>

### <a name="response_status_codes" ></a> Response Status codes

When the query parameters are all valid, the API will return results formatted per &ldquo;[Results Format](#results_format)&rdquo; with an HTTP status code of 200. The results will be in the body of the response.

An HTTP status code of 400 will be returned when the query parameters are not valid, typically either because they are not in valid JSON format, or a specified field or value is not valid. The &ldquo;status reason&rdquo; in the header will contain the error message. 

An HTTP status code of 500 will be returned when there is an internal error with the processing of the query. The &ldquo;status reason&rdquo; in the header will contain the error message.

### <a name="patent_field_list"></a> Patent Field List

<table>
$field_list_header
$patent_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>


## <a name="inventors_query"></a> Inventors Query

<code>***GET*** /api/inventors/query?q{,f,o,s}</code>

<code>***POST*** /api/inventors/query</code>

This will search for inventors matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>

<tr><td>Name</td><td>Description</td><td>Details</td></tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required <br/> example: <code>{"inventor_last_name":"Whitney"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults inventor_id, inventor_first_name, and inventor_last_name.</td>
<td>string, optional <br/> example: <code>["patent_number", "date"]</code></td>
</tr>

<tr>
<td><code>s</code></td>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal inventor identifier.</td>
<td>string, optional <br/> example: <code>[{"inventor_last_name":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>

<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li>json</li>
<li>xml</li>
</ul>
</td>
<td>string, optional <br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/inventors/query?q={"inventor_last_name":"Young"}&f=["inventor_id","inventor_last_name","inventor_first_name","patent_number","patent_date"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/inventors/query

with the body containing:

    {"q":{"inventor_last_name":"Young"},"f":["inventor_id","inventor_last_name","inventor_first_name","patent_number","patent_date"]}

### <a name="inventor_field_list"></a> Inventor Field List

<table>
$field_list_header
$inventor_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="assignees_query"></a> Assignees Query

<code>***GET*** /api/assignees/query?q{,f,o,s}</code>

<code>***POST*** /api/assignees/query</code>

This will search for assignees matching the query string (`q`) and returning the data fields listed in the field string (f) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>

<tr><th>Name</th><th>Description</th><th>Details</th></tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required <br/> example: <code>{"inventor_last_name":"Whitney"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to assignee_id, assignee_first_name, assignee_last_name, and assignee_organization.</td>
<td>string, optional <br/> example: <code>["patent_number", "date"]</code></td>
</tr>

<tr>
<td><code>s</code></td>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal assignee identifier.	string, optional</td>
<td>example: <code>[{"assignee_organization":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>

<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li><code>json</code></li>
<li><code>xml</code></li>
</ul>
</td>
<td>string, optional <br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/assignees/query?q={"_begins":{"assignee_organization":"Race"}}&f=["patent_number","patent_date","assignee_organization","assignee_id"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/assignees/query

with the body containing:

    {"q":{"_begins":{"assignee_organization":"Race"}},"f":["patent_number","patent_date","assignee_organization","assignee_id"]}

### <a name="assignee_field_list"></a> Assignee Field List

<table>
$field_list_header
$assignee_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="cpc_subsections_query"></a> CPC Subsections Query

<code>***GET*** /api/cpc_subsections/query?q{,f,o,s}</code>

<code>***POST*** /api/cpc_subsections/query</code>

This will search for CPC (Cooperative Patent Classification) subsections matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>

<tr>
<th>Name</th>
<th>Description</th>
<th>Details</th>
</tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required<br/> example: <code>{"cpc_subsection_id":"G12"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to cpc_subsection_id and cpc_subsection_title.</td>
<td>string, optional<br/> example: <code>["cpc_subsection_id", "cpc_subsection_title","cpc_total_num_patents"]</code></td>
</tr>

<tr>
<td><code>s</code></td>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal CPC subsection identifier.</td>
<td>string, optional<br/> example: <code>[{"cpc_total_num_patents":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>

<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li><code>json</code></li>
<li><code>xml</code></li>
</ul>
</td>
<td>string, optional<br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/cpc_subsections/query?q={"cpc_subsection_id":"G12"}&f=["cpc_subsection_id","cpc_subsection_title","cpc_total_num_patents"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/cpc_subsections/query

with the body containing:

    {"q":{"cpc_subsection_id":"G12"},"f":["cpc_subsection_id", "cpc_subsection_title","cpc_total_num_patents"]}

### <a name="cpc_subsection_field_list"></a> CPC Subsection Field List

<table>
$field_list_header
$cpc_subsection_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="uspc_mainclasses_query"></a> USPC Mainclasses Query

<code>***GET*** /api/uspc_mainclasses/query?q{,f,o,s}</code>

<code>***POST*** /api/uspc_mainclasses/query</code>

This will search for USPC (United States Patent Classification) mainclasses matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>
<tr>
<th>Name</th>
<th>Description</th>
<th>Details</th>
</tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required<br/> example: <code>{"uspc_mainclass_id":"292"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to uspc_mainclass_id and uspc_mainclass_title.</td>
<td>string, optional<br/> example: <code>["uspc_mainclass_id", "uspc_mainclass_title","uspc_total_num_patents"]</code></td>
</tr>

<tr>
<td><code>s</code></code>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal USPC mainclass identifier.</td>
<td<string, optional<br/> example: <code>[{"uspc_total_num_patents":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>


<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li>json</li>
<li>xml</li>
</ul>
</td>
<td>string, optional<br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/uspc_mainclasses/query?q={"uspc_mainclass_id":"292"}&f=["uspc_mainclass_id","uspc_mainclass_title","uspc_total_num_patents"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/uspc_mainclasses/query

with the body containing:

    {"q":{"uspc_mainclass_id":"292"},"f":["uspc_mainclass_id", "uspc_mainclass_title","uspc_total_num_patents"]}

### <a name="uspc_mainclass_field_list"></a> USPC Mainclass Field List

<table>
$field_list_header
$uspc_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="nber_subcategories_query"></a> NBER Subcategories Query

<code>***GET*** /api/nber_subcategories/query?q{,f,o,s}</code>

<code>***POST*** /api/nber_subcategories/query</code>

This will search for NBER (National Bureau of Economic Research) subcategories matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>

<tr>
<th>Name</th>
<th>Description</th>
<th>Details</th>
</tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required<br/> example: <code>{"nber_subcategory_id":"62"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to nber_subcategory_id and nber_subcategory_title.</td>
<td>string, optional<br/> example: <code>["nber_subcategory_id", "nber_subcategory_title","nber_total_num_patents"]</code></td>
</tr>

<tr>
<td><code>s</code></td>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal NBER subcategory identifier.</td>
<td>string, optional<br/> example: <code>[{"nber_total_num_patents":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>

<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li><code>json</code></li>
<li><code>xml</code></li>
</ul>
</td>
<td>string, optional<br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/nber_subcategories/query?q={"nber_subcategory_id":"62"}&f=["nber_subcategory_id","nber_subcategory_title","nber_total_num_patents"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/nber_subcategories/query

with the body containing:

    {"q":{"nber_subcategory_id":"62"},"f":["nber_subcategory_id", "nber_subcategory_title","nber_total_num_patents"]}

### <a name="nber_subcategories_field_list"></a> NBER Subcategories Field List

<table>

<tr>
$field_list_header
$nber_subcat_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="locations_query"></a> Locations Query

<code>***GET*** /api/locations/query?q{,f,o,s}</code>

<code>***POST*** /api/locations/query</code>

This will search for locations matching the query string (`q`) and returning the data fields listed in the field string (`f`) sorted by the fields in the sort string (`s`) using options provided in the option string (`o`).

The HTTP GET request method is the preferred access mechanism; however when the query parameters exceed a reasonable size (around 2,000 characters), then the POST method can be used. When using the POST method, the query parameters should be embedded within a JSON string within the request body.

<table>
<tr>
<th>Name</th>
<th>Description</th>
<th>Details</th>
</tr>

<tr>
<td><code>q</code></td>
<td>JSON formatted object containing the query parameters. See below for details on formatting this object.</td>
<td>string, required<br/> example: <code>{"location_city":"Mount Airy"}</code></td>
</tr>

<tr>
<td><code>f</code></td>
<td>JSON formatted array of fields to include in the results. If not provided, defaults to location_id, location_city, location_state, and location_country.</td>
<td>string, optional<br/> example: <code>["location_id", "location_city","location_state"]</code></td>
</tr>

<tr>
<td><code>s</code></code>
<td>JSON formatted array of objects to sort the results. If not provided, defaults to the unique, internal inventor identifier.</td>
<td<string, optional<br/> example: <code>[{"location_total_num_inventors":"desc"}]</code></td>
</tr>

<tr>
<td><code>o</code></td>
<td>JSON formatted object of options to modify the query or results.  Available options are:
<ul>
<li>matched_subentities_only &mdash; Whether only subentity data that matches the subentity-specific criteria should be included in the results. Defaults to true.</li>
<li>include_subentity_total_counts &mdash; Whether the total counts of unique subentities should be included in the results. Defaults to false.</li>
<li>page &mdash; return only the Nth page of results. Defaults to 1.</li>
<li>per_page &mdash; the size of each page to return. Defaults to 25.</li>
</ul>
</td>
<td>string, optional <br/> example: <code>o={"matched_subentities_only": "true", "page": 2, "per_page": 50, "include_subentity_total_counts": "false"}</code> </td>
</tr>


<tr>
<td><code>format</code></td>
<td>Specifies the response data format. If not provided, defaults to JSON. Available options are:
<ul>
<li>json</li>
<li>xml</li>
</ul>
</td>
<td>string, optional<br/> example: <code>format=xml</code></td>
</tr>

</table>

An example of a complete API call using the GET verb is:

    https://api.patentsview.org/api/locations/query?q={"location_city":"Mount Airy"}&f=["location_id","location_state","location_total_num_patents"]

An example of the equivalent API call using the POST verb is:

    https://api.patentsview.org/api/locations/query

with the body containing:

    {"q":{"location_city":"Mount Airy"},"f":["location_id", "location_state","location_total_num_patents"]}

### <a name="location_field_list"></a> Location Field List

<table>
$field_list_header
$location_field_list
</table>

<table>
<tr><td>*</td> <td>= unique identifier</td></tr>
<tr><td>**</td> <td>= not yet implemented</td></tr>
</table>

## <a name="release_notes"></a> Release Notes
### Test Version 4, 20150110
* Added at-issue location for inventors and assignees in the patent query
    * assignee_city
    * assignee_country
    * assignee_latitude
    * assignee_location_id
    * assignee_longitude
    * assignee_state
    * inventor_city
    * inventor_country
    * inventor_latitude
    * inventor_location_id
    * inventor_longitude
    * inventor_state
* Added the `include_subentity_total_counts` option
    * __Note__: this could be a breaking change since the old `total_found` field is no longer returned, it will be called, e.g., `total_patent_count`.
* Allow uspc_sequence in the patents query to be used as query criteria

### Test Version 3, 20150102
* Added Locations API
	* As part of implementing the locations API, we removed the following fields:
		* patents query
			* `assignee_city`
			* `assignee_country`
			* `assignee_latitide`
			* `assignee_location_id`
			* `assignee_longitude`
			* `assignee_state`
			* `inventor_city`
			* `inventor_country`
			* `inventor_latitude`
			* `inventor_location_id`
			* `inventor_longitude`
			* `inventor_state`
* Added NBER API and associated fields
* In the inventors query, the locations for assignees will only be those locations the assignee used on the inventor's patents, and vice versa assignee-to-inventors.
* In the `cpc_subsections` and `uspc_mainclass` queries, the inventor and assignee locations will only be those locations the inventors and and assignees used on that patent.
* Changed which fields are returned by default when not explicitly provided
	* If the `f` parameter is not specified on the API call, then the fields that will be returned in the results are:
		* patent query
			* `patent_id`
			* `patent_number`
			* `patent_title`
		* inventors query
			* `inventor_id`
			* `inventor_first_name`
			* `inventor_last_name`
		* assignees query
			* `assignee_id`
			* `assignee_first_name`
			* `assignee_last_name`
			* `assignee_organization`
		* cpc_subsections query
			* `cpc_subsection_id`
			* `cpc_subsection_title`
		* uspc_mainclasses query
			* `uspc_mainclass_id`
			* `uspc_mainclass_title`
		* locations query
			* `location_id`
			* `location_city`
			* `location_state`
			* `location_country`
* Changed `matched_subentities_only` option parameter to default to `true`
* Allow `patent_type` to be queryable
* Changed the `patent_firstnamed_*` fields so there are `patent_firstnamed_assignee_*` and `patent_firstnamed_inventor_*` fields 
* Miscellaneous fields added
	* patents query
		* `assignee_lastknown_location_id`
		* `assignee_sequence`
		* `citedby_patent_id`
		* `cited_patent_id`
		* `inventor_lastknown_location_id`
		* `inventor_sequence`
		* `patent_average_processing_time`
	* inventors query
		* `assignee_lastknown_location_id`
		* `coinventor_lastknown_location_id`
		* `inventor_lastknown_location_id`
	* assignees query
		* `assignee_lastknown_location_id`
		* `inventor_lastknown_location_id`
	* cpc_subsections query
		* `assignee_lastknown_location_id`
		* `inventor_lastknown_location_id`
	* uspc_mainclasses query
		* `assignee_lastknown_location_id`
		* `inventor_lastknown_location_id`
	* locations query
		* `assignee_lastknown_location_id`
		* `citedby_patent_id`
		* `cited_patent_id`
		* `inventor_lastknown_location_id`
* Replaced `*_years_active` fields with `*_first_seen_date` and `*_last_seen_date` fields.
* Improved performance of the cpc_subsections query by restructuring the underlying database and the queries used
* Improved performance of the uspc_mainclasses query by restructuring the underlying database and the queries used
