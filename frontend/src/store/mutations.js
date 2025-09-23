import { STORAGE_KEY } from './state'
export function setAccessToken (state, token) {
  state.auth = state.auth || {}
  state.auth.accessToken = token

  // Persistir en localStorage
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
}
export const UPDATE_AUTH = (state, auth) => {
  state.auth = auth
}

export const UPDATE_USER = (state, user) => {
  state.user = user
}

export const CLEAR_ALL_DATA = (state) => {
  // Auth
  state.auth.isLoggedIn = false
  state.auth.accessToken = null

  // User
  state.user.name = ''
  state.user.role = null
}

