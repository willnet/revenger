Revenger.Views.Helper = {
  process_button: function(button) {
    button
      .attr('data-behavior', '')
      .addClass('disabled');
    const icon = button.find('i');
    icon
      .removeClass(icon.attr('class'))
      .addClass('fas fa-sync-alt fa-spin');
  }
};
