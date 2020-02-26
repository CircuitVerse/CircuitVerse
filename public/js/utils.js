// To strip tags from input
function stripTags(string="") {
    return string.replace(/(<([^>]+)>)/ig, '').trim();
}
$(".vpop").on('click', function(e) {
    e.preventDefault();
    $("#video-popup-overlay,#video-popup-iframe-container,#video-popup-container,#video-popup-close").show();
    
    var srchref='',autoplay='',id=$(this).data('id');
    if($(this).data('type') == 'vimeo') var srchref="//player.vimeo.com/video/";
    else if($(this).data('type') == 'youtube') var srchref="https://www.youtube.com/embed/";
    
    if($(this).data('autoplay') == true) autoplay = '?autoplay=1';
    
    $("#video-popup-iframe").attr('src', srchref+id+autoplay);
    
    $("#video-popup-iframe").on('load', function() {
      $("#video-popup-container").show();
    });
  });
  
  $("#video-popup-close, #video-popup-overlay").on('click', function(e) {
    $("#video-popup-iframe-container,#video-popup-container,#video-popup-close,#video-popup-overlay").hide();
    $("#video-popup-iframe").attr('src', '');
  });
  