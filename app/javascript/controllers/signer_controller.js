import { Controller } from "@hotwired/stimulus"
import HelloSign from 'hellosign-embedded';

export default class extends Controller {
  static values = {
    url: String,
  }

  initialize() {
    this.client = new HelloSign();
  }

  sign() {
    t
  }
}
