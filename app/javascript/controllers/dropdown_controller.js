import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['toggle'];

  connect() {
    this.close();
  }

  toggle() {
    const open = this.element.classList.toggle('open');
    this.toggleTarget.setAttribute('aria-expanded', open);
  }

  close() {
    this.element.classList.remove('open');
    this.toggleTarget.setAttribute('aria-expanded', false);
  }
}
