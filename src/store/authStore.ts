import { defineStore } from 'pinia'

interface AuthStoreType {
    isLoggedIn: boolean
    userId: string | number
    username: string
    userAvatar: string
    locale: string
    isAdmin: boolean
}

interface UserInfo {
    isLoggedIn: boolean
    id: string
    attributes: {
        name: string
        profile_picture: string
        locale: string
        admin: boolean
    }
}
export const useAuthStore = defineStore({
    id: 'authStore',
    state: (): AuthStoreType => ({
        isLoggedIn: false,
        userId: '',
        username: 'Guest',
        userAvatar: 'default',
        locale: 'en',
        isAdmin: false,
    }),
    actions: {
        setUserInfo(userInfo: UserInfo): void {
            this.isLoggedIn = true
            this.userId = userInfo.id ?? ''
            this.username = userInfo.attributes.name ?? 'Guest'
            if (userInfo.attributes.profile_picture != 'original/Default.jpg') {
                this.userAvatar =
                    userInfo.attributes.profile_picture ?? 'default'
            }
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
        getUserAvatar(): string {
            return this.userAvatar
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
