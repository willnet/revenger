window.JST = window.JST || {};
window.JST['posts/updating_button'] = function() {
  return '<a class="btn btn-small btn-success disabled" data-behavior="updating">' +
         Global.icon('spinner') + ' ' +
         'update!' +
         '</a>';
};
