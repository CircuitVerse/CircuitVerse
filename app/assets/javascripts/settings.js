function loadUserSettings(userSettings, token)
{
    $.getJSON("/js/settings.json", (friendlySchema) => 
    {
        console.log('User Settings', userSettings);
        console.log('User Settings Schema', friendlySchema);
        $("#settings-container").html(generateHtml(friendlySchema, userSettings, token));
    })
    .fail((error) => showError('settings.json load - ' + 't'));
}

function showError(text)
{
    $("#settings-container").html('<p class="w-100 text-center"> <i class="fa fa-exclamation-triangle"></i> Failed to load your settings (' + text + ')</p>')
}

function generateHtml(friendlySchema, userSettings, token)
{
    let result = '';
    friendlySchema.categories.forEach(category => 
    {
        result += `<h3>${category.name}</h3>`

        friendlySchema.settings.filter(x => x.category == category.name).forEach(setting => 
        {
            if(userSettings[setting.name] !== undefined || setting.type === "button")
            {
                result += generateSettingRow(setting, userSettings[setting.name], token)
            }
            
        });
    });
    return result;
}    

function generateSettingRow(setting, value, token)
{
    let action = "Failed to generate action";
    if(setting.type == "boolean")
    {
        action = `<input type="checkbox" id="${setting.name}" onclick='handleClick(this, ${setting.refreshPage},"${token}");' ${value ? " checked" : ""}>`
    }
    else if(setting.type == "button")
    {
        action = `<a class="btn btn-secondary" href="${setting.buttonLink}" role="button">${setting.buttonText}</a>`
    }

    return `
    <div class="form-row w-100">
        <div class="form-group col-md-6">
            <strong>${setting.displayName}</strong> <br>
            ${setting.description}
        </div>
        <div class="form-group col-md-6 d-flex justify-content-center align-items-center">
            ${action}
        </div>
    </div>
    `
}

function handleClick(checkbox, refresh, token)
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
            if(refresh)
            {
                location.reload();
            }
            else
            {
                checkbox.disabled = false;
            }
        },
        error: () =>
        {
            checkbox.checked = !checkbox.checked;
            checkbox.disabled = false;
        }
    });
}