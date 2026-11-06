import '@hotwired/turbo-rails';
import 'controllers';

// 既定ではフレーム内に "Content missing" と表示されて操作できなくなるため、エラーページなどは画面全体に表示する。
document.addEventListener('turbo:frame-missing', (event) => {
  event.preventDefault();
  event.detail.visit(event.detail.response);
});
