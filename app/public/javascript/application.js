function addFavouritesHandler(){
  $(".star.solid").click(function(){
    var newOpacity = 1 - parseInt($(this).css('opacity'));
    $(this).animate({opacity: newOpacity}, 1000);
  });
}

$(function(){
  addFavouritesHandler();
});