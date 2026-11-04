window.Global = {
  icon: (name) => {
    return `<svg class="app-icon app-icon-${name}" aria-hidden="true" focusable="false"><use href="#icon-${name}"></use></svg>`;
  },
  duration_button: (post, value, text) => {
    if (post.get('duration') === value) {
      return `<button type='button' class='btn btn-small active' data-value='${value}'>${text}</button>`;
    } else {
      return `<button type='button' class='btn btn-small' data-value='${value}'>${text}</button>`;
    }
  }
};
