jQuery(() => {
  const closeFlashSuccess = () => {
    $('.alert-success.flash').each((_, element) => {
      const $alert = $(element);
      $alert.fadeOut(200, () => $alert.remove());
    });
  };

  setTimeout(closeFlashSuccess, 5000);
});
