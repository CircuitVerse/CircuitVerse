function loadUserSettings(settings, token)
{
    $.getJSON("/js/settings.json", (json) => 
    {
        console.log('start')
        $.ajax({
            url: 'http://127.0.0.1:8080/users/1/update',
            type: 'PATCH',
            data: 
            {
                authenticity_token: token,
                settings:
                {
                    change_logo_color: true
                }
            },
            success: function(result) {
                console.log(result);
            },
            error: function(result) {
                console.log(result);
            }
        });
    })
    .fail(() => showError('Failed to load settings.json'));
}

function showError(text)
{
    $("#settings-container").html('<p class="w-100 text-center"> <i class="fa fa-exclamation-triangle"></i> Failed to load your settings (' + text + ')</p>')
}
    