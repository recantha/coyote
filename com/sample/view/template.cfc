<cfcomponent>

	<cffunction name="init" returntype="template">
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="wrapTemplate" returntype="struct" access="public">
		<cfargument name="template" type="string" required="true">
		<cfargument name="combo" type="struct" required="true">

		<cfset var local = {}>

		<cftry>
			<cfinvoke method="#arguments.template#" returnvariable="local.result">
				<cfinvokeargument name="combo" value="#arguments.combo#">
			</cfinvoke>
			
			<cfcatch type="any">
				<cfsavecontent variable="local.result.output">
					<cfoutput>
						<h3>Error - #cfcatch.Message#</h3>
						<cfdump var="#arguments.combo#">
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="sample" returntype="struct" access="private">
		<cfargument name="combo" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				#header(arguments.combo).output#
				#body(arguments.combo).output#
				#footer(arguments.combo).output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="header" returntype="struct" access="private">
		<cfargument name="combo" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<html>
					<head>
						<title>#arguments.combo.content.title#</title>
						<link rel="stylesheet" type="text/css" href="#getSetting('pvc_css')#/main.css" />
						<!--- <link rel="stylesheet" type="text/css" href="#getSetting('recantha_css')#/menu.css" /> --->

						<meta name="description" combo="#arguments.combo.content.headline#" />
						<!--- <script type="text/javascript" src="#getSetting('coyote_js')#/jquery-1.5.1.min.js"></script>
						<script type="text/javascript" src="#getSetting('coyote_js')#/jquery.easing.1.3.js"></script>
						<script type="text/javascript" src="#getSetting('coyote_js')#/jquery.hoverIntent.min.js"></script>
						<script type="text/javascript" src="#getSetting('coyote_js')#/jquery.recantha.menu.js"></script> --->
					</head>
					<body>
						<div class="center_outer site_header">
							<div class="center_inner">
								<a href="/">recantha.co.uk</a>
							</div>
							<div class="clear"></div>
						</div>

						<cfif StructKeyExists(arguments.combo.content, "folder") AND Len(arguments.combo.content.folder.title)>
							<div class="center_outer folder_header">
								<div class="center_inner">
									<a href="#arguments.combo.content.folder.url#"><h1>#arguments.combo.content.folder.title#</h1></a>
								</div>
								<div class="clear"></div>
							</div>
							<div class="clear"></div>
						</cfif>
						<div class="center_outer">
							<div class="center_inner">
								<h2>#arguments.combo.content.title#</h2>
							</div>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="body" returntype="struct" access="private" output="false">
		<cfargument name="combo" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="center_outer">
					<div class="center_inner">
						<cfif Len(arguments.combo.content.headline)>
							<h3>#arguments.combo.content.headline#</h3>
							<div class="clear"></div>
						</cfif>

						<div>#arguments.combo.content.body#</div>
						<cfif Len(arguments.combo.content.code_call)>
							<cftry>
								<cfset local.comp = ListGetAt(arguments.combo.content.code_call, 1, ".")>
								<cfset local.meth = ListGetAt(arguments.combo.content.code_call, 2, ".")>

								<cfinvoke component="#getFactory(local.comp)#" method="#local.meth#" returnvariable="local.call">
									<cfinvokeargument name="combo" value="#arguments.combo#">
								</cfinvoke>
								#local.call.output#

								<cfcatch type="any">
									<cfdump var="#cfcatch#">
								</cfcatch>
							</cftry>
						</cfif>
						<div class="clear"></div>

						<cfif StructKeyExists(arguments.combo, "ebi")>
							<cfif arguments.combo.ebi.success>
								<h4>#arguments.combo.ebi.title#</h4>
								<div>#arguments.combo.ebi.output#</div>
								<div class="clear"></div>
							<cfelse>
								<!--
								#arguments.combo.ebi.output#
								-->
							</cfif>
						</cfif>
						<cfif Len(arguments.combo.inc.output)>
							#arguments.combo.inc.output#
						</cfif>
					</div>

					<!--- 
					<cfif Len(arguments.combo.content.side_title) OR Len(arguments.combo.content.side_body)
							OR Len(arguments.combo.content.side_code_call)
					>
						<div class="main_two">
							<cfif Len(arguments.combo.content.side_title)>
								<h4>#arguments.combo.content.side_title#</h4>
							</cfif>

							<cfif Len(arguments.combo.content.side_body)>
								#arguments.combo.content.side_body#
							</cfif>

							<cfif Len(arguments.combo.content.side_code_call)>
								<cftry>
									<cfset local.comp = ListGetAt(arguments.combo.content.side_code_call, 1, ".")>
									<cfset local.meth = ListGetAt(arguments.combo.content.side_code_call, 1, ".")>
	
									<cfinvoke component="#getFactory(local.comp)#" method="#local.meth#" returnvariable="local.call">
										<cfinvokeargument name="combo" value="#arguments.combo#">
									</cfinvoke>
									#local.call.output#
	
									<cfcatch type="any">
										<cfdump var="#cfcatch#">
									</cfcatch>
								</cftry>
							</cfif>
							<div class="clear"></div>
						</div>
					<cfelse>
					</cfif>
					 --->

					<div class="clear"></div>
				</div>
				<div class="clear"></div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="footer" returntype="struct" access="private">
		<cfargument name="combo" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
					<div class="clear"></div>
					<div class="center" style="z-index:999">
						<div id="footer">
							<div style="float:right">
								#getFactory("glacier.view").glacierIconRoot().output#
							</div>
							<cfif Len(arguments.combo.content.id)>
							<div style="float:right">
								#getFactory("glacier.view").glacierIconEditPage(arguments.combo.content.id).output#
							</div>
							</cfif>
							<div style="float:right">&copy; #year(now())# Michael Horne</div>
							<div class="clear"></div>
						</div>
					</div>
					<div class="clear"></div>
				</body>
			</html>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>

</cfcomponent>