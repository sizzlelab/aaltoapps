(function($) {

  var download_form_name_regexp = /^(product\[downloads_attributes\])\[(\d+)\](.*)$/;
  var new_download_num, new_download_fields;

  // creates fields for a new download
  function new_download() {
    var fields = new_download_fields.clone();

    // replace the download number in form fields with an unused number
    // and add suffix to id attributes
    new_download_num++;
    var update_id = function(i, val) {
      return val + "_new_dl_" + new_download_num;
    };
    fields.find('[id]').attr('id', update_id);
    fields.find('label[for]').attr('for', update_id);
    fields.find('[name]')
      .attr('name', function(i, val) {
        return val.replace(download_form_name_regexp, "$1[" + new_download_num + "]$3");
      });

    return fields;
  }

  // called after the order of the downloads is changed or new download is
  // added or deleted
  function after_order_change() {
    $('#product_edit_download_list li').each(function(i) {
      // recalculate order field values
      $('.product-download-order-field', this).val(i+1);

      // hide/show move up/down buttons
      $('.product-download-move-up', this).css(
        'visibility',
        $(this).is(':first-child') ? 'hidden' : 'visible' );
      $('.product-download-move-down', this).css(
        'visibility',
        $(this).is(':last-child') ? 'hidden' : 'visible' );
    });
  }

  $(document).ready(function() {
    // set header's vertical-align so that it doesn't move when download
    // list items are dragged
    $('#product_edit_downloads dt')
      .css('vertical-align', 'top');

    // move new download fields to the list and add grip elements
    var grip = $('<div class="product-download-formfields-grip">')
      .css({ width: '1.75em' });
    var new_dl = $('<li class="product-new-download">')
      .append($('#product_new_download'));
    $('#product_edit_download_list')
      .css('padding-left', 0)
      .append(new_dl)
      .children('li')
        .css({
          position: 'relative',
          paddingLeft: '2em'  // width of the grip + margin between the grip and contents
        })
        .prepend(grip)
        .find('.product-download-order').hide();  // remove order fields

    var button = $('<div class="product-download-ui-button ui-state-default ui-corner-all">')
      .append('<span class="ui-icon"></span>');

    // add move up/down buttons
    $('<div>')
      .css({
        position: 'absolute',
        paddingLeft: '0.25em'
      })
      .append(
        button.clone()
          .attr('title', translations.move_up)
          .addClass('product-download-move-up')
          .children('.ui-icon').addClass('ui-icon-arrowthick-1-n').end()
      )
      .append(
        button.clone()
          .attr('title', translations.move_down)
          .addClass('product-download-move-down')
          .css('margin-top', '0.2em')
          .children('.ui-icon').addClass('ui-icon-arrowthick-1-s').end()
      )
      .appendTo('#product_edit_download_list li')
      .each(function() {
        var $this = $(this);
        $this
          .position({
            my: 'left center',
            at: 'right center',
            of: $this.parent()
          })
          .css({
            left: '100%'  // overrides the value set by position()
          });
      });

    // add remove button to new download box
    button.clone()
      .attr('title', translations.remove_download)
      .addClass('product-download-delete-new')
      .css({
        position: 'absolute',
        top: '0.25em',
        right: '0.25em'
      })
      .children('.ui-icon').addClass('ui-icon-close').end()
      .appendTo(new_dl);

    // button event handlers
    $('#product_edit_download_list')
      .on({
          mouseenter: function() { $(this).addClass(   'ui-state-hover'); },
          mouseleave: function() { $(this).removeClass('ui-state-hover'); }
        }, '.product-download-ui-button')
      .on('click', '.product-download-move-up', function() {
        var li = $(this).closest('#product_edit_download_list li');
        li.prev().before(li);
        after_order_change();
      })
      .on('click', '.product-download-move-down', function() {
        var li = $(this).closest('#product_edit_download_list li');
        li.next().after(li);
        after_order_change();
      })
      .on('click', '.product-download-delete-new', function() {
        $(this).parent().remove();
        after_order_change();
      })
      .on('change', '.product-download-delete-checkbox', function() {
        $(this).closest('#product_edit_download_list li')
          [$(this).is(':checked') ? 'addClass' : 'removeClass']('product-deleted-download');
      });

    // store new download fields and associated info so that they can
    // be duplicated
    new_dl.find('[name]').each(function() {
      // find and store the array index of new download fields
      var result = download_form_name_regexp.exec($(this).attr('name'));
      if (result) {
        new_download_num = parseInt(result[2]);
        return false; // end each() loop
      }
      return true;
    });
    new_download_fields = new_dl.clone().hide();

    // add a button for adding new downloads
    $('<button class="smallbutton">')
      .text(translations.new_download)
      .insertAfter('#product_edit_download_list')
      .click(function() {
        new_download()
          .appendTo($('#product_edit_download_list'))
          .show({
            effect: 'blind',
            complete: after_order_change
          });
        return false;  // don't submit form
      });

    // make download list items drag-and-drop sortable
    $('#product_edit_download_list')
      .sortable({
        axis: 'y',
        cursor: 'move',
        placeholder: 'product-download-formfields-placeholder',
        forcePlaceholderSize: true,
        update: after_order_change,
        stop: function() {
          // remove top and left css properties that jQuery UI sometimes leaves
          // in the li elements
          // (occurs at least in Firefox 8.0 but not in Chrome 16;
          // may be caused by this bug: http://bugs.jqueryui.com/ticket/4792)
          $('#product_edit_download_list li')
            .css({ top: '', left: ''});
        }
      })

    after_order_change();
  });
})(jQuery);