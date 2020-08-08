function activeSearchBar(){
  let searchIconCollapse = document.getElementsByClassName("fa-search")[0];
  let searchIconExpand = document.getElementsByClassName("fa-search")[1];
  let searchBar = document.getElementsByClassName("navbar-search-active")[0];
  let burgerButton = document.getElementById("collapsed-navbar");
  if (searchIconCollapse.classList.contains("active") || searchIconExpand.classList.contains("active")) {
    searchIconCollapse.classList.remove("active");
    searchIconExpand.classList.remove("active");
    searchBar.style.display = "none";
  }
  else {
    searchIconCollapse.classList.add("active");
    searchIconExpand.classList.add("active");
    searchBar.style.display = "block";
  }
  burgerButton.classList.remove("show");
}
let searchIconCollapse = document.getElementsByClassName("fa-search")[0];
let searchIconExpand = document.getElementsByClassName("fa-search")[1];
let searchBar = document.getElementsByClassName("navbar-search-active")[0];
searchIconCollapse.addEventListener("click", activeSearchBar);
searchIconExpand.addEventListener("click", activeSearchBar);
if (window.location.href.includes('search')) {
    searchBar.style.display = "block";
}
