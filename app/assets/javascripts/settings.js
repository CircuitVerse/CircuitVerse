function loadUserSettings(userSettings, token)
{
    $.getJSON("/js/settings.json", (friendlySchema) => 
    {
        console.log('start')
        console.log(userSettings);
        $("#settings-container").html(generateHtml(friendlySchema, userSettings));
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

function generateHtml(friendlySchema, userSettings)
{
    let result = '';
    for(const settingName in userSettings)
    {
        const friendlySetting = friendlySchema.settings.find(x => x.name === settingName)
        const settingValue = userSettings[settingName];
        result +=
        `
        <div class="form-row w-100">
            <div class="form-group col-md-6">
                <strong>${friendlySetting ? friendlySetting.display_name : settingName}</strong> <br>
                ${friendlySetting ? friendlySetting.description : "<i>unknown</i>"}
            </div>
            <div class="form-group col-md-6 d-flex justify-content-center align-items-center">
                <input type="checkbox" id="defaultCheck1"${settingValue ? " checked" : ""}>
            </div>
        </div>
        `
    }
    return result;
}    