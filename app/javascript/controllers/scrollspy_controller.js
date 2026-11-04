import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['navigation', 'link'];

  connect() {
    this.measure();
  }

  disconnect() {
    this.navigationTarget.classList.remove('affix');
  }

  measure() {
    this.navigationTarget.classList.remove('affix');
    this.navigationTop = this.navigationTarget.getBoundingClientRect().top + window.scrollY;
    this.refresh();
  }

  refresh() {
    this.navigationTarget.classList.toggle('affix', window.scrollY > this.navigationTop - 20);

    let activeLink;
    this.linkTargets.forEach((link) => {
      const section = this.element.querySelector(link.getAttribute('href'));
      if (section && section.getBoundingClientRect().top <= 100) activeLink = link;
    });

    this.linkTargets.forEach((link) => {
      link.parentElement.classList.toggle('active', link === activeLink);
    });
  }
}
