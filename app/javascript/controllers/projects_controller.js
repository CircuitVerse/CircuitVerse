/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';
import SlimSelect from 'slim-select';

var flag = false;
var select;
export default class extends Controller {

    static values = { circuitdata: String, tagdata: String, name: String }
    // eslint-disable-next-line class-methods-use-this
    connect() {
        var project_name = this.nameValue.split(' ');
        // project tags
        var project_tag_list = this.tagdataValue.split(', ');
        const indexOfEmptyValue = project_tag_list.indexOf('');
        if (indexOfEmptyValue > -1) { // only splice array when item is found
            project_tag_list.splice(indexOfEmptyValue, 1);
        }
        for(let i in project_tag_list) {
            project_tag_list[i] = project_tag_list[i].toLocaleLowerCase();
        }
        // suggested tags list
        var suggested_circuit_element_list = [];
        // fetching the circuit used elements
        const circuit_data = JSON.parse(this.circuitdataValue)
        // storing the fetched circuit_data to suggested_circuit_element_list
        for(var key in circuit_data['scopes'][0]) {
            let data = circuit_data['scopes'][0][key][0];
            // if the data is object and contain objectType property then it is an object of used element in the circuit
            if(typeof data === 'object' && typeof data.objectType != 'undefined'){
                suggested_circuit_element_list.push(data.objectType.toLocaleLowerCase());
            }
        }
        // filter tags which are already selected
        suggested_circuit_element_list = suggested_circuit_element_list.filter(function(tag) {
            return !project_tag_list.includes(tag);
        })
        // final suggested tags array
        const suggested_tags = [];
        // pushing selected tags
        for(let i in project_tag_list) {
            suggested_tags.push({
                text: project_tag_list[i].toLocaleLowerCase(),
                selected: true
            })
        }
        // pushing suggested tags
        for(let i in suggested_circuit_element_list) {
            suggested_tags.push({
                text: suggested_circuit_element_list[i]
            })
        }
        // pushing name data
        for(let i in project_name) {
            suggested_tags.push({
                text: project_name[i].toLocaleLowerCase()
            })
        }
        // slim select initialisation
        select = new SlimSelect({
            select: '#multiple',
            addable: function (value) {
                return value.toLocaleLowerCase();
            },
            data: suggested_tags,
            searchPlaceholder: 'Search for suggested tags or add your customized tags!',
            placeholder: 'Click for suggested tags or add your customized tags!'
        })
    }

    // adding hidden input field for selected tags and appending it to the projectForm
    generateTags() {
        var input = document.createElement("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", "tag_list");
        input.setAttribute("value", select.selected());
        document.getElementById("projectForm").appendChild(input);
    }

    copy() {
        const textarea = document.getElementById('result');
        var x = document.querySelector('.projectshow-embed-text-confirmation');
        textarea.select();
        document.execCommand('copy');
        x.style.display = 'block';
    }

    showEmbedLink() {
        const clockTimeEnable = document.querySelector('#checkbox-clock-time').checked;
        const displayTitle = document.querySelector('#checkbox-display-title').checked;
        const fullscreen = document.querySelector('#checkbox-fullscreen').checked;
        const zoomInOut = document.querySelector('#checkbox-zoom-in-out').checked;
        const theme = document.querySelector('#theme').value;
        const url = `${document.querySelector('#url').value}?theme=${theme}&display_title=${displayTitle}&clock_time=${clockTimeEnable}&fullscreen=${fullscreen}&zoom_in_out=${zoomInOut}`;
        let height = document.querySelector('#height').value;
        if (height === '') height = 500;
        let width = document.querySelector('#width').value;
        if (width === '') width = 500;
        const borderPr = document.querySelector('#border_px').value;
        const borderStyle = document.querySelector('#border_style').value;
        const borderColor = document.querySelector('#border_color').value;
        const markup = `<iframe src="${url}" style="border-width:${borderPr}; border-style: ${borderStyle}; border-color:${borderColor};" name="myiframe" id="projectPreview" scrolling="no" frameborder="1" marginheight="0px" marginwidth="0px" height="${height}" width="${width}" allowFullScreen></iframe>`;
        document.querySelector('#result').innerText = markup;
        this.copy();
    }
}
