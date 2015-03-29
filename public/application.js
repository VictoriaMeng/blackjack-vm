$(document).ready(function() {
    
$(document).on("click", "form#hit_or_stay fieldset div.btn-group button#hit.btn", function() {

    alert("You draw a card.");

    $.ajax({
      type: "GET",
      url: "/hit_or_stay?hit_or_stay=hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });

    return false;
  });

$(document).on("click", "form#hit_or_stay fieldset div.btn-group button#stay.btn", function() {

  alert("Dealer's turn begins.");

  $.ajax({
    type: "GET",
    url: "/hit_or_stay?hit_or_stay=stay"
  }).done(function(msg) {
    $("#game").replaceWith(msg);
  }); 

  return false;
});

$(document).on("click", "form#dealer_card fieldset div button", function() {

  alert("Dealer draws a card.");

  $.ajax({
    type: "GET",
    url: "/dealer_card?dealer_card=dealer_card"
  }).done(function(msg) {
    $("#game").replaceWith(msg);
  });

  return false;
});

});