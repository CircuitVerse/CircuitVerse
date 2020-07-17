import { dots } from '../canvasApi';
// import getColors from '../modules/colors';
import themeOptions from "./themes";



function updateThemeForStyle(themeName) {
    // const selectedTheme = themeOptions.find(
    //     (t) => t.name.toLowerCase() === themeName.toLowerCase()
    // );
    const selectedTheme = themeOptions[themeName];
    const html = document.getElementsByTagName('html')[0];
    Object.keys(selectedTheme).forEach((property, i) => {
        // if (property === 'name') return;
        html.style.setProperty(property, selectedTheme[property]);
    });
}

export default updateThemeForStyle;

export const colorThemes = () => {
    const selectedTheme = localStorage.getItem('theme');
    $('#colorThemesDialog').empty();
    const themes = Object.keys(themeOptions);
    themes.forEach(theme => {
        if (theme === selectedTheme) {
            $('#colorThemesDialog').append(`
            <div class="theme selected set">${theme}</div> 
            `)
        } else {
            $('#colorThemesDialog').append(`
            <div class="theme">${theme}</div> 
            `)
        }
    })

    $('#colorThemesDialog').dialog({
        draggable: false,
        resizable: false,
        close() {
            updateThemeForStyle(localStorage.getItem('theme'));
            updateBG();
        },
        buttons: [{
            text: "Apply Theme",
            click() {
                localStorage.setItem('theme', $('.selected').text());
                $('.set').removeClass('set');
                $('.selected').addClass('set');
                $(this).dialog('close');
            }
        }]
    });
    $('#colorThemesDialog').focus()
    $('.ui-dialog[aria-describedby="colorThemesDialog"]').click(() => $('#colorThemesDialog').focus()) //hack for losing focus

    $('.theme').click((e) => {
        $('.selected').removeClass('selected');
        $(e.target).addClass('selected');
        updateThemeForStyle($('.selected').text());
        updateBG();
    });


    $('#colorThemesDialog').keydown((e) => {
        // if (e.which === 40 && $('.selected').next().length) {
        //     $('.selected').next().addClass('selected')
        //     $($('.selected')[0]).removeClass('selected')
        //     updateThemeForStyle($('.selected').text());
        //     updateBG();
        // } else if (e.which === 38 && $('.selected').prev().length) {
        //     $('.selected').prev().addClass('selected')
        //     $($('.selected')[1]).removeClass('selected')
        //     updateThemeForStyle($('.selected').text());
        //     updateBG();
        // }
        if (e.which === 13) {
            localStorage.setItem("theme", $('.selected').text());
            $('.set').removeClass('set');
            $('.selected').addClass('set');
            $('.ui-dialog').find('button:first').trigger('click');
        }
        if (e.which === 27) {
            updateThemeForStyle(localStorage.getItem('theme'));
            updateBG();
            // $('.ui-dialog').find('button:first').trigger('click');
        }
    });
}

const updateBG = () => {
    dots(true, false, true);
}

(() => {
    if (!localStorage.getItem('theme')) localStorage.setItem('theme', 'Default Theme');
    updateThemeForStyle(localStorage.getItem('theme'));
})();
