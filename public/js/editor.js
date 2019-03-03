"use strict";

function populate(show) {
  $('table#show').html($.templates("#show-template").render(show));
}
