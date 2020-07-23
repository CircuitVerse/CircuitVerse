import Driver from 'driver.js';

export const tour = [
    {
        element: '#guide_1',
        className: 'guide_1',
        popover: {
            className: '',
            title: 'Curcuit Elements panel',
            description: 'it consits of all the elements availabe here, which is used to build circuits.',
            position: 'right',
            offset: 160,
        },
    },
    {
        element: '.guide_2',
        popover: {
            title: 'Properties Panel',
            description: 'It will show the properties of the current element on focus, you can set or change properties here. Since no elements are currently on focus it is showing the properties of the current workspace.',
            position: 'left',
            offset: 200,
        },
    },
    {
        element: '.header',
        popover: {
            title: 'This is the header',
            description: 'It consists of menu items, the title and a quick buttons menu',
            position: 'bottom',
            offset: 750,
        },
    },
    {
        element: '.quick-btn',
        popover: {
            title: 'This is the quick options menu',
            description: "Here you can access options like save online, save offline, etc. Just hover any of the option & it will display it's name.",
            position: 'bottom',
            // offset: 750,
        },
    },
    // {
    //     element: '#tabsBar',
    //     popover: {
    //         title: 'This is the tabs bar',
    //         description: "Here you can see all the circuits you have currently in your project, change or delete them.",
    //         position: 'bottom',
    //         offset: 250,
    //     },
    // },
    // {
    //     element: '.text-light',
    //     popover: {
    //         title: 'This is the Report Issue button',
    //         description: "You can easily create new sub-circuits with the help of this button.",
    //         position: 'left',
    //         // offset: 250,
    //     },
    // },

]


const animatedTourDriver = new Driver({
    animate: true,
    opacity: 0.8,
    padding: 5,
    showButtons: true,
});

export default animatedTourDriver;