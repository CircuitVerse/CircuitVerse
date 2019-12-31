function loadRestrictions(restrictions) {
  _handleMainCheckbox()

  let elementHierarchy = metadata.elementHierarchy;
  let restrictionMap = _restrictionsMap(restrictions);
  
  _loadHtml(elementHierarchy,restrictionMap);
}
function _handleMainCheckbox()
{
    $('#restrict-elements').change((e) => {
        e.preventDefault();
        const radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-elements-list').removeClass('display--none');
        } else {
            $('.restricted-elements-list').addClass('display--none');
        }
    });
    $('#restrict-elements').trigger('change');
}

function _restrictionsMap(restrictions)
{
  let map = {};
  for (let i = 0; i < restrictions.length; i++)
  {
    map[restrictions[i]] = true;
  }
  return map;
}

function _loadHtml(elementHierarchy, restrictionMap)
{
  for (let category in elementHierarchy) {
    let elements = elementHierarchy[category];
    let html = `<div class="circuit-element-category"> ${category} </div>`;
    for (let i = 0; i < elements.length; i++) {
      let element = elements[i];
      let checked = restrictionMap[element] ? "checked" : "";
      html+= `<span class="circuit-element-container">
      <input type="checkbox" class="element-restriction" value="${element}" style= "margin-top: 0" ${checked}>
      <span> ${element} </span>
      </span>`
    }
    $('.restricted-elements-list').append(html);
  }
}
