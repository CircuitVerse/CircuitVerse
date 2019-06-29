$(document).ready(() => {
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

    let restriction_map = {}
    let elementHierarchy = metadata.elementHierarchy;
    for (let i = 0; i < restrictions.length; i++)
        restriction_map[restrictions[i]] = true;


    for (let category in elementHierarchy) {
        let elements = elementHierarchy[category];
        let html = `<div class="circuit-element-category"> ${category} </div>`;
        for (let i = 0; i < elements.length; i++) {
            let element = elements[i];
            let checked = restriction_map[element] ? "checked" : "";
            html+= `<span class="circuit-element-container">
            <input type="checkbox" class="element-restiction" value="${element}" style= "margin-top: 0" ${checked}>
            <span> ${element} </span>
         </span>`
        }
        $('.restricted-elements-list').append(html);
    }
});
