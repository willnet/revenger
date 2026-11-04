import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['duration'];

  durationTargetConnected(input) {
    if (this.duration === undefined) {
      if (input.checked) this.duration = input.value;
    } else {
      input.checked = input.value === this.duration;
    }
  }

  selectDuration({ currentTarget: input }) {
    this.duration = input.value;
  }
}
