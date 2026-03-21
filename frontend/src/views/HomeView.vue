<script setup>
import { supabase } from '@utils/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()

// Create a room and rout to it
const createRoom = async () => {
  try {
    const { data, error } = await supabase.from('Rooms').insert({}).select()

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
  <main>
    <article>
      <h1>FairShare</h1>
      <p>Best solution for splitting bills fairly between friends and family.</p>
      <button @click="createRoom">Create room</button>
    </article>
  </main>
</template>

<style scoped>
main {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  align-content: center;
}
article {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #f0f4f2;
  width: 35%;
  height: 30%;
  padding: 4rem;
  border-radius: 0.9rem;
  gap: 3rem;
  box-shadow: 0 2px 6px hsla(0, 0%, 0%, 0.5);
}
button {
  background-color: #7b9669;
  border-radius: 1rem;
  padding: 0.4rem;
  border: none;
  outline: none;
  transition: transform 0.1s ease-in-out;
  font-weight: bold;
  font-size: 2rem;
  width: 40%;
}
button:hover {
  transform: scale(1.1);
}
h1 {
  font-size: 4rem;
}
</style>
