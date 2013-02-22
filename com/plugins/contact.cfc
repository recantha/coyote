<cfcomponent>

	<cffunction name="init" returntype="contact" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="contactForm" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.scope = getScope()>

		<cfset local.leftSideInt = RandRange(1, 10)>
		<cfset local.rightSideInt = RandRange(1, 10)>

		<cfset local.leftSideEnc = "artichoke">
		<cfset local.rightSideEnc = "crank">

		<cfset local.leftSideMultiply = 4>
		<cfset local.rightSideMultiply = 6>

		<cfset local.leftSide = Encrypt(local.leftSideInt*local.leftSideMultiply, local.leftSideEnc)>
		<cfset local.rightSide = Encrypt(local.rightSideInt*local.rightSideMultiply, local.rightSideEnc)>

		<cfif NOT StructKeyExists(local.scope, "submit")>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<form action="#local.scope.script_name#" method="post">
						<div class="fieldlabel">Your name</div>
						<div class="fieldinput"><input name="name" id="name"></div>
						<div class="clear"></div>
		
						<div class="fieldlabel">Your email</div>
						<div class="fieldinput"><input name="email" id="email"></div>
						<div class="clear"></div>
		
						<div class="fieldlabel">Your message</div>
						<div class="fieldinput"><textarea name="message" cols="100" rows="50"></textarea></div>
						<div class="clear"></div>
		
						<div class="fieldlabel">Prove you are human!</div>
						<div class="fieldinput">#local.leftSideInt#+#local.rightSideInt# = <input type="text" name="human"></div>
						<input type="hidden" name="human2" value="#URLEncodedFormat(local.rightSide & '~~~' & local.leftSide)#">
		
						<div class="fieldlabel"></div>
						<div class="fieldinput"><input type="submit" name="submit" value="Send message" class="submit"></div>
						<div class="clear"></div>
					</form>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset local.humanOk = false>

			<cftry>
				<cfset local.sides = UrlDecode(local.scope.human2)>
				<cfset local.splitAt = Find("~~~", local.sides)>
				<cfset local.rightSidePass = Left(local.sides, local.splitAt-1)>
				<cfset local.leftSidePass = Right(local.sides, local.splitAt-1)>

				<cfset local.leftSideDec = Decrypt(local.leftSidePass, local.leftSideEnc) / local.leftSideMultiply>
				<cfset local.rightSideDec = Decrypt(local.rightSidePass, local.rightSideEnc) / local.rightSideMultiply>

				<cfset local.originalCalcValue = local.leftSideDec + local.rightSideDec>

				<cfif local.originalCalcValue eq local.scope.human>
					<cfset local.humanOk = true>
				</cfif>
				<!--- <textarea cols="100" rows="100">
				<cfoutput>
				#local.sides#
				-------------------------------------
				|---&gt;#local.leftSidePass#&lt;---|
				|---&gt;#local.rightSidePass#&lt;---|
				
				|---&gt;#local.leftSideDec#&lt;---|
				|---&gt;#local.rightSideDec#&lt;---|
				</cfoutput>
				</textarea> --->

				<cfcatch type="any">
					<!--- humanOk already false --->
				</cfcatch>
			</cftry>

			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<cfif NOT local.humanOk>
						<h4>There was a problem submitting the form or your answer to the calculation was wrong</h4>
					<cfelse>
						At this point, the contact page will have been submitted, checked to see if human and then an email sent.
						All without showing the email address of the person it is being sent TO
					</cfif>
				</cfoutput>
			</cfsavecontent>
		</cfif>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>