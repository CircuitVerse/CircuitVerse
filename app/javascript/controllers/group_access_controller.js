import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['access', 'groupField']

  connect () { this.toggle() }

  toggle () {
    const show = this.accessTarget.value === 'Group'
    this.groupFieldTarget.classList.toggle('d-none', !show)
  }
}