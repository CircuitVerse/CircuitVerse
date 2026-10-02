// Checks that every key in `schema` is present on `data`, regardless of key order
// or extra/unrecognized keys (kept for forward compatibility with newer save files).
export const hasSchemaKeys = (data, schema) => Boolean(data)
    && typeof data === 'object'
    && schema.every((key) => Object.prototype.hasOwnProperty.call(data, key));

export default hasSchemaKeys;
