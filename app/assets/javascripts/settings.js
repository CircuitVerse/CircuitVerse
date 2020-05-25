function loadUserSettings(userSettings, devEnv, token) {
    $.getJSON('/js/settings.json', (friendlySchema) => {
        // console.log('User Settings', userSettings);
        // console.log('User Settings Friendly Schema', friendlySchema);
        $("#settings-container").html(generateHtml(friendlySchema, userSettings, devEnv, token));
    })
    .fail(() => showError('settings.json load'));
}

function generateHtml(friendlySchema, userSettings, devEnv, token) {
    let result = '';
    friendlySchema.categories.forEach(category =>  {
        categoryElements = friendlySchema.settings.filter(x => x.category == category.name);
        notHiddenElements = categoryElements.filter(x => !x.hidden);
        if((!devEnv && notHiddenElements.length > 0) || (devEnv && categoryElements.length > 0)) {
            result += `<h3>${category.name}</h3>`

            categoryElements.forEach(setting => {
                if(userSettings[setting.action.name] !== undefined || setting.action.type === "button")
                {
                    result += generateSettingRow(setting, userSettings[setting.action.name], devEnv, token)
                }
                else
                {
                    console.error("Failed to generate setting row, schema and user settings mismatch: ", setting.action.name)
                }
            });
        }
    });
    return result;
}    

function generateSettingRow(setting, value, devEnv, token) {
    if(setting.hidden && !devEnv) return "";

    let action = "Failed to generate action";
    if(setting.action.type == "boolean") {
        action = `<input type="checkbox" id="${setting.action.name}" onclick='handleCheckbox(this, ${setting.action.refreshPage},"${token}");' ${value ? " checked" : ""}>`
    }
    else if(setting.action.type == "button") {
        action = `<a class="btn btn-secondary" href="${setting.action.buttonLink}" role="button">${setting.action.buttonText}</a>`
    }
    else {
        console.error("Failed to generate setting row, unknown action type", setting.type)
    }

    return `
    <div class="form-row w-100">
        <div class="form-group col-md-6">
            <strong>${setting.name}</strong> ${setting.hidden ? '<span class="badge badge-dark">Hidden</span>' : ""} <br>
            ${setting.description}
        </div>
        <div class="form-group col-md-6 d-flex justify-content-center align-items-center">
            ${action}
        </div>
    </div>
    `
}

function handleCheckbox(checkbox, refresh, token) {
    checkbox.disabled = true;
    console.log(`changing ${checkbox.id} to ${checkbox.checked}...`)
    $.ajax({
        url: '/users/1/update',
        type: 'PATCH',
        data: {
            authenticity_token: token,
            settings: {
                [checkbox.id]: checkbox.checked
            }
        },
        success: () => {
            console.log('Successfully!')
            if(refresh) {
                location.reload();
            }
            else {
                checkbox.disabled = false;
            }
        },
        error: () => {
            checkbox.checked = !checkbox.checked;
            checkbox.disabled = false;
        }
    });
}

function showError(text) {
    $("#settings-container").html('<p class="w-100 text-center"> <i class="fa fa-exclamation-triangle"></i> Failed to load your settings (' + text + ')</p>')
}