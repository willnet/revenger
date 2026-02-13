jQuery(() => {
  $(document).on('click', '[data-dismiss=alert]', (event) => {
    event.preventDefault();
    const $trigger = $(event.currentTarget);
    const $alert = $trigger.closest('.alert');
    const target = $trigger.data('target');

    if ($alert.length) {
      $alert.remove();
      return;
    }

    if (target) $(target).remove();
  });

  $(document).on('click', '[data-toggle=dropdown]', (event) => {
    event.preventDefault();
    event.stopPropagation();
    const $toggle = $(event.currentTarget);
    const $dropdown = $toggle.closest('.dropdown');
    const willOpen = !$dropdown.hasClass('open');

    $('.dropdown.open').removeClass('open');
    if (willOpen) $dropdown.addClass('open');
  });

  $(document).on('click', () => {
    $('.dropdown.open').removeClass('open');
  });

  $(document).on('click', '[data-toggle=buttons-radio] .btn, [data-toggle=buttons-radio] button', (event) => {
    event.preventDefault();
    const $button = $(event.currentTarget);
    const $group = $button.closest('[data-toggle=buttons-radio]');
    $group.find('.btn,button').removeClass('active');
    $button.addClass('active');
  });
});
