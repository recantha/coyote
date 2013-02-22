<cfcomponent hint="menu">

	<cffunction name="init" returntype="menu" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="generate" returntype="struct" access="public" output="false">
		<cfargument name="prefix" type="string" required="true" hint="Used for prefixing IDs and class names">
		<cfargument name="configurationFilePath" type="string" required="true" hint="Absolute path to the configuration file">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.config = getFactory("dataTypeConvert.model").xmlFileToStruct(arguments.configurationFilePath)/>
		<cfset local.config = local.config.menu>

		<cfif NOT isArray(local.config.item)>
			<cfset local.tmp = [local.config.item]>
			<cfset local.config.item = local.tmp>
		</cfif>

		<!--- Establish default values where not present --->
		<cfloop from="1" to="#ArrayLen(local.config.item)#" index="local.i">
			<cfset local.item = local.config.item[local.i]>
			<cfif NOT StructKeyExists(local.item, "icon")>
				<cfset local.item.icon = "">
			</cfif>
			<cfif NOT StructKeyExists(local.item, "width")>
				<cfset local.item.width= "24">
			</cfif>
			<cfif NOT StructKeyExists(local.item, "align")>
				<cfset local.item.align = "absmiddle">
			</cfif>

			<cfif StructKeyExists(local.item, "item")>
				<cfif NOT isArray(local.item.item)>
					<cfset local.tmp = local.item.item>
					<cfset local.item.item = [local.tmp]>
				</cfif>
	
				<cfloop from="1" to="#ArrayLen(local.item.item)#" index="local.j">
					<cfset local.subitem = local.item.item[local.j]>
					<cfif NOT StructKeyExists(local.subitem, "icon")>
						<cfset local.subitem.icon = "green_button">
					</cfif>
					<cfif NOT StructKeyExists(local.subitem, "width")>
						<cfset local.subitem.width = "24">
					</cfif>
					<cfif NOT StructKeyExists(local.subitem, "align")>
						<cfset local.subitem.align = "absmiddle">
					</cfif>
					<cfset local.subitem.icon_url = local.config.icon_path & "/#local.subitem.icon#.png">
					<cfset local.item.item[local.j] = local.subitem>
				</cfloop>
			</cfif>

			<cfset local.config.item[local.i] = local.item>
		</cfloop>

		<cfsetting enablecfoutputonly="true">
		<cfsavecontent variable="local.result.output">
			<cfoutput><ul class="jsddm"></cfoutput>
			<cfoutput><li class="first">&nbsp;</li></cfoutput>

			<cfloop from="1" to="#ArrayLen(local.config.item)#" index="local.i">
				<cfset local.showHeadItem = false>
				<cfset local.item = local.config.item[local.i]>

				<cfsavecontent variable="local.subMenu">
					<cfif StructKeyExists(local.item, "item")>
						<cfoutput><ul></cfoutput>
							<cfloop from="1" to="#ArrayLen(local.item.item)#" index="local.j">
								<cfset local.subitem = local.item.item[local.j]>

								<cfif Len(local.subitem.href)>
									<cfset local.showHeadItem = true>
								</cfif>

								<cfif local.subitem.label eq "--SEP--">
									<cfoutput><li>---</li></cfoutput>
								<cfelse>
									<cfoutput><li>#displayItem(local.config, local.subitem).output#</li></cfoutput>
								</cfif>
							</cfloop>
						<cfoutput></ul></cfoutput>
					</cfif>
				</cfsavecontent>

				<cfoutput><li>#displayItem(local.config, local.item).output##local.subMenu#</li></cfoutput>
			</cfloop>
			<cfoutput><div class="clear"></div></ul></cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="displayItem" returntype="struct" access="private" output="false">
		<cfargument name="config" type="struct" required="true">
		<cfargument name="item" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.cfg = arguments.config>
		<cfset local.item = arguments.item>

		<cfsavecontent variable="local.result.output">
			<cfif Len(local.item.label)>
				<cfoutput><a href="#local.item.href#"></cfoutput>
					<cfif Len(local.item.icon)>
						<cfoutput><img src="#local.cfg.icon_path#/#local.item.icon#.png" width="#local.item.width#" align="#local.item.align#" hspace="2" border="0"/></cfoutput>
					</cfif>
					<cfoutput>#local.item.label#</cfoutput>
				<cfoutput></a></cfoutput>
			<cfelse>
				<!--- <cfoutput><img src="#getSetting('urls').resources#/img/icons/blank.png" height="3"/></cfoutput> --->
			</cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>