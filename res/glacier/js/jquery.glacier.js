$(document).ready(function() {
	$('.folder_title').click(function() {
		var $sub = $(this).closest('.folder_wrapper').find('.folder_sub:first');
		if ($sub.is(':visible')) {
			$sub.slideUp();
		} else {
			$sub.slideDown();
		} 
		return false;
	})

	$('.deleteNo').click(function() {
		$('.confirmDelete').hide();
	})

	$('.triggerDelete').click(function() {
		var $this = $(this);
		$.prompt("", {
			title: "Are you sure you want to delete the page?",
			buttons: { "Yes, delete the age": true, "No, maybe not": false },
			submit: function(e,v,m,f){
				if (v)
					window.location = $this.attr('href');
			}
		});
	})
})
