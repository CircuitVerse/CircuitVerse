/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import 'controllers';
import 'trumbowyg';
import 'jquery';
import 'bootstrap-tagsinput';

function showDropDown(dropDown) {
    let collapsedDropdown = (dropDown === 0)? document.getElementsByClassName('dropdown-menu')[0] : document.getElementsByClassName('dropdown-menu')[1];
    if (collapsedDropdown.classList.contains('show')) {
        collapsedDropdown.classList.remove('show');
    }
    else {
        collapsedDropdown.classList.add('show');
    }
}
document.getElementsByClassName('dropdown-toggle')[0].addEventListener('click', ()=>showDropDown(0))
document.getElementsByClassName('dropdown-toggle')[1].addEventListener('click', ()=>showDropDown(1))

console.log('Hello World from Webpacker')
