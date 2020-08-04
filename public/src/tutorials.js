import Driver from 'driver.js';

export const tour = [
    {
        element: '#guide_1',
        className: 'guide_1',
        popover: {
            className: '',
            title: 'Circuit Elements panel',
            description: 'This is where you can find all the circuit elements that are offered to build amazing circuits.',
            position: 'right',
            offset: 160,
        },
    },
    {
        element: '.guide_2',
        popover: {
            title: 'Properties Panel',
            description: 'This panel lets you change element properties as they are selected. When no elements are selected, the panel displays project properties.',
            position: 'left',
            offset: 200,
        },
    },
    {
        element: '.quick-btn',
        popover: {
            title: 'Quick Access Panel',
            description: "This movable panel offers to perform some actions like Save Online, Open, Download quickly. Hover over the icons and see for yourself",
            position: 'bottom',
            // offset: 750,
        },
    },
    {
        element: '#tabsBar',
        popover: {
            title: 'Circuit Tabs',
            description: "This section displays all the circuits you have in your project. You can easily add and delete circuits.",
            position: 'bottom',
            offset: 250,
        },
    },
    {
        element: '#subCirGuide',
        popover: {
            title: 'Sub-Circuits',
            description: "This feature lets you add one of your circuits into another by converting it to a sub-circuit..",
            position: 'right',
            // offset: 250,
        },
    },
    {
        element: '#delCirGuide',
        popover: {
            title: 'Delete sub-circuit button',
            description: "You can make delete sub-circuits by pressing the cross *Note that main circuit cannot be deleted.",
            position: 'right',
            // offset: 250,
        },
    },
    {
        element: '.fa-bug',
        popover: {
            className: "bug-guide",
            title: 'Report System',
            description: "You can report any issues/bugs you face through this issue reporting button there and then quickly.",
            position: 'left',
            offset: -25,
        },
    },
    // {
    //     element: '.fa-bug',
    //     popover: {
    //         className: "forum-tab",
    //         title: 'The forums can help you report issues & bugs, feature requests, and discussing about circuits with the community!',
    //         description: "",
    //         position: 'left',
    //         offset: -25,
    //     },
    // }
 
]
 
const animatedTourDriver = new Driver({
    animate: true,
    opacity: 0.8,
    padding: 5,
    showButtons: true,
});

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
    $('.icon').click(() => {
        panelHighlight.reset(true);
    });
} 

export default animatedTourDriver;