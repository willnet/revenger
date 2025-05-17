window.Global = {
  duration_button: (post, value, text) => {
    if (post.get('duration') === value) {
      return `<button type='button' class='btn btn-small active' data-value='${value}'>${text}</button>`;
    } else {
      return `<button type='button' class='btn btn-small' data-value='${value}'>${text}</button>`;
    }
  }
};
