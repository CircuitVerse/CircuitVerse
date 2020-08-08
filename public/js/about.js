async function getContributors(url){
  let apiData = await fetch(url);
  let contributorsData = await apiData.json();
  for (let i=0; i<contributorsData.length; i++){
    let contributorElement = document.createElement('div');
    let contributorElementAnchor = document.createElement('a');
    let contributorElementImage = document.createElement('img');
    contributorElement.classList.add('about-contributor');
    contributorElementAnchor.href = await contributorsData[i]['html_url'];
    contributorElementImage.src = await contributorsData[i]['avatar_url'];
    contributorElementImage.classList.add('about-contributor-image');
    contributorElementAnchor.appendChild(contributorElementImage);
    contributorElement.appendChild(contributorElementAnchor);
    document.getElementsByClassName('about-contributors-section')[0].appendChild(contributorElement);
  }
}
getContributors('https://api.github.com/repos/CircuitVerse/CircuitVerse/contributors');
