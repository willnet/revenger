import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { dismissAfter: Number };

  connect() {
    if (this.hasDismissAfterValue) {
      this.dismissTimeout = setTimeout(() => this.fadeOut(), this.dismissAfterValue);
    }
  }

  disconnect() {
    clearTimeout(this.dismissTimeout);
    clearTimeout(this.removalTimeout);
  }

  close() {
    this.element.remove();
  }

  fadeOut() {
    this.element.classList.remove('in');
    this.removalTimeout = setTimeout(() => this.close(), 200);
  }
}
