function showLinkFavouritedNotice(link){
  var favourited = !!$(link).data("favourited");
  var name = $(link).find('.title').text();
  var message = favourited ? name + " was added to favourites" : name + " was removed from favourites";
  var $flash = $("<div></div>").addClass('flash notice').html(message);
  $flash.appendTo('#flash-container');
  window.setTimeout(function(){$flash.fadeOut(function(){
    $(this).remove();
  });}, 3000);
}

function addFavouritesHandler(){
  $(".star.solid").click(function(event){
    var link = $(this).parent();
    var favourited = !!$(link).data("favourited");
    var newOpacity = favourited ? 0 : 1;
    $(link).data("favourited", !favourited);
    $(this).animate({opacity: newOpacity}, 1000);
    showLinkFavouritedNotice(link);
  });
}


$(function(){
  addFavouritesHandler();
});