// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.ja.js
//= require select2
//= require select2_locale_"ja"
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
import "controllers"
import "chartkick"
import "Chart.bundle"

$(window).on('load',function(){
  $('.datepicker').datepicker({
    language:'ja',
    autoclose: true,
  });

  $('.select-user').select2({
    placeholder: 'ユーザー名',
    width: 200,
    allowClear: true
  });

  $('.select-process').select2({
    placeholder: 'プロセス名',
    width: 200,
    allowClear: true
  });
}); 
