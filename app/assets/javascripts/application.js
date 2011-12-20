// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require menu
//= require edit_downloads

(function ($) {
  $(document).ready(function() {
    // replace each comment edit form with comment text and a button that
    // opens the form
    $('#product-comment-list, #product-admin-comment-list')
      .find('.commentfield')
      .parents('.product-comment-line')
      .each(function () {
        var form = $(this);
        var text = $('<div class="commenttext markdown-content"/>')
          .html(form.find('.commentfield').data('html'))
          .insertBefore(form);
        form.hide();
        var editbutton = $('<button class="smallbutton">').text(translations.edit)
          .prependTo( form.parent().find('.product-comment-buttons') );
        editbutton.click(function () {
            editbutton.prop("disabled", true);
            text.hide();
            form.show();
          });
        $('<button class="smallbutton">').text(translations.cancel)
          .appendTo(form)
          .click(function () {
            editbutton.prop("disabled", false);
            text.show();
            form.hide();
            return false; // don't submit form
          });
      });

    // replace ordinary links with ajax popups
    // using jQuery UI's dialog widget
    $('.ajax-popup').each(function () {
      var $this = $(this);
      var url = this.href;

      var checkbox = false;
      var label = $this.parents('label')
      if (label.length != 0) {
        var label_for = label.attr('for');
        if (label_for) {
          checkbox = $('#' + label_for);
        }
        else {
          checkbox = label.find('input:checkbox');
        }
      }

      var dialog =
        $('<div style="display:hidden">' + translations.loading + '</div>')
        .attr('title', $this.text())
        .appendTo('body')
        .dialog({
          autoOpen: false,
          modal: false,
          width: '70%',
          height: 0.9 * $(window).height(),
          closeText: translations.close,
          buttons:
            // If there is a checkbox associated with the element,
            // add accept and decline buttons that check and uncheck it.
            // Otherwise add a close button.
            checkbox ? [
              { text: translations.accept,
                click: function () { checkbox.val(['1']); $(this).dialog('close'); } },
              { text: translations.decline,
                click: function () { checkbox.val([]);    $(this).dialog('close'); } }
            ] : [
              { text: translations.close,
                click: function () { $(this).dialog('close'); } }
            ]});

      $(this).click(function (e) {
        // open popup only on left click with no modifier keys down
        if (e.which == 1 && !(e.shiftKey || e.ctrlKey || e.altKey || e.metaKey)) {
          // load popup contents if not already loaded
          if (! dialog.hasClass('ajax-popup-loaded')) {
            dialog
              .load(url, function () {
                  // if there is a header in the returned content,
                  // move it to dialog title bar
                  var h1 = dialog.find('h1');
                  if (h1.length != 0) {
                    dialog.dialog('option', 'title', h1.text());
                  }
                  h1.remove();
                })
              .addClass('ajax-popup-loaded');
          }

          dialog.dialog('open');

          // prevent the browser from following the link
          return false;
        }
        return true;
      });
    });

    // enable autocompletion in products' tag fields
    $('#product_tag_list')
      // don't navigate away from the field on tab when selecting an item
      .bind("keydown", function(event) {
        if (event.keyCode === $.ui.keyCode.TAB && $(this).data("autocomplete").menu.active) {
          event.preventDefault();
        }
      })
      .autocomplete({
        minLength: 0,
        source: function(request, response) {
          // extract last term
          var lastTerm = /(?:^|,)\s*([^,]*|"[^"]*"?|'[^']*'?)\s*$/.exec(request.term)[1];
          lastTerm = lastTerm.replace(/^(?:"(.*?)"?|'(.*?)'?)$/, '$1$2');  // remove quotes

          $.getJSON( this.element.data('autocompleteUrl'),
            { term: lastTerm },
            response );
        },
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function(event, ui) {
          // add quotes around value if it contains commas
          var value = ui.item.value;
          if (value.indexOf(',') != -1) {
            value = '"' + value + '"';
          }

          // replace the last term with new value
          var lastTerm = /(?:^|,)\s*(?:[^,]*|"[^"]*"?|'[^']*'?)\s*$/.exec(this.value);
          this.value = this.value.slice(0, lastTerm.index) + ', ' + value + ', ';

          return false;
        }
      });
  });

})(jQuery);
