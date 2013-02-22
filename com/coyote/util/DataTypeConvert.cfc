<cfcomponent name="dataTypeConvert" hint="Convert data type to data type using various functions">

	<cffunction name="init" returntype="DataTypeConvert" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="queryToArray" access="public" returntype="array" output="false">
		<cfargument name="theQuery" required="true" type="query">
		<cfargument name="trimStrings" type="boolean" required="false" default="true">

		<cfset var local = {}>
		<cfset local.result = []>

		<cfloop from="1" to="#arguments.theQuery.recordCount#" index="local.i">
			<cfset local.record = queryRowToStruct(arguments.theQuery, local.i, arguments.trimStrings)>
			<cfset ArrayAppend(local.result, local.record)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="QueryToStruct" access="public" returntype="struct" hint="Converts a query to struct.">
		<cfargument name="query"      required="yes" type="query"  hint="The query to convert.">
		<cfargument name="primaryKey" required="no"  type="string" hint="Column name that contains the primary key." default="">
		<cfargument name="columnList" required="no"  type="string" hint="Comma-delimited list of the query columns." default="">
		<cfargument name="preserveKey" required="no" type="boolean" default="true">

		<cfset var local = {}>
		<cfset local.result = {}>

		<!--- determine query column names --->
		<cfif Len(arguments.columnList)>
			<cfset local.cols = Replace(arguments.columnList, " ", "")>
		<cfelse>
			<cfset local.cols = arguments.query.columnList>
		</cfif>

		<!--- remove primary key --->
		<cfif Len(arguments.primaryKey)>
			<cfset local.usePrimaryKey = true>
	
			<cfset local.pkPosition = ListFindNoCase(local.cols, arguments.primaryKey)>
			<cfif local.pkPosition AND NOT arguments.preserveKey>
				<cfset local.cols = ListDeleteAt(local.cols, local.pkPosition)>
			</cfif>
		<cfelse>
			<cfset local.usePrimaryKey = false>
		</cfif>

		<cfset local.cols = ListToArray(local.cols)>

		<!--- loop thru rows --->
		<cfloop from="1" to="#arguments.query.recordCount#" index="local.i">
			<cfif local.usePrimaryKey>
				<cfset local.key = arguments.query[arguments.primaryKey][local.i]>
			<cfelse>
				<cfset local.key = local.i>
			</cfif>

			<cfset local.newkey = Replace(local.key, ",", "", "ALL")>
			<cfset local.result[local.newkey] = {}>
			
			<!--- this is the big processor hog --->
			<cfloop from="1" to="#ArrayLen(local.cols)#" index="local.n">
				<cfset local.result[local.newkey][local.cols[local.n]] = arguments.query[local.cols[local.n]][local.i]>
			</cfloop>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="queryToDelimitedFile" access="public" returntype="struct" hint="Takes a query and column order and outputs to a file">
		<!--- queryToDelimitedFile(dataQuery,columnOrder,filepath,delimiter) --->
		<cfargument name="dataQuery" type="query" required="true">
		<cfargument name="columnOrder" type="string" required="true">
		<cfargument name="filepath" type="string" required="true" hint="Full path to the file - make sure the extension matches the delimiter. Comma is .csv, tab is .txt">
		<cfargument name="delimiter" type="string" required="false" default="#CHR(9)#">

		<cfset var local = {}>
		<cfset local.result = {success=true}>

		<cfset local.dm = arguments.delimiter>

		<cfset local.outStr = "">
		<cfloop from="1" to="#ListLen(arguments.columnorder)#" index="local.i">
			<cfset local.col = listGetAt(arguments.columnOrder, local.i)>
			<cfif local.i neq 1>
				<cfset local.outStr = local.outStr & local.dm>
			</cfif>
			<cfset local.outStr = local.outStr & local.col>
		</cfloop>
		<cfset local.outStr = local.outStr & CHR(13)>

		<cfloop query="arguments.dataQuery">
			<cfloop from="1" to="#ListLen(arguments.columnorder)#" index="local.i">
				<cfset local.col = listGetAt(arguments.columnOrder, local.i)>

				<cfset local.val = arguments.dataQuery[local.col][arguments.dataQuery.currentRow]>
				<cfif local.i neq 1>
					<cfset local.outStr = local.outStr & local.dm>
				</cfif>
				<cfset local.outStr = local.outStr & local.val>
			</cfloop>
			<cfset local.outStr = local.outStr & CHR(13)>
		</cfloop>

		<cffile action="write" output="#local.outStr#" file="#arguments.filepath#">

		<cfreturn local.result>
	</cffunction>

	<cffunction name="arrayOfStructsToDelimitedFile" access="public" returntype="struct" hint="Same as queryToDelimitedFile but takes array of structs">
		<!--- arrayOfStructsToDelimitedFile(dataArray,fields,filepath,delimiter) --->
		<cfargument name="dataArray" type="array" required="true">
		<cfargument name="fields" type="string" required="true">
		<cfargument name="filepath" type="string" required="true" hint="Full path to the file - make sure the extension matches the delimiter. Comma is .csv, tab is .txt">
		<cfargument name="delimiter" type="string" required="false" default="#CHR(9)#">

		<cfset var local = {}>
		<cfset local.result = {success=true}>

		<cfset local.dm = arguments.delimiter>

		<cfset local.outStr = "">
		<cfloop from="1" to="#ListLen(arguments.fields)#" index="local.i">
			<cfset local.col = listGetAt(arguments.fields, local.i)>
			<cfif local.i neq 1>
				<cfset local.outStr = local.outStr & local.dm>
			</cfif>
			<cfset local.outStr = local.outStr & local.col>
		</cfloop>
		<cfset local.outStr = local.outStr & CHR(13)>

		<cfloop from="1" to="#ArrayLen(arguments.dataArray)#" index="local.a">
			<cfset local.data = arguments.dataArray[local.a]>

			<cfloop from="1" to="#ListLen(arguments.fields)#" index="local.f">
				<cfset local.col = listGetAt(arguments.fields, local.f)>

				<cfset local.val = arguments.dataArray[local.a][local.col]>
				<cfif local.f neq 1>
					<cfset local.outStr = local.outStr & local.dm>
				</cfif>
				<cfset local.outStr = local.outStr & local.val>
			</cfloop>
			<cfset local.outStr = local.outStr & CHR(13)>
		</cfloop>

		<cffile action="write" output="#local.outStr#" file="#arguments.filepath#">

		<cfreturn local.result>
	</cffunction>

	<cffunction name="xmlToStruct" returntype="any" access="public" hint="Faster version of function that works in Railo and CF8">
		<cfargument name="raw" type="any" required="true">
		<cfargument name="parentKey" type="string" required="false" default="root">
		
		<cfset var local = {}>
		<cfset local.maxLoop = 9999>
		<cfset local.data = {}>
		<cfset local.raw = arguments.raw>

		<cfparam name="request.xmlToStructCounter" default="0">
		<cfset request.xmlToStructCounter++>

		<cfset local.keys = StructKeyList(local.raw)>
		<cfloop from="1" to="#ListLen(local.keys)#" index="local.i">
			<cfset local.key = ListGetAt(local.keys, local.i)>

			<cfif request.xmlToStructCounter le local.maxLoop>
				<cfif NOT StructKeyExists(local.data, local.key)>
					<!--- first time you found the key --->
					<!--- recurse --->
					<cfset local.data[local.key] = xmlToStruct(local.raw[local.key])>

					<cfset local.attribs = local.raw[local.key].xmlAttributes>
					<cfset local.attribKeys = StructKeyList(local.attribs)>
					<cfloop list="#local.attribKeys#" index="local.aKey">
						<cfset local.data[local.key][local.aKey] = local.attribs[local.aKey]>
					</cfloop>
				<cfelse>
					<cfif NOT isArray(local.data[local.key])>
						<!--- second time you found the key --->
						<!--- create an array with ONE item in it - the first one you hit --->
						<cfset local.tmp = local.data[local.key]>
						<cfset local.data[local.key] = [local.tmp]>
					</cfif>

					<cfset local.curCnt = ArrayLen(local.data[local.key])>
					<cfset local.nextCnt = local.curCnt + 1>

					<cfset local.nextPass = local.raw[local.key][local.nextCnt]>

					<!--- recurse --->
					<cfset local.nextData = xmlToStruct(local.nextPass)>

					<cfset local.attribs = local.nextPass.xmlAttributes>
					<cfset local.attribKeys = StructKeyList(local.attribs)>
					<cfloop list="#local.attribKeys#" index="local.aKey">
						<cfset local.nextData[local.aKey] = local.attribs[local.aKey]>
					</cfloop>

					<cfset ArrayAppend(local.data[local.key], local.nextData)>
				</cfif>
			</cfif>

		</cfloop>

		<cfreturn local.data>
	</cffunction>

	<cffunction name="xmlToStruct_adobecf" returntype="any" access="public" output="false">
		<cfargument name="raw" type="any" required="true">
		<cfargument name="levelReset" type="boolean" required="false" default="true" hint="Reset the iteration checker to 0 on first call">
		<cfargument name="debug" type="boolean" required="false" default="false">

		<!--- Thou shalt not allow infinite loops in a recursive function --->
		<cfset var local = {
				debug=arguments.debug,
				maxLevel=99999,
				data=structNew(),
				keys=StructKeyList(arguments.raw)
		}>

		<cfparam name="request.level" default="0">
		<cfif arguments.levelReset>
			<cfset request.level = 0>
		</cfif>
		<cfset request.level++>

		<cfif request.level ge local.maxLevel>
			<cfabort showerror="Too many iterations in xmlToStruct()">
		</cfif>

		<!--- If subkeys in the XML... --->
		<cfif Len(local.keys)>
			<cfloop from="1" to="#ListLen(local.keys)#" index="local.keyIndex">
				<cfset local.key = listGetAt(local.keys, local.keyIndex)>

				<!--- Determine which of the duplicate elements in arguments.raw we should convert. e.g. there can be multiple keys with the same name
					in the StructKeyList above --->
				<cfif NOT StructKeyExists(local.data, local.key)>
					<cfset local.elementPosition = 1>
				<cfelseif NOT isArray(local.data[local.key])>
					<cfset local.elementPosition = 2>
				<cfelse>
					<cfset local.elementPosition = ArrayLen(local.data[local.key]) + 1>
				</cfif>

				<!--- no is converted to zero, so code around that. Probably the same can be said about Yes --->
				<cfif CompareNoCase(local.key, "no") eq 0>
					<cfset local.worker = arguments.raw.No[local.elementPosition]>
				<cfelseif CompareNoCase(local.key, "Yes") eq 0>
					<cfset local.worker = arguments.raw.Yes[local.elementPosition]>
				<cfelse>
					<cfset local.worker = arguments.raw[local.key][local.elementPosition]>
				</cfif>

				<!--- <cfif local.debug AND local.key eq "promotion">
					<cfoutput><hr></cfoutput>
					<cfoutput><p>Current element keyed by loop (at position #local.elementPosition#) with key #local.key#</p></cfoutput>
					<cfdump var="#local.worker#">
				</cfif> --->

				<!--- Check to see if the element has already been found and is therefore an array --->
				<cfif NOT StructKeyExists(local.data, local.key)>
					<!--- Must be the first time we found the key --->
					<!--- The key 'NO' is translated to zero, so manually account for it --->
					<cfif local.key eq "no">
						<!--- <cfif local.debug AND local.key eq "promotion">
							<cfoutput><p>First occurence of key (no) #local.key#</p></cfoutput>
						</cfif> --->
						<cfset local.data[local.key] = xmlToStruct(local.worker, false)>
					<cfelse>
						<!--- <cfif local.debug AND local.key eq "promotion">
							<cfoutput><p>First occurence of key #local.key#</p></cfoutput>
						</cfif> --->
						<cfset local.data[local.key] = xmlToStruct(local.worker, false)>
					</cfif>
				<cfelse>
					<!--- The key already exists, so check to see if we've already created the key as an array and then convert if necessary --->
					<cfif NOT isArray(local.data[local.key])>
						<!--- <cfif local.debug AND local.key eq "promotion">
							<cfoutput><p>Second occurence of key #local.key#<br>
							<span style="font-size:xx-small">Key list of current loop structure:<br>#structKeylist(arguments.raw)#</span>
							</p>
							</cfoutput>
						</cfif> --->

						<!--- Create an array, stick the single element in it then swap it in --->
						<cfset local.tmp = [Duplicate(local.data[local.key])]>
						<cfset local.data[local.key] = local.tmp>

						<!--- <cfif local.debug AND local.key eq "promotion">
						<cfdump var="#local.data[local.key]#" label="post-array-conversion">
						</cfif> --->
					</cfif>

					<!--- Convert the sub-structure and add it to the array that now contains element 1 --->
					<cfset ArrayAppend(local.data[local.key], xmlToStruct(local.worker, false))>
					<cfif local.debug AND local.key eq "promotion">
						<!--- <cfoutput><p>Adding additional instance (no #arrayLen(local.data[local.key])#) to data array with key #local.key#</p></cfoutput>
						<cfdump var="#local.data[local.key]#" label="post-add"> --->
					</cfif>
				</cfif>

				<!--- Now allow for xmlText to added to the structure if it exists in the XML --->
				<cfif Len(local.worker.xmlText)>
					<cfset local.text = local.worker.xmlText>
				<cfelse>
					<cfset local.text = "">
				</cfif>

				<!--- <cfif local.debug AND local.key eq "promotion">
					<cfoutput>
						<strong>
						Debug array - #local.key# - isArray?:#isArray(local.data[local.key])# <cfif isArray(local.data[local.key])>#arrayLen(local.data[local.key])#</cfif>
						</strong><br>
					</cfoutput>
				</cfif> --->

				<!--- Check to see if the working structure already has something in it. If it has, then add an attribute, otherwise just set it --->
				<cfset local.text = Trim(local.text)>
				<cfif Len(local.text)>
					<cfif isStruct(local.data[local.key])>
						<cfset local.data[local.key].text = local.text>
						<!--- Debug in case TEXT starts to creep in again --->
						<!--- <cfset local.data[local.key].text2 = "1-" & Len(local.text) & "-" & local.text & Asc(Left(local.text, 1)) & "-1"> --->
					<!---cfelse>
						<cfset local.data[local.key] = local.text--->
					</cfif>
				</cfif>

				<cfif isStruct(local.data[local.key])
						AND StructCount(local.data[local.key]) eq 1
						AND StructKeyList(local.data[local.key]) eq "text"
				>
					<cfset local.data[local.key] = local.data[local.key].text>
				<cfelseif isStruct(local.data[local.key])
						AND StructCount(local.data[local.key]) eq 0
				>
					<cfdump var="#local.data[local.key]#">
					<cfabort showerror="134">
					<cfset local.data[local.key] = "">
				</cfif>
				<!--- <cfif local.debug AND local.key eq "promotion">
					<cfoutput>
						<strong>
						Debug array - #local.key# - isArray?:#isArray(local.data[local.key])# <cfif isArray(local.data[local.key])>#arrayLen(local.data[local.key])#</cfif>
						</strong><br>
					</cfoutput>
				</cfif> --->


				<!--- <cfif local.debug AND local.key eq "promotion">
					<cfoutput><p>
						End of loop - #local.key# - isArray?:#isArray(local.data[local.key])# <cfif isArray(local.data[local.key])>#arrayLen(local.data[local.key])#</cfif>
					</p><hr></cfoutput>
				</cfif> --->
			</cfloop>
		<cfelse>
			<!--- final item --->
		</cfif>

		<!--- Get XML Text or XML attributes for the parent --->
		<cfif StructKeyExists(arguments.raw, "XmlText")>
			<cfif Len(Trim(arguments.raw.xmlText))>
				<cfset local.data.text = arguments.raw.xmlText>
			</cfif>
			<cfloop list="#StructKeyList(arguments.raw.xmlAttributes)#" index="local.attr">
				<cfset local.data[local.attr] = arguments.raw.xmlAttributes[local.attr]>
			</cfloop>

			<!--- compress down when just 'text' --->
			<cfif isStruct(local.data) AND StructCount(local.data) eq 1 AND StructKeyList(local.data) eq "text">
				<cfset local.data = local.data.text>
			<cfelseif isStruct(local.data) AND StructCount(local.data) eq 0>
				<cfset local.data = "">
			</cfif>
		</cfif>

		<!--- dump out a bit
		<cfif isStruct(local.data) AND ListFindNoCase(structKeyList(local.data), "valuePromotions")>
			<cfdump var="#arguments.raw.valuePromotions#">
			<cfdump var="#local.data.valuePromotions#">
		</cfif>--->

		<cfreturn local.data>
	</cffunction>

	<cffunction name="xmlFileToStruct" returntype="struct" access="public" hint="Reads in an XML file and passes it to xmlToStruct() for conversion">
		<cfargument name="filename" type="any" required="true" hint="Fully-qualified path name to .xml file">

		<cfset var local = structNew()>

		<cffile action="read" file="#arguments.filename#" variable="local.raw">

		<cfset local.xml = xmlParse(local.raw)>
		<cfset local.struct = xmlToStruct(local.xml)>

		<cfreturn local.struct>
	</cffunction>

	<cffunction name="structToArray" returntype="array" access="public">
		<cfargument name="structIn" type="struct" required="true">

		<cfset var local = structNew()>
		<cfset local.arrayOut = arrayNew(1)>
		<cfset ArrayAppend(local.arrayOut, arguments.structIn)>

		<cfreturn local.arrayOut>
	</cffunction>

	<cffunction name="structToSortedArray" returntype="array" access="public">
		<!--- structToSortedArray(structIn, sort_by, sort_order) --->
		<cfargument name="structIn" type="struct" required="true">
		<cfargument name="sort_by" type="string" required="true" hint="The field within each struct to sort by">
		<cfargument name="sort_order" type="string" required="false" default="asc">
		<cfargument name="sort_type" type="string" required="false" default="textnocase">

		<cfset var local = {}>
		<cfset local.sorter = {}>
		<cfset local.counter = {}>
		<cfloop list="#structKeyList(arguments.structIn)#" index="local.orig_key">
			<cfset local.sortkey = arguments.structIn[local.orig_key][arguments.sort_by]>
			<cfset local.pkt = arguments.structIn[local.orig_key]>
			
			<cfif NOT StructKeyexists(local.counter, local.sortKey)>
				<cfset local.counter[local.sortKey] = 0>
			</cfif>
			<cfset local.counter[local.sortKey]++>

			<cfif StructKeyExists(local.sorter, local.sortkey)>
				<cfset local.sortkey = local.sortKey & "_" & local.counter[local.sortKey]>
			</cfif>
			
			<cfset local.sorter[local.sortkey] = local.pkt>
		</cfloop>

		<cfset local.key_list = ListSort(StructKeyList(local.sorter), arguments.sort_type, arguments.sort_order)>

		<cfset local.retArray = []>
		<cfloop list="#local.key_list#" index="local.newkey">
			<cfset ArrayAppend(local.retArray, local.sorter[local.newkey])>
		</cfloop>

		<cfreturn local.retArray>
	</cffunction>

	<cffunction name="structDrillForValue" returntype="any" access="public">
		<cfargument name="theStruct" type="struct" required="true">
		<cfargument name="key" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		<cfargument name="debug" type="boolean" required="false" default="false">

		<cfset var local = {}>
		<cfset local.continue = true>

		<!--- Example keys:
			reference - will just get the reference field's value
			publisher.id - will drill into the publisher struct and get the value of the id field
			authors[1].first_name - will get the first_name field value from the first element of the authors array
			authors[1].first_name,authors[1].last_name - will get the first_name and last_name field values from the first authors array element and concat them together using
					the delimiter passed in
			authors[*].first_name - will get all the first_name field values as a delimited list
		 --->

		<!--- 
		<cfif arguments.key eq "authors[1].first_name,authors[1].last_name">
		<cfif arguments.key eq "Change this to the key name for debugging purposes">
		 --->
		<cfif arguments.debug>
			<cfset local.debug = arguments.debug>
		<cfelseif arguments.key eq "Change this to the key name for debugging purposes">
			<cfset local.debug = true>
			<cfoutput><p><strong>full key is #arguments.key#</strong></p></cfoutput>
		<cfelse>
			<cfset local.debug = false>
		</cfif>

		<cfset local.value = "">

		<!--- For multiple keys, loop through them. If a single key, the comma delimiter wont exist and the function just acts on the singleton key --->
		<cfloop list="#arguments.key#" index="local.current_key">
			<cfif local.debug>
				<cfoutput><hr></cfoutput>
				<cfoutput><p>Key singleton is #local.current_key#</p></cfoutput>
			</cfif>

			<!--- For each key, start with the start structure --->
			<cfset local.bit = arguments.theStruct>
			<cfset local.current_key_length = ListLen(local.current_key, ".")>
			<cfloop from="1" to="#local.current_key_length#" index="local.k">
				<cfset local.bit_key = ListGetAt(local.current_key, local.k, ".")>

				<cfif local.debug>
					<cfoutput><p>Bit key: #local.bit_key#</p></cfoutput>
				</cfif>

				<cfif Find("[", local.bit_key)>
					<cfset local.isArray = true>
					<cfset local.bit_index = ListFirst(ListLast(local.bit_key, "["), "]")>
					<cfset local.bit_key = ListFirst(local.bit_key, "[")>

					<cfif local.bit_index eq "*">
						<cfset local.drill_all_bits = true>
					<cfelse>
						<cfset local.drill_all_bits = false>
					</cfif>

				<cfelse>
					<cfset local.isArray = false>
				</cfif>

				<cfif local.debug>
					<cfoutput>
						<p>
							Post-mod bit key: #local.bit_key#
							<cfif local.isArray><br>Bit index: #local.bit_index#</cfif>
						</p>
					</cfoutput>
				</cfif>

				<cfif NOT StructKeyExists(local.bit, local.bit_key)>
					<cfthrow type="application" message="Unable to find key bit #local.bit_key# in key #arguments.key# in that structure in structDrillForValue()">
				<cfelse>
					<cfset local.bit = local.bit[local.bit_key]>

					<cfif local.isArray>
						<cfif NOT isArray(local.bit)>
							<cfthrow type="application" message="structDrillForValue() has found that #local.bit_key# is not an array as expected">

						<cfelseif ArrayLen(local.bit) lt local.bit_index>
							<cfthrow type="application" message="structDrillForValue() has found that #local.bit_key# has only #arrayLen(local.bit)# elements but is looking for element #local.bit_index#">

						<cfelse>
							<cfif local.drill_all_bits>
								<cfset local.rest_of_bit_key = getFactory("stringUtil").ListMid(local.current_key, local.k+1, local.current_key_length, ".")>
								
								<!--- Only going to work with strings. C'est la vie --->
								<cfset local.looped_bit_result = "">
								<cfloop from="1" to="#ArrayLen(local.bit)#" index="local.b">
									<cfset local.sub_value = structDrillForValue(local.bit[local.b], local.rest_of_bit_key)>

									<cfif Len(local.looped_bit_result)>
										<cfset local.looped_bit_result = local.looped_bit_result & arguments.delimiter>
									</cfif>
									<cfset local.looped_bit_result = local.looped_bit_result & local.sub_value>
								</cfloop>

								<cfset local.bit = local.looped_bit_result>
								<cfbreak>

							<cfelse>
								<cfset local.bit = local.bit[local.bit_index]>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
				
				<cfif local.debug>
					<cfoutput>
						<p><em>Current part of the current key (#local.bit_key#) has a value of <cfdump var="#local.bit#" expand="false"></em></p>
					</cfoutput>
				</cfif>
			</cfloop>

			<cfif isStruct(local.bit) OR isArray(local.bit)>
				<cfset ArrayAppend(local.value, local.bit)>
			<cfelse>
				<cfset local.value = Trim(local.value)>

				<!--- Not using listappend as the delimiter COULD be a multi-character delimiter --->
				<cfif Len(local.value)>
					<cfset local.value = local.value & arguments.delimiter>
				</cfif>
				<cfset local.value = local.value & local.bit>
			</cfif>

			<cfif local.debug>
				<cfoutput>
					<p><em>Value of the singleton was <cfdump var="#local.value#" expand="false"></em></p>
				</cfoutput>
			</cfif>
		</cfloop>

		<cfif local.debug>
			<cfoutput><p>structDrillForValue() value is <cfdump var="#local.value#"></p></cfoutput>
			<cfdump var="#arguments#" label="args to structDrillForValue()">
			<cfabort>
		</cfif>

		<cfreturn local.value>
	</cffunction>

	<cffunction name="ensureIsArray" returntype="array" access="public">
		<cfargument name="data" type="any" required="true">

		<cfset var local = {}>
		<cfif isArray(arguments.data)>
			<cfreturn arguments.data>
		<cfelse>
			<cfset local.data = [arguments.data]>
			<cfreturn local.data>
		</cfif>
	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- RemoveInvalidChar --->
	<cffunction name="RemoveInvalidChar" access="private" output="no" returntype="string" hint="Replace all non-ascii characters from XML name.">

		<!--- Function Arguments --->
		<cfargument name="string" required="yes" type="string"  hint="String with the XML name.">

		<cfscript>

			arguments.string = Replace(arguments.string, ":", "_", "ALL");             // Replace character before prefix
			arguments.string = REReplace(arguments.string, "[^[:ascii]]", "_", "ALL"); // Replace all non-ascii character

			/* Return string */
			return arguments.string;

		</cfscript>

	</cffunction>

	<cffunction name="ListDeleteDuplicates" access="private" returnType="string">
		<cfargument name="theList" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">

		<cfset var local = StructNew()>

		<cfset local.returnValue = "">
		<cfset local.arrayList = ListToArray(arguments.theList, arguments.delimiter)>

		<cfloop from="1" to="#ArrayLen(local.arrayList)#" index="local.i">
			<cfif NOT ListFind(local.returnValue, local.arrayList[local.i], arguments.delimiter)>
				<cfset local.returnValue = ListAppend(local.returnValue, local.arrayList[local.i], arguments.delimiter)>
			</cfif>
		</cfloop>
		<cfreturn local.returnValue>
	</cffunction>

	<cffunction name="displayUnknownTypeAsText" returntype="string" access="public">
		<cfargument name="unknown" type="any" required="true">

		<cfif isArray(arguments.unknown)>
			<cfreturn "[array]">
		<cfelseif isStruct(arguments.unknown)>
			<cfreturn "{struct}">
		<cfelseif isQuery(arguments.unknown)>
			<cfreturn "&lt;query&gt;">
		<cfelse>
			<cfreturn arguments.unknown>
		</cfif>
	</cffunction>

	<cffunction name="queryRowToStruct" access="public" returntype="struct" output="false">
		<cfargument name="data" type="query" required="true">
		<cfargument name="row" type="numeric" required="true">
		<cfargument name="trimStrings" type="boolean" required="false" default="true">

		<cfset var local = structNew()>
		<cfset local.result = structNew()>

		<cfloop list="#arguments.data.columnList#" index="local.col">
			<cftry>
				<cfset local.val = arguments.data[local.col][arguments.row]>
				<cfif isBinary(local.val)>
					<cfset local.result[local.col] = local.val>
				<cfelseif arguments.trimStrings>
					<cfset local.result[local.col] = Trim(local.val)>
				<cfelse>
					<cfset local.result[local.col] = local.val>
				</cfif>
				<cfcatch type="any">
					<cfoutput>#local.col#</cfoutput>
					<cfdump var="#arguments.data[local.col]#">
					<cfabort>
				</cfcatch>
			</cftry>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="queryRowsToArray" access="public" returntype="array">
		<cfargument name="data" type="query" required="true">

		<cfset var local = structNew()>
		<cfset local.result = ArrayNew(1)>

		<cfloop query="arguments.data">
			<cfset ArrayAppend(local.result, queryRowToStruct(arguments.data, arguments.data.currentRow))>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getValFromStruct" access="public" returntype="any">
		<cfargument name="theStruct" type="struct" required="true">
		<cfargument name="path" type="string" required="true" hint="wibble.banana.nipton">
		
		<cfset var local = {}>
		<cfset local.wk = arguments.theStruct>
		<cfloop list="#arguments.path#" index="local.bit" delimiters=".">
			<cfif StructKeyExists(local.wk, local.bit)>
				<cfset local.wk = local.wk[local.bit]>
			<cfelse>
				<cfthrow message="Could not find #local.bit# in the struct when searching for #arguments.path#" type="application">
			</cfif>
		</cfloop>
		
		<cfreturn local.wk>
	</cffunction>	

	<cffunction name="arrayOfStructToSimpleJSON" access="public" returntype="string">
		<cfargument name="data" type="array" required="true">
		<cfargument name="keyfield" type="string" required="true">
		<cfargument name="valfield" type="string" required="true">

		<cfset var local = {}>
		<cfset local.json = "">

		<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.i">
			<cfset local.key = arguments.data[local.i][arguments.keyfield]>
			<cfset local.val = arguments.data[local.i][arguments.valfield]>
			
			<cfset local.json = ListAppend(local.json, '"#local.key#":"#local.val#"')>
		</cfloop>
		<cfset local.json = "{#trim(local.json)#}">

		<cfreturn local.json>
	</cffunction>

	<cffunction name="arrayOfStructsToList" access="public" returntype="string">
		<cfargument name="theArray" type="array" required="true">
		<cfargument name="structKey" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">

		<cfset var local = {}>
		<cfset local.list = "">
		
		<cfloop from="1" to="#ArrayLen(arguments.theArray)#" index="local.i">
			<cfset local.val = StructDrillForValue(arguments.theArray[local.i], arguments.structKey, ".")>
			<cfif Len(local.val) eq 0>
				<cfset local.val = " ">
			</cfif>
			<cfset local.list = ListAppend(local.list, local.val, arguments.delimiter)>
		</cfloop>

		<cfreturn local.list>
	</cffunction>

	<cffunction name="arrayOfStructsToSortedArray" access="public" returntype="array">
		<cfargument name="theArray" type="array" required="true">
		<cfargument name="structKey" type="string" required="true">
		<cfargument name="seperator" type="string" required="false" default="^">

		<cfset var local = {}>
		<cfset local.ix_list = "">

		<cftry>
			<cfloop from="1" to="#ArrayLen(arguments.theArray)#" index="local.i">
				<cfset local.val = arguments.theArray[local.i][arguments.structKey]>
				<cfif Len(local.val) eq 0>
					<cfset local.val = " ">
				</cfif>
				<cfset local.ix_list = ListAppend(local.ix_list, local.val & arguments.seperator & local.i, "~")>
			</cfloop>
			<cfset local.ix_sort = ListSort(local.ix_list, "textnocase", "asc", "~")>
			
			<cfset local.sortedArray = []>
			<cfloop list="#local.ix_sort#" index="local.item" delimiters="~">
				<cfset local.keyvalue = ListGetAt(local.item, 1, arguments.seperator)>
				<cfset local.keyindex = ListGetAt(local.item, 2, arguments.seperator)>
				<cfset ArrayAppend(local.sortedArray, arguments.theArray[local.keyindex])>
			</cfloop>
			
			<cfcatch type="any">
				<!--- <cfdump var="#local.ix_sort#">
				<cfdump var="#arguments.thearray#">
				<cfdump var="#cfcatch#"><cfabort> --->
			</cfcatch>
		</cftry>

		<cfreturn local.sortedArray>
	</cffunction>

	<cffunction name="structOfStructsToList" access="public" returntype="string">
		<cfargument name="theStruct" type="struct" required="true">
		<cfargument name="structKey" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">

		<cfset var local = {}>
		<cfset local.list = "">

		<cfset local.theStruct = Duplicate(arguments.theStruct)>

		<cfif structKeyExists(local.theStruct, "order")>
			<cfset local.orderby = local.thestruct.order>
			<cfset StructDelete(local.theStruct, "order")>
		<cfelse>
			<cfset local.orderby = StructkeyList(local.theStruct)>
		</cfif>

		<cfloop list="#local.orderby#" index="local.key">
			<cfif isStruct(local.theStruct[local.key])>
				<cfset local.val = Replace(arguments.theStruct[local.key][arguments.structKey], arguments.delimiter, " ", "ALL")>
				<cfif Len(local.val) eq 0>
					<cfset local.val = " ">
				</cfif>
				<cfset local.list = ListAppend(local.list, local.val, arguments.delimiter)>
			</cfif>
		</cfloop>

		<cfreturn local.list>
	</cffunction>

	<cffunction name="structOfStructsToSortedList" returntype="string" access="public">
		<!--- structOfStructsToSortedList(structIn, sort_by, sort_order, sort_by_list) --->
		<cfargument name="structIn" type="struct" required="true">
		<cfargument name="sort_by" type="string" required="true" hint="The field within each struct to sort by">
		<cfargument name="sort_order" type="string" required="false" default="asc">
		<cfargument name="sort_type" type="string" required="false" default="textnocase">
		<cfargument name="sort_by_list" type="string" required="false" default="" hint="List of struct keys to sort by">

		<cfset var local = {}>
		<cfset local.sorter = {}>
		<cfset local.counter = {}>

		<cfif Len(arguments.sort_by_list)>
			<cfset local.sortList = arguments.sort_by_list>
		<cfelse>
			<cfset local.sortList = StructKeyList(arguments.structIn)>
		</cfif>
		
		<cfloop list="#local.sortList#" index="local.orig_key">
			<cfset local.sortkey = arguments.structIn[local.orig_key][arguments.sort_by]>
			<cfset local.pkt = arguments.structIn[local.orig_key]>
			
			<cfif NOT StructKeyexists(local.counter, local.sortKey)>
				<cfset local.counter[local.sortKey] = 0>
			</cfif>
			<cfset local.counter[local.sortKey]++>

			<cfif StructKeyExists(local.sorter, local.sortkey)>
				<cfset local.sortkey = local.sortKey & "_" & local.counter[local.sortKey]>
			</cfif>

			<cfset local.pkt.___dtc_original_key = local.orig_key>			
			<cfset local.sorter[local.sortkey] = local.pkt>
		</cfloop>

		<cfif Len(arguments.sort_by_list)>
			<cfset local.key_list = local.sort_by_list>
		<cfelse>
			<cfset local.key_list = ListSort(StructKeyList(local.sorter), arguments.sort_type, arguments.sort_order)>
		</cfif>

		<cfset local.retList = "">
		<cfloop list="#local.key_list#" index="local.newkey">
			<cfset local.retList = ListAppend(local.retList, local.sorter[local.newKey].___dtc_original_key)>
		</cfloop>

		<cfreturn local.retList>
	</cffunction>

	<cffunction name="structOfStructsToSubKeySortedList" returntype="string" access="public">
		<cfargument name="structIn" type="struct" required="true">
		<cfargument name="sub_key" type="string" required="true">
		<cfargument name="sort_by_list" type="string" required="false" default="" hint="List of struct keys to sort by">
		<cfargument name="delimiter" type="string" required="false" default=",">

		<cfset var local = {}>

		<cfset local.sortList = arguments.sort_by_list>

		<cfset local.retList = "">
		<cfloop list="#local.sortList#" index="local.orig_key">
			<cfset local.retList = ListAppend(local.retList, arguments.structIn[local.orig_key][arguments.sub_key], arguments.delimiter)>
		</cfloop>

		<cfreturn local.retList>
	</cffunction>

	<cffunction name="arrayOfStructsToStructWithKey" access="public" returntype="struct">
		<!--- getFactory("dataTypeConvert").arrayOfStructsToStructWithKey(inArray,key) --->
		<cfargument name="inArray" type="array" required="true">
		<cfargument name="key" type="string" required="true" hint="Key inside ALL structs in the array to use as the struct entry key">

		<cfset var local = {}>
		<cfset local.outStruct = {}>

		<cfloop from="1" to="#ArrayLen(arguments.inArray)#" index="local.i">
			<cfset local.pkt = arguments.inArray[local.i]>
			<cfset local.outStruct[local.pkt[arguments.key]] = local.pkt>
		</cfloop>

		<cfreturn local.outStruct>
	</cffunction>

	<cffunction name="structOfStructsToArray" access="public" returntype="array">
		<cfargument name="struct_in" type="struct" required="true" hint="The struct to convert">
		<cfargument name="key_order" type="string" required="false" default="" hint="The order of the struct keys for the array as a list - default is blank and it just puts them in in any old order">
		<cfargument name="key_delimiter" type="string" required="false" default="," hint="Delimiter for key_order argument">
		<cfargument name="only_elements_with_subkey" type="string" required="false" default="" hint="Looks for a subkey inside the structs (if that's what they are) inside in_struct. Excludes if not found. Of course, it also excludes any element of struct_in which is NOT a struct at all">

		<cfset var local = {}>

		<cfif NOT Len(arguments.key_order)>
			<cfset local.key_order = StructKeyList(arguments.struct_in)>
		<cfelse>
			<cfset local.key_order = arguments.key_order>
		</cfif>

		<cfset local.array_out = []>
		<cfloop list="#local.key_order#" index="local.key">
			<!--- Here, local.ele could be of ANY type - it is the current element in struct_in indexed by local.key --->
			<cfset local.ele = arguments.struct_in[local.key]>

			<cfif NOT Len(arguments.only_elements_with_subkey)
					OR (
						Len(arguments.only_elements_with_subkey)
						AND isStruct(local.ele)
						AND StructKeyExists(local.ele, arguments.only_elements_with_subkey)
					)
			>
				<cfset ArrayAppend(local.array_out, arguments.struct_in[local.key])>
			</cfif>
		</cfloop>

		<cfreturn local.array_out>
	</cffunction>

	<!--- Copyright Ray Camden - moved here for convenience from his toXML.cfc, then modded for structs of structs and structs with arrays --->
	<cffunction name="structToXML" returnType="string" access="public" output="true" hint="Converts a struct into XML.">
		<cfargument name="data" type="any" required="true">
		<cfargument name="rootelement" type="string" required="false" default="">
		<cfargument name="itemelement" type="string" required="false" default="">
		<cfargument name="includeheader" type="boolean" required="false" default="true">
		
		<cfset var local = {}>
		<cfset local.buffer = createObject('java','java.lang.StringBuffer').init()>
	
		<cfset local.keys = structKeyList(arguments.data)>
		<cfset local.key = "">
	
		<cfif arguments.includeheader>
			<cfset local.buffer.append("<?xml version=""1.0"" encoding=""UTF-8""?>")>
		</cfif>

		<cfif Len(arguments.rootElement)>
			<cfset local.buffer.append("<#arguments.rootelement#>")>
		</cfif>
		<cfif Len(arguments.itemElement)>
			<cfset local.buffer.append("<#arguments.itemelement#>")>
		</cfif>

		<cftry>
			<cfif Len(local.keys)>
				<cfloop list="#local.keys#" index="local.key">
					<cftry>
						<cfif isStruct(arguments.data[local.key])>
							<cfset local.buffer.append(structToXML(data=arguments.data[local.key], rootElement="#local.key#", includeHeader=false))>
						<cfelseif isArray(arguments.data[local.key])>
							<cfloop from="1" to="#arrayLen(arguments.data[local.key])#" index="local.a">
								<cfset local.tmp = {}>
								<cfset local.tmp[local.key] = arguments.data[local.key][local.a]>
								<cfset local.buffer.append(structToXML(data=local.tmp, includeHeader=false))>
							</cfloop>
						<cfelse>
							<cfset local.buffer.append("<#local.key#>#safeText(arguments.data[local.key])#</#local.key#>")>
						</cfif>
		
						<cfcatch type="any">
							<!--- <cfoutput>#local.key# <cfdump var="#arguments.data[local.key]#"></cfoutput>
							<cfdump var="#cfcatch#"> --->
							<cfset local.buffReturn = "">
							<cfrethrow>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
	
			<cfif Len(arguments.itemElement)>
				<cfset local.buffer.append("</#arguments.itemelement#>")>
			</cfif>
			<cfif Len(arguments.rootElement)>
				<cfset local.buffer.append("</#arguments.rootelement#>")>
			</cfif>
			
			<cfset local.buffReturn = local.buffer.toString()>
			<cfcatch type="any">
				<cfset local.buffReturn = "">
			</cfcatch>
		</cftry>

		<cfset local.bufString = local.buffer.toString()>
		
		<cfset local.buffer = javaCast("null", "")>

		<cfreturn local.bufString>
	</cffunction>

	<!--- Fix damn smart quotes. Thank you Microsoft! --->
	<!--- This line taken from Nathan Dintenfas' SafeText UDF --->
	<!--- www.cflib.org/udf.cfm/safetext --->
	<!--- I wrapped up both xmlFormat and this code together. --->
	<cffunction name="safeText" returnType="string" access="private" output="false">
		<cfargument name="txt" type="string" required="true">
		<cfset arguments.txt = unicodeWin1252(arguments.txt)>
		<cfreturn xmlFormat(arguments.txt)>
	</cffunction>
	
	<!--- This method written by Ben Garret (http://www.civbox.com/) --->
	<cffunction name="UnicodeWin1252" hint="Converts MS-Windows superset characters (Windows-1252) into their XML friendly unicode counterparts" returntype="string">
		<cfargument name="value" type="string" required="yes">
		<cfscript>
			var string = value;
			string = replaceNoCase(string,chr(8218),'&##8218;','all');
			string = replaceNoCase(string,chr(402),'&##402;','all');
			string = replaceNoCase(string,chr(8222),'&##8222;','all');
			string = replaceNoCase(string,chr(8230),'&##8230;','all');
			string = replaceNoCase(string,chr(8224),'&##8224;','all');
			string = replaceNoCase(string,chr(8225),'&##8225;','all');
			string = replaceNoCase(string,chr(710),'&##710;','all');
			string = replaceNoCase(string,chr(8240),'&##8240;','all');
			string = replaceNoCase(string,chr(352),'&##352;','all');
			string = replaceNoCase(string,chr(8249),'&##8249;','all');
			string = replaceNoCase(string,chr(338),'&##338;','all');
			string = replaceNoCase(string,chr(8216),'&##8216;','all');
			string = replaceNoCase(string,chr(8217),'&##8217;','all');
			string = replaceNoCase(string,chr(8220),'&##8220;','all');
			string = replaceNoCase(string,chr(8221),'&##8221;','all');
			string = replaceNoCase(string,chr(8226),'&##8226;','all');
			string = replaceNoCase(string,chr(8211),'&##8211;','all');
			string = replaceNoCase(string,chr(8212),'&##8212;','all');
			string = replaceNoCase(string,chr(732),'&##732;','all');
			string = replaceNoCase(string,chr(8482),'&##8482;','all');
			string = replaceNoCase(string,chr(353),'&##353;','all');
			string = replaceNoCase(string,chr(8250),'&##8250;','all');
			string = replaceNoCase(string,chr(339),'&##339;','all');
			string = replaceNoCase(string,chr(376),'&##376;','all');
			string = replaceNoCase(string,chr(376),'&##376;','all');
			string = replaceNoCase(string,chr(8364),'&##8364','all');
		</cfscript>
		<cfreturn string>
	</cffunction>

	<!--- Ben Nadel --->
	<cffunction name="reSplit" access="public" returntype="array" output="false" hint="I split the given string using the given Java regular expression.">
		<!--- Define arguments. --->
		<cfargument name="regex" type="string" required="true" hint="I am the regular expression being used to split the string."/>
		<cfargument name="value" type="string" required="true" hint="I am the string being split."/>
	 
		<!--- Define the local scope. --->
		<cfset var local = {} />
	 
		<!---
			Get the split functionality from the core Java script. I am
			using JavaCast here as a way to alleviate the fact that I'm
			using *undocumented* functionality... sort of.
	 
			The -1 argument tells the split() method to include trailing
			parts that are empty.
		--->
		<cfset local.parts = javaCast( "string", arguments.value ).split(
			javaCast( "string", arguments.regex ),
			javaCast( "int", -1 )
			) />
	 
		<!---
			We now have the individual parts; however, the split()
			method does not return a ColdFusion array - it returns a
			typed String[] array. We now have to convert that to a
			standard ColdFusion array.
		--->
		<cfset local.result = [] />
	 
		<!--- Loop over the parts and append them to the results. --->
		<cfloop
			index="local.part"
			array="#local.parts#">
	 
			<cfset arrayAppend( local.result, local.part ) />
	 
		</cfloop>

		<!--- Return the result. --->
		<cfreturn local.result />
	</cffunction>
 
	<!--- 
		Author: Ben Nadel / Kinky Solutions
		http://www.bennadel.com/index.cfm?event=blog.view&id=2041
		Oct 22, 2010 at 5:37 PM
	--->
	
	<cffunction name="csvToArray" access="public" returntype="array" output="false" hint="I take a CSV file or CSV data value and convert it to an array of arrays based on the given field delimiter. Line delimiter is assumed to be new line / carriage return related.">
		<!--- csvToArray(file,csv,delimiter,trim) --->
		<!--- Define arguments. --->
		<cfargument	name="file"	type="string"	required="false"	default=""	hint="I am the optional file containing the CSV data."/>
		<cfargument name="csv" type="string" required="false" default="" hint="I am the CSV text data (if the file argument was not used)."/>
		<cfargument name="delimiter" type="string" required="false" default="," hint="I am the field delimiter (line delimiter is assumed to be new line / carriage return)."/>
		<cfargument name="trim" type="boolean" required="false" default="true" hint="I flags whether or not to trim the END of the file for line breaks and carriage returns."/>

		<!--- Define the local scope. --->
		<cfset var local = {} />

		<!---
			Check to see if we are using a CSV File. If so, then all we
			want to do is move the file data into the CSV variable. That
			way, the rest of the algorithm can be uniform.
		--->
		<cfif len( arguments.file )>
	 
			<!--- Read the file into Data. --->
			<cfset arguments.csv = fileRead( arguments.file ) />
	 
		</cfif>
	 
		<!---
			ASSERT: At this point, no matter how the data was passed in,
			we now have it in the CSV variable.
		--->
	 
		<!---
			Check to see if we need to trim the data. Be default, we are
			going to pull off any new line and carraige returns that are
			at the end of the file (we do NOT want to strip spaces or
			tabs as those are field delimiters).
		--->
		<cfif arguments.trim>
	 
			<!--- Remove trailing line breaks and carriage returns. --->
			<cfset arguments.csv = reReplace(
				arguments.csv,
				"[\r\n]+$",
				"",
				"all"
				) />
	 
		</cfif>
	 
		<!--- Make sure the delimiter is just one character. --->
		<cfif (len( arguments.delimiter ) neq 1)>
	 
			<!--- Set the default delimiter value. --->
			<cfset arguments.delimiter = "," />
	 
		</cfif>
	 
	 
		<!---
			Now, let's define the pattern for parsing the CSV data. We
			are going to use verbose regular expression since this is a
			rather complicated pattern.
	 
			NOTE: We are using the verbose flag such that we can use
			white space in our regex for readability.
		--->
		<cfsavecontent variable="local.regEx">(?x)
			<cfoutput>
	 
				<!--- Make sure we pick up where we left off. --->
				\G
	 
				<!---
					We are going to start off with a field value since
					the first thing in our file should be a field (or a
					completely empty file).
				--->
				(?:
	 
					<!--- Quoted value - GROUP 1 --->
					"([^"]*+ (?>""[^"]*+)* )"
	 
					|
	 
					<!--- Standard field value - GROUP 2 --->
					([^"\#arguments.delimiter#\r\n]*+)
	 
				)
	 
				<!--- Delimiter - GROUP 3 --->
				(
					\#arguments.delimiter# |
					\r\n? |
					\n |
					$
				)
	 
			</cfoutput>
		</cfsavecontent>
	 
		<!---
			Create a compiled Java regular expression pattern object
			for the experssion that will be parsing the CSV.
		--->
		<cfset local.pattern = createObject(
			"java",
			"java.util.regex.Pattern"
			).compile(
				javaCast( "string", local.regEx )
				)
			/>
	 
		<!---
			Now, get the pattern matcher for our target text (the CSV
			data). This will allows us to iterate over all the tokens
			in the CSV data for individual evaluation.
		--->
		<cfset local.matcher = local.pattern.matcher(
			javaCast( "string", arguments.csv )
			) />
	 
	 
		<!---
			Create an array to hold the CSV data. We are going to create
			an array of arrays in which each nested array represents a
			row in the CSV data file. We are going to start off the CSV
			data with a single row.
	 
			NOTE: It is impossible to differentiate an empty dataset from
			a dataset that has one empty row. As such, we will always
			have at least one row in our result.
		--->
		<cfset local.csvData = [ [] ] />
	 
		<!---
			Here's where the magic is taking place; we are going to use
			the Java pattern matcher to iterate over each of the CSV data
			fields using the regular expression we defined above.
	 
			Each match will have at least the field value and possibly an
			optional trailing delimiter.
		--->
		<cfloop condition="local.matcher.find()">
	 
			<!---
				Next, try to get the qualified field value. If the field
				was not qualified, this value will be null.
			--->
			<cfset local.fieldValue = local.matcher.group(
				javaCast( "int", 1 )
				) />
	 
			<!---
				Check to see if the value exists in the local scope. If
				it doesn't exist, then we want the non-qualified field.
				If it does exist, then we want to replace any escaped,
				embedded quotes.
			--->
			<cfif structKeyExists( local, "fieldValue" )>
	 
				<!---
					The qualified field was found. Replace escpaed
					quotes (two double quotes in a row) with an unescaped
					double quote.
				--->
				<cfset local.fieldValue = replace(
					local.fieldValue,
					"""""",
					"""",
					"all"
					) />
	 
			<cfelse>
	 
				<!---
					No qualified field value was found; as such, let's
					use the non-qualified field value.
				--->
				<cfset local.fieldValue = local.matcher.group(
					javaCast( "int", 2 )
					) />
	 
			</cfif>
	 
			<!---
				Now that we have our parsed field value, let's add it to
				the most recently created CSV row collection.
			--->
			<cfset arrayAppend(
				local.csvData[ arrayLen( local.csvData ) ],
				local.fieldValue
				) />
	 
			<!---
				Get the delimiter. We know that the delimiter will always
				be matched, but in the case that it matched the end of
				the CSV string, it will not have a length.
			--->
			<cfset local.delimiter = local.matcher.group(
				javaCast( "int", 3 )
				) />
	 
			<!---
				Check to see if we found a delimiter that is not the
				field delimiter (end-of-file delimiter will not have
				a length). If this is the case, then our delimiter is the
				line delimiter. Add a new data array to the CSV
				data collection.
			--->
			<cfif (
				len( local.delimiter ) &&
				(local.delimiter neq arguments.delimiter)
				)>
	 
				<!--- Start new row data array. --->
				<cfset arrayAppend(
					local.csvData,
					arrayNew( 1 )
					) />
	 
			<!--- Check to see if there is no delimiter length. --->
			<cfelseif !len( local.delimiter )>
	 
				<!---
					If our delimiter has no length, it means that we
					reached the end of the CSV data. Let's explicitly
					break out of the loop otherwise we'll get an extra
					empty space.
				--->
				<cfbreak />
	 
			</cfif>
	 
		</cfloop>

		<!---
			At this point, our array should contain the parsed contents
			of the CSV value as an array of arrays. Return the array.
		--->
		<cfreturn local.csvData />
	</cffunction>

	<cffunction name="toXML" returntype="string" access="public" output="no" hint="Recursively converts any kind of data to xml">
		<cfargument name="data" type="any" required="yes" />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" hint="Optional string like 'order=2', which will be added into the starting rootElement tag." />
		<cfargument name="addXMLHeader" type="boolean" required="no" default="true" hint="Whether or not to add the &lt;?xml?&gt; tag" />
		<cfset var returnValue = "" />
		<cfif Len(arguments.elementattributes)>
			<cfset arguments.elementattributes = " " & Trim(arguments.elementattributes) />
		</cfif>
		<cfsavecontent variable="returnValue"><!---
			---><cfoutput><!---
				---><cfif arguments.addXMLHeader><!---
					---><?xml version="1.0" encoding="UTF-8"?><!---
				---></cfif><!---
				---><cfif IsSimpleValue(arguments.data)><!---
					--->#$simpleValueToXml(argumentCollection=arguments)#<!---
				---><cfelseif IsQuery(arguments.data)><!---
					--->#$queryToXML(argumentCollection=arguments)#<!---
				---><cfelseif IsArray(arguments.data)><!---
					--->#$arrayToXML(argumentCollection=arguments)#<!---
				---><cfelseif IsObject(arguments.data)><!---
					--->#$objectToXML(argumentCollection=arguments)#<!---
				---><cfelseif IsStruct(arguments.data)><!---
					--->#$structToXML(argumentCollection=arguments)#<!---
				---><cfelseif REFindNoCase("^coldfusion\..*Exception$", arguments.data.getClass().getName())><!---
					--->#$structToXML(argumentCollection=arguments)#<!---
				---><cfelse><!---
					--->#$simpleValueToXml(data="Unknown object of type #arguments.data.getClass().getName()#", rootelement=arguments.rootelement, elementattributes=arguments.elementattributes)#<!---
				---></cfif><!---
			---></cfoutput><!---
		---></cfsavecontent>
		<cfreturn returnValue />
	</cffunction>
	
	<cffunction name="$simpleValueToXml" access="public" output="false" returntype="string">
		<cfargument name="data" type="string" required="true" />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" />
		<cfset var returnValue = "" />
		<cfset arguments.data = XmlFormat(arguments.data) />
		<cfsavecontent variable="returnValue"><!---
			---><cfoutput><!---
				---><cfif IsNumeric(arguments.data)><!---
					---><#arguments.rootelement# type="numeric"#arguments.elementattributes#>#arguments.data#</#arguments.rootelement#><!---
				---><cfelseif IsBoolean(arguments.data)><!---
					---><#arguments.rootelement# type="boolean"#arguments.elementattributes#><cfif arguments.data>1<cfelse>0</cfif></#arguments.rootelement#><!---
				---><cfelseif not Len(arguments.data)><!---
					---><#arguments.rootelement# type="string"#arguments.elementattributes#/><!---
				---><cfelse><!---
					---><#arguments.rootelement# type="string"#arguments.elementattributes#>#arguments.data#</#arguments.rootelement#><!---
				---></cfif><!---
			---></cfoutput><!---
		---></cfsavecontent>
		<cfreturn returnValue />
	</cffunction>
	
	<cffunction name="$arrayToXML" access="public" output="false" returntype="string" hint="Converts an array into XML">
		<cfargument name="data" type="array" required="true" />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" />
		<cfargument name="itemelement" type="string" required="false" default="item" />
		<cfset var loc = {} />
		
		<cfsavecontent variable="loc.returnValue"><!---
			---><cfoutput><!---
				---><#arguments.rootelement# type="array"#elementattributes#><!---
					---><cfloop from="1" to="#ArrayLen(arguments.data)#" index="loc.x"><!---
						--->#toXML(data=arguments.data[loc.x], rootelement=arguments.itemelement, elementattributes="order=""#loc.x#""", addXMLHeader=false)#<!---
					---></cfloop><!---
				---></#arguments.rootelement#><!---
			---></cfoutput><!---
		---></cfsavecontent>
		
		<cfreturn loc.returnValue />
	</cffunction>
	
	<cffunction name="$queryToXML" access="public" output="false" returntype="string" hint="Converts a query to XML">
		<cfargument name="data" type="query" required="true" />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" />
		<cfargument name="itemelement" type="string" required="false" default="row" />
		<cfset var loc = {} />
		<cfset loc.columns = arguments.data.columnList />
		
		<cfsavecontent variable="loc.returnValue"><!---
			---><cfoutput><!---
				---><#arguments.rootelement# type="query"#arguments.elementattributes#><!---
					---><cfloop query="arguments.data"><!---
						---><#arguments.itemelement# order="#arguments.data.currentrow#"><!---
							---><cfloop list="#loc.columns#" index="loc.col"><!---
								--->#toXML(data=arguments.data[loc.col][arguments.data.currentRow], rootElement=loc.col, addXMLHeader=false)#<!---
							---></cfloop><!---
						---></#arguments.itemelement#><!---
					---></cfloop><!---
				---></#arguments.rootelement#><!---
			---></cfoutput><!---
		---></cfsavecontent>

		<cfreturn loc.returnValue />
	</cffunction>
	
	<cffunction name="$structToXML" access="public" output="false" returntype="string" hint="Converts a struct into XML.">
		<cfargument name="data" type="any" required="true" hint="It should be a struct, but can also be an 'exception' type." />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" />
		<cfset var loc = {} />
		<cfset loc.keys = StructKeyList(arguments.data) />
		
		<cfsavecontent variable="loc.returnValue"><!---
			---><cfoutput><!---
				---><#arguments.rootelement# type="struct"#arguments.elementattributes#><!---
					---><cfloop list="#loc.keys#" index="loc.key"><!---
						--->#toXML(data=arguments.data[loc.key], rootelement=loc.key, addXMLHeader=false)#<!---
					---></cfloop><!---
				---></#arguments.rootelement#><!---
			---></cfoutput><!---
		---></cfsavecontent>
		
		<cfreturn loc.returnValue />
	</cffunction>
	
	<cffunction name="$objectToXML" access="public" output="false" returntype="string" hint="Converts a struct into XML.">
		<cfargument name="data" type="component" required="true" hint="It should be a struct, but can also be an 'exception' type." />
		<cfargument name="rootelement" type="string" required="false" default="data" />
		<cfargument name="elementattributes" type="string" required="false" default="" />
		<cfset var loc = {} />
		<cfset loc.keys = ListSort(StructKeyList(arguments.data), "textnocase", "asc") />
		<cfset loc.name = GetMetaData(arguments.data).name/>
		
		<cfsavecontent variable="loc.returnValue"><!---
			---><cfoutput><!---
				---><#arguments.rootelement# type="component" name="#loc.name#"#arguments.elementattributes#><!---
					---><cfloop list="#loc.keys#" index="loc.key"><!---
						---><cfif !IsCustomFunction(arguments.data[loc.key])><!---
							--->#toXML(data=arguments.data[loc.key], rootelement=loc.key, addXMLHeader=false)#<!---
						---></cfif><!---
					---></cfloop><!---
				---></#arguments.rootelement#><!---
			---></cfoutput><!---
		---></cfsavecontent>
		
		<cfreturn loc.returnValue />
	</cffunction>

</cfcomponent>