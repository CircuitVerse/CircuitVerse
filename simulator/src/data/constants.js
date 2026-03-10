/**
 * Circuit data format version.
 *
 * The single source of truth for the save-data schema version.
 * Legacy files have no version field at all; the new canonical
 * format is stamped with this value.
 *
 * Version history:
 *   (absent) – legacy format, no version field in saved data
 *   "v1"     – first explicitly versioned canonical format
 *
 * @category data
 */
export const CIRCUIT_DATA_VERSION = 'v1';
