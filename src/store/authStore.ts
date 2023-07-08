import { defineStore } from 'pinia'

interface AuthStoreType {
    isLoggedIn: boolean
    userId: string | number
    username: string
    locale: string
    isAdmin: boolean
}

interface UserInfo {
    isLoggedIn: boolean
    id: string
    attributes: {
        name: string
        locale: string
        admin: boolean
    }
}
export const useAuthStore = defineStore({
    id: 'authStore',
    state: (): AuthStoreType => ({
        isLoggedIn: false,
        userId: '',
        username: '',
        locale: 'en',
        isAdmin: false,
    }),
    actions: {
        setUserInfo(userInfo: UserInfo): void {
            this.isLoggedIn = true
            this.userId = userInfo.id ?? ''
            this.username = userInfo.attributes.name ?? ''
            this.locale = userInfo.attributes.locale ?? 'en'
            this.isAdmin = userInfo.attributes.admin
        },
    },
    getters: {
        getIsLoggedIn(): boolean {
            return this.isLoggedIn
        },
        getUserId(): string | number {
            return this.userId
        },
        getUsername(): string {
            return this.username
        },
        getLocale(): string {
            return this.locale
        },
        getIsAdmin(): boolean {
            return this.isAdmin
        },
    },
})

//  TODO: extract store verify and check better ways to impliment
