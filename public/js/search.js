/* jshint esversion: 6 */

$(document).ready(() => {

    // Highlight searched text
    var searchText = $('.navbar-search-bar-input').val().trim();

    if (searchText !== '') {
        $('.search-container').find('.search-project-name, .search-project-description p').each(function highlight() {
            // Loop over each result
            var text = $(this).html();

            var currentPos = 0;
            loop = true;

            while (loop && currentPos < text.length) { // Loop over all text and highlight any occurences of the search term
                var occurence = text.toLowerCase().indexOf(searchText.toLowerCase(), currentPos);

                if (occurence === -1) {
                    loop = false;
                } else {
                    text = `${text.substring(0, occurence)}<span class="search-match">${text.substring(occurence, occurence + searchText.length)}</span>${text.substring(occurence + searchText.length)}`;
                }
                currentPos += 34 + searchText.length;
            }

            $(this).html(text);
        });
    }
});
