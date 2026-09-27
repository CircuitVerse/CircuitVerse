import { checkRestricted, getOS, getKey } from '../src/hotkey_binder/model/utils';

describe('Hotkey Binder Utils', () => {
    const originalNavigator = global.navigator;

    afterEach(() => {
        Object.defineProperty(global, 'navigator', {
            value: originalNavigator,
            writable: true,
            configurable: true,
        });
    });

    test('getOS detects Windows, MacOS, Linux, and UNIX correctly', () => {
        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)' },
            writable: true,
            configurable: true,
        });
        expect(getOS()).toBe('MacOS');

        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' },
            writable: true,
            configurable: true,
        });
        expect(getOS()).toBe('Windows');

        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (X11; FreeBSD amd64)' },
            writable: true,
            configurable: true,
        });
        expect(getOS()).toBe('UNIX');

        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (Linux x86_64)' },
            writable: true,
            configurable: true,
        });
        expect(getOS()).toBe('Linux');
    });

    test('checkRestricted restricts Windows Ctrl shortcuts on Windows', () => {
        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' },
            writable: true,
            configurable: true,
        });

        expect(checkRestricted('Ctrl + W')).toBe(true);
        expect(checkRestricted('Ctrl + N')).toBe(true);
        expect(checkRestricted('Ctrl + T')).toBe(true);
        expect(checkRestricted('Meta + W')).toBe(false);
        expect(checkRestricted('Ctrl + K')).toBe(false);
    });

    test('checkRestricted restricts macOS Meta shortcuts on MacOS', () => {
        Object.defineProperty(global, 'navigator', {
            value: { appVersion: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)' },
            writable: true,
            configurable: true,
        });

        expect(checkRestricted('Meta + W')).toBe(true);
        expect(checkRestricted('Meta + N')).toBe(true);
        expect(checkRestricted('Meta + T')).toBe(true);
        expect(checkRestricted('Ctrl + W')).toBe(false);
        expect(checkRestricted('Meta + K')).toBe(false);
    });

    test('getKey retrieves the key matching the given value', () => {
        const testObj = { a: 'first', b: 'second' };
        expect(getKey(testObj, 'second')).toBe('b');
        expect(getKey(testObj, 'nonexistent')).toBeUndefined();
    });
});
