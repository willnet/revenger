window.JST = window.JST || {};
window.JST['posts/update_button'] = function() {
  return '<a class="btn btn-small btn-success" data-behavior="update">' +
         Global.icon('upload') + ' ' +
         'update!' +
         '</a>';
};
