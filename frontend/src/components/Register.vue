<template>
  <div>
    <app-nav></app-nav>
    <div class="container">
      <h2>Registro de usuario federado</h2>
      <form @submit.prevent="registerUser">
        <div class="form-group">
          <label for="email">Email</label>
          <input type="email" v-model="email" class="form-control" id="email" required readonly>
        </div>
        <div class="form-group">
          <label for="name">Nombre</label>
          <input type="text" v-model="name" class="form-control" id="name" required>
        </div>
        <button type="submit" class="btn btn-primary">Registrar</button>
      </form>
      <div v-if="errorMessage" class="alert alert-danger mt-2">{{ errorMessage }}</div>
    </div>
  </div>
</template>

<script>
import AppNav from '@/components/AppNav'
export default {
  name: 'register',
  components: { AppNav },
  data () {
    return {
      email: '',
      name: '',
      errorMessage: ''
    }
  },
  mounted () {
    // Obtener datos del token si están en la URL
    const hash = window.location.hash
    const match = hash.match(/id_token=([^&]+)/)
    if (match) {
      try {
        const token = match[1]
        const payload = JSON.parse(atob(token.split('.')[1]))
        this.email = payload.email || ''
        this.name = payload.name || ''
      } catch (e) {
        this.errorMessage = 'Token inválido'
      }
    }
  },
  methods: {
    registerUser () {
      // Aquí deberías hacer la petición al backend para registrar el usuario
      // Simulación: redirigir a todos
      window.location.hash = '#/todos'
    }
  }
}
</script>