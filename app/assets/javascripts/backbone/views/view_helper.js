Revenger.Views.Helper = {
  process_button: function(button) {
    button
      .attr('data-behavior', '')
      .addClass('disabled');
    button.find('.app-icon').replaceWith(Global.icon('spinner'));
  }
};
