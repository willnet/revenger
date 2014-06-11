Revenger.Views.Helper =
  process_button: (button) ->
    button.
      attr('data-behavior', '').
      addClass('disabled')
    icon = button.find('i')
    icon.
      removeClass(icon.attr('class')).
      addClass('icon-refresh icon-spin')
