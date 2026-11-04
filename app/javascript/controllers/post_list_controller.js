import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['post'];

  prepareDelete({ currentTarget: form }) {
    form.querySelectorAll('input[name="visible_post_ids[]"]').forEach((input) => input.remove());
    this.postTargets.forEach((post) => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'visible_post_ids[]';
      input.value = post.dataset.postId;
      form.append(input);
    });
  }
}
