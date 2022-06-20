import type {
    PiniaCustomStateProperties,
    StoreActions,
    StoreGeneric,
    StoreGetters,
    StoreState,
} from 'pinia'
import type { ToRefs } from 'vue'
import { isReactive, isRef, toRaw, toRef } from 'vue'

type Extracted<SS> = ToRefs<
    StoreState<SS> &
        StoreGetters<SS> &
        PiniaCustomStateProperties<StoreState<SS>>
> &
    StoreActions<SS>

/**
 * Creates an object of references with all the state, getters, actions
 * and plugin-added state properties of the store.
 *
 * @param store - store to extract the refs from
 */
export function extractStore<SS extends StoreGeneric>(
    store: SS
): Extracted<SS> {
    const rawStore = toRaw(store)
    const refs: Record<string, unknown> = {}

    for (const [key, value] of Object.entries(rawStore)) {
        if (isRef(value) || isReactive(value)) {
            refs[key] = toRef(store, key)
        } else if (typeof value === 'function') {
            refs[key] = value
        }
    }

    // eslint-disable-next-line @typescript-eslint/consistent-type-assertions
    return refs as Extracted<SS>
}
