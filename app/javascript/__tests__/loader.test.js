import { showLoader, hideLoader } from '../loader';

describe('Loader', () => {
    let loaderElement;

    beforeEach(() => {
        loaderElement = document.createElement('div');
        loaderElement.id = 'loader';
        document.body.appendChild(loaderElement);
    });

    afterEach(() => {
        document.body.removeChild(loaderElement);
    });

    test('showLoader displays the loader element', () => {
        showLoader();
        expect(loaderElement.style.display).toBe('flex');
    });

    test('hideLoader hides the loader element', () => {
        hideLoader();
        expect(loaderElement.style.display).toBe('none');
    });

    test('hideLoader clears the timeout', () => {
        jest.useFakeTimers();
        const spy = jest.spyOn(global, 'clearTimeout');
        hideLoader();
        expect(spy).toHaveBeenCalled();
        spy.mockRestore();
    });

    test('turbolinks:before-visit event sets a timeout to show loader', () => {
        jest.useFakeTimers();
        const event = new Event('turbolinks:before-visit');
        document.dispatchEvent(event);
        expect(setTimeout).toHaveBeenCalledWith(expect.any(Function), 300);
        jest.runAllTimers();
        expect(loaderElement.style.display).toBe('flex');
    });

    test('turbolinks:load event hides the loader', () => {
        const event = new Event('turbolinks:load');
        document.dispatchEvent(event);
        expect(loaderElement.style.display).toBe('none');
    });

    test('window load event hides the loader', () => {
        const event = new Event('load');
        window.dispatchEvent(event);
        expect(loaderElement.style.display).toBe('none');
    });
});
