import { hasSchemaKeys } from '../src/file/schemaValidation';

describe('hasSchemaKeys', () => {
    const schema = ['name', 'timePeriod', 'clockEnabled'];

    test('returns true when all schema keys are present in order', () => {
        const data = { name: 'test', timePeriod: 500, clockEnabled: true };
        expect(hasSchemaKeys(data, schema)).toBe(true);
    });

    test('returns true when schema keys are present in a different order', () => {
        const data = { clockEnabled: true, name: 'test', timePeriod: 500 };
        expect(hasSchemaKeys(data, schema)).toBe(true);
    });

    test('returns true when extra unrecognized keys are present', () => {
        const data = {
            name: 'test', timePeriod: 500, clockEnabled: true, extraField: 'future',
        };
        expect(hasSchemaKeys(data, schema)).toBe(true);
    });

    test('returns false when a required key is missing', () => {
        const data = { name: 'test', clockEnabled: true };
        expect(hasSchemaKeys(data, schema)).toBe(false);
    });

    test('returns false for null or non-object input', () => {
        expect(hasSchemaKeys(null, schema)).toBe(false);
        expect(hasSchemaKeys(undefined, schema)).toBe(false);
        expect(hasSchemaKeys('not an object', schema)).toBe(false);
    });
});
