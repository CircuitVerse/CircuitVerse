import Driver from 'driver.js';
import banana from './i18n';

export const tour = [
    {
        element: '#guide_1',
        className: 'guide_1',
        popover: {
            className: '',
            title: banana.i18n('tutorials-guide1-title'),
            description: banana.i18n('tutorials-guide1-description'),
            position: 'right',
            offset: 160,
        },
    },
    {
        element: '.guide_2',
        popover: {
            title: banana.i18n('tutorials-guide2-title'),
            description: banana.i18n('tutorials-guide2-description'),
            position: 'left',
            offset: 200,
        },
    },
    {
        element: '.quick-btn',
        popover: {
            title: banana.i18n('tutorials-quick-btn-title'),
            description: banana.i18n('tutorials-quick-btn-description'),
            position: 'bottom',
            // offset: 750,
        },
    },
    // {
    //     element: '.forum-tab',
    //     popover: {
    //         className: "",
    //         title: 'Forum Tab',
    //         description: "The forums can help you report issues & bugs, feature requests, and discussing about circuits with the community!",
    //         position: 'right',
    //         // offset: -25,
    //     },
    // },
    {
        element: '#tabsBar',
        popover: {
            title: banana.i18n('tutorials-tabs-bar-title'),
            description: banana.i18n('tutorials-tabs-bar-description'),
            position: 'bottom',
            offset: 250,
        },
    },
    {
        element: '.timing-diagram-panel',
        popover: {
            title: banana.i18n('tutorials-timing-diagram-panel-title'),
            description: banana.i18n('tutorials-timing-diagram-panel-description'),
            position: 'bottom',
            offset: 0,
        },
    },
    
    
    // {
    //     element: '#delCirGuide',
    //     popover: {
    //         title: 'Delete sub-circuit button',
    //         description: "You can make delete sub-circuits by pressing the cross *Note that main circuit cannot be deleted.",
    //         position: 'right',
    //         // offset: 250,
    //     },
    // },
    {
        element: '.fa-bug',
        popover: {
            className: "bug-guide",
            title: banana.i18n('tutorials-bug-guide-title'),
            description: banana.i18n('tutorials-bug-guide-description'),
            position: 'left',
            offset: -105,
        },
    },
    {
        element: '.tour-help',
        popover: {
            className: 'tourHelpStep',
            title: banana.i18n('tutorials-tour-help-title'),
            description: banana.i18n('tutorials-tour-help-description'),
            position: 'right',
            offset: 0,
        },
    },


]

// Not used currently
export const tutorialWrapper = () => {
    const panelHighlight = new Driver();
    $('.panelHeader').one('click', (e) => {
        if (localStorage.tutorials === "next") {
            panelHighlight.highlight({
                element: '#guide_1',
                showButtons: false,
                popover: {
                    title: 'Here are the elements',
                    description: 'Select any element by clicking on it & then click anywhere on the grid to place the element.',
                    position: 'right',
                    offset: $($(e.target).next()).height() + $(e.target).offset().top - 45,
                }
            })
            localStorage.setItem('tutorials', 'done');
        }
    })
    $('.icon').on('click',() => {
        panelHighlight.reset(true);
    });
}

const animatedTourDriver = new Driver({
    animate: true,
    opacity: 0.8,
    padding: 5,
    showButtons: true,
});

export function showTourGuide() {
    $('.draggable-panel .maximize').trigger('click');
    animatedTourDriver.defineSteps(tour);
    animatedTourDriver.start();
    localStorage.setItem('tutorials_tour_done', true);
}

export default showTourGuide; 