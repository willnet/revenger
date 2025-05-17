window.JST = window.JST || {};
window.JST['reviews/review'] = function(context) {
  const post = context.post;
  return '<div class="post">' +
         '  <span class="common">' +
         '    <a id="read" class="btn btn-primary" data-behavior="read">' +
         '      <i class="fas fa-check"></i> ' +
         '      read it!' +
         '    </a>' +
         '    <div class="duration btn-group" data-toggle="buttons-radio" data-behavior="duration">' +
         '      ' + Global.duration_button(post, null, 'no more') +
         '      ' + Global.duration_button(post, 1, '1 day') +
         '      ' + Global.duration_button(post, 7, '1 week') +
         '      ' + Global.duration_button(post, 14, '2 week') +
         '      ' + Global.duration_button(post, 30, '1 month') +
         '      ' + Global.duration_button(post, 90, '3 months') +
         '      ' + Global.duration_button(post, 180, '6 months') +
         '      ' + Global.duration_button(post, 365, '1 year') +
         '    </div>' +
         '  </span>' +
         '  <span class="view" data-behavior="view-element">' +
         '    <span class="manage pull-right">' +
         '      <a class="btn btn-small btn-success" data-behavior="edit">' +
         '        <i class="fas fa-edit"></i> ' +
         '        edit' +
         '      </a>' +
         '      <a class="btn btn-small btn-danger" data-behavior="destroy">' +
         '        <i class="fas fa-trash"></i> ' +
         '        delete' +
         '      </a>' +
         '    </span>' +
         '    <div class="body">' + post.get('markdown') + '</div>' +
         '    <div class="info">作成: ' + post.get('created_at') + ' 更新: ' + post.get('updated_at') + '</div>' +
         '  </span>' +
         '  <span class="edit" data-behavior="edit-element">' +
         '    <span class="manage pull-right">' +
         '      <a class="btn btn-small" data-behavior="cancel">' +
         '        <i class="fas fa-ban"></i> ' +
         '        cancel' +
         '      </a>' +
         '      ' + JST['posts/update_button']() +
         '    </span>' +
         '    <div class="input-body">' +
         '      <textarea class="body" data-behavior="body">' + post.get('body') + '</textarea>' +
         '    </div>' +
         '  </span>' +
         '</div>';
};
