(function ($) {

  function submenuOpen(j) {
    j .parent('.menutop') .removeClass('menutop-closed') .addClass('menutop-open');
    j .removeClass('menutop-closed') .addClass('menutop-open') .siblings('ul') .slideDown(250);
  }

  function submenuClose(j) {
    j .removeClass('menutop-open') .addClass('menutop-closed')  .siblings('ul') .slideUp(250);
    j .parent('.menutop') .removeClass('menutop-open') .addClass('menutop-closed');
  }

  $(document).ready(function() {
    // update open/closed status of menus from cookie
    $.each(document.cookie.split(';'), function (i, cookie) {
      var match = $.trim(cookie).match(/^openMenus=([a-zA-Z0-9_,-]+)$/);
      if (match) {
        $.each(match[1].split(','), function (i, id) {
          $('#menu #' + id + ' .menutop') .addClass('menutop-open');
        });
      }
    });

    $('.menutop:not(.menutop-open)') .addClass('menutop-closed') .siblings('ul') .hide();

    $('#menu .menutop') .click(function() {

      if ($(this) .hasClass('menutop-open')) {
        submenuClose($(this));
      }else{
        submenuClose($('#menu .menutop-open'));
        submenuOpen($(this));
      }

      // set cookie to a list of ids of open menus
      document.cookie =
        'openMenus=' +
        $('#menu .menutop-open').parent().map(function() { return this.id; }).get().join(',') +
        '; path=/';

      return false;
    });
  });
})(jQuery);
