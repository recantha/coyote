<cfcomponent displayname="jQueryUtil">

	<cffunction name="init" returntype="jQueryUtil" access="public">
		<cfreturn this>
	</cffunction>

	<cffunction name="genericJqueryValidation" returntype="struct" access="public" hint="">
		<cfargument name="formID" type="string" required="true">
		<cfargument name="equalFields" type="string" required="false" default="" hint="field1=field2,field3=field4">
		<cfargument name="requiredFields" type="string" required="false" default="" hint="field1,field2">
		<cfargument name="requiredCondition" type="string" required="false" default="" hint="Jquery expression to check on validation">
		<cfargument name="emailFields" type="string" required="false" default="" hint="field1,field2">
		<cfargument name="minLengthFields" type="string" required="false" default="" hint="field1=4,field2=6">
		
		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.rules = {}>
		<cfloop list="#arguments.equalFields#" index="local.pair">
			<cfset local.left = ListGetAt(local.pair, 1, "=")>
			<cfset local.right = ListGetAt(local.pair, 2, "=")>
			<cfif NOT StructKeyExists(local.rules, local.left)>
				<cfset local.rules[local.left] = []>
			</cfif>
			<cfset ArrayAppend(local.rules[local.left], "equalTo: '###local.right#'")>
		</cfloop>

		<cfset local.reqIDs = "">
		<cfloop list="#arguments.requiredFields#" index="local.fld">
			<cfif NOT StructKeyExists(local.rules, local.fld)>
				<cfset local.rules[local.fld] = []>
			</cfif>
			<cfif Len(arguments.requiredCondition) eq 0>
				<cfset ArrayAppend(local.rules[local.fld], "required: true")>
			<cfelse>
				<cfset ArrayAppend(local.rules[local.fld], "required: '#arguments.requiredCondition#'")>
			</cfif>
			<cfset local.reqIDs = ListAppend(local.reqIDs, "###local.fld#")>
		</cfloop>

		<cfloop list="#arguments.emailFields#" index="local.fld">
			<cfif NOT StructKeyExists(local.rules, local.fld)>
				<cfset local.rules[local.fld] = []>
			</cfif>
			<cfset ArrayAppend(local.rules[local.fld], "email: true")>
		</cfloop>

		<cfset local.minLenIDs = "">
		<cfloop list="#arguments.minLengthFields#" index="local.pair">
			<cfset local.field = ListGetAt(local.pair, 1, "=")>
			<cfset local.leng = ListGetAt(local.pair, 2, "=")>
			<cfif NOT StructKeyExists(local.rules, local.field)>
				<cfset local.rules[local.field] = []>
			</cfif>
			<cfset ArrayAppend(local.rules[local.field], "minlength: '#local.len#'")>
			<cfset local.minLenIDs = ListAppend(local.minLenIDs, "###local.field#")>
		</cfloop>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<script type="text/javascript">
					<!--- FORM VALIDATION AND PRETTINESS --->
					$(document).ready(function() {
						<!--- Make sure that EVERY input tag has an ID --->
						$(':input[id=]').each(function() {
							$(this).attr('id', $(this).attr('name'));
						});

						<!--- Every time you come out of a field, the jquery validates the element you left --->
						$(':input').blur(function() {
							$('label.validationError').hide();
							$('###arguments.formID#').validate().element('##' + $(this).attr('id'));
						});

						<!--- When the form is submitted, hide all the validation labels so you only see the up-to-date ones --->
						$("###arguments.formID#").submit (function() {
							$('label.validationError').hide();
						})
						
						$("###arguments.formID#").bind('add-validation', function() {
							$("###arguments.formID#").validate({
								focusCleanup:true,
								errorClass: 'validationError',
								rules: {
									<cfloop from="1" to="#ListLen(structKeyList(local.rules))#" index="local.r">
										<cfset local.fld = ListGetAt(StructKeyList(local.rules), local.r)>
										#local.fld#: {
											<cfloop from="1" to="#ArrayLen(local.rules[local.fld])#" index="local.i">
												#local.rules[local.fld][local.i]#
												<cfif local.i neq ArrayLen(local.rules[local.fld])>,</cfif>
											</cfloop>
										}
										<cfif local.r neq ListLen(structKeyList(local.rules))>,</cfif>
									</cfloop>
								}
							});
						})
						$("###arguments.formID#").trigger('add-validation');
						
						$("###arguments.formID#").bind('remove-validation', function() {
							$("###arguments.formID#").validate();
						})
						
						$(':input').bind('make-required', function() {
							<!--- Prevent repeats --->
							if (!($(this).hasClass('required-field'))) {
								<!--- and the repeat-check class and add the required flag * --->
								$(this).addClass('required-field');
								$(this).parent().prev('div').append('<span class="required-flag">*</span>');
							}
						})
						$(':input').bind('make-nonrequired', function() {
							<!--- Prevent repeats --->
							if ($(this).hasClass('required-field')) {
								<!--- and the repeat-check class and add the required flag * --->
								$(this).removeClass('required-field');
								$(this).parent().prev('div').find('.required-flag').remove();
							}
						})
						$('#local.reqIDs#').trigger('make-required');
					});
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>