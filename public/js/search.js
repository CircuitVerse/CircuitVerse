$(document).ready(() => {
    // remove search in nav bar on the search page
    if (window.location.href.includes('search')) {
        $('#nav-search').remove();
    }
});
