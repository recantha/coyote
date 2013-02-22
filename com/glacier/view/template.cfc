<cfcomponent>
	<cffunction name="init" returntype="template">
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="wrapTemplate" returntype="struct" access="public">
		<cfargument name="template" type="string" required="true">
		<cfargument name="combo" type="struct" required="true">

		<cfset var local = {}>

		<cfinvoke method="#arguments.template#" returnvariable="local.result">
			<cfinvokeargument name="combo" value="#arguments.combo#">
		</cfinvoke>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="default" returntype="struct" access="private">
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
						<link href="#getSetting('glacier_css')#/glacier.css" rel="stylesheet" type="text/css"></link>

						<script type="text/javascript" src="//code.jquery.com/jquery-1.9.0.min.js"></script>
						<script type="text/javascript" src="#getSetting('coyote_js')#/jquery.cycle.all.min.js"></script>
						<script type="text/javascript" src="#getSetting('coyote_js')#/jquery.validate.pack.js"></script>
						<script type="text/javascript" src="#getSetting('glacier_js')#/jquery.glacier.js"></script>
						<script type="text/javascript" src="#getSetting('glacier_js')#/jquery-impromptu.js"></script>
						<link href="#getSetting('glacier_js')#/jquery-impromptu.css" rel="stylesheet" type="text/css"></link>
					</head>

					<body>
						<div class="center">
							<div id="header">
								<h1><a href="#getSetting('glacier_url_root')#">glacier</a></h1>
								<h2><a href="#getSetting('glacier_url_root')#">content management system</a></h2>

								<div style="float:right">
									<a href="#getSetting('glacier_url_root')#">
										<img src="#getSetting('glacier_img')#/logo_medium.png" height="100">
									</a>
								</div>
								<div class="clear"></div>
							</div>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
				<!-- end header-->
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="body" returntype="struct" access="private">
		<cfargument name="combo" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="center">
					<div class="combo">
						<cfif Len(arguments.combo.ebi.title)>
							<h1>#arguments.combo.ebi.title#</h1>
						<cfelseif arguments.combo.content.success AND Len(arguments.combo.content.title)>
							<h1>#arguments.combo.content.title#</h1>
						</cfif>
						<cfif getFactory("glacier.model").isLoggedIn()>
							<cfif arguments.combo.content.success AND Len(arguments.combo.content.body)>
							#arguments.combo.content.body#
							</cfif>
							#arguments.combo.ebi.output#
						<cfelse>
							#getFactory("glacier.controller").login().output#
						</cfif>
						<div class="clear"></div>
					</div>
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
				<!-- start footer -->
						<div class="clear"></div>
						<div class="center">
							<div class="footer">
								<a href="#getSetting('glacier_url_root')#/logout">logout</a>|
								&copy; 2010 Michael Horne
								<div class="clear"></div>
							</div>
						</div>
					</body>
				</html>
				<!-- end footer -->
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>

</cfcomponent>