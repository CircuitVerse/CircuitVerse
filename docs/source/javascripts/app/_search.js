//= require ../lib/_lunr
//= require ../lib/_jquery
//= require ../lib/_jquery.highlight
;(function () {
  'use strict';

  var content, searchResults;
  var highlightOpts = { element: 'span', className: 'search-highlight' };
  var searchDelay = 0;
  var timeoutHandle = 0;

  var index = new lunr.Index();

  index.ref('id');
  index.field('title', { boost: 10 });
  index.field('body');
  index.pipeline.add(lunr.trimmer, lunr.stopWordFilter);

  $(populate);
  $(bind);

  function populate() {
    $('h1, h2').each(function() {
      var title = $(this);
      var body = title.nextUntil('h1, h2');
      index.add({
        id: title.prop('id'),
        title: title.text(),
        body: body.text()
      });
    });

    determineSearchDelay();
  }
  function determineSearchDelay() {
    if(index.tokenStore.length>5000) {
      searchDelay = 300;
    }
  }

  function bind() {
    content = $('.content');
    searchResults = $('.search-results');

    $('#input-search').on('keyup',function(e) {
      var wait = function() {
        return function(executingFunction, waitTime){
          clearTimeout(timeoutHandle);
          timeoutHandle = setTimeout(executingFunction, waitTime);
        };
      }();
      wait(function(){
        search(e);
      }, searchDelay );
    });
  }

  function search(event) {
    var searchInput = $('#input-search')[0];
    var searchTerm = searchInput.value;
  
    unhighlight();
    searchResults.addClass('visible');
  
    // ESC clears the field
    if (event.keyCode === 27) searchInput.value = '';
  
    if (searchTerm) {
      var results = index.search(searchTerm).filter(function (r) {
        return r.score > 0.0001;
      });
  
      if (results.length) {
        let resultHTML = '';
  
        results.forEach(function (result) {
          var elem = document.getElementById(result.ref);
          if (elem) {
            resultHTML += "<li><a href='#" + result.ref + "'>" + $(elem).text() + "</a></li>";
          }
        });
  
        searchResults.html(resultHTML); // Update DOM once
        highlight.call(searchInput);    // Call once after all updates
  
      } else {
        searchResults.html('<li>No Results Found for "' + searchTerm + '"</li>');
      }
    } else {
      unhighlight();
      searchResults.removeClass('visible');
    }
  }
  

  function highlight() {
    if (this.value) content.highlight(this.value, highlightOpts);
  }

  function unhighlight() {
    content.unhighlight(highlightOpts);
  }
})();

