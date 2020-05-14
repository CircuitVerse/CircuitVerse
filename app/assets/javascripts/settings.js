function loadUserSettings(settings)
{
    $.getJSON("/js/settings.json", (json) => 
    {
        console.log(json);
        console.log(settings);
    })
    .fail(() => showError('Failed to load settings.json'));
}

function showError(text)
{
    $("#settings-container").html('<p class="w-100 text-center"> <i class="fa fa-exclamation-triangle"></i> Failed to load your settings (' + text + ')</p>')
}
    