import { userSignedIn } from '../ux';
import load from '../data/load';
import { showMessage } from '../utils';

const getDialogContent = () => {
    return `
    <div style="padding: 10px;">
        <div style="margin-bottom: 10px; display: flex;">
            <input type="text" id="onlineCircuitSearchInput" class="search-input" placeholder="Search your projects..." style="flex-grow: 1; padding: 5px; border-radius: 5px; border: 1px solid #ccc;">
            <button id="onlineCircuitSearchBtn" class="custom-btn--primary import-btn" style="margin-left: 5px;">Search</button>
        </div>
        <div id="onlineCircuitList" style="height: 300px; overflow-y: auto; border: 1px solid #ddd; padding: 5px;">
            <div style="text-align: center; color: #666; padding-top: 20px;">
                ${userSignedIn ? 'Loading your projects...' : 'Please sign in to access your projects.'}
            </div>
        </div>
    </div>
    `;
};

const fetchProjects = async (query = '') => {
    if (!userSignedIn) return [];
    try {
        // If query is present, use search API, otherwise list user projects
        let url = `/api/v1/users/${window.user_id}/projects?page[number]=1&page[size]=20`;
        if (query) {
            url = `/api/v1/projects/search?q=${encodeURIComponent(query)}&page[number]=1&page[size]=20`;
        }

        const response = await fetch(url);
        const data = await response.json();
        return data.data; // API v1 returns { data: [...] }
    } catch (error) {
        console.error('Error fetching projects:', error);
        return [];
    }
};

const renderProjects = (projects) => {
    const listContainer = $('#onlineCircuitList');
    listContainer.empty();

    if (projects.length === 0) {
        listContainer.append('<div style="text-align: center; padding: 20px;">No projects found.</div>');
        return;
    }

    projects.forEach(project => {
        const p = project.attributes;
        const item = $(`
            <div class="online-project-item" style="padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div style="font-weight: bold; color: var(--text-panel)">${p.name}</div>
                    <div style="font-size: 0.8em;color: var(--text-panel);">Updated: ${new Date(p.updated_at).toLocaleDateString()}</div>
                </div>
                <button class="custom-btn--primary import-btn" data-id="${project.id}">Import</button>
            </div>
        `);
        listContainer.append(item);
    });

    $('.import-btn').on('click', async function () {
        const projectId = $(this).data('id');
        await importCircuit(projectId);
    });
};

const importCircuit = async (projectId) => {
    try {
        const response = await fetch(`/simulator/get_data/${projectId}`);
        const data = await response.json();

        load(data);
        $('#ImportOnlineCircuitDialog').dialog('close');
        showMessage(`Project loaded successfully!`);
    } catch (error) {
        console.error("Error loading circuit data:", error);
        showMessage("Failed to load circuit data.");
    }
};

const ImportOnlineCircuit = () => {
    $('#ImportOnlineCircuitDialog').empty();
    $('#ImportOnlineCircuitDialog').append(getDialogContent());

    $('#ImportOnlineCircuitDialog').dialog({
        resizable: false,
        width: 500,
        height: 450,
        modal: true,
        title: "Import Online Circuit",
        buttons: [
            {
                text: 'Close',
                click() {
                    $(this).dialog('close');
                },
            },
        ],
    });

    if (userSignedIn) {
        fetchProjects().then(renderProjects);
    }

    $('#onlineCircuitSearchBtn').on('click', () => {
        const query = $('#onlineCircuitSearchInput').val();
        fetchProjects(query).then(renderProjects);
    });

    $('#onlineCircuitSearchInput').on('keypress', (e) => {
        if (e.which === 13) {
            const query = $('#onlineCircuitSearchInput').val();
            fetchProjects(query).then(renderProjects);
        }
    });
};

export default ImportOnlineCircuit;
