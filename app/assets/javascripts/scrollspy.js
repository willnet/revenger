jQuery(() => {
  const $body = $('.main_controller.help_action');
  if (!$body.length) return;

  const $affix = $('[data-spy=affix]');
  if ($affix.length) {
    const baseTop = $affix.offset().top;
    const toggleAffix = () => {
      $affix.toggleClass('affix', $(window).scrollTop() > baseTop - 20);
    };
    toggleAffix();
    $(window).on('scroll', toggleAffix);
  }

  const $links = $('[data-spy=affix] a[href^="#"]');
  if (!$links.length) return;

  const sections = $links
    .map((_, link) => {
      const href = $(link).attr('href');
      return href ? $(href)[0] : null;
    })
    .get()
    .filter(Boolean);

  const refreshActive = () => {
    const top = $(window).scrollTop() + 100;
    let activeId = null;

    sections.forEach((section) => {
      if ($(section).offset().top <= top) activeId = section.id;
    });

    $links.parent('li').removeClass('active');
    if (!activeId) return;
    $links
      .filter((_, link) => $(link).attr('href') === `#${activeId}`)
      .parent('li')
      .addClass('active');
  };

  refreshActive();
  $(window).on('scroll', refreshActive);
});
