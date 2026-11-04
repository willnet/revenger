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
    this.sections = this.linkTargets
      .map((link) => ({ link, section: this.element.querySelector(link.getAttribute('href')) }))
      .filter(({ section }) => section);
    this.refresh();
  }

  refresh() {
    let activeLink;
    this.sections.forEach(({ link, section }) => {
      if (section.getBoundingClientRect().top <= 100) activeLink = link;
    });

    this.navigationTarget.classList.toggle('affix', window.scrollY > this.navigationTop - 20);
    this.sections.forEach(({ link }) => {
      link.parentElement.classList.toggle('active', link === activeLink);
    });
  }
}
