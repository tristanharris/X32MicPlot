"use strict";

function populate(show) {
  $.templates("#show-template").link('table#show', show);

  $('#show').on('click', 'tbody td', function(e) {
    e.preventDefault();
    var data = $.view(this).data;
    var o = $.observable(data);
    o.setProperty('state', data.state ? '' : '*');
  });
}
