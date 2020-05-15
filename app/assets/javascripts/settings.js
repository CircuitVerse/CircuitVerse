function loadUserSettings(userSettings, token)
{
    $.getJSON("/js/settings.json", (friendlySchema) => 
    {
        console.log('User Settings', userSettings);
        console.log('User Settings Schema', friendlySchema);
        $("#settings-container").html(generateHtml(friendlySchema, userSettings, token));
    })
    .fail(() => showError('Failed to load settings.json'));
}

function showError(text)
{
    $("#settings-container").html('<p class="w-100 text-center"> <i class="fa fa-exclamation-triangle"></i> Failed to load your settings (' + text + ')</p>')
}

function generateHtml(friendlySchema, userSettings, token)
{
    let result = '';
    friendlySchema.categories.forEach(category => {
        result += `<h3>${category.name}</h3>`
        friendlySchema.settings.filter(x => x.category == category.name).forEach(setting => {
            const settingValue = userSettings[setting.name];
            if(settingValue !== undefined)
            {
                result +=
                `
                <div class="form-row w-100">
                    <div class="form-group col-md-6">
                        <strong>${setting.display_name}</strong> <br>
                        ${setting.description}
                    </div>
                    <div class="form-group col-md-6 d-flex justify-content-center align-items-center">
                        <input type="checkbox" id="${setting.name}" onclick='handleClick(this, "${token}");' ${settingValue ? " checked" : ""}>
                    </div>
                </div>
                `
            }
            else
            {
                console.error(`${setting.name} exist in schema but does not exist in user settings`)
            }
            
        });
    });
    return result;
}    

function handleClick(checkbox, token)
{
    checkbox.disabled = true;
    console.log(`changing ${checkbox.id} to ${checkbox.checked}...`)
    $.ajax({
        url: '/users/1/update',
        type: 'PATCH',
        data: 
        {
            authenticity_token: token,
            settings:
            {
                [checkbox.id]: checkbox.checked
            }
        },
        success: () =>
        {
            console.log('Successfully!')
            checkbox.disabled = false;
        },
        error: (result) =>
        {
            checkbox.checked = !checkbox.checked;
            checkbox.disabled = false;
        }
    });
}