function jsddm_open() {
	$(this).find('ul').slideDown('fast');
}

function jsddm_close() {
	$(this).find('ul').hide();
}

$(document).ready(function() {
	$('.jsddm > li').hoverIntent(jsddm_open, jsddm_close);

});

/*
 * (function($) { $.extend($.fn, { recanthaMenu: function(styleClass,
 * easingMethodOut, easingMethodIn) { var $this = $(this); var $toplevel =
 * $this; $toplevel.attr('processHover', 1);
 * 
 * if(!easingMethodOut) easingMethodOut='easeOutQuad';
 * 
 * if(!easingMethodIn) easingMethodIn='easeInQuad';
 *  // What to do when you hover over a sub heading (i.e. a top level item) - in
 * this case, drop down the submenu
 * $this.children('ul').children('li').hoverIntent( function () { var $this =
 * $(this);
 *  // processHover is used to prevent recursion causing endless parade of
 * down-up-down-up if ($toplevel.attr('processHover') == 1) {
 * $toplevel.attr('processHover', 0); var $submenu = $this.find('ul');
 * 
 * if (!$submenu.is(':visible')) { $('.adminContainer').css('opacity', 0.2);
 * 
 * $this._hideAll(function() { $submenu.slideDown(300, easingMethodOut,
 * function() { $toplevel.attr('processHover', 1); }) }) } else {
 * $toplevel.attr('processHover', 1); } } }, function () { var $this = $(this);
 * var $submenu = $this.find('ul'); if ($submenu.is(':visible')) {
 * $submenu.slideUp(150, easingMethodIn, function (){
 * $('.adminContainer').css('opacity', 1); }); } $toplevel.attr('processHover',
 * 1); } );
 *  // Animation for list items - in this case, grow the text, grow the image
 * $this.find("li ul li").hover( function() { var $this = $(this);
 * $this.addClass(styleClass + "_hover"); }, function() { var $this = $(this);
 * $this.removeClass(styleClass + "_hover"); } );
 * 
 * $this.fadeIn();
 *  }, _hideAll: function(cback) { var $this = $(this); var $all_submenus =
 * $this.find('li').find('ul');
 * 
 * if ($all_submenus.length == 0) { if(typeof cback == 'function') cback(); }
 * else { $all_submenus.fadeTo(0.1, 0, function() { if(typeof cback ==
 * 'function') cback(); }) } } }) })(jQuery);
 * 
 */