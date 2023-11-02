// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.ja.js
import "@hotwired/turbo-rails"
import "controllers"

$('.datepicker').datepicker({
  language:'ja',
  autoclose: true,
});