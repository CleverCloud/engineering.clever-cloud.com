$( document ).ready(function() {
  $(".date.value").each(function(){
     var day = new moment($(this).html(), "YYYY-MM-DD");
     var newdate = day.fromNow();
     $(this).html(newdate);
  });
});