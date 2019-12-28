/* jshint esversion: 6 */

$(document).ready(() => {
    // remove search in nav bar on the search page
    if (window.location.href.includes('search')) {
        $('#nav-search').remove();
    }

    $('.dropdown > div > a').on('click', () => {
        const $a = $(this);
        $('#dropdownSearchMenuLink').text($a.html());
        $('.dropdown .dropdown-menu').removeClass('show');
        $('.dropdown input[name=resource]').val($a.text());
        return false;
    });
});
