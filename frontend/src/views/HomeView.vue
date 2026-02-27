<script setup>
import { supabase } from '@utils/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()

// Create a room and rout to it
const createRoom = async () => {
  try {
    const { data, error } = await supabase.from('rooms').insert({}).select()

    if (error) {
      throw error
    }

    await router.push({ name: 'room', params: { roomId: data[0].id } })
  } catch (error) {
    alert(error.message)
  }
}
</script>

<template>
  <h1>home</h1>
  <button @click="createRoom">Create room</button>
</template>

<style scoped></style>
